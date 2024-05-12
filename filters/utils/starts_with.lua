local function starts_with(str, start_str) 
    return str:find('^' .. start_str) ~= nil
end

return starts_with