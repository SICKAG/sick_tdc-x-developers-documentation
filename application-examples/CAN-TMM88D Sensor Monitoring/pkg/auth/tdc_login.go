package auth

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

var Tdc_ip = os.Getenv("TDCX_ADDRESS")
var Tokendata tdcToken
var request_data reqData

type tdcToken struct {
	Token string `json:"token"`
}

type reqData struct {
	url    string
	method string
	body   string
	header string
	token  string
	cookie string
}

func Login() (string, error) {
	log.Println("Login: PROCESS START...")

	if Tdc_ip == "" {
		Tdc_ip = "192.168.0.100"
	}

	var admin = os.Getenv("TDCX_USERNAME")
	if admin == "" {
		admin = "admin"
	}

	var password = os.Getenv("TDCX_PASSWORD")
	if password == "" {
		password = "adminadmin123X."
	}

	var tdc_address = "http://" + Tdc_ip
	var url_login string = tdc_address + "/auth/login"

	request_data.url = url_login
	request_data.body = fmt.Sprintf("{\"username\":\"%s\",\"password\":\"%s\",\"realm\":\"admin\"}", admin, password)
	request_data.header = "Content-Type: application/json"
	request_data.method = "POST"

	data, err := FetchDataTDC(request_data)
	if err != nil {
		return "", fmt.Errorf("login failed: %v", err)
	}

	if err := json.Unmarshal(data, &Tokendata); err != nil {
		return "", fmt.Errorf("failed to unmarshal token: %v", err)
	}
	log.Println("Login: SUCCESS")
	return "Success", nil
}

func FetchDataTDC(request_data reqData) ([]byte, error) {
	var jsonStr = []byte(request_data.body)
	req, err := http.NewRequest(request_data.method, request_data.url, bytes.NewBuffer(jsonStr))
	if err != nil {
		return nil, fmt.Errorf("error creating request: %v", err)
	}

	if request_data.method == "GET" {
		req, err = http.NewRequest("GET", request_data.url, bytes.NewBuffer(jsonStr))
		if err != nil {
			return nil, fmt.Errorf("error creating GET request: %v", err)
		}
	} else if request_data.method == "PUT" {
		req, err = http.NewRequest(http.MethodPut, request_data.url, bytes.NewBuffer(jsonStr))
		if err != nil {
			return nil, fmt.Errorf("error creating PUT request: %v", err)
		}
		req.Header.Add("Content-Type", "application/json")
		req.Header.Add("Accept", "application/json")
	} else {
		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("Accept", "application/json")
	}

	if len(request_data.token) > 20 {
		req.Header.Set("Authorization", "Bearer "+request_data.token)
	}

	if len(request_data.cookie) > 20 {
		cookie := &http.Cookie{
			Name:   "access_token",
			Value:  request_data.cookie,
			Path:   "/",
			Domain: Tdc_ip,
		}
		req.AddCookie(cookie)
	}

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("error on response: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusUnauthorized {
		return nil, fmt.Errorf("unauthorized")
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("error reading response body: %v", err)
	}

	return body, nil
}
