local str_ends_with = require "utils.str_ends_with"
local ternary = require "utils.ternary"
local read_metadata = require "utils.read_metadata"
local tobool = require "utils.tobool"
local get_output_filename_without_ext = require "utils.get_output_filename_without_ext"

-- Function to encode string
---@param str string
---@return string
local function urlencode(str)
  if str then
      str = string.gsub(str, "\n", "\r\n")
      str = string.gsub(str, "([^%w %-%_%.%~])",
          function(c) return string.format("%%%02X", string.byte(c)) end)
      str = string.gsub(str, " ", "+")
  end
  return str
end

-- Function to create a Google Colab link
---@param ipynb_output_uri string
---@param title string
---@param badge_url string
---@return string
local function create_colab_link(ipynb_output_uri, title, badge_url)
  return 
    '<a \
      target="_blank" \
      href="https://colab.research.google.com/#fileId=' .. ipynb_output_uri .. '" \
      aria-label="' .. title .. '" \
      title="' .. title ..'">\
      <img src="' .. badge_url .. '" aria-label="' .. title .. '" title="' .. title .. '" />\
    </a>'
end

-- Function to create a Download link for the notebook
---@param ipynb_output_uri string
---@param title string
---@param badge_url string
---@return string
local function create_download_link(ipynb_output_uri, title, badge_url)
  return 
      '<a \
      target="_blank" \
      style="height:30px" \
      href="' .. ipynb_output_uri .. '" \
      aria-label="' .. title .. '" \
      title="' .. title .. '">\
      <img src="' .. badge_url .. '" aria-label="' .. title .. '" title="' .. title .. '" />\
    </a>'
end

-- Function to create a Deepnote link
---@param ipynb_output_uri string
---@param title string
---@param badge_url string
---@return string
local function create_deepnote_link(ipynb_output_uri, title, badge_url)
  return 
      '<a \
      target="_blank" \
      href="https://deepnote.com/launch?url=' .. urlencode(ipynb_output_uri) .. '" \
      aria-label="' .. title .. '" \
      title="' .. title .. '">\
      <img src="' .. badge_url .. '" aria-label="' .. title .. '" title="' .. title .. '" />\
    </a>'
end

-- Function to create a PDF link
---@param pdf_output_uri string
---@param title string
---@param badge_url string
---@return string
local function create_PDF_link(pdf_output_uri, title, badge_url)
  return 
    '<a \
      target="_blank" \
      href="' .. pdf_output_uri .. '" \
      aria-label="' .. title .. '" \
      title="' .. title ..'">\
      <img src="' .. badge_url .. '" aria-label="' .. title .. '" title="' .. title .. '" />\
    </a>'
end

-- buttons_wrapper
---@param html string
---@return string
local buttons_wrapper = function (html)
  local links_html = 
    '<div class="d-flex justify-content-center gap-3 align-items-center flex-wrap clearfix p-1 post_action_buttons">'
      .. html ..
    '</div>'
  links_html = '<hr class="mt-1 mb-1 w-50 mx-auto"/>' .. links_html .. '<hr class="mt-1 mb-1 w-50 mx-auto mb-5"/>'
  return links_html
end

-- Function to add the open .ipynb buttons to HTML, you can also add a global method: function Pandoc(doc) { }
---@param doc pandoc.Pandoc
---@return pandoc.Pandoc
local function post_action_buttons(doc)
  local input_file = quarto.doc.input_file
  local is_prod = (not PANDOC_STATE.trace) -- quarto preview --trace
  local siteUrl = read_metadata(quarto.project.directory .. '/_quarto.yml')['website']['site-url']
  local output_filepath_without_ext = 
    ternary(is_prod, pandoc.utils.stringify(siteUrl), '') .. get_output_filename_without_ext(doc)
  quarto.log.debug("output_filepath_without_ext", output_filepath_without_ext)
  local pdf_output_uri = output_filepath_without_ext .. '.pdf'
  local pdf_link_html = ternary(
    siteUrl,
    create_PDF_link(
      pdf_output_uri, 
      'Download as PDF', 
      '/images/badges/png/pdf.png'),
    '')
  local links_html = buttons_wrapper(pdf_link_html)
  local treat_as_qmd = tobool(doc.meta['treat_as_qmd'])
  if str_ends_with(input_file, ".ipynb") and not treat_as_qmd then
    local ipynb_output_uri = output_filepath_without_ext .. '.output.ipynb'
    local colab_link_html = create_colab_link(
      ipynb_output_uri,
      'Open in Colab', 
      '/images/badges/png/colab.png')
    local download_link_html = create_download_link(
      ipynb_output_uri,
      'Download Notebook', 
      '/images/badges/png/download-ipynb.png')
    local deepnote_link_html = create_deepnote_link(
      ipynb_output_uri,
      'Open in Deepnote', 
      '/images/badges/png/deepnote.png')
    
    links_html = buttons_wrapper(
      colab_link_html .. deepnote_link_html .. download_link_html .. pdf_link_html)
  end

  local body_blocks = pandoc.List:new{}
  if quarto.doc.is_format('pdf') then
    -- this is the same as `quarto pandoc index.html -o index.pdf`
    local html_blocks = pandoc.read(links_html, 'html').blocks
    body_blocks:insert(pandoc.RawInline('latex', '\\begin{centering}'))
    body_blocks:extend(html_blocks)
    body_blocks:insert(pandoc.RawInline('latex', '\\end{centering}'))
  elseif quarto.doc.is_format('html') then
    -- this just parses the raw HTML and returns pandoc.RawBlock and pandoc.RawInline, 
    --- which is not convertable to PDF, see: https://quarto.org/docs/visual-editor/technical.html#latex-and-html
    local html_blocks = quarto.utils.string_to_blocks(links_html)
    body_blocks:extend(html_blocks)
  end
  body_blocks:extend(doc.blocks)

  local new_doc = pandoc.Pandoc(body_blocks, doc.meta)
  return new_doc
end

return {{
  Pandoc = post_action_buttons
}}