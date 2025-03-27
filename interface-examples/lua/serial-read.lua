local function Callback(data)
  print("Received data: " .. data)
end

local function main()
  -- creates serial communication called SER1
  S1 = SerialCom.create('SER1')
  -- setting termination to false
  S1:setTermination(false)
  
  -- sets type of communication to [RS422 | RS485]
  S1:setType("RS485")
  
  -- setting the BaudRate of the device
  S1:setBaudRate(115200)
  
  -- opens communication
  S1:open()
  S1:register('OnReceive', Callback)
end

Script.register("Engine.OnStarted", main)
