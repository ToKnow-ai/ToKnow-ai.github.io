-- Function to get commandline output
function get_std(command)
  local handle = assert(io.popen(command))
  local result = handle:read("*a")
  handle:close()
  return result:sub(1, -2) -- Trim the trailing newline
end

-- Function to automatically encode and replace a substring
local function autoEncodeReplace(original, pattern, replacement)
  local encodedPattern = pattern:gsub("[%p%c%s]", "%%%0") -- Escape special characters
  return original:gsub(encodedPattern, replacement)
end

-- test ends with
function ends_with_extension(str, ext)
  return string.sub(str, -#ext) == ext
end

function create_link(repository, branch, notebook_path, title, badge_url)
  return 
    '<a \
      href="https://colab.research.google.com/github/' .. repository .. '/blob/' .. branch .. notebook_path .. '" \
      aria-label="' .. title .. '" \
      title="' .. title ..'">\
      <img src="' .. badge_url .. '" aria-label="' .. title .. '" title="' .. title .. '" />\
    </a>'
end

function Pandoc(doc)
  local input_file = quarto.doc.input_file
  if not ends_with_extension(input_file, ".ipynb") then
    return doc
  end

  local repository_username = "ToKnow-ai"
  -- https://stackoverflow.com/a/42543006
  local repository_name = get_std("basename -s .git `git config --get remote.origin.url`")
  local repository = repository_username .. "/" .. repository_name
  local branch = get_std("git rev-parse --abbrev-ref HEAD")
  local git_dir = get_std("git rev-parse --show-toplevel")
  local notebook_path = autoEncodeReplace(input_file, git_dir, "")
  local link_html = create_link(repository, branch, notebook_path, 'Open in Colab', '../../images/badges/colab.svg')
  -- https://github.com/feynlee/code-insertion/blob/main/_extensions/code-insertion/code-insertion.lua
  link_blocks = pandoc.read(link_html, "html").blocks
  link_blocks:extend(doc.blocks)
  local new_doc = pandoc.Pandoc(link_blocks, doc.meta)
  return new_doc
end