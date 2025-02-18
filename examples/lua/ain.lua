-- script for getting / setting measure mode and getting values for AIN A, B, C

local function createCallback(device, countLimit)
    local count = 0
    return function()
      print("in callback function for " .. device:getName())
      Script.sleep(1000)
      device:setMeasureMode('Current')
      if countLimit then
        count = count + 1
        if count == countLimit then
          print("Deregistering callback for " .. device:getName())
          device:deregister('Overcurrent', callback)
        end
      end
    end
  end
  
  -- function for setting and reading from device by providing a device name, 
  -- the initial mode [CURRENT|VOLTAGE], the callback function and a count limit
  local function setupDevice(deviceName, initialMode, callback, countLimit)
    print("-----------Device is '" .. deviceName .. "'---------------")
    
    -- creating AIN handle
    local device = AnalogIn.create(deviceName)
    device:setMeasureMode(initialMode)
    device:register('Overcurrent', createCallback(device, countLimit))
  
    -- reading device specifications
  
    local measureMode = device:getMeasureMode()
    print("Measure mode is set to: " .. measureMode)
    local rawValue = device:readRaw()
    print(string.format("Raw value is: %s", rawValue))
    local convertedValue = device:readConverted()
    print(string.format("Converted value is: %s", convertedValue))
  
    return device
  end
  
  Log.setLevel('ALL')
  
  local a1 = setupDevice('AI_A', 'Voltage', createCallback, nil)
  local a2 = setupDevice('AI_B', 'Voltage', createCallback, nil)
  local a3 = setupDevice('AI_C', 'Current', createCallback, 4)
  
  print("Engine version: " .. Engine.getVersion())
  Log.setLevel('ALL')
  