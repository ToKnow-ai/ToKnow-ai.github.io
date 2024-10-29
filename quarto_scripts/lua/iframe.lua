local generate_unique_string = require "utils.generate_unique_string"

return {
  ['iframe'] = function (args, kwargs)
    if quarto.doc.is_format('ipynb') then
      local iframe_attrs = ''
      for key, value in pairs(kwargs) do
        iframe_attrs = iframe_attrs .. string.format(' %s="%s"', key, value)
      end
      -- @type iframe_tag string
      local iframe_tag = '<iframe ' .. iframe_attrs .. '></iframe>'
      return pandoc.RawBlock('markdown', iframe_tag)
    end

    -- Check if the output format is HTML
    if quarto.doc.is_format('html') then
      -- @type iframe_tag string
      local loading_status = "Loading IFrame..."
      if args and args[1] then
        loading_status = ""
        for _, arg in ipairs(args) do
          loading_status = loading_status .. ' ' .. pandoc.utils.stringify(arg)
        end
      end
      -- @type iframe_container_class string
      local iframe_container_class = 'iframe_container_' .. generate_unique_string()
      -- @type iframe_attrs string
      local iframe_attrs = 'style="opacity: 0; background-color: #fff3cd;"'
      for key, value in pairs(kwargs) do
        iframe_attrs = iframe_attrs .. string.format(' %s="%s"', key, value)
      end

      -- @type iframe_container string
      local iframe_container =
          [[
          <style>
            .]] .. iframe_container_class .. [[ {
                /* To position the loading */
                position: relative;
            }
            .iframe-loading {
                /* Absolute position */
                left: 0;
                position: absolute;
                top: 0;
                /* Take full size */
                height: 100%;
                width: 100%;
                /* Center */
                display: flex;
                align-items: center;
                justify-content: center;
            }
        </style>
        <div class="]] .. iframe_container_class .. [[">
          <div class="iframe-loading rounded border border-warning" style="background-color: #fff3cd;">
            <strong style="font-size: 1.5rem;">]] .. loading_status .. [[</strong>
            <div class="spinner-grow" style="margin: 2rem; width: 3rem; height: 3rem;" role="status"></div>
          </div>
          <iframe ]] .. iframe_attrs .. [[></iframe>
        </div>
        <script>
            document.querySelector('.]] .. iframe_container_class .. [[ > iframe').addEventListener('load', function () {
                const loadingEle = document.querySelector('.]] .. iframe_container_class .. [[ > .iframe-loading');
                // Hide the loading indicator
                loadingEle.style.display = 'none';
                // Bring the iframe back
                this.style.opacity = 1;
                console.log(this, { loadingEle })
            });
        </script>
        ]]
        
      return pandoc.RawBlock('html', iframe_container)
    end

    -- Return null for non-HTML formats
    return pandoc.Null()
  end
}