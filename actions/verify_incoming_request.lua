event: ["incoming_request_received"]
priority: 50

local is_valid = keys.verify_http_signature(request)

if not keys.verify_http_signature(request)
and request.path_segments[1] ~= "profile"
and request.path_segments[2] ~= "new"
then
  if request.headers.signature then
    log.warn("invalid request signature")
  end
  -- Respond 401
end

