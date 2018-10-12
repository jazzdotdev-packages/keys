event: ["reqProcess"]
priority: 1

-- TODO: The headers part of the signature header is being ignored.
-- every header listed in headers, separated with spaces, must be included
-- in the signature string. Also the algorithm field is ignored as well, this
-- should fail if algorithm is not ed25519, also fields can be given in any
-- order, not specifically keyId before signature

local helpers = require "lighttouch-keys.helpers"

local header = req.headers["signature"]
log.trace("signature header", header)

if not header then log.info("Unsigned Request") return end

local keyId, signature = header:match('keyId="(%a+)".+signature="([^"]+)"')
log.debug("keyId", keyId)
log.debug("signature", signature)

local pub_key = helpers.iter_content_files_of("home",
  function (file_uuid, header, body)
    if header.type == "key" and header.kind == "sign_public" then
      return body
    end
  end
)

if not pub_key then
  log.info("no public key found for profile " .. keyId)
  req.headers["x-trusted"] = "0"
end

pub_key = crypto.sign.load_public(pub_key)

local signature_string = "date: " .. req.headers.date .. "\n" .. req.body_raw
log.trace("signature string", signature_string)

local is_valid = pub_key:verify_detached(signature_string, signature)
if is_valid then
  log.debug("request signature is valid")
  req.headers["x-trusted"] = "1"
else
  log.warn("invalid request signature")
  req.headers["x-trusted"] = "0"
end

