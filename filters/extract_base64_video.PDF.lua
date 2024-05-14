local str_ends_with = require "utils.str_ends_with"
local notebook_div_walk = require "utils.notebook_div_walk"

local function makeBox(text, url, icon, color) 
  return pandoc.Div(pandoc.List({
    pandoc.RawInline('latex', '\\begin{centering}\\begin{tcolorbox}[hbox,\ncolframe=lightgray,\ncolback=white]\n'),
    pandoc.RawInline('latex', '\\textcolor{' .. color .. '}{{\\Large {' .. icon .. '}}} %'),
    pandoc.Link(pandoc.RawInline("latex", '\\raisebox{0.1 em}{' .. text .. '}'),url),
    pandoc.RawInline('latex', '\n\\end{tcolorbox}\\end{centering}\n\\vspace{1em}')
  }))
end

-- Function to extract base64 video
---@param div pandoc.Div
---@param video_src string
---@return pandoc.Div|pandoc.List
local function replace_base64_video_src(div, video_src)
  if not (str_ends_with(quarto.doc.input_file, ".ipynb")) then
    return div
  end
  
  if not quarto.doc.is_format('pdf') then
    return div
  end
  
  video = makeBox("Click to watch the video at Youtube.", video_src, "\\faYoutube", "youtubeColor")
  -- video = pandoc.read("Please watch the video at <" .. video_src .. ">", 'markdown').blocks
  return video
end

return {
  ---@param div pandoc.Div
  ---@return pandoc.Div
  Div = function (div)
    return notebook_div_walk('video-src', div, replace_base64_video_src)
  end, 
}