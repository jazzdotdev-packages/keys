event: ["reqProcess"]
priority: 1

-- TODO: The headers part of the signature header is being ignored.
-- every header listed in headers, separated with spaces, must be included
-- in the signature string. Also the algorithm field is ignored as well, this
-- should fail if algorithm is not ed25519, also fields can be given in any
-- order, not specifically keyId before signature

local helpers = require "lighttouch-keys.helpers"

if helpers.verify_http_signature(req) then
  log.debug("valid request signature")
  req.headers["x-trusted"] = "1"
else
  if req.headers.signature then
    log.warn("invalid request signature")
  end
  req.headers["x-trusted"] = "0"
end

