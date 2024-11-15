local replace_string = require "utils.replace_string"
local str_trim = require "utils.str_trim"

local function remove_both_slashes(str)
  return str:gsub("^/+", ""):gsub("/+$", "")
end

return {{
  ---@param doc pandoc.Pandoc
---@return pandoc.Pandoc
  Pandoc = function (doc)
    if quarto.doc.is_format("html") then
      local render_output_file = replace_string(
        quarto.doc.project_output_file() or '', 
        quarto.project.directory, '')
      local dir = '/' .. remove_both_slashes(str_trim(render_output_file:match("(.*/)")))
      local image_html = [[
        <img
          src="https://toknow.ai/pageviews?page_path=]] .. dir .. [["
          class="rounded mx-auto d-block"
          style="height: 1.3em;">
      ]]
      
      doc.blocks:insert(1, pandoc.RawBlock('html', image_html))
    end
    return doc
  end
}}