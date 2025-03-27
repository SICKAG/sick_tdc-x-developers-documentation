require 'networking_util'

---Get TDC admin JWT token.
---@return boolean
function login()

  print("Request Auth token")

  local endpoint = getEndpointRoot() .. Config.endpoint_auth

  -- Create client.
  local client = HTTPClient.create()
  -- Create request.
  local request = HTTPClient.Request.create()
  request:setURL(endpoint)
  request:setMethod("POST")
  -- Prepare credentials.
  request:addHeader("Accept", "application/json")
  
  local body =     createRequestBody(
    {
      username=Config.username, 
      password=Config.password, 
      realm="admin"}
  )

  print(body);

  -- Prepare setting data.
  request:setContentType("application/json")
  request:setContentBuffer(
    createRequestBody(
      {
        username=Config.username, 
        password=Config.password, 
        realm="admin"}
    )
  )
  -- Execute.
  local response = client:execute(request)
  local response_code = response:getStatusCode()
  local response_body = response:getContent()

  if response_code == 200 then   
    local json = JSON.create()
    local json_body = json:parseFromString(response_body)    
    Config.token = json_body:getValue("/token")
    print("Token:" .. Config.token)    
    return true
  else    
    print("Unable to get token, check your credentials")
    return false
  end
end

login()

