-- Function to Parse a string into pandoc.List
-- The reason we have this utility function is because when using to parse a string, we don't get {{< meta value>}}
-- but if we use quarto.utils.string_to_blocks, we get the value, but other undesired markdown in PDF
-- Test example: "Please visit <https://toknow.ai> to view the plot. {{< meta href >}}"
---@param template_str string
---@return pandoc.List
local function quarto_pandoc_parse_str(template_str)
  local blocks = quarto.utils.string_to_blocks(template_str)
  -- local doc = pandoc.Pandoc (blocks)
  -- local doc_str = pandoc.write(doc, 'markdown')
  -- local new_blocks = pandoc.read(doc_str, 'markdown').blocks
  return blocks
end

return quarto_pandoc_parse_str