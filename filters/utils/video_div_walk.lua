-- Function to find and return an atribute
---@param attributes table<string, string>
---@param key string
---@return string|nil
local function attributes_find(attributes, key)
  for k, v in pairs(attributes) do
    if k == key then
      return v
    end
  end
  return nil
end

-- Function to replace a base64 video with a youtube video
-- #| video-src: "https://www.youtube.com/watch?v=kCc8FmEb1nY"
---@param div pandoc.Div
---@param walk_block 'RawBlock'|'CodeBlock'
---@param replace_base64_video_src function
---@return pandoc.Div
local function video_div_walk(div, walk_block, replace_base64_video_src)
  local is_prod = (not PANDOC_STATE.trace) -- quarto preview --trace
  if not is_prod then
    return div
  end

  local video_src = attributes_find(div.attr.attributes, 'video-src')
  if video_src then
    div = div:walk{
      ---@param block pandoc.RawBlock|pandoc.CodeBlock
      ---@return pandoc.RawBlock|pandoc.CodeBlock
      [walk_block] = function (block)
        return replace_base64_video_src(block, video_src)
      end,  
    }
  end
  
    return div
  end

  return video_div_walk