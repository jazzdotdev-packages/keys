event: ["send_key"]
priority: 1

local fs = require "fs"
local split_yaml_header = (require "helpers").split_yaml_header

-- Find the keypair with highest priority

local highest_priority = 0
local private_key = nil
local public_uuid = nil

log.trace("Looking the files")

for _, file_id in ipairs(fs.get_all_files_in("content/")) do

  log.trace("id", file_id)

  local file_content = fs.read_file("content/" .. file_id)
  if not file_content then
    log.error("could not open " .. file_id)
  end


  local header, content = split_yaml_header(file_content)

  log.trace(header, content)

  if header.type == "key"
  and header.kind == "sign_private"
  and header.priority > highest_priority
  then
    highest_priority = header.priority
    private_key = content
    public_uuid = header.public_uuid
  end
end

log.trace("Checking key existence")

if not private_key then
    log.error("no sign key exists")
    return {
        headers = {
            ["content-type"] = "application/json",
        },
        status = 404,
        body = '{"error": "Couldn\'t find private key"}',
    }
end

local public_key
do
  local file_content = fs.read_file("content/" .. public_uuid)
  local header, content = split_yaml_header(file_content)
  public_key = content
end

local port = req.path_segments[2]

log.info("sending public key", public_key, "to port", port)

local new_todo = ClientRequest.build()
    :method("POST")
    :uri("http://localhost:" .. port .. "/")
    :headers({
      ["content-type"] = "application/json",
      ["lighttouch-identity"] = "alice",
    })
    :send_with_body('{"title":"recieved key","type":"key","text":"' .. public_key .. '"}')

return {
    headers = {
        ["content-type"] = "application/json",
    },
    body = '{"message":"key sent"}'
}