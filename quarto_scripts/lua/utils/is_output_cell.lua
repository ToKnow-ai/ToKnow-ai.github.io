-- Function to find cell output block
---@param block pandoc.Div
---@return boolean
local function is_output_cell(block)
    if block and block.attr and block.attr.classes then
        if quarto.doc.is_format("ipynb") then
            return block.attr.classes:includes("display_data")
        end
        return block.attr.classes:includes("cell-output-display")
    end
    return false
end

return is_output_cell