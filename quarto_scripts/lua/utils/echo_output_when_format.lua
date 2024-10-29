local str_starts_with = require "utils.str_starts_with"
local str_ends_with = require "utils.str_ends_with"

return function(format_with_template)
    -- Function to manage echo/output for given format:
    --    - Replace the current block, if the format is matched!
    --    - Include the current block as is, if the format is matched!
    -- A complement for: https://quarto.org/docs/authoring/conditional.html#format-matching
    -- Usage:   #|echo/output-when-format: "{format}"              =>  #|echo/output-when-format: "html"
    --          #|echo/output-when-format-{format}: "{template}"   =>  #|echo/output-when-format-pdf: "[text](link)"
    ---@param key_template_format table<"key"|"value", string>
    ---@param block pandoc.Block
    ---@param sibling_match_count number
    ---@return pandoc.Block
    return function (key_template_format, block, sibling_match_count)
        if not (str_ends_with(quarto.doc.input_file, ".ipynb")) then
            return block
        end
        local format = key_template_format.key
        local template = key_template_format.value
        if str_starts_with(format, format_with_template) then
            format = string.sub(format, #format_with_template + 1)
            if quarto.doc.is_format(format) then
                if template and sibling_match_count == 0 then
                    -- This replaces the current block, if the format is matched!
                    return pandoc.Div(quarto.utils.string_to_blocks(template))
                end
            else
                -- Wrapping this may not render well in some cases, eg: plotly interactive plots!!
                return block
            end
        else
            format = template
            if quarto.doc.is_format(format) and sibling_match_count == 0 then
                -- This includes the current block as is, if the format is matched!
                return block
            end
        end
        return pandoc.Null()
    end
end
