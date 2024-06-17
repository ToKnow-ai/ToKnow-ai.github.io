local read_file = require "utils.read_file"

return {
    ---@param doc pandoc.Pandoc
    ---@return pandoc.Pandoc
    Pandoc = function (doc)
      local general_disclaimer = quarto.project.directory .. '/posts/_general-disclaimer.md'
      local security_disclaimer = quarto.project.directory .. '/posts/_security-disclaimer.md'

      local div = pandoc.Div(pandoc.List:new{}, pandoc.Attr('', {'disclaimer'}, {}))

      local general_disclaimer_blocks = quarto.utils.string_to_blocks(read_file(general_disclaimer))
      general_disclaimer_blocks:insert(1, pandoc.HorizontalRule())
      div.content:insert(pandoc.Div(general_disclaimer_blocks))

      local security_disclaimer_blocks = quarto.utils.string_to_blocks(read_file(security_disclaimer))
      security_disclaimer_blocks:insert(1, pandoc.HorizontalRule())
      div.content:insert(pandoc.Div(security_disclaimer_blocks))
      
      doc.blocks:insert(div)
      -- quarto.doc.include_text(location, text)
      return doc
    end
  }