event: ["key_generation_request"]
priority: 1


function write_file (kind, key)
  local key_uuid = uuid.v4()
  local params = {
    type = "key",
    kind = kind
  }

  local content = yaml.dump(params) .. "\n\n" .. key
  
  local file = io.open("content/" .. key_uuid, "w")
  file:write(content)
  file:close()

  return key_uuid
end

print("Generating keys")
local box_pair = crypto.box.new_keypair()
local sign_pair = crypto.sign.new_keypair()

local box_priv, box_pub = box_pair:get_keys()
local sign_priv, sign_pub = sign_pair:get_keys()

print("Saving keys")

local box_priv_id = write_file("box-private", box_priv)
local box_pub_id = write_file("box-public", box_pub)
local seal_priv_id = write_file("seal_private", sign_priv)
local seal_pub_id = write_file("seal_public", sign_pub)

print("Returning keys")

local keys = '{"box_priv": "' .. box_priv_id ..
  '", "box_pub": "' .. box_pub_id ..
  '", "seal_priv": "' .. seal_priv_id ..
  '", "seal_pub": "' .. seal_pub_id .. '"}'

local signature = sign_pair:sign_detached(keys)

local body = '{"keys": ' .. keys .. ', "signature": "' .. signature .. '"}'

return {
    headers = {
        ["content-type"] = "application/json",
        ["X-Request-ID"] = key_uuid 
    },
    body = body
}
