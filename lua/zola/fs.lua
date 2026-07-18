local M = {}

local Path = require 'plenary.path'

---check for known zola config files and if it finds any
---return the path to the found file
---nil if nothing is foind
---@param path string|Path
---@return Path|nil
function M.discover_config_file(path)
    local dir = Path:new(path)

    for _, filename in pairs { 'zola.toml', 'config.toml' } do
        local p = dir:joinpath(filename)

        if p:is_file() then
            return p
        end
    end
    return nil
end

---check if the provided path has a content subfolder
---and returns the absolute path to it if it is found
---@param path string|Path
---@return Path|nil
function M.discover_content_dir(path)
    local dir = Path:new(path)
    local content_dir = dir:joinpath 'content'
    if content_dir:is_dir() then
        return content_dir
    else
        return nil
    end
end

function M.write_to_file(path, content)
    local p
    if type(path) == 'table' then
        p = path.filename
    else
        p = path
    end

    local file = io.open(p, 'w')
    if file == nil then
        error 'could not open file'
    end
    if content then
        file:write(content)
    end
    file:close()
    return 0
end

return M
