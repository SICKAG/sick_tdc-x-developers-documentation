package main

import (
	"can-app/pkg/auth"
	"can-app/pkg/pb/protos"
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/go-daq/canbus"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"

	_ "modernc.org/sqlite"
)

var dbLock sync.Mutex

var (
	canBus *canbus.Socket
)

func sendCanMsg(canBus *canbus.Socket) {
	print("\n")
	log.Println("Entering sensor Op mode: PROCESS START")
	var msg [7]canbus.Frame

	msg[0] = canbus.Frame{
		ID:   0x000,
		Data: []byte{0x80, 0x0a},
	}

	msg[1] = canbus.Frame{
		ID:   0x60a,
		Data: []byte{0x2f, 0x00, 0x18, 0x02, 0xff, 0x00, 0x00, 0x00},
	}

	msg[2] = canbus.Frame{
		ID:   0x60a,
		Data: []byte{0x2b, 0x00, 0x18, 0x05, 0x32, 0x00, 0x00, 0x00},
	}

	msg[3] = canbus.Frame{
		ID:   0x60a,
		Data: []byte{0x2f, 0x01, 0x18, 0x02, 0xff, 0x00, 0x00, 0x00},
	}

	msg[4] = canbus.Frame{
		ID:   0x60a,
		Data: []byte{0x2b, 0x01, 0x18, 0x05, 0x32, 0x00, 0x00, 0x00},
	}

	msg[5] = canbus.Frame{
		ID:   0x60a,
		Data: []byte{0x23, 0x10, 0x10, 0x01, 0x73, 0x61, 0x76, 0x65},
	}

	msg[6] = canbus.Frame{
		ID:   0x000,
		Data: []byte{0x01, 0x0a},
	}

	for i := 0; i < len(msg); i++ {
		_, err := canBus.Send(msg[i])
		if err != nil {
			log.Printf("Error sending CAN message: %v", err)
		}
		log.Printf("Sent message: ID=0x%X, Data=%v", msg[i].ID, msg[i].Data)
	}
	log.Println("Entering sensor Op mode: SUCCESS")
}

func goPreOp(canBus *canbus.Socket) {
	msg := canbus.Frame{
		ID:   0x000,
		Data: []byte{0x80, 0x0a},
	}

	_, err := canBus.Send(msg)
	if err != nil {
		log.Printf("Error sending CAN message: %v", err)
	}
	log.Printf("Sent message: ID=0x%X, Data=%v", msg.ID, msg.Data)
	log.Println("Enter Pre-Op mode")
}

func createTable(db *sql.DB) {
	createTable := `CREATE TABLE IF NOT EXISTS tmm_values (
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,		
		"outputx" INTEGER,
		"outputy" INTEGER,
		"timestamp" DATETIME DEFAULT CURRENT_TIMESTAMP
	);`

	statement, err := db.Prepare(createTable)
	if err != nil {
		log.Fatal(err.Error())
	}
	_, err = statement.Exec()
	if err != nil {
		log.Fatal("Error executing create table:", err)
	}
}

func insertData(db *sql.DB, outputx int16, outputy int16) {
	log.Println("Inserting value record...")
	sql := `INSERT INTO tmm_values(outputx, outputy, timestamp) VALUES (?, ?, CURRENT_TIMESTAMP)`

	statement, err := db.Prepare(sql)
	if err != nil {
		log.Fatalln("ERROR func insertData: ", err)
	}
	defer statement.Close()
	_, err = statement.Exec(outputx, outputy)

	if err != nil {
		log.Fatalln("ERROR exec func insertData: ", err)
	}
}

func abs(val int16) int16 {
	if val < 0 {
		return -val
	}
	return val
}

func offset(db *sql.DB, outputx int16, outputy int16) {
	row, err := db.Query("SELECT * FROM tmm_values ORDER BY id DESC LIMIT 1")
	if err != nil {
		log.Fatal("ERROR offset func QUERY: ", err)
	}
	var id int
	var lastRowX, lastRowY int16
	var timestamp string
	defer row.Close()

	if row.Next() {
		err := row.Scan(&id, &lastRowX, &lastRowY, &timestamp)
		if err != nil {
			log.Fatal("Error scanning last row:", err)
		}
	}

	// Check if the difference is greater than 3 (in any direction)
	if abs(outputx-lastRowX) > 3 || abs(outputy-lastRowY) > 3 {
		insertData(db, outputx, outputy)
		displayData(db)
	}
}

func displayData(db *sql.DB) {
	print("\n")
	log.Println("-----------TABLE---------")
	row, err := db.Query("SELECT * FROM tmm_values")
	if err != nil {
		log.Fatal(err)
	}
	defer row.Close()
	for row.Next() {
		var id int
		var outputx int16
		var outputy int16
		var timestamp string
		row.Scan(&id, &outputx, &outputy, &timestamp)
		log.Println("Data number:", id, "x:", outputx, "y:", outputy, "time: ", timestamp)
	}
	log.Println("-----------END---------")
	print("\n")
}

var WPANDevice string
var ctx context.Context

func refreshToken() error {
	_, err := auth.Login()
	if err != nil {
		return fmt.Errorf("failed to refresh token: %v", err)
	}
	return nil
}

