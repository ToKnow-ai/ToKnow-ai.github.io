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

local link_button_classes = "{.btn .btn-outline-success .btn-sm}"

-- Function to create a Google Colab link
---@param ipynb_uri string
---@return string
local function create_colab_markdown(ipynb_uri)
  local title = "Open in Colab"
  local colab_url = 'https://colab.research.google.com/#fileId=' .. urlencode(ipynb_uri)
  return '[{{< fa code >}} ' .. title .. '](' .. colab_url .. ')' .. link_button_classes
end

-- Function to create a Download link for the notebook
---@param ipynb_uri string
---@return string
local function create_download_markdown(ipynb_uri)
  local title = "Download Notebook"
  return '[{{< fa download >}} ' .. title .. '](' .. ipynb_uri .. ')' .. link_button_classes
end

-- Function to create a Deepnote link
---@param ipynb_uri string
---@return string
local function create_deepnote_markdown(ipynb_uri)
  local title = "Open in Deepnote"
  local deepnote_url = 'https://deepnote.com/launch?url=' .. urlencode(ipynb_uri)
  return '[{{< fa code >}} ' .. title .. '](' .. deepnote_url .. ')' .. link_button_classes
end

-- Function to create a PDF link
---@param pdf_uri string
---@return string
local function create_pdf_markdown(pdf_uri)
  local title = "Download as PDF"
  return '[{{< fa file-pdf >}} ' .. title .. '](' .. pdf_uri .. ')' .. link_button_classes
end

-- buttons_wrapper
---@param markdown_text string
---@return pandoc.List
local create_link_wrapper = function (markdown_text)
  local html_classes =
  "d-flex justify-content-center gap-3 align-items-center flex-wrap clearfix p-1 post_action_buttons"
  local blocks = pandoc.List:new {}
  blocks:insert(pandoc.RawInline('latex', '\\begin{centering}'))
  blocks:insert(pandoc.RawInline('latex', '\\vspace{-1em} \\rule{0.5\\linewidth}{0.5pt}'))
  blocks:insert(pandoc.RawInline('html', '<hr class="mt-1 mb-1 w-50 mx-auto" />'))
  -- blocks:insert(pandoc.RawInline('html', '<div class="' .. html_classes  .. '">'))
  blocks:extend(quarto.utils.string_to_blocks('<div class="' .. html_classes .. '">' .. markdown_text .. '</div>'))
  -- blocks:insert(pandoc.RawInline('html', '</div>'))
  blocks:insert(pandoc.RawInline('html', '<hr class="mt-1 mb-1 w-50 mx-auto mb-5" />'))
  blocks:insert(pandoc.RawInline('latex', '\\vspace{-0.5em}  \\rule{0.5\\linewidth}{0.5pt}'))
  blocks:insert(pandoc.RawInline('latex', '\\end{centering}'))
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
  local pdf_output_uri = output_filepath_without_ext .. '.pdf'
  local pdf_markdown = create_pdf_markdown(pdf_output_uri)
  local links_blocks = create_link_wrapper(pdf_markdown)
  local treat_as_qmd = tobool(doc.meta['treat_as_qmd'])
  if str_ends_with(input_file, ".ipynb") and not treat_as_qmd then
    local ipynb_output_uri = output_filepath_without_ext .. '.output.ipynb'
    local colab_markdown = create_colab_markdown(ipynb_output_uri)
    local download_markdown = create_download_markdown(ipynb_output_uri)
    local deepnote_markdown = create_deepnote_markdown(ipynb_output_uri)
    
    links_blocks = create_link_wrapper(
      colab_markdown .. deepnote_markdown .. download_markdown .. pdf_markdown)
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