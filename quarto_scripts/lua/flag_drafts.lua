local replace_string = require "utils.replace_string"
local get_output_filename_without_ext = require "utils.get_output_filename_without_ext"

---create_draft_marker
---@param filename string
---@param text string
local function append_to_file(filename, text)
    -- Check if the file exists
    local file = io.open(filename, "r")
    if file then
        -- File exists, close it and prepare to append
        file:close()
        file = io.open(filename, "a")
        if file then
            file:write("\n" .. text) -- Add a newline before the new text
            file:close()
            print("Text appended to '" .. filename .. "'.")
        end
    else
        -- File doesn't exist, create it and write the text
        file = io.open(filename, "w")
        if file then
            file:write(text)
            file:close()
            print("File '" .. filename .. "' created and text added.")
        end
    end
end

return {{
    Pandoc = function(doc)
        local is_draft = doc.meta['draft'] == true
        if is_draft then
            local render_output_file = replace_string(
                quarto.doc.project_output_file() or '', quarto.project.directory,
                '')
            local filename = render_output_file:match("([^/]+)$") -- Get the filename
            doc.meta['output-file'] = filename .. '.draft'

            -- local draft_file = quarto.project.directory .. '/drafts.txt'
            -- quarto.log.debug('draft_file', draft_file)
            -- append_to_file(draft_file, quarto.doc.project_output_file() or '')
            -- append_to_file(draft_file, quarto.doc.output_file)
            -- local success, error_message = os.remove(quarto.doc.project_output_file())
            -- if success then
            --     print("File deleted successfully")
            -- else
            --     print("Error deleting file: " .. error_message)
            -- end
        end
        return doc
    end
}}
