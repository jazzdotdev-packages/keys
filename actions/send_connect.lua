event = ["send_connect_request"]
priority = 1
input_parameters = ["request"]

local place = request.query.connect
local data = keys.get_profile_data()

local response = send_request({
  method = "POST",
  uri = "http://localhost:3001/?pong",
  headers = {},
  body = json.from_table(data)
})

local result = keys.connect(response.body)

return {
  headers = {
    ["content-type"] = "application/json",
  },
  body = json.from_table(result)
}
