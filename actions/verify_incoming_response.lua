event = ["incoming_response_received"]
priority = 50
input_parameters = ["response"]

if not keys.verify_http_signature(response) then
  log.info("Unsigned response")
end

