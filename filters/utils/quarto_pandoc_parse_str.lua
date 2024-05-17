local notebook_special_comments_walker = require "utils.notebook_special_comments_walker"

-- Function to Parse a string into pandoc.Blocks
-- The reason we have this utility function is because when we have `{{< meta value >}}` in the string remplate.
-- Its possible to escape the special comments but its tricky when used in attributes: 
--`#|output-when-format-pdf: "Please visit <https://toknow.ai> to view the plot. {{< meta href >}}"`
-- <https://quarto.org/docs/authoring/variables.html>
---@param template_str string
---@return pandoc.Blocks
local function quarto_pandoc_parse_str(template_str)
  local template_doc = pandoc.read(template_str, 'markdown')
  -- quarto.log.debug('template_doc', template_doc)
  local new_doc = template_doc:walk (notebook_special_comments_walker(
    'data-raw',
    ---@param data_raw string
    ---@param block pandoc.Block
    ---@return pandoc.Blocks
    function (data_raw, block)
      -- if data_raw == 'meta' then
      --   return block
      -- end

      quarto.log.debug('data_raw', data_raw, template_str, block)
      return pandoc.Plain(data_raw)
    end))
  local clean_template = pandoc.utils.stringify(new_doc)
  local blocks = quarto.utils.string_to_blocks(clean_template)
  quarto.log.debug('clean_template', clean_template)
  return blocks
end

return quarto_pandoc_parse_str