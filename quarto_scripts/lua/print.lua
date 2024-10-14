return {
  ---@param doc pandoc.Pandoc
  ---@return pandoc.Pandoc
  Pandoc = function (doc)
    quarto.log.debug('print:doc.blocks', doc.blocks)
    return doc
  end
}