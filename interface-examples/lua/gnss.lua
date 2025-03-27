-- lua script for gnss

-- create and enable GNSS
gnssHandle = Gnss.create()
gnssHandle:enable()

if (gnssHandle:isEnabled()) then
  print("GNSS Receiver is enabled")
  print("--------------------------------")
end

local function getData()
  local x,y,z = gnssHandle:getPosition()
  print("Latitude: " .. x)
  print("Longitude: " .. y)
  print("Altitude: " .. z)

  local q,w,e,r = gnssHandle:getSignalMetrics()
  print("Number of satellites: " .. q)
  print("Fix type: " .. w)
  print("Fix quality: " .. e)
  print("HDOP: " .. r)

  local h=gnssHandle:getNmeaSentence('RMC')
  print('RMC sentence: ' .. h)
  h=gnssHandle:getNmeaSentence('GSA')
  print('GSA sentence: ' .. h)
  h=gnssHandle:getNmeaSentence('GGA')
  print('GGA sentence: ' .. h)
  h=gnssHandle:getNmeaSentence('GSV')
  print('GSV sentence: ' .. h)
  h=gnssHandle:getNmeaSentence('VTG')
  print('VTG sentence: ' .. h)
  
  print("Speed in KPH: " .. gnssHandle:getSpeed('KPH'))
  print("Speed MPH:" .. gnssHandle:getSpeed('MPH'))
  print("Course " .. gnssHandle:getCourse())
end

local function handleOnNewData(timestamp, positionData, motionData, metricsData)
  print("Timestamp: " .. timestamp)
  print("Latitude: " .. positionData[1])
  print("Longitude: " .. positionData[2])
  print("Altitude: " .. positionData[3])
  print("Speed [KPH]: " .. motionData[1])
  print("Speed [MPH]: " .. motionData[2])
  print("Course: " .. motionData[3])
  print("Satellite number: " .. metricsData[1])
  print("Fix type: " .. metricsData[2])
  print("Fix quality: " .. metricsData[3])
  print("HDOP: " .. metricsData[4])
  print("--------------------------------")
end

-- on receiving data, prints new formatted data
Gnss.register(gnssHandle, 'OnNewData', handleOnNewData)
