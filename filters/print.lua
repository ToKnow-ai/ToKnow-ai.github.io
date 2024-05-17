return {
  ---@param doc pandoc.Pandoc
  Pandoc = function (doc)
    local markdown_str = 'Please visit <https://example.com> to view the plot. {{< meta title >}}'
    local blocks_1 = quarto.utils.string_to_blocks(markdown_str)
    local blocks_2 = quarto.utils.string_to_inlines(markdown_str)
    local blocks_3 = pandoc.read(markdown_str, 'markdown').blocks

    doc.blocks:insert(pandoc.Header(1, 'quarto.utils.string_to_blocks'))
    doc.blocks:insert(pandoc.Div(blocks_1))
    
    doc.blocks:insert(pandoc.Header(1, 'quarto.utils.string_to_inlines'))
    doc.blocks:insert(pandoc.Div(blocks_2))

    doc.blocks:insert(pandoc.Header(1, 'pandoc.read(markdown_str, "markdown").blocks'))
    doc.blocks:insert(pandoc.Div(blocks_3))

    return doc
  end
}

