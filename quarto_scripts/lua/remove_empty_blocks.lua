return {
  ---@param div pandoc.Div
  ---@diagnostic disable-next-line: undefined-doc-name
  ---@return pandoc.Div|pandoc.Null
  Div = function (div)
    if quarto.doc.is_format("ipynb") then
      if div and div.attr and div.attr.classes then
        -- This is the empty code cell left after using `#|echo: false`
        -- Other formats (pdf/html) remove it, or ignore it, or is just not visible, so no problem!
        if div.attr.classes:includes("cell") and div.attr.classes:includes("code") then
          local some_children_have_value = false
          div:walk {
            Div = function(sub_div)
              if #sub_div.content > 0 then
                some_children_have_value = true
              end
            end
          }
          if #div.content == 0 or not some_children_have_value then
            return pandoc.Null()
          end
        end
      end
    end
    return div
  end
}