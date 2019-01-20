event = ["send_profile_and_key"]
priority = 1
input_parameters = ["request"]

local profile
local pub_key

content.walk_documents("home", function (file_uuid, header, body)
  if header.type == "key" and header.kind == "sign_public" then
    pub_key = body
  end

  if header.type == "profile" then
    profile = header
    profile.uuid = file_uuid
  end
end)


if not profile then
  log.error("No associated profile found")
  return {
    headers = {
      ["content-type"] = "application/json",
    },
    status = 404,
    body = '{"error":"No associated profile found"}',
  }
end

if not pub_key then
  log.error("No associated public key found")
  return {
    headers = {
      ["content-type"] = "application/json",
    },
    status = 404,
    body = '{"error":"No associated public key found"}',
  }
end

local target_uuid = request.path_segments[2]

local target_host = content.walk_documents(target_uuid,
  function (file_uuid, header, body)
    if header.type == "place" then
      return header.host
    end
  end
)

if not target_host then
  log.error("No associated host found for " .. target_uuid)
  return {
    headers = {
      ["content-type"] = "application/json",
    },
    status = 404,
    body = '{"error":"No associated host found"}',
  }
end

log.info("sending profile info to", target_host)

local response = client_request.send({
  method = "POST",
  uri = "jade_new_profile",
  headers = {
    ["content-type"] = "application/json",
  },
  body = '{"uuid":"' .. profile.uuid .. '","name":"' .. profile.name .. '","public_key":"' .. pub_key .. '"}'
})

log.debug(require("inspect").inspect(response))

if not keys.verify_http_signature(response) then
  log.error("Invalid response signature")
end

return {
  headers = {
    ["content-type"] = "application/json",
  },
  body = '{"message":"data sent","host":"' .. target_host .. '"}'
}
