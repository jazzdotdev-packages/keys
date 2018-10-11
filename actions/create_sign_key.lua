event: ["key_generation_request"]
priority: 1

function write_file (key_uuid, key, params)

  local content = yaml.dump(params) .. "\n...\n" .. tostring(key)
  
  local file = io.open("content/" .. key_uuid, "w")
  file:write(content)
  file:close()

  return key_uuid
end

log.debug("Generating keys")

--local box_pair = crypto.box.new_keypair()
--local box_priv, box_pub = box_pair:get_keys()

local sign_priv, sign_pub = crypto.sign.new_keypair()

log.debug("Saving keys")

--local box_priv_id = write_file("box-private", box_priv)
--local box_pub_id = write_file("box-public", box_pub)

local sign_priv_id = uuid.v4()
local sign_pub_id = uuid.v4()

write_file(sign_priv_id, sign_priv, {
  type = "key",
  kind = "sign_private",
  priority = math.random()*0.9 + 0.1,
  public_uuid = sign_pub_id,
})

write_file(sign_pub_id, sign_pub, {
  type = "key",
  kind = "sign_public",
  private_uuid = sign_priv_id,
})

log.debug("Returning keys")

--[[local keys = '{"box_priv": "' .. box_priv_id ..
  '", "box_pub": "' .. box_pub_id ..
  '", "sign_priv": "' .. sign_priv_id ..
  '", "sign_pub": "' .. sign_pub_id .. '"}']]

local keys = '{"sign_priv": "' .. sign_priv_id .. '", "sign_pub": "' .. sign_pub_id .. '"}'

local signature = sign_priv:sign_detached(keys)

local body = '{"keys": ' .. keys .. ', "signature": "' .. signature .. '"}'

return {
    headers = {
        ["content-type"] = "application/json",
        ["X-Request-ID"] = key_uuid 
    },
    body = body
}
