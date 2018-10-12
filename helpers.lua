
local exports = {}

local fs = require "fs"
local split_yaml_header = (require "helpers").split_yaml_header

function exports.iter_content_files_of (profile, fn)
  local dir = "content/" .. profile .. "/"

  for _, file_uuid in ipairs(fs.get_all_files_in(dir)) do
    local path = dir .. file_uuid
    local file_content = fs.read_file(path)
    if not file_content then
      log.error("could not open " .. path)
    end

    local header, content = split_yaml_header(file_content)

    local result = fn(file_uuid, header, content)
    if result then return result end
  end
end

return exports
