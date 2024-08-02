local generate_unique_string = function (length)
    length = (length == nil and 10) or length
    math.randomseed(os.time()) -- Initialize random seed
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    local charTable = {}
    for c in chars:gmatch"." do
        table.insert(charTable, c)
    end
    for i = 1, length do
        result = result .. charTable[math.random(1, #charTable)]
    end
    return result
end

return generate_unique_string