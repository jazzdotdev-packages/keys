event: ["response_process"]
priority: 2 -- Before logging the response

-- https://tools.ietf.org/id/draft-cavage-http-signatures-08.html

log.info("Signing response")

local helpers = require "lighttouch-keys.helpers"

local res = torchbear_response

local profile_uuid = helpers.iter_content_files_of("home",
  function (file_uuid, header, body)
    if header.type == "profile" then
      return file_uuid
    end
  end
)

if not profile_uuid then
  log.error("Could not sign: No home profile found")
  return
end

local priv_key = helpers.iter_content_files_of("home",
  function (file_uuid, header, body)
    if header.type == "key"
    and header.kind == "sign_private"
    then
      return body
    end
  end
)

if not priv_key then
  log.error("Could not sign: No private key for home profile")
  return
end

priv_key = crypto.sign.load_secret(priv_key)

if not res.headers.date then
  res.headers.date = tostring(time.now())
end

-- Fails if body is not a string
local signature_string = "date: " .. res.headers.date .. "\n" .. res.body

local signature = priv_key:sign_detached(signature_string)

res.headers["x-profile-uuid"] = profile_uuid
res.headers.signature = 'keyId="' .. profile_uuid .. '",algorithm="ed25519",signature="' .. signature .. '"'
