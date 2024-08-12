local function generate_unique_string(length)
    length = length or 10
    local seed = os.time() * 1000 + math.floor(os.clock() * 1000)
    math.randomseed(seed)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local rand = math.random(#chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

return generate_unique_string