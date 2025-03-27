-- recieves data and prints data id
--@handleOnReceive(id:int,buffer:binary)
local function handleOnReceive(id, buffer)
  print("Received data.")
  print(id)
end

-- logs error code
--@handleOnReceive(errorCode:int)
local function handleOnError(errorCode)
  Log.info("Error code " .. errorCode)
end

Handle = CANSocket.create('CAN1')
Handle:setBaudRate(500000)
Handle:setTermination(true)
Handle:open()

-- Uncomment for receiving
-- CANSocket.register(Handle, "OnReceive", handleOnReceive)
-- CANSocket.register(Handle, "OnError", handleOnError)

-- transmitting messages
Ids = {20, 21, 22}
Msgs = {"\x41\x42\x43\x44\x45\x46\x47\x48", "\x51\x52\x53\x54\x55\x56\x57\x58", "\x61\x62\x63\x64\x65\x66\x67\x68"}
while true do
  Handle:transmit(Ids, Msgs)
  Script.sleep(1000)
end