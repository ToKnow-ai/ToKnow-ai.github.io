return {
    ['pagepath'] = function (args)
        local page = pandoc.utils.stringify(args[1])
        local offset = quarto.project.offset
        local pagepath = offset .. "/" .. page
        quarto.log.debug('pagepath', pagepath)
        return pandoc.Str(pagepath)
    end
  }