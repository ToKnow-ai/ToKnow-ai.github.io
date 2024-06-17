local read_file = require "utils.read_file"

return {
    ---@param doc pandoc.Pandoc
    ---@return pandoc.Pandoc
    Pandoc = function (doc)
      local general_disclaimer_path = quarto.project.directory .. '/posts/_general-disclaimer.md'
      local blocks = quarto.utils.string_to_blocks(read_file(general_disclaimer_path))
      blocks:insert(1, pandoc.HorizontalRule())
      doc.blocks:insert(pandoc.Div(blocks))
      return doc
    end
  }