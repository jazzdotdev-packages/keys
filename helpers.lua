
local helpers = {}

local fs = require "fs"
local split_yaml_header = (require "helpers").split_yaml_header

function helpers.iter_content_files_of (profile, fn)
  local dir = "content/" .. profile .. "/"

  for _, file_uuid in ipairs(fs.get_all_files_in(dir)) do
    local path = dir .. file_uuid
    local file_content = fs.read_file(path)
    if not file_content then
      log.error("could not open " .. path)
    end

    local header, content = split_yaml_header(file_content)

    local result = fn(file_uuid, header, content)
    if result then return result end
  end
end

function helpers.verify_http_signature (message)
  local header = message.headers["signature"]
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
    return false
  end

  pub_key = crypto.sign.load_public(pub_key)

  local signature_string = "date: " .. message.headers.date .. "\n" .. message.body_raw
  log.trace("signature string", signature_string)

  local is_valid = pub_key:verify_detached(signature_string, signature)
  return is_valid
end

return helpers
