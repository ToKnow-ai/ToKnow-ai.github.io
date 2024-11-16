return {
  ---@param table pandoc.Table
  ---@return pandoc.Div|pandoc.Table
  Table = function (table)
    if quarto.doc.is_format("html") then
      table.classes:insert("table-striped")
      return pandoc.Div(table, pandoc.Attr("", { "table-responsive" }))
    end
    return table
  end
}