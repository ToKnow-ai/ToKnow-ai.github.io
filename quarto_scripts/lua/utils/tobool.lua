
local str_trim = require "utils.str_trim"

---str_trim
---@param value pandoc.MetaBlocks|any
---@return boolean
local function tobool(value)
    local bool_str = str_trim(string.lower(pandoc.utils.stringify(value or '') or ''))
    return bool_str == 'true' or tonumber(bool_str) == 1
end

return tobool