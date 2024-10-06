local is_output_cell = require "utils.is_output_cell"
local ternary = require "utils.ternary"

return {
  ---@param block pandoc.Block
  ---@diagnostic disable-next-line: undefined-doc-name
  ---@return pandoc.Block|pandoc.Null
  Block = function(block)
    if is_output_cell(block) and block['walk'] then
      local unable_to_display = false
      ---@diagnostic disable-next-line: undefined-field
      block:walk {
        ---@param sub_block pandoc.CodeBlock
        ---@return nil
        Block = function (sub_block)
          local text = ternary(
            -- https://github.com/jgm/pandoc/issues/6456
            sub_block.tag == "CodeBlock", 
            sub_block.text, 
            pandoc.utils.stringify(sub_block))
          if text then
            local match = string.match(
              text:lower(), 
              string.lower("^Unable to display output for mime type"))
            if match then
              unable_to_display = true
            end
          end
        end
      }
      if unable_to_display then
        return pandoc.Null()
      end
    end
    return block
  end,

  -- ---@param block pandoc.CodeBlock
  -- ---@return nil
  -- Block = function(block)
  --   local text = ternary(
  --   -- https://github.com/jgm/pandoc/issues/6456
  --     block.tag == "CodeBlock",
  --     block.text,
  --     pandoc.utils.stringify(block))
  --   if text then
  --     local match = string.match(
  --       text:lower(),
  --       string.lower("^Unable to display output for mime type"))
  --     if match then
  --       return pandoc.Null()
  --     end
  --   end
  --   return block
  -- end
}