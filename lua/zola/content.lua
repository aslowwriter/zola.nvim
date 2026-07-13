local M = {}

--- Render default TOML front matter for new content.
---@param draft boolean|nil should the content be marked as drafted
---@return string a string containing the front matter including separators to include in Zola content files
function M._render_front_matter(draft)
    local date = os.date '%Y-%m-%d'
    local lines = {
        '+++',
        'title = ""',
        'date = ' .. date,
    }

    if draft then
        table.insert(lines, 'draft = true')
    end

    vim.list_extend(lines, { '+++', '' })
    return table.concat(lines, '\n')
end

--- Determine the coordinates to place the cursor so the user can fill out the title in the front matter.
---@param lines string[] the text of the buffer, typically containing only the front matter
---@return integer|nil row
---@return integer|nil col
function M._calculate_cursor_pos(lines)
    for row, line in ipairs(lines) do
        local _, col = line:find 'title%s*=%s*()""'
        if col then
            return row, col
        end
    end

    return nil, nil
end

--- Put the cursor inside the empty title quotes in the front matter of the current buffer.
---@return boolean success whether the operation was successful
function M._put_cursor_at_title()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local row, col = M._calculate_cursor_pos(lines)

    if not row or not col then
        vim.notify('Could not determine title position in front matter.', vim.log.levels.WARN)
        return false
    end

    vim.api.nvim_win_set_cursor(0, { row, col })
    vim.api.nvim_feedkeys('i', 'n', false)
    return true
end

return M
