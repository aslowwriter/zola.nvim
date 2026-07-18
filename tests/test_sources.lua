local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local source = require 'zola.sources.content_paths'
local fs = require 'zola.fs'
local Path = require 'plenary.path'
local T = new_set()

T['content_paths'] = new_set()

T['content_paths']['. is root label'] = function()
    local expected = 'root'
    local input = '.'
    local output = source._label_from_rel_path(input)
    eq(output, expected)
end

T['content_paths']['root content_paths label'] = function()
    local expected = 'root'
    local input = '_index.md'
    local output = source._label_from_rel_path(input)
    eq(output, expected)
end

T['content_paths']['label page file'] = function()
    local expected = 'foo/bar/baz'
    local input = 'foo/bar/baz.md'
    local output = source._label_from_rel_path(input)
    eq(output, expected)
end

T['content_paths']['label of page dir'] = function()
    local expected = 'foo/bar/baz'
    local input = 'foo/bar/baz/index.md'
    local output = source._label_from_rel_path(input)
    eq(output, expected)
end

T['content_paths']['label for random path is untouched'] = function()
    local input = 'foo/bar/baz/arf/mew.toml'
    local expected = input
    local output = source._label_from_rel_path(input)

    eq(output, expected)
end
T['content_paths']['label _index.md as part of path'] = function()
    local expected = 'foo/_index.md/baz'
    local input = 'foo/_index.md/baz'
    local output = source._label_from_rel_path(input)
    eq(output, expected)
end
T['content_paths']['section'] = function()
    local expected = 'foo/bar/baz'
    local input = 'foo/bar/baz/_index.md'
    local output = source._label_from_rel_path(input)
    eq(output, expected)
end

T['content_paths']['glob finds all necessary files, no dirs'] = function()
    local tmp_dir = fs._new_tmp_path()

    for _, file in ipairs {
        'content/_index.md',
        'content/page.md',
        'content/foo/bar/arf/mew/index.md',
        'content/foo/bar/arf/mew/configl.toml',
        'content/foo/bar/arf/mew/pic.jpg',
        'content/foo/bar/arf/mew/bs.json',
    } do
        local path = Path:new(tmp_dir:joinpath(file))

        local parent = Path:new(path:parent())

        parent:mkdir { parents = true, exists_ok = true }

        fs.write_to_file(path)
    end

    local found_files = source._discover_files(tmp_dir)

    local expected_files = {
        tmp_dir.filename .. '/content/_index.md',
        tmp_dir.filename .. 'content/page.md',
        tmp_dir.filename .. 'content/foo/bar/arf/mew/bs.json',
        tmp_dir.filename .. 'content/foo/bar/arf/mew/configl.toml',
        tmp_dir.filename .. 'content/foo/bar/arf/mew/pic.jpg',
        tmp_dir.filename .. 'content/foo/bar/arf/mew/index.md',
    }
    found_files = table.sort(found_files)
    expected_files = table.sort(expected_files)
    eq(found_files, expected_files)
end

return T
