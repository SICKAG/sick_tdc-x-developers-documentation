-- lua script for DIO devices

function PrintDIOStateIn(dio, name)
    local state = dio:get()
    print(string.format("%s state: %s", name, state))
  end
  
  Log.setLevel('ALL')
  print("Engine version: " .. Engine.getVersion())
  
  -- sets DIO A as output
  -- outputs: DIO_AO, DIO_BO, DIO_CO, DIO_DO
  
  -- setting DIO [HIGH | LOW]
  dioAO = Connector.DigitalOut.create('DIO_AO')
  dioAO:set(true);
  print("Set DO A output to HIGH.")
  --dioAO:set(false);
  --print("Set DIO A output to LOW.")
  
  -- sets DIO B and C as input
  -- inputs: DIO_AI, DIO_BI, DIO_CI, DIO_DI, DI_A, DI_B, DI_C
  
  dioBI = Connector.DigitalIn.create('DIO_BI')
  PrintDIOStateIn(dioBI, "DIO BI")
  
  dioCI = Connector.DigitalIn.create('DIO_CI')
  PrintDIOStateIn(dioCI, "DIO CI")
  
  dioDI = Connector.DigitalIn.create('DIO_DI')
  function Print_DIODI()
      local state = dioDI:get()
      print(string.format("DIO_DI state: %s", state))
  end
  -- printing can also be registered to print onChangeStamped
  Connector.DigitalIn.register(dioDI, "OnChangeStamped", Print_DIODI)
  