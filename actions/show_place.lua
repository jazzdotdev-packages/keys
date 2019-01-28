event = ["show_place"]
priority = 1
input_parameters = ["request"]

local place = get_place()

return {
  headers = {
    ["content-type"] = "text/plain",
  },
  body = place
}
