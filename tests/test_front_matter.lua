local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

local render_front_matter = require('zola.front_matter').render_front_matter

local T = new_set()
local today = os.date '%Y-%m-%d'

T['basic'] = new_set()

T['basic']['render basic header no args'] = function()
    local header, _, _ = render_front_matter(false)
    local expected = { '+++', 'title = ""', 'date = ' .. today, '+++', '' }
    eq(header, expected)
end

T['basic']['render basic header with args'] = function()
    local header, _, _ = render_front_matter(true)
    local expected = { '+++', 'title = ""', 'date = ' .. today, 'draft = true', '+++', '' }
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
    local expected = { '+++', 'title = ""', 'date = ' .. today, 'draft = true', '+++', '' }

    eq(header, expected)
end

return T
