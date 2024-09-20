-- Function to automatically encode and replace a substring
---@param original string
---@param replace_pattern string
---@param replace_with string
---@return string
local function replace_string(original, replace_pattern, replace_with)
    local encoded_pattern = replace_pattern:gsub("[%p%c%s]", "%%%0")
    local result = original:gsub(encoded_pattern, replace_with)
    return result
end

return replace_string
