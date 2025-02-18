---Include common script.
require 'networking_util'

---Get TDC network WLAN interfaces list.
---@return void
function getWlanInterfaceList()

  print("Get Wlan Interface List...")

  -- Define endpoint.
  local endpoint = getEndpointRoot() .. Config.endpoint_wlan

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

---Get TDC network WLAN specific interface setting.
---@return void
function getWlanInterfaceSetting(interface_name)

  print("Get Wlan Interface List...")

  -- Define endpoint.
  local endpoint = getEndpointRoot() .. Config.endpoint_wlan .. "/" .. interface_name

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

---Add new network connection.
---@return void
function setWlanNetwork(interface_name, wlan_ssid, wlan_password)

  print("Get Wlan Interface List...")

  -- Define endpoint.
  local endpoint = getEndpointRoot() .. Config.endpoint_wlan .. "/" .. interface_name .. "/networks/" .. wlan_ssid

  -- Create client.
  local client = HTTPClient.create()
  
  -- Create request.
  local request = HTTPClient.Request.create()
  request:setURL(endpoint)
  request:setMethod("PUT")

  -- Prepare credentials.
  request:addHeader("accept", "application/json")
  request:addHeader("Authorization", "Bearer " .. Config.tdc_token)

  -- Set Wlan data.
  request:setContentType("application/json")
  request:setContentBuffer(createRequestBody(
      {
        connectionState="connected",
        passphrase=wlan_password,
        reconnect=true,
        username=""
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


---Remove wireless network connection.
---@return void
function deleteWlanNetwork(interface_name, wlan_ssid, wlan_password)

  print("Get Wlan Interface List...")

  -- Define endpoint.
  local endpoint = getEndpointRoot() .. Config.endpoint_wlan .. "/" .. interface_name .. "/networks/" .. wlan_ssid

  -- Create client.
  local client = HTTPClient.create()
  
  -- Create request.
  local request = HTTPClient.Request.create()
  request:setURL(endpoint)
  request:setMethod("DELETE")

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

-- getWlanInterfaceList()
-- getWlanInterfaceSetting("wlan0")
-- getWlanInterfaceNetworkList("wlan0")
-- setWlanNetwork("wlan0", "my-network1-name", "wlanpassword") 
-- deleteWlanNetwork("wlan0", "my-network1-name")