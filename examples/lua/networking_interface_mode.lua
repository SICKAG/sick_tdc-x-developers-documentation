require 'networking_util'

---Set interface mode DHCP or static.
---@return void
function setInterfaceMode(interface_name, mode)

  print("Get Interface List...")

  -- Define endpoint.
  local endpoint = getEndpointRoot() .. Config.endpoint_iface .. interface_name .. "/settings"

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

  mode_data = {}
  if mode == 'dhcp' then
    mode_data = {
      enabled=true, 
      useDhcp=true, 
      staticAddress="",
      defaultGateway="0.0.0.0",
      dhcpFallbackAddress="192.168.222.1/24",
      dhcpFallbackGateway="0.0.0.0",
      dhcpFallbackMode=0
    }
  elseif mode == 'static' then
    mode_data = {
      enabled=true, 
      useDhcp=false, 
      staticAddress="192.168.2.100/24",
      defaultGateway="192.168.2.1",
      dhcpFallbackAddress="",
      dhcpFallbackGateway="",
      dhcpFallbackMode=0
    }
  else 
    print("Invalid mode")    
    return
  end

  request:setContentBuffer(createRequestBody(mode_data))

  -- Execute.
  local response = client:execute(request)
  local response_code = response:getStatusCode()
  local response_body = response:getContent()

  print("Token: " .. Config.tdc_token)
  print("Endpoint: " .. endpoint)
  print("Request status: " .. response_code)  
  print("Response body: " .. response_body)

end

-- setInterfaceMode("eth2", "dhcp")
-- setInterfaceMode("eth2", "static")