func setupCanGrpc() {
	conn, err := grpc.NewClient(auth.Tdc_ip+":8081", grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()

	client := protos.NewCanClient(conn)
	md := metadata.New(map[string]string{
		"Authorization": "Bearer " + auth.Tokendata.Token,
	})
	ctx = metadata.NewOutgoingContext(context.Background(), md)
	ctx, cancel := context.WithTimeout(ctx, time.Second*5)
	defer cancel()

	_, err = client.SetTransceiverPower(ctx, &protos.SetTransceiverPowerRequest{PowerOn: true, InterfaceName: "CAN1"})
	if err != nil {
		if isUnauthorized(err) {
			log.Println("Token expired during SetTransceiverPower, refreshing...")
			if refreshErr := refreshToken(); refreshErr != nil {
				log.Fatalf("Failed to refresh token: %v", refreshErr)
			}
			// Retry with new token
			setupCanGrpc()
			return
		}
		log.Fatalf("Set Transceiver Power: FAIL: %v", err)
	} else {
		log.Println("Set Transceiver Power: SUCCESS")
	}
	time.Sleep(time.Millisecond * 100)

	_, err = client.SetTermination(ctx, &protos.SetTerminationRequest{EnableTermination: true, InterfaceName: "CAN1"})
	if err != nil {
		if isUnauthorized(err) {
			log.Println("Token expired during SetTermination, refreshing...")
			if refreshErr := refreshToken(); refreshErr != nil {
				log.Fatalf("Failed to refresh token: %v", refreshErr)
			}
			// Retry with new token
			setupCanGrpc()
			return
		}
		log.Fatalf("Set Termination: FAIL: %v", err)
	} else {
		log.Println("Set Termination: SUCCESS")
	}
	time.Sleep(time.Millisecond * 100)

	_, err = client.SetInterfaceToContainer(ctx, &protos.SetInterfaceToContainerRequest{InterfaceName: "CAN1", DockerContainerName: "tmm_can_app"})
	if err != nil {
		if isUnauthorized(err) {
			log.Println("Token expired during SetInterfaceToContainer, refreshing...")
			if refreshErr := refreshToken(); refreshErr != nil {
				log.Fatalf("Failed to refresh token: %v", refreshErr)
			}
			// Retry with new token
			setupCanGrpc()
			return
		}
		log.Fatalf("Set Interface To Container: FAIL: %v", err)
	} else {
		log.Println("Set Interface To Container: SUCCESS")
	}
	time.Sleep(time.Millisecond * 200)

	cmd := exec.Command("ip", "link", "set", "can0", "type", "can", "bitrate", "125000")
	cmd.Run()

	cmd = exec.Command("ip", "link", "set", "can0", "up")
	cmd.Run()
}

// Helper function to check if error is due to unauthorized access
func isUnauthorized(err error) bool {
	return err != nil && (err.Error() == "rpc error: code = Unauthenticated" ||
		err.Error() == "rpc error: code = Unauthenticated desc = unauthorized" ||
		err.Error() == "unauthorized")
}

func setupCan() {
	if auth.Tokendata.Token == "" {
		log.Println("NO TOKEN...")
		if err := refreshToken(); err != nil {
			log.Fatalf("Failed to get token: %v", err)
		}
		setupCanGrpc()
	}

	var err error
	// Create new CAN bus device socket and assign to global variable
	canBus, err = canbus.New()
	if err != nil {
		log.Fatalf("Failed to open CAN bus: %v", err)
	}

	// Binds can0 to the socket
	err = canBus.Bind("can0")
	if err != nil {
		log.Fatalf("Failed to bind CAN socket to interface: %v", err)
	}
	sendCanMsg(canBus)
}

func main() {
	setupCan()
	defer canBus.Close()

	// Open the created SQLite File
	sqliteDatabase, err := sql.Open("sqlite", "./sqlite-database.db")
	sqliteDatabase.Exec("PRAGMA journal_mode=WAL;")
	if err != nil {
		log.Fatalln(err.Error())
	}
	defer sqliteDatabase.Close()
	createTable(sqliteDatabase)

	var lastProcessed time.Time

	// Set up signal handling for graceful shutdown
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		goPreOp(canBus)
		os.Exit(1)
	}()

	// Looping until it catches termination signal
	for {
		if auth.Tokendata.Token == "" {
			log.Println("No token, process login for token...")
			if err := refreshToken(); err != nil {
				log.Println("Error refreshing token:", err)
				time.Sleep(5 * time.Second) // Wait before retrying
				continue
			}
			setupCanGrpc()
		}

		frame, err := canBus.Recv()
		if err != nil {
			if isUnauthorized(err) {
				log.Println("Token expired during CAN reception, refreshing...")
				if refreshErr := refreshToken(); refreshErr != nil {
					log.Println("Error refreshing token:", refreshErr)
					time.Sleep(5 * time.Second) // Wait before retrying
				} else {
					setupCanGrpc()
				}
				continue
			}
			log.Fatalf("Cannot receive frame: %v", err)
		}

		now := time.Now()
		if now.Sub(lastProcessed) < 200*time.Millisecond {
			continue
		}
		lastProcessed = now

		if len(frame.Data) < 4 {
			fmt.Printf("Not enough bytes")
			continue
		}

		// parsing sensor values (big-endian)
		x := int16(frame.Data[1])<<8 | int16(frame.Data[0])
		y := int16(frame.Data[3])<<8 | int16(frame.Data[2])

		// applying resolution scaling
		const resolution = 100.0
		x = x / resolution
		y = y / resolution

		dbLock.Lock()
		offset(sqliteDatabase, x, y)
		dbLock.Unlock()
		log.Printf("X: %d, Y: %d", x, y)
	}
}
