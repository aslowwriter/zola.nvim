local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local fs = require 'zola.fs'
local Path = require 'plenary.path'

local T = new_set()

local function new_tmp_path()
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

T['site detection'] = new_set()

T['site detection']['empty dir has no config'] = function()
    local tmp_path = new_tmp_path()
    if tmp_path == nil then
        error 'could not create tmp dir'
    end

    eq(fs.discover_config_file(tmp_path), nil)
    eq(fs.discover_content_dir(tmp_path), nil)
end

T['site detection']['site with zola.toml'] = function()
    local tmp_path = new_tmp_path()
    if tmp_path == nil then
        error 'could not create tmp dir'
    end

    local tmp_content_dir = tmp_path:joinpath 'content'
    tmp_content_dir:mkdir()

    local tmp_config_file = tmp_path:joinpath 'zola.toml'
    local write_result = fs.write_to_file(tmp_config_file)
    eq(write_result, 0)

    eq(fs.discover_config_file(tmp_path).filename, tmp_config_file.filename)
    eq(fs.discover_content_dir(tmp_path).filename, tmp_content_dir.filename)
end

T['site detection']['site with config.toml'] = function()
    local tmp_path = new_tmp_path()
    if tmp_path == nil then
        error 'could not create tmp dir'
    end

    local tmp_content_dir = tmp_path:joinpath 'content'
    tmp_content_dir:mkdir()

    local tmp_config_file = tmp_path:joinpath 'config.toml'
    local write_result = fs.write_to_file(tmp_config_file)
    eq(write_result, 0)

    eq(fs.discover_config_file(tmp_path).filename, tmp_config_file.filename)
    eq(fs.discover_content_dir(tmp_path).filename, tmp_content_dir.filename)
end

return T
