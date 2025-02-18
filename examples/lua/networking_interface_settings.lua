require 'networking_util'

---Get interface settings.
---@return void
function getInterfaceSettings(interface_name)
  print("Get Interface List...")

  -- Define endpoint.
  local endpoint = getEndpointRoot() .. Config.endpoint_iface .. interface_name .. "/settings"

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
  print("Request body: " .. response_body)

end

getInterfaceSettings('eth1')