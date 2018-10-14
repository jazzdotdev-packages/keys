event: ["witness_request"]
priority: 1

local fs = require "fs"
local split_yaml_header = (require "helpers").split_yaml_header

-- Find the keypair with highest priority

local highest_priority = 0
local private_key = nil
local public_uuid = nil

for _, file_id in ipairs(fs.get_all_files_in("content/")) do

  local file_content = fs.read_file("content/" .. file_id)
  if not file_content then
    log.error("could not open " .. file_id)
  end

  local header, content = split_yaml_header(file_content)

  if header.type == "key"
  and header.kind == "sign_private"
  and header.priority > highest_priority
  then
    highest_priority = header.priority
    private_key = content
    public_uuid = header.public_uuid
  end
end

if not private_key then
    log.error("no sign key exists")
    return {
        headers = {
            ["content-type"] = "application/json",
        },
        status = 404,
        body = '{"error": "Couldn\'t sign the file"}',
    }
end

local public_key
do
  local file_content = fs.read_file("content/" .. public_uuid)
  local header, content = split_yaml_header(file_content)
  public_key = content
end

local keypair = crypto.sign.load_keypair(private_key, public_key)

-- Reading the file to sign

local type, id = request.path_segments[1], request.path_segments[2]
local filename = "content/" .. id
local file_content = fs.read_file(filename)

if not file_content then
    log.warn("could not open file " .. filename)
    return {
        headers = {
            ["content-type"] = "application/json",
        },
        status = 404,
        body = '{"error": "Document not found"}',
    }
end

local signature = keypair:sign_detached(file_content)

log.debug("file signature", signature)

return {
    headers = {
        ["content-type"] = "application/json",
    },
    body = '{"signature":"' .. signature .. '"}'
}
