local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local source = require 'zola.sources.shortcodes'
local fs = require 'zola.fs'
local Path = require 'plenary.path'
local T = new_set()

T['shorcodes'] = new_set()

T['shorcodes']['should show'] = new_set()

T['shorcodes']['should show']['empty line'] = function()
    local line = ''
    local start_col = 1

    local expected = false

    local result = source._should_show(line, start_col)

    eq(expected, result)
end

T['shorcodes']['should show']['long line no trigger'] = function()
    local line =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. In hendrerit venenatis vehicula. Proin nisl purus, rutrum eu justo consectetur, dapibus aliquam dui. Aliquam erat volutpat. Curabitur porttitor consequat tincidunt. Suspendisse vehicula, nisl sit amet varius posuere, ante erat consequat velit, ac pellentesque nulla nisl non nulla. Sed quis lectus ac magna euismod gravida. Interdum et malesuada fames ac ante ipsum primis in faucibus. Quisque lacinia sagittis laoreet. Etiam ullamcorper sapien risus, nec consequat velit convallis sit amet. Etiam feugiat ultricies est vitae posuere|.'
    local start_col, _ = string.find(line, '|')

    local expected = false

    local result = source._should_show(line, start_col)

    eq(expected, result)
end
T['shorcodes']['should show']['single open tag'] = function()
    local line = '{{|'
    local start_col, _ = string.find(line, '|')

    local expected = true

    local result = source._should_show(line, start_col)

    eq(expected, result)
end

T['shorcodes']['should show']['single closed tag'] = function()
    local line = '{{aside(|)}}'
    local start_col, _ = string.find(line, '|')

    local expected = false

    local result = source._should_show(line, start_col)

    eq(expected, result)
end
T['shorcodes']['should show']['past closed tag'] = function()
    local line = "{{aside(text='foo')}} |"
    local start_col, _ = string.find(line, '|')

    local expected = false

    local result = source._should_show(line, start_col)

    eq(expected, result)
end
T['shorcodes']['should show']['inside closed tag'] = function()
    local line = '{{aside(|)}} blah'
    local start_col, _ = string.find(line, '|')

    local expected = false

    local result = source._should_show(line, start_col)

    eq(expected, result)
end
T['shorcodes']['should show']['inside new closed tag'] = function()
    local line = "{{aside(text='asdf')}} blah {{|}}"
    local start_col, _ = string.find(line, '|')

    local expected = true

    local result = source._should_show(line, start_col)

    eq(expected, result)
end
return T
