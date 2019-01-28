event = ["send_connect_request"]
priority = 1
input_parameters = ["request"]

local place = request.query.connect
local data = keys.get_profile_data()

return {
  headers = {
    ["content-type"] = "application/json",
  },
  body = json.from_table({
    place = place,
    data = data
  })
}
