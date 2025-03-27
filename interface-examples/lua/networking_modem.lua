require 'networking_util'

---Get TDC network MODEM interfaces list.
---@return void
function getModemInterfaceList()

  print("Get Modem Interface List...")

  -- Define endpoint.
  local endpoint = getEndpointRoot() .. Config.endpoint_modem

  -- Create client.
  local client = HTTPClient.create()
  -- Create request.
  local request = HTTPClient.Request.create()
  request:setURL(endpoint)
  request:setMethod("GET")

  -- Prepare credentials.
  request:addHeader("accept", "application/json")
  request:addHeader("Authorization", "Bearer " .. Config.tdc_token)

  -- Execute.
  local response = client:execute(request)
  local response_code = response:getStatusCode()
  local response_body = response:getContent()

  print("Token: " .. Config.tdc_token)
  print("Endpoint: " .. endpoint)
  print("Request status: " .. response_code)  
  print("Response body: " .. response_body)

end

---Get TDC network specific MODEM interface setting.
---@return void
function getModemInterfaceStatus(interface_name)

  print("Get Modem Interface Status.")

  -- Define endpoint.
  local endpoint = getEndpointRoot() .. Config.endpoint_modem .. "/" .. interface_name

  -- Create client.
  local client = HTTPClient.create()
  -- Create request.
  local request = HTTPClient.Request.create()
  request:setURL(endpoint)
  request:setMethod("GET")

  -- Prepare credentials.
  request:addHeader("accept", "application/json")
  request:addHeader("Authorization", "Bearer " .. Config.tdc_token)

  -- Execute.
  local response = client:execute(request)
  local response_code = response:getStatusCode()
  local response_body = response:getContent()

  print("Token: " .. Config.tdc_token)
  print("Endpoint: " .. endpoint)
  print("Request status: " .. response_code)  
  print("Response body: " .. response_body)
  
end

---Get TDC network specific MODEM interface setting.
---@return void
function getModemInterfaceSetting(interface_name)

  print("Get Modem Interface Setting.")

  -- Define endpoint.
  local endpoint = getEndpointRoot() .. Config.endpoint_modem .. "/" .. interface_name .. "/settings"

  -- Create client.
  local client = HTTPClient.create()
  -- Create request.
  local request = HTTPClient.Request.create()
  request:setURL(endpoint)
  request:setMethod("GET")

  -- Prepare credentials.
  request:addHeader("accept", "application/json")
  request:addHeader("Authorization", "Bearer " .. Config.tdc_token)

  -- Execute.
  local response = client:execute(request)
  local response_code = response:getStatusCode()
  local response_body = response:getContent()

  print("Token: " .. Config.tdc_token)
  print("Endpoint: " .. endpoint)
  print("Request status: " .. response_code)  
  print("Response body: " .. response_body)
  
end

---Add OR update network modem connection.
---@return void
function setModemNetwork(interface_name, mdm_apn, mdm_username, mdm_password, mdm_dial)

  print("SET modem Interface List.")

  -- Define endpoint.
  local endpoint = getEndpointRoot() .. Config.endpoint_modem .. "/" .. interface_name .. "/settings"

  -- Create client.
  local client = HTTPClient.create()
  
  -- Create request.
  local request = HTTPClient.Request.create()
  request:setURL(endpoint)
  request:setMethod("PUT")

  -- Prepare credentials.
  request:addHeader("accept", "application/json")
  request:addHeader("Authorization", "Bearer " .. Config.tdc_token)

  -- Set Modem data.
  request:setContentType("application/json")
  request:setContentBuffer(createRequestBody(
      {      
        enabled=true,
        connectionEnabled=true,
        persistConnection=true,      
        apn=mdm_apn,
        apnPassword=mdm_password,
        apnUsername=mdm_username,
        dialString=mdm_dial
      }
    )
  )

  -- Execute.
  local response = client:execute(request)
  local response_code = response:getStatusCode()
  local response_body = response:getContent()

  print("Token: " .. Config.tdc_token)
  print("Endpoint: " .. endpoint)
  print("Request status: " .. response_code)  
  print("Response body: " .. response_body)
  
end

-- getModemInterfaceList()
-- getModemInterfaceStatus("wwan0")
-- getModemInterfaceSetting("wwan0")
-- setModemNetwork("wwan0", "internet.ht.hr", "", "", "")