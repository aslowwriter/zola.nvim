local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local fs = require 'zola.fs'
local Path = require 'plenary.path'

local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set {
    hooks = {
        pre_case = function()
            -- Restart child process with custom 'init.lua' script
            child.restart { '-u', 'scripts/minimal_init.lua' }
            child.bo.readonly = false
            child.lua [[M = require('zola')]]
            -- Load tested plugin
        end,
        -- Stop once all test cases are finished
        post_once = child.stop,
    },
}

T['create'] = new_set()

T['create']['create page'] = function()
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

    -- slightly cheating but I can't get it to work otherwise :/
    child.lua('require("zola").runtime.content_dir = "' .. tmp_dir.filename .. '/content"')
    child.lua 'require("zola").create{ slug="colours/blue", kind="page", page_is_dir=false, prefix="blog"}'

    eq(child.fn.mode(), 'i')

    local path = Path:new(Path:new(tmp_dir):joinpath 'content/colours/blue.md')
    eq(path:exists(), true)

    local child_col = child.api.nvim_win_get_cursor(0)[2]
    eq(child.api.nvim_get_current_line(), 'title = ""')
    eq(child_col, 9)
end
T['create']['create page'] = function()
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

    -- slightly cheating but I can't get it to work otherwise :/
    child.lua('require("zola").runtime.content_dir = "' .. tmp_dir.filename .. '/content"')
    child.lua 'require("zola").create{ slug="colours/blue", kind="page", page_is_dir=false, prefix="blog"}'

    eq(child.fn.mode(), 'i')

    local path = Path:new(Path:new(tmp_dir):joinpath 'content/colours/blue.md')
    eq(path:exists(), true)

    local child_col = child.api.nvim_win_get_cursor(0)[2]
    eq(child.api.nvim_get_current_line(), 'title = ""')
    eq(child_col, 9)
end

return T
