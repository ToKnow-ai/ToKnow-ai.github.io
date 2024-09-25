local str_ends_with = require "utils.str_ends_with"
local ternary = require "utils.ternary"
local read_metadata = require "utils.read_metadata"
local tobool = require "utils.tobool"
local get_output_filename_without_ext = require "utils.get_output_filename_without_ext"

-- -- Function to encode string
-- ---@param str string
-- ---@return string
-- local function urlencode(str)
--   if str then
--       str = string.gsub(str, "\n", "\r\n")
--       str = string.gsub(str, "([^%w %-%_%.%~])",
--           function(c) return string.format("%%%02X", string.byte(c)) end)
--       str = string.gsub(str, " ", "+")
--   end
--   return str
-- end

---create_html_or_pdf_button
---@param uri string
---@param title string
---@param html_icon string
---@param pdf_icon string
---@return string
local function create_html_or_pdf_button(uri, title, html_icon, pdf_icon)
  if quarto.doc.is_format("html") then
    return 
      string.format(
        '<a target="_blank" class="btn btn-outline-success btn-sm" href="%s">%s %s</a>', 
        uri, html_icon, title)
  elseif quarto.doc.is_format("pdf") then
    return 
    string.format(
      '\\linkbutton{%s}{%s\\hspace{5pt}%s}',
      uri, pdf_icon, title)
  end
  -- quarto.doc.is_format('ipynb')
  return string.format('[%s](%s)', title, uri)
end

-- -- Function to create a Google Colab link
-- ---@param ipynb_uri string
-- ---@return string
-- local function create_colab_markdown(ipynb_uri)
--   local title = "Run in Colab"
--   local colab_url = 'https://colab.research.google.com/\\#fileId=' .. ipynb_uri
--   return create_html_or_pdf_button(
--     colab_url, 
--     title, 
--     '<i class="bi bi-code-slash"></i>',
--     '\\faCode')
-- end

-- Function to create a Download link for the notebook
---@param ipynb_uri string
---@return string
local function create_download_markup(ipynb_uri)
  local title = "Download as Notebook"
  return create_html_or_pdf_button(
    ipynb_uri,
    title,
    '<i class="bi bi-file-earmark-arrow-down-fill"></i>',
    '\\faFileDownload')
end

-- -- Function to create a Deepnote link
-- ---@param ipynb_uri string
-- ---@return string
-- local function create_deepnote_markup(ipynb_uri)
--   local title = "Run in Deepnote"
--   -- https://deepnote.com/docs/launch-repositories-in-deepnote
--   local deepnote_url = 'https://deepnote.com/launch?url=' .. ipynb_uri
--   return create_html_or_pdf_button(
--     deepnote_url,
--     title,
--     '<i class="bi bi-code-slash"></i>',
--     '\\faCode')
-- end

-- Function to create a PDF link
---@param pdf_uri string
---@return string
local function create_pdf_markup(pdf_uri)
  local title = "Download as PDF"
  return create_html_or_pdf_button(
    pdf_uri,
    title,
    '<i class="bi bi-file-pdf"></i>',
    '\\faFilePdf')
end

-- Function to create a website link
---@param html_uri string
---@return string
local function create_online_markup(html_uri)
  if quarto.doc.is_format("html") then
    return ''
  end

  local title = "Read Online"
  return create_html_or_pdf_button(
    html_uri,
    title,
    '<i class="bi bi-link"></i>',
    '\\faLink')
end

-- create_links_wrapper
---@param link_buttons string
---@return pandoc.List
local create_links_wrapper = function (link_buttons)
  local blocks = pandoc.List:new {}
  if quarto.doc.is_format("html") then
    local html_classes =
      "d-flex \
      justify-content-center \
      gap-3 align-items-center \
      flex-wrap \
      clearfix \
      p-1 \
      post_action_buttons"
    
    blocks:insert(pandoc.RawInline('html', '<hr class="mt-1 mb-1 w-50 mx-auto" />'))
    blocks:insert(pandoc.RawInline('html', '<div class="' .. html_classes  .. '">'))
    blocks:insert(pandoc.RawInline('html', link_buttons))
    blocks:insert(pandoc.RawInline('html', '</div>'))
    blocks:insert(pandoc.RawInline('html', '<hr class="mt-1 mb-1 w-50 mx-auto mb-5" />'))
  elseif quarto.doc.is_format("pdf") then
    blocks:insert(pandoc.RawInline('latex', '\\begin{center}'))
    blocks:insert(pandoc.RawInline('latex', '\\vspace{1em} \\rule{0.5\\linewidth}{0.5pt}'))
    blocks:insert(pandoc.RawInline('latex', link_buttons))
    blocks:insert(pandoc.RawInline('latex', '\\vspace{-1em}  \\rule{0.5\\linewidth}{0.5pt}'))
    blocks:insert(pandoc.RawInline('latex', '\\end{center}'))

  elseif quarto.doc.is_format('ipynb') then
    blocks:insert(pandoc.RawInline('markdown', ' *** \n' .. link_buttons .. '\n *** '))
  end
  return blocks
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
  local pdf_markup = create_pdf_markup(output_filepath_without_ext .. '.pdf')
  local html_markup = create_online_markup(output_filepath_without_ext .. '.html')
  local links_blocks = pandoc.List:new {}
  local separator = ternary(quarto.doc.is_format('ipynb'), ' -- ', '\n')
  local treat_as_qmd = tobool(doc.meta['treat_as_qmd'])
  if str_ends_with(input_file, ".ipynb") and not treat_as_qmd then
    local ipynb_output_uri = output_filepath_without_ext .. '.output.ipynb'
    -- local colab_markup = create_colab_markdown(ipynb_output_uri)
    -- local deepnote_markup = create_deepnote_markup(ipynb_output_uri)
    local download_markup = create_download_markup(ipynb_output_uri)
    links_blocks = create_links_wrapper(
      ternary(html_markup, html_markup .. separator, '') .. download_markup .. separator .. pdf_markup)
  else
    links_blocks = create_links_wrapper(ternary(html_markup, html_markup .. separator, '') .. pdf_markup)
  end

  local body_blocks = pandoc.List:new{}
  body_blocks:extend(links_blocks)
  body_blocks:extend(doc.blocks)

  local new_doc = pandoc.Pandoc(body_blocks, doc.meta)
  return new_doc
end

return {{
  Pandoc = post_action_buttons
}}