utils = require('utils')

-- table comparison
do 
    local x = {1, 2, 3}    
    local y = {1, 2, 3}    
    assert(utils.compare_tables(x, y))
    
    x[2] = -1
    assert(not utils.compare_tables(x, y))

    local x = {1, 2, 3}
    local y = {1, 2, 3, 4}
    assert(not utils.compare_tables(x, y))
end

-- table range function
do
    local x = utils.range(10)
    local y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    assert(utils.compare_tables(x, y))

    local x = utils.range(2, 5)
    local y = {2, 3, 4, 5}
    assert(utils.compare_tables(x, y))

    local x = utils.range(3, 8, 2)
    local y = {3, 5, 7}
    assert(utils.compare_tables(x, y))

    local x = utils.range(3, 13, 3)
    local y = {3, 6, 9, 12}
    assert(utils.compare_tables(x, y))
end

-- table reduce function
do
    local x = utils.range(36)
    local x_sum = utils.reduce(function(a, b) return a+b end, x)
    assert(x_sum == 666)

    local x = utils.range(5)
    local acc = 10
    local x_fac = utils.reduce(function (a, b) return a*b end, x, acc)
    assert(x_fac == 1200)

end


print('Test passed')
