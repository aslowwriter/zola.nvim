local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

local T = new_set()

T['front_matter'] = new_set()

-- Actual tests definitions will go here
T['front_matter']['respects `config` argument'] = function()
    eq('===','+++')
end
T['front_matter']['respects `config` argument 2'] = function()
    eq('===','+++')
end

return T
