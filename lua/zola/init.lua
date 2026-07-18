M = {}

local fs = require 'zola.fs'

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

return M
