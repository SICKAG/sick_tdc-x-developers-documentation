local function extractTemperature(temperatureMonitor)
  if not temperatureMonitor then
    return nil
  end
  return temperatureMonitor:get()
end

local function main()

  PCB0 = Monitor.Temperature.create('PCB_TEMP0')
  PCB1 = Monitor.Temperature.create("PCB_TEMP1") 
  CPU0 = Monitor.Temperature.create('A53_CPU_TEMP')
  CPU1 = Monitor.Temperature.create("SOC_ANAMIX_TEMP") 

  print(string.format("PCB_TEMP0: %.2f°C", extractTemperature(PCB0)))
  print(string.format("PCB_TEMP1: %.2f°C", extractTemperature(PCB1)))
  print(string.format("A53_CPU_TEMP: %.2f°C", extractTemperature(CPU0)))
  print(string.format("SOC_ANAMIX_TEMP: %.2f°C", extractTemperature(CPU1)))

end

Script.register("Engine.OnStarted", main)
