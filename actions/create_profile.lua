event: ["create_profile"]
priority: 1

local split_yaml_header = (require "helpers").split_yaml_header
local helpers = require "lighttouch-keys.helpers"

local home_dir = "content/home/"

local path
local existing_profile = helpers.iter_content_files_of("home",
  function (file_uuid, header, body)
    if header.type == "profile" then
      path = "home/" .. file_uuid
      return header.name
    end
  end
)

if existing_profile then
  log.warn("A profile '" .. existing_profile .. "' already exists, in " .. path)
  return {
    headers = {
      ["content-type"] = "application/json"
    },
    body = '{"error":"a profile already exists"}'
  }
end

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
  name = request.body.name
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
