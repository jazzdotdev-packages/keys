event: ["send_profile_and_key"]
priority: 1

local fs = require "fs"
local split_yaml_header = (require "helpers").split_yaml_header

local profile
local pub_key

local home_dir = "content/home/"
for _, file_id in ipairs(fs.get_all_files_in(home_dir)) do

  local path = home_dir .. file_id
  log.trace("checking file", path)

  local file_content = fs.read_file(path)
  if not file_content then
    log.error("could not open " .. path)
  end

  local header, content = split_yaml_header(file_content)

  if header.type == "key" and header.kind == "sign_public" then
    pub_key = content
  end

  if header.type == "profile" then
    profile = header
    profile.uuid = file_id
  end
end

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

local target_uuid = req.path_segments[2]

local target_dir = "content/" .. target_uuid .. "/"
log.debug("target dir", target_dir)

local target_host

for _, file_id in ipairs(fs.get_all_files_in(target_dir)) do

  local path = target_dir .. file_id
  local file_content = fs.read_file(path)
  if not file_content then
    log.error("could not open " .. path)
  end

  local header, content = split_yaml_header(file_content)

  if header.type == "place" then
    target_host = header.host
  end
end

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

local new_todo = ClientRequest.build()
    :method("POST")
    :uri(target_host .. "jade_new_profile")
    :headers({
      ["content-type"] = "application/json",
    })
    :send_with_body('{"uuid":"' .. profile.uuid .. '","name":"' .. profile.name .. '","public_key":"' .. pub_key .. '"}')

return {
    headers = {
        ["content-type"] = "application/json",
    },
    body = '{"message":"data sent","host":"' .. target_host .. '"}'
}
