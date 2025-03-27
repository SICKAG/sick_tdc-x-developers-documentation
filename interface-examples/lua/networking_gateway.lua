require 'networking_util'

---Setup new gateway priority list.
---@return void
function setGatewayPriorityByList(interface_list)

  print("Set Gateway priority by list.")

  -- Define endpoint.
  local endpoint = getEndpointRoot() .. Config.endpoint_sett

  -- Create client.
  local client = HTTPClient.create()
  
  -- Create request.
  local request = HTTPClient.Request.create()
  request:setURL(endpoint)
  request:setMethod("PUT")

  -- Prepare credentials.
  request:addHeader("accept", "application/json")
  request:addHeader("Authorization", "Bearer " .. Config.tdc_token)

  -- Prepare setting data.
  request:setContentType("application/json")
  request:setContentBuffer('{"defaultGatewayPriority": ["eth2","eth1","wlan0","wwan0"], "networkDriver": "ControlCenter"}')

  -- Execute.
  local response = client:execute(request)
  local response_code = response:getStatusCode()
  local response_body = response:getContent()

  print("Token: " .. Config.tdc_token)
  print("Endpoint: " .. endpoint)
  print("Response status: " .. response_code)  
  print("Response body: " .. response_body)
  
end

setGatewayPriorityByList()