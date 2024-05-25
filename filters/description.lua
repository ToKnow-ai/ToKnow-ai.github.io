-- https://github.com/quarto-dev/quarto-cli/blob/e1026cf2cc1c91febbf4631b38f91ef7848f4f33/src/project/types/website/listing/website-listing-read.ts#L505
-- https://github.com/quarto-dev/quarto-cli/discussions/9767
-- https://stackoverflow.com/questions/78531833
local pattern = ":([^:]+/[^/]+%.html)%s*-->"

return {
  ---@param doc pandoc.Pandoc
  ---@return pandoc.Pandoc
  Pandoc = function (doc)
    local blocks = doc.blocks {
      ---@param block pandoc.RawInline
      ---@return pandoc.Block
      RawInline = function (block)
        if block and block.text then
          local filename = string.match(block.text, pattern)
          if filename then
            filename
          end
        end
      end
    }
    quarto.log.debug('args, kwargs, meta, raw_args || ', args, kwargs, meta, raw_args)
    return pandoc.Str(pandoc.utils.stringify(os.date("%Y")))
  end
}