event = ["jade_new_profile"]
priority = 1
input_parameters = ["request"]

local profile_uuid = request.body.uuid

local exists = content.walk_documents(profile_uuid,
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
  log.into("A profile " .. profule_uuid .. " already exists")
  return { status = 403 }
end

content.write_file(profile_uuid, profile_uuid, {
  type = "profile",
  name = request.body.name
})

local sign_pub_id = uuid.v4()
content.write_file(profile_uuid, sign_pub_id, {
  type = "key",
  kind = "sign_public",
}, request.body.public_key)


return { }
