return {
  ---@param doc pandoc.Pandoc
  Pandoc = function (doc)
    quarto.log.debug('Pandoc.doc', doc)

    local blocks = doc.blocks:walk {
      ---@param float pandoc.FloatRefTarget
      ---@return pandoc.FloatRefTarget
      FloatRefTarget = function(float)
        -- if float.type == 'Listing' then
          quarto.log.debug(float)
          return float
        -- end
      end
    }
    
    return pandoc.Pandoc(blocks, doc.meta)
  end,
  FloatRefTarget = function(float)
    -- if float.type == 'Listing' then
      quarto.log.debug(float)
      return float
    -- end
  end
}