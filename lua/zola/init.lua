M = {}

local fs = require 'zola.fs'
local render_front_matter = require('zola.front_matter').render_front_matter
local Path = require 'plenary.path'

M.config = {
    draft_by_default = false, -- if true newly created pages and sections are marked as drafts
    page_is_dir = false, -- if true pages are located at `slug/index.md` instead of `slug.md`
}

M.runtime = {}

M.setup = function(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})
    M.runtime.content_dir = fs.discover_content_dir(opts.root or vim.fn.getcwd())
    M.runtime.config_file = fs.discover_config_file(opts.root or vim.fn.getcwd())
end

function M.create(opts)
    vim.validate {
        slug = { opts.slug, 'string' },
        kind = { opts.kind, 'string' },
        draft = { opts.draft, 'boolean', true },
        page_is_dir = { opts.page_is_dir, 'boolean', true },
        taxonomies = { opts.taxonomies, 'table', true },
    }

    if M.runtime.content_dir == nil then
        vim.notify('Could not determine content folder, unable to create', vim.log.levels.ERROR)
        return
    end

    local page_is_dir = opts.page_is_dir or M.config.page_is_dir
    local draft = opts.draft or M.config.draft_by_default

    local file_path = Path:new(fs.filepath_from_slug(M.runtime.content_dir, opts.slug, opts.kind, page_is_dir))

    if file_path:exists() then
        vim.notify('file already exists, opening existing file...', vim.log.levels.WARN)
        vim.cmd('e ' .. file_path:absolute())
    else
        local front_matter, row, col = render_front_matter(draft, opts.taxonomies)
        local parent = file_path:parent()
        parent:mkdir { exists_ok = true, parents = true }
        fs.write_to_file(file_path.filename, table.concat(front_matter, '\n'))
        vim.cmd('e ' .. file_path:absolute())
        vim.api.nvim_win_set_cursor(0, { row, col })
        vim.api.nvim_feedkeys('i', 'n', false)
    end
end

function M.create_interactive(opts)
    local new_opts = opts
    vim.validate {
        kind = { new_opts.kind, 'string' },
    }
    vim.ui.input({ prompt = 'Enter slug: ' }, function(result)
        if not result then
            return
        end

        if opts.prefix then
            new_opts.slug = opts.prefix .. '/' .. result
        else
            new_opts.slug = result
        end

        new_opts.prefix = nil

        M.create(new_opts)
    end)
end

return M
