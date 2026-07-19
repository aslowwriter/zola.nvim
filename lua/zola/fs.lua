local M = {}

local Path = require 'plenary.path'

---creates a randomly named dir in the /tmp folder
---used for testing
---@return Path|nil
function M._new_tmp_path()
    local name = ''
    for _ = 1, 10 do
        name = name .. string.char(math.random(65, 90))
    end

    local tmp_path = Path:new(Path:new('/tmp/zola_nvim_testing/' .. name):normalize())
    if tmp_path:mkdir { parents = true } then
        return tmp_path
    else
        return nil
    end
end

function M.discover_shortcode_dir(path)
    local dir = Path:new(path)
    local shortcode_dir = dir:joinpath 'templates/shortcodes'
    if shortcode_dir:is_dir() then
        return shortcode_dir
    else
        return nil
    end
end

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

---comment
---@param slug any
---@param kind any
---@param page_is_dir any
---@return string
function M.filepath_from_slug(content_dir, slug, kind, page_is_dir)
    local path = Path:new(content_dir):joinpath(slug)

    if kind == 'section' then
        return path:joinpath('_index.md').filename
    elseif kind == 'page' then
        if page_is_dir then
            return path:joinpath('index.md').filename
        else
            return path.filename .. '.md'
        end
    else
        error('unknown kind: ' .. kind)
    end
end

return M
