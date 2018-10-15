event: ["outgoing_response_about_to_be_sent"]
priority: 2 -- Before logging the response

local signed = require("lighttouch-keys.helpers").sign_http_message(response)

if not signed then
  log.error("Could not sign response")
end
