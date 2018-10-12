event: ["create_profile"]
priority: 1

local split_yaml_header = (require "helpers").split_yaml_header

local home_dir = "content/home/"

for _, file_id in ipairs(fs.get_all_files_in(home_dir)) do

  local path = home_dir .. file_id
  log.trace("checking file", path)

  local file_content = fs.read_file(path)
  if not file_content then
    log.error("could not open " .. path)
  end

  local header, content = split_yaml_header(file_content)

  if header.type == "profile" then
    log.warn("A profile '" .. header.name .. "' already exists, in " .. path)
    return {
      headers = {
        ["content-type"] = "application/json"
      },
      body = '{"error":"a profile already exists"}'
    }
  end
end

log.debug("No profile found")

function write_file (path, header, body)
  local content = yaml.dump(header) .. "\n...\n" .. (body or "")
  local file = io.open(path, "w")
  if not file then
    log.error("Could not open file", path)
  end
  file:write(content)
  file:close()
end

local profile_uuid = uuid.v4()

local sign_priv, sign_pub = crypto.sign.new_keypair()

local sign_priv_id = uuid.v4()
local sign_pub_id = uuid.v4()

write_file(home_dir .. profile_uuid, {
  type = "profile",
  name = req.path_segments[3]
})

write_file(home_dir .. sign_priv_id, {
  type = "key",
  kind = "sign_private",
  priority = math.random()*0.9 + 0.1,
  profile_uuid = profile_uuid,
}, tostring(sign_priv))

write_file(home_dir .. sign_pub_id, {
  type = "key",
  kind = "sign_public",
  private_uuid = sign_priv_id,
}, tostring(sign_pub))

local body = '{"uuid":"' .. profile_uuid .. '", "sign_priv": "' .. sign_priv_id .. '", "sign_pub": "' .. sign_pub_id .. '"}'

return {
    headers = {
        ["content-type"] = "application/json",
        ["X-Request-ID"] = key_uuid 
    },
    body = body
}
