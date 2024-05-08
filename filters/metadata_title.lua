

-- Function to extract title from metadata, you can also add a global method: function Pandoc(doc) { }
---@param doc pandoc.Pandoc
---@return pandoc.Pandoc
function metadata_title(doc)
  local meta_title = doc.meta
  quarto.log.debug(doc.meta['title'])
  quarto.log.debug(doc.meta['faketitle'])

  return doc
end

return {
  ['Pandoc'] = metadata_title
}