M = {}

local function open_front_matter()
    return { '+++' }
end

local function append_draft(front_matter)
    table.insert(front_matter, 'draft = true')
    return front_matter
end

local function append_date(front_matter)
    local date = os.date '%Y-%m-%d'
    table.insert(front_matter, 'date = ' .. date )
    return front_matter
end

local function end_front_matter(front_matter)
    table.insert(front_matter, '+++')
    table.insert(front_matter, '')
    return front_matter
end

local function append_title(front_matter)
    table.insert(front_matter, 'title = ""')
    return front_matter
end

function M.render_front_matter(draft)
    local front_matter = open_front_matter()

    -- counted these out by hand
    local cursor_row = 2
    local cursor_col = 9

    front_matter = append_title(front_matter)
    front_matter = append_date(front_matter)

    if draft then
	front_matter = append_draft(front_matter)
    end

    front_matter = end_front_matter(front_matter)

    return front_matter, cursor_row, cursor_col
end

return M
