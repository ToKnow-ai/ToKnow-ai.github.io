return {
    ---@param doc pandoc.Pandoc
    ---@return pandoc.Pandoc
    Pandoc = function (doc)
      local general_disclaimer_path = '_general-disclaimer.md'
      local blocks = quarto.utils.string_to_blocks("<pagepath _general-disclaimer.md>}}")
      quarto.log.debug('blocks', blocks)
      doc.blocks:insert(pandoc.Div(blocks))
      return doc
    end
  }