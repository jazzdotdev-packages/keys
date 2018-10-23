event: ["incoming_request_received"]
priority: 50

-- TODO: The headers part of the signature header is being ignored.
-- every header listed in headers, separated with spaces, must be included
-- in the signature string. Also the algorithm field is ignored as well, this
-- should fail if algorithm is not ed25519, also fields can be given in any
-- order, not specifically keyId before signature

local helpers = require "lighttouch-keys.helpers"

local is_valid = helpers.verify_http_signature(request)

if not helpers.verify_http_signature(request)
and request.path_segments[1] ~= "profile"
and request.path_segments[2] ~= "new"
then
  if request.headers.signature then
    log.warn("invalid request signature")
  end
  -- Respond 401
end

