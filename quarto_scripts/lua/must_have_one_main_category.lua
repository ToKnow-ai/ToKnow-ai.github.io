local read_metadata = require "utils.read_metadata"

-- compare_categories
---@param main_categories table
---@param sub_categories table
---@return boolean
local compare_categories = function(main_categories, sub_categories)
  for _, main_category in ipairs(main_categories) do
    for _, sub_category in ipairs(sub_categories) do
      if pandoc.utils.stringify(main_category) == pandoc.utils.stringify(sub_category) then
        return true
      end
    end
  end
  return false
end

local function tableToListString(t, stringfy)
  stringfy = stringfy or tostring
  local result = "["
  for i, v in ipairs(t) do
    result = result .. stringfy(v)
    if i < #t then
      result = result .. ", "
    end
  end
  return result .. "]"
end

return {
  compare_categories = compare_categories,

  ---@param doc pandoc.Pandoc
  ---@return pandoc.Pandoc|nil
  Pandoc = function (doc)
    local main_categories = read_metadata(quarto.project.directory .. '/_index.yml')['enforce-categories'] or {}
    local sub_categories = doc.meta['categories'] or {}
    local is_draft = doc.meta['draft'] == true
    local has_main_category =
        type(main_categories) == "table" and
        type(sub_categories) == "table" and
        compare_categories(main_categories, sub_categories)
    if not has_main_category and not is_draft then
      error(
        quarto.doc.input_file .. " HAS NO MAIN CATEGORY!" 
        .. " has_main_category=" .. pandoc.utils.stringify(has_main_category)
        .. " main_categories=" .. tableToListString(main_categories, pandoc.utils.stringify)
        .. " sub_categories=" .. tableToListString(sub_categories, pandoc.utils.stringify))
      os.exit(1)  -- Exit with a status code (non-zero indicates an error)
      return
    end
    return doc
  end
}
