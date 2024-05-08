local str_ends_with = require "utils.str_ends_with"

-- Function to create a Github link
-- https://github.com/feynlee/code-insertion/blob/c7aa90f63a176c40578f3e427c1898272f44b51c/_extensions/code-insertion/code-insertion.lua#L1
---@param file string
---@return string
local function readFile(file)
  local f = assert(io.open(file, "rb"))
  local content = f:read("*all")
  f:close()
  return content
end

-- Helper function for file existence
-- https://github.com/danmackinlay/quarto_tikz/blob/6cd699abf22c8b8fd34605dc071d5fcde343915c/_extensions/tikz/tikz.lua#L47
---@param name string
---@return boolean
local function file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local _metadata_yml = "_metadata.yml"

-- Function to extract title from metadata, you can also add a global method: function Pandoc(doc) { }
---@param doc pandoc.Pandoc
---@return pandoc.Pandoc
local function metadata_title(doc)
  local input_file = quarto.doc.input_file
  quarto.log.debug("input_file", input_file)
  if not (str_ends_with(input_file, ".ipynb") and file_exists(_metadata_yml)) then
    return doc
  end

  local yml_text = readFile(_metadata_yml)
  local yml_doc = pandoc.read('---\n' .. yml_text .. '\n---', "markdown")
  local yml_doc_title = yml_doc.meta['title']
  
  local body_blocks = doc.blocks
  if yml_doc_title then
    local old_title = doc.meta['title']
    body_blocks = pandoc.List:new{old_title}
    body_blocks:extend(doc.blocks)
    doc.meta['title'] = yml_doc_title
  end

  local new_doc = pandoc.Pandoc(body_blocks, doc.meta)
  return new_doc
end

return {
  ['Pandoc'] = metadata_title
}