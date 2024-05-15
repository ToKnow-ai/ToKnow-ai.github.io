
local str_ends_with = require "utils.str_ends_with"
local notebook_special_comments_walker = require "utils.notebook_special_comments_walker"
local is_output_cell = require "utils.is_output_cell"

-- Function to add the open .ipynb buttons to HTML, you can also add a global method: function Pandoc(doc) { }
---@param video_src string
---@param block pandoc.Block
---@param meta_blocks pandoc.MetaBlocks
---@return pandoc.Block,pandoc.MetaBlocks
local function post_action_buttons(video_src, block, meta_blocks)
  if str_ends_with(quarto.doc.input_file, ".ipynb") then
    quarto.log.debug(quarto.doc.input_file, quarto.doc.is_format('pdf'), video_src, block)
  end
  return block, meta_blocks
end

return notebook_special_comments_walker('video-src', post_action_buttons, is_output_cell)

