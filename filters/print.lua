return {
  ---@param doc pandoc.Pandoc
  Pandoc = function (doc)
    quarto.log.debug(doc.blocks)
    return doc
  end
}