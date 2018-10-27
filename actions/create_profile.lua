event: ["create_profile"]
priority: 1

local profile = content.walk_documents("home",
  function (file_uuid, header, body)
    if header.type == "profile" then
      return {name = header.name, uuid = file_uuid}
    end
  end
)

if profile then
  local msg = "A profile '" .. profile.name .. "' already exists in 'content/home/" .. profile.uuid .. "'"
  log.warn(msg)
  return {
    headers = {
      ["content-type"] = "application/json"
    },
    body = '{"error":"' .. msg .. '"}'
  }
end

local profile_uuid = uuid.v4()

local sign_priv, sign_pub = crypto.sign.new_keypair()

local sign_priv_id = uuid.v4()
local sign_pub_id = uuid.v4()

content.write_file("home", profile_uuid, {
  type = "profile",
  name = request.body.name
})

content.write_file("home", sign_priv_id, {
  type = "key",
  kind = "sign_private",
  priority = math.random()*0.9 + 0.1,
  profile_uuid = profile_uuid,
}, tostring(sign_priv))

content.write_file("home", sign_pub_id, {
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
