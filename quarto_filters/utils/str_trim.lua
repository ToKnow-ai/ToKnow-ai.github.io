---str_trim
---@param str string
---@return string
local function str_trim(str)
    -- Replace leading whitespace
    local _str, _ = str:gsub("^%s+", "")
    -- Replacecount trailing whitespace
    local _str_, _  = _str:gsub("%s+$", "")
    return _str_
end

return str_trim