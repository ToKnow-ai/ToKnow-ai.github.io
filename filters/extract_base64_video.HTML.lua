local str_ends_with = require "utils.str_ends_with"

-- Function to extract base64 video
---@param block pandoc.RawBlock
---@return pandoc.RawBlock
local function extract_base64_video(block)
  if not (str_ends_with(quarto.doc.input_file, ".ipynb")) then
    return block
  end
  
  if not quarto.doc.is_format('html') then
    return block
  end

  if not (block.format == "html") then
    return block
  end

  if not (block.text:find('data:video/')) then
    return block
  end

  quarto.log.debug(block)
  
  video = quarto.utils.string_to_blocks("{{< video https://www.youtube.com/embed/wo9vZccmqwc >}}")
  return video
end

return {
  ['RawBlock'] = extract_base64_video
} 