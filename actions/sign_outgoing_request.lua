event = ["outgoing_request_about_to_be_sent"]
priority = 2
input_parameters = ["request"]

local signed, err = keys.sign_http_message(request)

if not signed then
  log.warn("Could not sign request: " .. err)
end
