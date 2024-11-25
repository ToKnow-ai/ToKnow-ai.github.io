local replace_base64_video_src = require "replace_base64_video_src"

return {
    ['video-src'] = function(args)
        local video_src = pandoc.utils.stringify(args[1])
        return replace_base64_video_src.replace_base64_video_src({ ['value'] = video_src }, pandoc.Null(), 0, {})
    end
}
