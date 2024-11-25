---@param image pandoc.Image
---@param meta pandoc.MetaBlocks
---@return pandoc.Image | pandoc.List
local function addFrameToImage(image, meta)
    if quarto.doc.is_format("pdf") then
        -- Skip images that have the 'no-frame' class
        if not image.classes:includes('no-frame') or meta['no-frame'] == true then
            quarto.log.debug('image', image)
            return pandoc.Inlines {
                pandoc.RawInline('latex', "\\begin{tcolorbox}[boxrule=0.5pt, colframe=gray, capture=hbox, boxsep=0pt, left=0pt, right=0pt, top=0pt, bottom=0pt]\n"),
                image,
                pandoc.RawInline('latex', '\n\\end{tcolorbox}'),
            }
        end
    end
    return image
end

return {
    ---@param doc pandoc.Pandoc
    ---@return pandoc.Pandoc
    Pandoc = function (doc)
        doc.blocks = doc.blocks:walk {
            Image = function (image)
                return addFrameToImage(image, doc.meta)
            end
        }
        return doc
    end
}