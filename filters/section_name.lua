local notebook_special_comments_walker = require "utils.notebook_special_comments_walker"

-- Function to extract section name
---@param section_name table<'key'|'value', string>
---@param block pandoc.Block
---@param meta pandoc.MetaBlocks
---@return pandoc.Block|nil,pandoc.MetaBlocks
local function extract_section_name(section_name, block, meta)
  meta[section_name.value] = block
  return nil, meta
end

return notebook_special_comments_walker('section-name', extract_section_name)