event: ["jade_new_profile"]
priority: 1

local split_yaml_header = (require "helpers").split_yaml_header

local helpers = require "lighttouch-keys.helpers"

function write_file (path, header, body)
  local content = yaml.dump(header) .. "\n...\n" .. (body or "")
  local file = io.open(path, "w")
  if not file then
    log.error("Could not open file", path)
  end
  file:write(content)
  file:close()
end

log.trace("body raw", request.body_raw)
log.trace("body")
for k, v in pairs(request.body) do
  log.trace(k, v)
end

local profile_uuid = request.body.uuid

local exists = helpers.iter_content_files_of(profile_uuid,
  function (file_uuid, header, body)
    if header.type == "profile" then
      return true
    end
  end
)

if exists then
  -- Could be 403.3 but actix_web only supports integers
  -- https://en.wikipedia.org/wiki/HTTP_403#o403_substatus_error_codes_for_IIS
  -- https://docs.rs/http/0.1.13/src/http/status.rs.html#43
  return { status = 403 }
end

local dir = "content/" .. profile_uuid .. "/"
os.execute("mkdir -p " .. dir)

write_file(dir .. profile_uuid, {
  type = "profile",
  name = request.body.name
})

local sign_pub_id = uuid.v4()
write_file(dir .. sign_pub_id, {
  type = "key",
  kind = "sign_public",
}, request.body.public_key)


return { }
