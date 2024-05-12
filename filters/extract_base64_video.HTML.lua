local str_ends_with = require "utils.str_ends_with"
local notebook_div_walk = require "utils.notebook_div_walk"

-- Function to replace base64 video with a youtube src
---@param block pandoc.RawBlock
---@param video_src string
---@return pandoc.RawBlock|pandoc.Blocks
local function replace_base64_video_src(block, video_src)
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
  
  video = quarto.utils.string_to_blocks("{{< video " .. video_src .. " >}}")
  return video
end

return {
  ---@param div pandoc.Div
  ---@return pandoc.Div
  Div = function (div)
    return notebook_div_walk('video-src', div, 'RawBlock', replace_base64_video_src)
  end, 
}