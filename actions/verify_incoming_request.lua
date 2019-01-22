event = ["incoming_request_received"]
priority = 50
input_parameters = ["request"]

if not keys.verify_http_signature(request) then
  log.info("Unsigned request")
end

