local ternary = require "utils.ternary"
local read_metadata = require "utils.read_metadata"
local get_output_filename_without_ext = require "utils.get_output_filename_without_ext"

---@param doc pandoc.Pandoc
---@return pandoc.Pandoc
local function create_href(doc)
  local is_prod = (not PANDOC_STATE.trace) -- quarto preview --trace
  local siteUrl = read_metadata(quarto.project.directory .. '/_quarto.yml')['website']['site-url']
  local output_filepath_without_ext = 
    ternary(is_prod, pandoc.utils.stringify(siteUrl), '') .. get_output_filename_without_ext(doc)
  local html_uri = output_filepath_without_ext .. '.html'
  doc.meta['html_uri'] = html_uri
  return pandoc.Pandoc(doc.blocks, doc.meta)
end

return {{
  Pandoc = create_href
}}