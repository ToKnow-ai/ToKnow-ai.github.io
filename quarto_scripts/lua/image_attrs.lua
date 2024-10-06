local bash = require "bash"

--- is_empty_table
---@param table table<any, any> | any
---@return boolean
local is_empty_table = function (table)
    if type(table) == "table" then
        for k, v in pairs(table) do
            return true
        end
    end
    return false
end

function get_image_size(filepath)
    local command = string.format('identify -format "%%w,%%h" "%s"', filepath)
    local result = bash.terminal(command)
    if result then
        local width, height = result:match("(%d+),(%d+)")
        return tonumber(width), tonumber(height)
    end
    return nil, nil
end

return {
    ---@param doc pandoc.Pandoc
    ---@return pandoc.Pandoc
    Pandoc = function (doc)
        if quarto.doc.is_format('html') then
            --- @type table<string, string>
            --- @diagnostic disable-next-line: assign-type-mismatch
            local image_attrs = doc.meta['image-attrs'] or {}
            if is_empty_table(image_attrs) then
                local blocks = doc.blocks:walk {
                    ---@param image pandoc.Image
                    ---@return pandoc.Inline|pandoc.List|nil
                    Image = function (image)
                        for k, v in pairs(image_attrs) do
                            image.attributes[k] = pandoc.utils.stringify(v)
                        end
                        -- MAKES IMAGES OVERFLOW DISPLAY AREA!!!
                        -- local width, height = get_image_size(image.src)
                        -- if width and height then
                        --     image.attributes['width'] = tostring(width)
                        --     image.attributes['height'] = tostring(height)
                        -- end
                        return image
                    end
                }
                return pandoc.Pandoc(blocks, doc.meta)
            end
        end
        
        return doc
    end
}
