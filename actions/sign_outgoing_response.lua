event = ["outgoing_response_about_to_be_sent"]
priority = 2
input_parameters = ["response"]

local signed, err = keys.sign_http_message(response)

if not signed then
  log.warn("Could not sign response: " .. err)
end
