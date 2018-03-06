--- @module
local utils = {
    _DESCRIPTION = 'Several utility functions for lua (inspired by Python)'
}

-- return value of os.execute on successful execution
-- XXX: works only on Linux
utils.ok_return = os.execute('echo -n')


function utils.capture_output(cmd, raw)
    -- execute `cmd` and return output
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if not raw then
        s = string.gsub(s, '^%s+', '')
        s = string.gsub(s, '%s+$', '')
        s = string.gsub(s, '[\n\r]+', ' ')
    end
    return s
end

function utils.sleep(n)
    -- block for `n` seconds
    local cmd = string.format("sleep %.2f", n)
    local r = os.execute(cmd)
    if r ~= utils.ok_return then os.exit(2) end
end

function utils.get_tty_dim()
    -- get dimension of terminal in number of characters
    local lines = tonumber(utils.capture_output("tput lines"))
    local cols = tonumber(utils.capture_output("tput cols"))
    return lines, cols
end

function utils.progressbar(step, total)
    -- print progressbar across terminal in bottom line
    local _, cols = utils.get_tty_dim()
    local num_chars = math.floor(step / total * cols) - 1
    io.write('\r')
    for i = 1, num_chars do 
        io.write('=') 
    end
    io.write('>')
    io.flush()
end

function utils.reduce(fun, iter, acc)
    local start = acc and 1 or 2
    local acc = acc or iter[1]
    for i = start, #iter do
        acc = fun(acc, iter[i])
    end
    return acc
end

function utils.map(fun, iter)
    local out = {}
    for k, v in pairs(iter) do
        out[k] = fun(v)
    end
    return out
end

function utils.imap(fun, iter)
    local out = {}
    for k, v in ipairs(iter) do
        out[k] = fun(v)
    end
    return out
end

function utils.filter(fun, iter)
    local out = {}
    for k, v in pairs(iter) do
        if fun(v) then 
            table.insert(out, v)
        end
    end
    return out    
end

function utils.range(start, stop, step)
    -- simple range function for integer, positive steps

    if not stop then
        start, stop = 1, start
    end
    local step = step or 1

    local out = {}
    for i = start, stop, step do
        table.insert(out, i)
    end
    return out
end

function utils.arange(start, stop, step)
    -- better range function that can handle non-integer and negative values

    if not stop then
        start, stop = 1, start
    end
    local step = step or 1

    local out_table = {}
    
    if step > 0 then
        local current_val = start
        while current_val < stop do
            table.insert(out_table, current_val)
            current_val = current_val + step
        end
    elseif step < 0 then
        local current_val = stop
        while current_val > start do
            table.insert(out_table, current_val)
            current_val = current_val + step
        end
    end

    return out_table
end

function utils.linspace(start, stop, steps, endpoint)
    if endpoint == nil then endpoint = true end

    local stepsize
    if endpoint then
        stepsize = (stop - start) / (steps - 1)
    else
        stepsize = (stop - start) / steps
    end

    local out_table = {}

    for i = 0, steps - 1 do
        local val = start + i * stepsize
        table.insert(out_table, val)
    end

    return out_table 
end

function utils.compare_tables(t1, t2)
    -- compare two tables array-wise
    
    -- check if the same object
    if tostring(t1) == tostring(t2) then
        return true
    end    
    
    -- check for length
    if #t1 ~= #t2 then
        return false
    end 
    
    -- check each item (recursively if table)
    for i, v in ipairs(t1) do
        if type(v) == 'table' then
            if not utils.compare_tables(v, t2[i]) then
                return false
            end
        else
            if v ~= t2[i] then
                return false
            end
        end 
    end
    
    return true
end

function utils.copy(obj)
    -- recursively deepcopy table (without metatable)
    
    if type(obj) == 'table' then
        local new = {}
        for k, v in pairs(obj) do
            new[k] = utils.copy(v)
        end
        return new
    else
        return obj
    end
end

function utils.ndtable(val, dim)
    -- build multidimensional table of shape `dim` filled with `val` 

    if type(dim) == 'number' then
        dim = {dim}
    end

    local out_table = {}
    
    -- number of dimensions
    local ndim = #dim

    -- return table if one dimensional
    if ndim == 1 then
        for i = 1, dim[1] do
            out_table[i] = val
        end

    -- recursively build table if more dimensions
    else
        local sub_dim = utils.copy(dim)
        local this_len = table.remove(sub_dim, 1)
        for i = 1, this_len do
            out_table[i] = utils.ndtable(val, sub_dim)
        end
    end

    return out_table
end

return utils
