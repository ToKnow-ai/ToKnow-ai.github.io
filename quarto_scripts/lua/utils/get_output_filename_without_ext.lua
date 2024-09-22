local ternary = require "utils.ternary"
local replace_string = require "utils.replace_string"

---comment
---@param doc pandoc.Pandoc
---@return string
local get_output_filename_without_ext = function(doc)
    local render_output_file = replace_string(quarto.doc.project_output_file() or '', quarto.project.directory, '')
    local dir = render_output_file:match("(.*/)")
    local filename = render_output_file:match("([^/]+)$") -- Get the filename
    local name_without_ext = ternary(
        doc.meta['output-file'],
        pandoc.utils.stringify(doc.meta['output-file'] or {}),
        filename:match("(.+)%..+$"))
        
    return dir .. name_without_ext
end

return get_output_filename_without_ext
