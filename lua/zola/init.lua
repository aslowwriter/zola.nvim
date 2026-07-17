M = {}

M.config = {
    draft_by_default = false, -- if true newly created pages and sections are marked as drafts
    page_is_dir = false, -- if true pages are located at `slug/index.md` instead of `slug.md`
}

M.setup = function(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

return M
