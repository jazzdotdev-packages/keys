event: ["jade_new_profile"]
priority: 1

local split_yaml_header = (require "helpers").split_yaml_header

function write_file (path, header, body)
  local content = yaml.dump(header) .. "\n...\n" .. (body or "")
  local file = io.open(path, "w")
  if not file then
    log.error("Could not open file", path)
  end
  file:write(content)
  file:close()
end

log.trace("body raw", req.body_raw)
log.trace("body")
for k, v in pairs(req.body) do
  log.trace(k, v)
end

local profile_uuid = req.body.uuid
local dir = "content/" .. profile_uuid .. "/"
os.execute("mkdir -p " .. dir)

write_file(dir .. profile_uuid, {
  type = "profile",
  name = req.body.name
})

local sign_pub_id = uuid.v4()
write_file(dir .. sign_pub_id, {
  type = "key",
  kind = "sign_public",
}, req.body.public_key)


return {
    headers = {
        ["content-type"] = "application/json",
        ["X-Request-ID"] = key_uuid 
    },
    body = '{"msg":"profile created"}'
}
