event: ["reqProcess"]
priority: 1

-- TODO: the headers part of the signature header is being ignored.
-- every header listed in headers, separated with spaces, must be included

local header = req.headers["signature"]
log.trace("signature header", header)

if not header then log.info("Unsigned Request") return end

local keys = {
  alice = "xpKtm+beeRN+kT7VWIJ05/tkhdDn/JxHlTsk73L5Z50="
}

local keyId, signature = header:match('keyId="(%a+)".+signature="([^"]+)"')
log.debug("keyId", keyId)
log.debug("signature", signature)

--[=[
local sig_parts = {}
for _, part in ipairs(header:split(",")) do
  local ps = part:split("=")
  -- remove start and end quotes (doesn't handle escape sequences)
  sig_parts[ps[1]] = ps[2]:sub(2, -2)
end

log.trace("signature parts")
for k, v in pairs(sig_parts) do
  log.debug(k, v)
end

local signature = sig_parts.signature
]=]

local key = crypto.sign.load_public(keys[keyId])
log.trace("public key for", keyId, key)

local signature_string = "date: " .. req.headers.date .. "\n" .. req.body_raw
signature_string = "a"
log.trace("signature string", signature_string)

local is_valid = key:verify_detached(signature_string, signature)
if is_valid then
  log.info("request signature is valid")
else
  log.warn("invalid request signature")
end

