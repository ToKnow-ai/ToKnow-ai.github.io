local generate_unique_string = require "utils.generate_unique_string"

return {
  ['iframe'] = function (args, kwargs)
    -- Check if the output format is HTML
    if quarto.doc.is_format('html') then
      local loading_var = ''
      if args and args[1] then
        for _, arg in ipairs(args) do
          loading_var = loading_var .. ' ' .. pandoc.utils.stringify(arg)
        end
      else
        loading_var = "Loading IFrame..."
      end
      local class_name = 'class_' .. generate_unique_string()
      -- @type iframe_attrs string
      local iframe_attrs = 'style="opacity: 0"'
      for key, value in pairs(kwargs) do
        iframe_attrs = iframe_attrs .. string.format(' %s="%s"', key, value)
      end

      -- @type iframe_tag string
      local iframe_tag =
        [[
          <style>
            .iframe-container {
                /* To position the loading */
                position: relative;
            }

            .loading {
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

                background-color: #fff3cd;
            }
        </style>
        <div class="iframe-container ]] .. class_name .. [[">
          <div class="loading rounded border border-warning">
            <strong style="font-size: 1.5rem;">]] .. loading_var .. [[</strong>
            <div class="spinner-grow" style="margin: 2rem; width: 3rem; height: 3rem;" role="status"></div>
          </div>
          <iframe ]] .. iframe_attrs .. [[></iframe>
        </div>
        <script>
            // Query the elements
            const iframeEle = document.querySelector('.]] .. class_name .. [[ > iframe');
            const loadingEle = document.querySelector('.]] .. class_name .. [[ > .loading');

            iframeEle.addEventListener('load', function () {
                // Hide the loading indicator
                loadingEle.style.display = 'none';

                // Bring the iframe back
                iframeEle.style.opacity = 1;
            });
        </script>
        ]]

      -- quarto.log.debug('iframe_tag', iframe_tag)
        
      return pandoc.RawBlock('html', iframe_tag)
    end

    -- Return null for non-HTML formats
    return pandoc.Null()
  end
}