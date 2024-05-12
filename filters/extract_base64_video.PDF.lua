local str_ends_with = require "utils.str_ends_with"

-- Function to extract base64 video
---@param block pandoc.CodeBlock
---@return pandoc.CodeBlock
local function extract_base64_video(block)
  if not (str_ends_with(quarto.doc.input_file, ".ipynb")) then
    return block
  end
  
  if not quarto.doc.is_format('pdf') then
    return block
  end
  
  if not (block.text == "<IPython.core.display.HTML object>") then
    return block
  end
  
  return pandoc.CodeBlock("WE CANT SHOW A VIDEO HERE, GO TO YOUTUBE!")
end

return {
  ['CodeBlock'] = extract_base64_video
} 