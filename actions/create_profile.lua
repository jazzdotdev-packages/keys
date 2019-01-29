event = ["create_profile"]
priority = 1
input_parameters = ["request"]


local profile = content.walk_documents(content.home,
  function (file_uuid, header, body)
    if header.type == "profile" then
      return {name = header.name, uuid = file_uuid}
    end
  end
)

if profile then
  local path = content.stores[content.home] .. profile.uuid
  local msg = "A profile '" .. profile.name .. "' already exists in '" .. path .. "'"
  log.warn(msg)
  return {
    headers = {
      ["content-type"] = "application/json"
    },
    body = '{"error":"' .. msg .. '"}'
  }
end

local profile_uuid = content.home

local sign_priv, sign_pub = crypto.sign.new_keypair()

local sign_priv_id = uuid.v4()
local sign_pub_id = uuid.v4()

content.write_file(content.home, profile_uuid, {
  model = "profile",
  name = request.body["fields.name"]
})

content.write_file(content.home, sign_priv_id, {
  model = "key",
  kind = "sign_private",
  profile_uuid = profile_uuid,
}, tostring(sign_priv))

content.write_file(content.home, sign_pub_id, {
  model = "key",
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
