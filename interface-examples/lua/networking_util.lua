
---Main config.
Config = {
  username = "admin",
  password = "adminpassword",  -- Change this to your password
  tdc_ip = "192.168.0.100", -- Change this to your device IP
  tdc_protocol = "http",  
  tdc_token = "",
  endpoint = "",
  endpoint_auth  = "/auth/login",
  endpoint_iface = "/api/v1/network/interfaces/",
  endpoint_wlan  = "/api/v1/network/wlan",
  endpoint_sett  = "/api/v1/network/settings",
  endpoint_modem = "/api/v1/network/modem"
}
 
---Function returns TDC device endpoint root.
---@return string
function getEndpointRoot()
  local endpoint = Config.tdc_protocol .. "://" .. Config.tdc_ip
  return endpoint
end

---Returns json used for authentication
---@param username string
---@param password string
function createRequestBody(data)
  local json = JSON.create()
  local req = json:parseFromString('{}')
  for k, v in pairs(data) do
      req:createElement('/' .. k .. '', v)    
  end
  return req:toString() 
end