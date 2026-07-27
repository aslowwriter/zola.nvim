local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local source = require 'zola.sources.taxonomies'
local fs = require 'zola.fs'
local Path = require 'plenary.path'
local T = new_set()

T['taxonomies'] = new_set()

T['taxonomies']['should show'] = new_set()

T['taxonomies']['should show']['long line no trigger'] = function()
    local line =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. In hendrerit venenatis vehicula. Proin nisl purus, rutrum eu justo consectetur, dapibus aliquam dui. Aliquam erat volutpat. Curabitur porttitor consequat tincidunt. Suspendisse vehicula, nisl sit amet varius posuere, ante erat consequat velit, ac pellentesque nulla nisl non nulla. Sed quis lectus ac magna euismod gravida. Interdum et malesuada fames ac ante ipsum primis in faucibus. Quisque lacinia sagittis laoreet. Etiam ullamcorper sapien risus, nec consequat velit convallis sit amet. Etiam feugiat ultricies est vitae posuere|.'
    local start_col, _ = string.find(line, '|')

    local known_taxonomies = { 'tags' }
    local expected = nil

    local result = source.relevant_taxonomy(line, start_col, known_taxonomies)

    eq(expected, result)
end

T['taxonomies']['should show']['single open tag'] = function()
    local line = 'tags =[|'
    local start_col, _ = string.find(line, '|')
    local known_taxonomies = { 'tags' }

    local expected = 'tags'

    local result = source.relevant_taxonomy(line, start_col, known_taxonomies)

    eq(expected, result)
end

T['taxonomies']['should show']['unknown taxonomy'] = function()
    local line = 'asdf = [|'
    local start_col, _ = string.find(line, '|')
    local known_taxonomies = { 'tags' }

    local expected = nil

    local result = source.relevant_taxonomy(line, start_col, known_taxonomies)

    eq(expected, result)
end
T['taxonomies']['should show']['past closed tag'] = function()
    local line = 'tags =[] |'
    local start_col, _ = string.find(line, '|')
    local known_taxonomies = { 'tags' }

    local expected = nil

    local result = source.relevant_taxonomy(line, start_col, known_taxonomies)

    eq(expected, result)
end
return T
