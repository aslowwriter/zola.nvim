local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local render_front_matter = require('zola.front_matter').render_front_matter

local T = new_set()
local today = os.date '%Y-%m-%d'

T['basic'] = new_set()

T['basic']['render basic header no args'] = function()
    local header, _, _ = render_front_matter(false)
    local expected = { '+++', 'title = ""', 'date = ' .. today, '', '+++', '' }
    eq(header, expected)
end

T['basic']['render basic header with args'] = function()
    local header, _, _ = render_front_matter(true)
    local expected = { '+++', 'title = ""', 'date = ' .. today, 'draft = true', '', '+++', '' }
    eq(header, expected)
end

T['basic']['basic render puts cursor between quotes'] = function()
    local header, row, col = render_front_matter(true)
    local rendered_title_line = header[row]
    assert(rendered_title_line:find '^title%s*=')

    eq(string.sub(rendered_title_line, col, col), '"')
    eq(string.sub(rendered_title_line, col + 1, col + 1), '"')
end
T['basic']['render draft header'] = function()
    local header, _, _ = render_front_matter(true)
    local expected = { '+++', 'title = ""', 'date = ' .. today, 'draft = true', '', '+++', '' }

    eq(header, expected)
end

T['taxonomy'] = new_set()

T['taxonomy']['empty taxonomy table does not add header'] = function()
    local header, _, _ = render_front_matter(false, {})
    local expected = { '+++', 'title = ""', 'date = ' .. today, '', '+++', '' }

    eq(header, expected)
end
T['taxonomy']['nil taxonomy table does not add header'] = function()
    local header, _, _ = render_front_matter(false, nil)
    local expected = { '+++', 'title = ""', 'date = ' .. today, '', '+++', '' }

    eq(header, expected)
end

T['taxonomy']['empty taxonomy still adds it'] = function()
    local header, _, _ = render_front_matter(false, { tags = {} })
    local expected = { '+++', 'title = ""', 'date = ' .. today, '', '[taxonomies]', 'tags = []', '', '+++', '' }

    eq(header, expected)
end

T['taxonomy']['empty string value still adds it'] = function()
    local header, _, _ = render_front_matter(false, { tags = '' })
    local expected = { '+++', 'title = ""', 'date = ' .. today, '', '[taxonomies]', 'tags = []', '', '+++', '' }

    eq(header, expected)
end

T['taxonomy']['taxonomy with values'] = function()
    local header, _, _ = render_front_matter(false, { tags = { 'nvim', 'testing' } })
    local expected = { '+++', 'title = ""', 'date = ' .. today, '', '[taxonomies]', 'tags = ["nvim", "testing"]', '', '+++', '' }

    eq(header, expected)
end

T['taxonomy']['multiple taxonomies'] = function()
    local header, _, _ = render_front_matter(false, { tags = { 'nvim', 'testing' }, categories = { 'tutorial' } })
    local expected = {
        '+++',
        'title = ""',
        'date = ' .. today,
        '',
        '[taxonomies]',
        'categories = ["tutorial"]',
        'tags = ["nvim", "testing"]',
        '',
        '+++',
        '',
    }

    eq(header, expected)
end

return T
