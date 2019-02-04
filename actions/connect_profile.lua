event = ["connect_profile"]
priority = 1
input_parameters = ["request"]

local result = keys.connect(request.body)
log.debug("Connected pofile: " .. inspect(result))
local data = keys.get_profile_data()

return {
  headers = {
    ["content-type"] = "application/json",
  },
  body = json.from_table(data)
}
