local str_starts_with = require "utils.str_starts_with"
local notebook_special_comments_walker = require "utils.notebook_special_comments_walker"
local echo_output_when_format = require "utils.echo_output_when_format"

local format_with_template = 'echo-when-format-'

---predicate
---@param k string - key from the div.attr.attributes: table<string, string>
---@return boolean
local function predicate(k)
  return str_starts_with(k, 'echo-when-format')
end

return notebook_special_comments_walker(
  predicate, 
  echo_output_when_format(format_with_template))
