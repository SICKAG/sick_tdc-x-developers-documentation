local function readSerial(S1, message)
  return function()
    local Retb = S1:transmit(message)
    print("Transmitted " .. Retb .. " bytes.")
  end
end

local function main()
  -- creates serial communication called SER1
  S1 = SerialCom.create('SER1')
  S1:setTermination(false)
  
  -- sets type of communication to [RS-422 | RS-485]
  S1:setType("RS485")
  -- setting the BaudRate of the device
  S1:setBaudRate(115200)
  
  -- opens communication
  S1:open()
  local message = "Hello world!\n"

  readTimer = Timer.create()
  readTimer:register('OnExpired', readSerial(S1, message))
  readTimer:setPeriodic(true)
  readTimer:setExpirationTime(5000)
  readTimer:start()
end

Script.register("Engine.OnStarted", main)