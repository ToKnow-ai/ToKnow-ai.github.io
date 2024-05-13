local str_ends_with = require "utils.str_ends_with"
local notebook_div_walk = require "utils.notebook_div_walk"
local str_starts_with = require "utils.str_starts_with"
local quarto_pandoc_parse_str = require "utils.quarto_pandoc_parse_str"

local format_with_template = 'output-when-format-'

-- Function to manage output for given format:
--    - Replace the current block, if the format is matched!
--    - Include the current block as is, if the format is matched!
-- A complement for: https://quarto.org/docs/authoring/conditional.html#format-matching
-- Usage:   #|output-when-format: "{format}"              =>  #|output-when-format: "html"
--          #|output-when-format-{format}: "{template}"   =>  #|output-when-format-pdf: "[text](link)"
---@param div pandoc.Div
---@param key_template_format table<"key"|"value", string>
---@return pandoc.List
local function output_when_format(div, key_template_format)
  if not (str_ends_with(quarto.doc.input_file, ".ipynb")) then
    return div
  end
  local format = key_template_format.key
  local template = key_template_format.value
  local template_blocks = pandoc.List:new {}
  if str_starts_with(format, format_with_template) then
    format = string.sub(format, #format_with_template + 1)
    if quarto.doc.is_format(format) then
      if template then
        -- This replaces the current block, if the format is matched!
        template_blocks = quarto_pandoc_parse_str(template)
      end
    end
  else
    format = template
    if quarto.doc.is_format(format) then
      -- This includes the current block as is, if the format is matched!
      template_blocks:insert(div)
    end
  end
  return template_blocks
end

---predicate
---@param k string - key from the div.attr.attributes: table<string, string>
---@param v string - value from the div.attr.attributes: table<string, string>
---@return table|boolean
local function predicate(k, v)
  if str_starts_with(k, 'output-when-format') then
    return { ['key'] = k, ['value'] = v }
  end
  return false
end

return {
  ---@param div pandoc.Div
  ---@return pandoc.Div
  Div = function (div)
    return notebook_div_walk(predicate, div, output_when_format)
  end,
}
