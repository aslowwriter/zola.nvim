local M = {}

local Path = require 'plenary.path'

--- Discover Zola config.toml in project root.
---@param root string|nil, the path to search. cwd will be used if nil
---@return Path|nil the path of the config.toml if found, nil otherwise
function M._discover_config_file(root)
    local project_root = M._strip_trailing_slash(root or vim.fn.getcwd())
    local root_path = Path:new(project_root)

    local config_path = root_path:joinpath 'config.toml'
    if config_path:is_file() then
        return config_path
    end

    config_path = root_path:joinpath 'zola.toml'
    if config_path:is_file() then
        return config_path
    end

    return nil
end

--- Discover Zola content folder in project root.
---@param root string|nil, the path to search. cwd will be used if nil
---@return Path|nil the path of the content folder if found, nil otherwise
function M._discover_content_folder(root)
    local project_root = M._strip_trailing_slash(root or vim.fn.getcwd())
    local content_path = Path:new(project_root):joinpath 'content'
    return content_path:is_dir() and content_path or nil
end

--- Strip trailing slashes from a path safely.
---@param path string the string to strip
---@return string the string with any potential trailing / removed
function M._strip_trailing_slash(path)
    if path == '/' then
        return path
    end
    local stripped = path:gsub('/*$', '')
    return stripped
end

--- Write content to file at given path.
---@param path string the path where to write the file
---@param content string the text that should be written to the file.
---@return boolean indicating success of the operation
function M._write_to_file(path, content)
    local fd, err = vim.uv.fs_open(path, 'w', 420) -- permission 0644
    if not fd then
        vim.notify('Failed to open file: ' .. err, vim.log.levels.ERROR)
        return false
    end

    local ok, write_err = vim.uv.fs_write(fd, content, -1)
    vim.uv.fs_close(fd)
    if not ok then
        vim.notify('Failed to write file: ' .. write_err, vim.log.levels.ERROR)
        return false
    end

    return true
end

return M
