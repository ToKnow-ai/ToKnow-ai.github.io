-- Function to encode string
---@param str string
---@return string
function urlencode(str)
  if str then
      str = string.gsub(str, "\n", "\r\n")
      str = string.gsub(str, "([^%w %-%_%.%~])",
          function(c) return string.format("%%%02X", string.byte(c)) end)
      str = string.gsub(str, " ", "+")
  end
  return str
end

-- Function to get commandline output
---@param command string
---@return string
function get_std(command)
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
function autoEncodeReplace(original, pattern, replacement)
  local encodedPattern = pattern:gsub("[%p%c%s]", "%%%0") -- Escape special characters
  return original:gsub(encodedPattern, replacement)
end

-- Function to check if string ends with ends with
---@param str string
---@param ext string
---@return string
function str_ends_with(str, ext)
  return string.sub(str, -#ext) == ext
end

-- Function to create a Google Colab link
---@param repository string
---@param branch string
---@param notebook_path string
---@param title string
---@param badge_url string
---@return string
function create_colab_link(repository, branch, notebook_path, title, badge_url)
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
function create_binder_link(repository, branch, notebook_path, title, badge_url)
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
function create_github_link(repository, branch, notebook_path, title, badge_url)
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
function create_deepnote_link(repository, branch, notebook_path, title, badge_url)
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

-- Function to add the open .ipynb buttons to HTML, you can also add a global method: function Pandoc(doc) { }
---@param doc pandoc.Pandoc
---@return pandoc.Pandoc
function add_buttons(doc)
  local input_file = quarto.doc.input_file
  if not str_ends_with(input_file, ".ipynb") then
    return doc
  end

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
  local pdf_link_html = create_github_link(repository, branch, notebook_path, 'Download as PDF', '/images/badges/pdf.svg')
  
  -- https://github.com/feynlee/code-insertion/blob/main/_extensions/code-insertion/code-insertion.lua
  local colab_link_blocks = pandoc.read(colab_link_html, "html").blocks
  local binder_link_blocks = pandoc.read(binder_link_html, "html").blocks
  local github_link_blocks = pandoc.read(github_link_html, "html").blocks
  local deepnote_link_blocks = pandoc.read(deepnote_link_html, "html").blocks
  local pdf_link_blocks = pandoc.read(pdf_link_html, "html").blocks

  local body_blocks = pandoc.List:new{}
  body_blocks:extend(colab_link_blocks)
  body_blocks:extend(binder_link_blocks)
  body_blocks:extend(github_link_blocks)
  body_blocks:extend(deepnote_link_blocks)
  body_blocks:extend(pdf_link_blocks)
  body_blocks:extend(doc.blocks)

  local new_doc = pandoc.Pandoc(body_blocks, doc.meta)
  return new_doc
end

return {{
  -- https://quarto.org/docs/projects/binder.html#add-a-link-to-binder
  Pandoc = add_buttons
}}