local str_ends_with = require "utils.str_ends_with"
local notebook_special_comments_walker = require "utils.notebook_special_comments_walker"
local is_output_cell = require "utils.is_output_cell"

---get_youtube_image
---@param video_src string
---@return string|nil
local get_youtube_image = function(video_src)
  local video_id = 
    -- "www.youtube.com/watch?v=kCc8FmEb1nY"
    string.match(video_src, ".+youtube.com/watch%?v%=(.+)$") or
    -- "https://youtu.be/kCc8FmEb1nY?si=77OsaKikOnJgRRRy"
    string.match(video_src, ".+youtu.be/(.+)%?.+$") or
    -- "https://www.youtube.com/embed/kCc8FmEb1nY?si=XspSx2xnp7xhYgDe"
    string.match(video_src, ".+youtube.com/embed/(.+)%?.+$")
  if video_id then
    return 'https://img.youtube.com/vi/' .. video_id .. '/hqdefault.jpg'
  end
  return nil
end

local makeBox = function (text, url, icon, color)
  local youtube_image_src = get_youtube_image(url)
  if not youtube_image_src then
    local blocks = pandoc.RawInline(
      'latex',
      '\\href{' .. url .. '}{ \
          \\begin{centering} \
            \\begin{tcolorbox}[\
                hbox,\
                colframe='.. color .. ',\
                colback=white] \
                { \\Large { \
                    \\textcolor{' .. color .. '}{' .. icon .. '} \
                    \\textbf{' .. text .. '} \
                }} \
            \\end{tcolorbox}\
          \\end{centering}\
      }')
    return pandoc.Div(blocks)
  else
    -- local test_image = '/home/anon-b/Downloads/hqdefault.jpg'
    -- local blocks = pandoc.RawInline(
    --   'latex',
    --   '\\href{' .. url .. '}{ \
    --       \\begin{centering} \
    --       \\begin{tcolorbox}[\
    --           hbox,\
    --           colframe='.. color .. ',\
    --           colback=white, \
    --           left=0pt, right=0pt, top=0pt, bottom=0pt,\
    --           title=' .. text ..', \
    --           fonttitle=\\bfseries] \
    --           \\begin{tikzpicture}\
    --               \\node[inner sep = 0pt] (a) {\
    --                   \\includegraphics[width=0.5\\textwidth]{' .. youtube_image_src .. '}\
    --               };\
    --               \\node[anchor=center] at (a.center) {\
    --                   \\textcolor{' .. color .. '}{{\\fontsize{70}{0}\\selectfont {' .. icon .. '}}} \
    --               };\
    --           \\end{tikzpicture}\
    --       \\end{tcolorbox}\
    --   \\end{centering}\
    --   }')
    -- return pandoc.Div(blocks)

    local block1 = pandoc.RawInline(
      'latex',
      '\\begin{centering} \
          \\begin{tcolorbox}[\
              hbox,\
              colframe='.. color .. ',\
              colback=white, \
              left=0pt, right=0pt, top=0pt, bottom=0pt,\
              title=' .. text ..', \
              fonttitle=\\bfseries] \
              \\begin{tikzpicture} \
              \\node[inner sep = 0pt] (a) {')
    local attrs = {
      width = '50%'
    }
    local block2 = pandoc.Image('', youtube_image_src, '', attrs)
    local block3 = pandoc.RawInline(
      'latex',
                      '};\
                      \\node[anchor=center] at (a.center) {\
                      \\textcolor{' .. color .. '}{{\\fontsize{70}{0}\\selectfont {' .. icon .. '}}} \
                    };\
                      \\end{tikzpicture}\
          \\end{tcolorbox}\
      \\end{centering}')

    local div = pandoc.Div(pandoc.Link(pandoc.List{ block1, block2, block3 }, url))

    quarto.log.debug('div', div)
    
    return div
  end
end

-- Function to return video block for PDF
---@param video_src string
---@return pandoc.Block
local function pdf_src_block(video_src)
  local video = makeBox("Click to watch the video at Youtube.", video_src, "\\faYoutube", "youtubeColor")
  -- video = pandoc.read("Please watch the video at <" .. video_src .. ">", 'markdown').blocks
  return video
end

-- Function to return video block for HTML
---@param video_src string
---@return pandoc.Block
local function html_src_block(video_src)
  local video = quarto.utils.string_to_blocks("{{< video " .. video_src .. " >}}")
  return pandoc.Div(video)
end

-- Function to extract base64 video
---@param video_src string
---@param block pandoc.Block
---@return pandoc.Block
local function replace_base64_video_src(video_src, block)
  if not (str_ends_with(quarto.doc.input_file, ".ipynb")) then
    return block
  end
  
  if quarto.doc.is_format('pdf') then
    return pdf_src_block(video_src)
  end

  if quarto.doc.is_format('html') then
    return html_src_block(video_src)
  end
  
  return block
end

return notebook_special_comments_walker('video-src', replace_base64_video_src, is_output_cell)