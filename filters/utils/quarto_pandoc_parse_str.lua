-- Function to Parse a string into pandoc.Blocks
-- The reason we have this utility function is because when we have special coments in the string remplate,
-- quarto already parses the value of `{{< meta value >}}`. Its possible to escape
-- the special comments but its tricky when used in attributes: `#|output-when-format-pdf: "Please visit <https://toknow.ai> to view the plot. {{< meta href >}}"`
-- <https://quarto.org/docs/authoring/variables.html>
---@param template_str string
---@return pandoc.Blocks
local function quarto_pandoc_parse_str(template_str)
  local clean_template = pandoc.write(pandoc.read(template_str, 'markdown'), 'markdown')
  local blocks = quarto.utils.string_to_blocks(clean_template)
  return blocks
end

return quarto_pandoc_parse_str