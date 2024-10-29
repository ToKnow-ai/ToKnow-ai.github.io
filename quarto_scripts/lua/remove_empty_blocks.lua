return {
  ---@param block pandoc.Div
  ---@diagnostic disable-next-line: undefined-doc-name
  ---@return pandoc.Div|pandoc.Null
  Block = function (block)
    if quarto.doc.is_format("ipynb") then
      if block and block.attr and block.attr.classes then
        -- This is the empty code cell left after using `#|echo: false`
        -- Other formats (pdf/html) remove it, or ignore it, or is just not visible, so no problem!
        if block.attr.classes:includes("cell") and block.attr.classes:includes("code") then
          local some_children_have_value = false
          block:walk {
            Block = function(sub_block)
              if sub_block.content and #sub_block.content > 0 then
                some_children_have_value = true
              end
              if sub_block.text and #sub_block.text > 0 then
                some_children_have_value = true
              end
            end
          }
          if not block.content or #block.content == 0 or not some_children_have_value then
            return pandoc.Null()
          end
        end
      end
    end
    return block
  end
}