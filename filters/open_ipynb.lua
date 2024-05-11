local str_ends_with = require "utils.str_ends_with"
local read_file = require "utils.read_file"

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

-- Function to get readFile output
---@param command string
---@return string
local function get_std(command)
  local handle = assert(io.popen(command))
  local result = handle:read("*a")
  handle:close()
  return result:sub(1, -2) -- Trim the trailing newline
end

-- Function to automatically encode and replace a substring
---@param original string
---@param pattern string
---@param replacement string
---@return string
local function autoEncodeReplace(original, pattern, replacement)
  local encodedPattern = pattern:gsub("[%p%c%s]", "%%%0") -- Escape special characters
  return original:gsub(encodedPattern, replacement)
end

-- Function to create a Google Colab link
---@param repository string
---@param branch string
---@param notebook_path string
---@param title string
---@param badge_url string
---@return string
local function create_colab_link(repository, branch, notebook_path, title, badge_url)
  return 
    '<a \
      target="_blank" \
      href="https://colab.research.google.com/github/' .. repository .. '/blob/' .. branch .. notebook_path .. '" \
      aria-label="' .. title .. '" \
      title="' .. title ..'">\
      <img src="' .. badge_url .. '" aria-label="' .. title .. '" title="' .. title .. '" />\
    </a>'
end

-- Function to create a Binder link
---@param repository string
---@param branch string
---@param notebook_path string
---@param title string
---@param badge_url string
---@return string
local function create_binder_link(repository, branch, notebook_path, title, badge_url)
  return 
    '<a \
      target="_blank" \
      href="https://mybinder.org/v2/gh/' .. repository .. '/' .. branch .. '?labpath=' .. notebook_path .. '" \
      aria-label="' .. title .. '" \
      title="' .. title ..'">\
      <img src="' .. badge_url .. '" aria-label="' .. title .. '" title="' .. title .. '" />\
    </a>'
end

-- Function to create a Github link
---@param repository string
---@param branch string
---@param notebook_path string
---@param title string
---@param badge_url string
---@return string
local function create_github_link(repository, branch, notebook_path, title, badge_url)
  return 
    '<a \
      target="_blank" \
      href="https://github.com/' .. repository .. '/blob/' .. branch .. '/' .. notebook_path .. '" \
      aria-label="' .. title .. '" \
      title="' .. title ..'">\
      <img src="' .. badge_url .. '" aria-label="' .. title .. '" title="' .. title .. '" />\
    </a>'
end

-- Function to create a Deepnote link
---@param repository string
---@param branch string
---@param notebook_path string
---@param title string
---@param badge_url string
---@return string
local function create_deepnote_link(repository, branch, notebook_path, title, badge_url)
  local github_url = 'https://github.com/' .. repository .. '/blob/' .. branch .. '/' .. notebook_path
  return 
    '<a \
      target="_blank" \
      href="https://deepnote.com/launch?url=' .. urlencode(github_url) .. '" \
      aria-label="' .. title .. '" \
      title="' .. title ..'">\
      <img src="' .. badge_url .. '" aria-label="' .. title .. '" title="' .. title .. '" />\
    </a>'
end

-- Function to create a PDF link
---@param pdf_uri string
---@param title string
---@param badge_url string
---@return string
local function create_PDF_link(pdf_uri, title, badge_url)
  return 
    '<a \
      target="_blank" \
      href="' .. pdf_uri .. '" \
      aria-label="' .. title .. '" \
      title="' .. title ..'">\
      <img src="' .. badge_url .. '" aria-label="' .. title .. '" title="' .. title .. '" />\
    </a>'
end

-- Function to remove extention
--- @param file_name string
--- @return string
local function remove_extention(file_name)
  local file_name_without_ext = file_name:match("^(.+/.+)%..+$")
  return file_name_without_ext
end

---Funtion to evaluate ternary operation - https://stackoverflow.com/a/5529577
---@param cond any - able value that will resolve to boolish
---@param T any
---@param F any
---@return any
local function ternary (cond, T, F )
  if cond then return T else return F end
end

-- Funtion to extract the metadata of a file, given a file_name
---@param file_name string
--- @return pandoc.MetaValue
local function read_metadata(file_name)
  local yml_text = read_file(file_name)
  local yml_doc = pandoc.read('---\n' .. yml_text .. '\n---', "markdown")
  return yml_doc.meta
end

-- Function to add the open .ipynb buttons to HTML, you can also add a global method: function Pandoc(doc) { }
---@param doc pandoc.Pandoc
---@return pandoc.Pandoc
local function add_buttons(doc)
  local input_file = quarto.doc.input_file
  if not str_ends_with(input_file, ".ipynb") then
    return doc
  end
  
  local siteUrl = read_metadata(quarto.project.directory .. '/_quarto.yml')['website']['site-url']
  local pdf_output_file = remove_extention(quarto.doc.output_file:sub(#quarto.project.output_directory + 1)) .. '.pdf'
  local repository_username = "ToKnow-ai"
  -- https://stackoverflow.com/a/42543006
  local repository_name = get_std("basename -s .git `git config --get remote.origin.url`")
  local repository = repository_username .. "/" .. repository_name
  local branch = get_std("git rev-parse --abbrev-ref HEAD")
  local git_dir = get_std("git rev-parse --show-toplevel") -- quarto.project.directory,offset,output_directory
  local notebook_path = autoEncodeReplace(input_file, git_dir, "")

  local colab_link_html = create_colab_link(repository, branch, notebook_path, 'Open in Colab', '/images/badges/colab.svg')
  local binder_link_html = create_binder_link(repository, branch, notebook_path, 'Open in Binder', '/images/badges/binder.svg')
  local github_link_html = create_github_link(repository, branch, notebook_path, 'View on Github', '/images/badges/github.svg')
  local deepnote_link_html = create_deepnote_link(repository, branch, notebook_path, 'Open in Deepnote', '/images/badges/deepnote.svg')
  local pdf_link_html = ternary(
    siteUrl,
    create_PDF_link(pandoc.utils.stringify(siteUrl) .. pdf_output_file, 'Download as PDF', '/images/badges/pdf.svg'),
    '')

  local links_html = 
    '<div class="d-flex justify-content-evenly align-items-center flex-wrap clearfix p-1">'
      .. colab_link_html
      .. binder_link_html
      .. github_link_html
      .. deepnote_link_html
      .. pdf_link_html ..
    '</div>'
  links_html = '<hr class="mt-1 mb-1 w-50 mx-auto"/>' .. links_html .. '<hr class="mt-1 mb-1 w-50 mx-auto"/>'


  local body_blocks = pandoc.List:new{}
  if quarto.doc.is_format('pdf') then
    -- this is the same as `quarto pandoc index.html -o index.pdf`
    local html_blocks =  pandoc.read(links_html, 'html').blocks
    body_blocks:extend(html_blocks)
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
  -- https://quarto.org/docs/projects/binder.html#add-a-link-to-binder
  -- https://github.com/feynlee/code-insertion/blob/main/_extensions/code-insertion/code-insertion.lua
  Pandoc = add_buttons
}}