local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local fs = require 'zola.fs'

local T = new_set()

T['site detection'] = new_set()

T['site detection']['empty dir has no config'] = function()
    local tmp_path = fs._new_tmp_path()
    if tmp_path == nil then
        error 'could not create tmp dir'
    end

    eq(fs.discover_config_file(tmp_path), nil)
    eq(fs.discover_content_dir(tmp_path), nil)
end

T['site detection']['site with zola.toml'] = function()
    local tmp_path = fs._new_tmp_path()
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
    local tmp_path = fs._new_tmp_path()
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

T['file creation'] = new_set()

T['file creation']['page file path from slug no page_is_dir'] = function()
    local slug = 'foo/bar/arf/mew'

    local file_path = fs.filepath_from_slug('content', slug, 'page', false)
    local expected = 'content/foo/bar/arf/mew.md'
    eq(file_path, expected)
end

T['file creation']['page file path from slug page_is_dir'] = function()
    local slug = 'foo/bar/arf/mew'

    local file_path = fs.filepath_from_slug('content', slug, 'page', true)
    local expected = 'content/foo/bar/arf/mew/index.md'
    eq(file_path, expected)
end

T['file creation']['section file path from slug no page_is_dir'] = function()
    local slug = 'foo/bar/arf/mew'

    local file_path = fs.filepath_from_slug('content', slug, 'section', false)
    local expected = 'content/foo/bar/arf/mew/_index.md'
    eq(file_path, expected)
end

T['file creation']['section file path from slug page_is_dir'] = function()
    local slug = 'foo/bar/arf/mew'

    local file_path = fs.filepath_from_slug('content', slug, 'section', true)
    local expected = 'content/foo/bar/arf/mew/_index.md'
    eq(file_path, expected)
end

return T
