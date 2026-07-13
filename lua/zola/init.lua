---@class zola_plugin
local M = {}

--- Plugin configuration defaults.
M.config = {
    page_defaults = { -- any options used when creating new pages (zola.nvim only)
        page_is_dir = true, -- pages are located at page-slug/index.md instead of page-slug.md
        force = false, -- continue and oferwrite files it already exists at provided path
        draft = false, -- mark created page as draft
        open = true, -- open the new page file in a new neovim buffer
    },
    section_defaults = { -- any options used when creating new sections (zola.nvim only)
        force = false, -- continue and overwrite if specified path already exists
        draft = false, -- mark created section as draft
        open = false, -- open the _index.md of new section in a new buffer
    },
}

--- Setup user configuration, merging with defaults.
---@param user_config table|nil
function M.setup(user_config)
    M.config = vim.tbl_deep_extend('force', M.config, user_config or {})
end

--- Determine if a folder is a Zola site.
---@param root string|nil
---@return boolean
function M.is_zola_site(root)
    local site_utils = require 'zola.site'
    return site_utils._discover_config_file(root) ~= nil and site_utils._discover_content_folder(root) ~= nil
end

--- Create a new section with _index.md in the content folder.
---@param opts {slug: string, root?: string, force?: boolean, draft?: boolean, open?: boolean, date?: boolean}
function M.create_section(opts)
    vim.validate { path = { opts.slug, 'string' } }
    local Path = require 'plenary.path'

    local used_opts = vim.tbl_deep_extend('force', opts, M.config.section_defaults)

    local content_folder = require('zola.site')._discover_content_folder(used_opts.root)
    if not content_folder then
        return vim.notify('Could not determine content folder.', vim.log.levels.ERROR)
    end

    local section_path = Path:new(content_folder):joinpath(used_opts.slug)
    if section_path:exists() and not used_opts.force then
        return vim.notify('Section already exists!', vim.log.levels.ERROR)
    end

    if used_opts.force and section_path:exists() then
        vim.uv.fs_rmdir(section_path:absolute())
    end
    vim.uv.fs_mkdir(section_path:absolute(), 493) -- permission 0755

    local final_path = section_path:joinpath '_index.md'
    require('zola.utils')._write_to_file(final_path:absolute(), require('zola.content')._render_front_matter(used_opts.draft))

    if used_opts.open then
        vim.cmd('e ' .. final_path:absolute())
        require('zola.content')._put_cursor_at_title()
    end
end

--- Create a new page in the content folder.
---@param opts { slug: string, root?: string, force?: boolean, draft?: boolean, open?: boolean, page_is_dir?: boolean }
function M.create_page(opts)
    vim.validate { slug = { opts.slug, 'string' } }
    local Path = require 'plenary.path'

    local used_opts = vim.tbl_deep_extend('force', opts, M.config.page_defaults)

    local content_folder = require('zola.site')._discover_content_folder(used_opts.root)
    if not content_folder then
        return vim.notify('Could not determine content folder.', vim.log.levels.ERROR)
    end

    local page_path = Path:new(content_folder):joinpath(used_opts.slug)
    local final_path = page_path

    if used_opts.page_is_dir then
        if page_path:exists() and not used_opts.force then
            return vim.notify('Page directory already exists!', vim.log.levels.ERROR)
        elseif page_path:exists() then
            vim.uv.fs_unlink(page_path:absolute())
        end

        vim.uv.fs_mkdir(page_path:absolute(), 493)
        final_path = page_path:joinpath 'index.md'
    else
        -- Note: Path.filename returns the full path string in plenary
        if not page_path.filename:match '.md$' then
            final_path = Path:new(page_path.filename .. '.md')
        end
    end

    require('zola.utils')._write_to_file(final_path:absolute(), require('zola.content')._render_front_matter(used_opts.draft))

    if used_opts.open then
        vim.cmd('e ' .. final_path:absolute())
        require('zola.content')._put_cursor_at_title()
    end
end
return M
