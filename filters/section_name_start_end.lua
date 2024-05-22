local attributes = require "utils.attributes"
local str_starts_with = require "utils.str_starts_with"

-- any_child_match
---@param element pandoc.Block|pandoc.Inline
---@param predicate function - takes current element and returns true
---@return any - predicate result
any_child_match = function (element, predicate)
  if element then
    local predicate_result = predicate(element)
    if predicate_result then
      return predicate_result
    end
  end
    
  if element and element.content and #element.content > 0 then
    for _, sub_element in ipairs(element.content) do
      local predicate_result = any_child_match(sub_element, predicate)
      if predicate_result then
        return predicate_result
      end
    end
  end
  return false
end

-- section_name_elements_walker
---@param elements pandoc.List|pandoc.Blocks|pandoc.Inlines - elements
---@param parent_predicate function - returns the parent which match the given predicate
---@param child_redicate function - takes current element and returns true
---@param callback function - takes current element and meta; returns new element or nil and new meta
---@return pandoc.List
function section_name_elements_walker (elements, parent_predicate, child_redicate, callback, get_and_update_meta)
  local new_elements = pandoc.List:new{}
  if elements and #elements > 0 then
    for _, element in ipairs(elements) do
      local child_result = any_child_match(element, child_redicate)
      if parent_predicate(element) and child_result then
        local meta, update_meta = get_and_update_meta()
        local new_element, new_meta = callback(child_result, element, meta)
        update_meta(new_meta)
        if new_element then
          new_elements:insert(new_element)
        end
      else
        if element.content then
          element.content = section_name_elements_walker(element.content, parent_predicate, child_redicate, callback, get_and_update_meta)
        end
        new_elements:insert(element)
      end
    end
  end
  return new_elements
end

-- parent_predicate_fn
---@param element pandoc.Block|pandoc.Inline - element
---@return true
local parent_predicate_fn = function (element)
  return element and element.content and #element.content == 1
end

local section_starts_with = 'section-name-'

-- child_redicate_fn
---@param element pandoc.Block|pandoc.Inline - element
---@return any
local child_redicate_fn = function (element)
  local attr_value =  attributes.get_attribute_value(
    element,
    function (key)
      return str_starts_with(key, section_starts_with)
    end)

  return attr_value
end

-- Function to extract section name
---@param section_name table<'key'|'value', string>
---@param block pandoc.Block
---@param meta pandoc.MetaBlocks
---@return pandoc.Block|nil,pandoc.MetaBlocks
local function extract_section_name(section_name, block, meta)
  meta[section_name.value] = pandoc.MetaString(pandoc.utils.stringify(block))
  return nil, meta
end

return {
  Pandoc = function(doc)
    local meta = doc.meta
    local get_and_update_meta = function ()
      return meta, function (updated_meta)
        meta = updated_meta
      end
    end
    local blocks = section_name_elements_walker(
      doc.blocks, 
      parent_predicate_fn, 
      child_redicate_fn, 
      extract_section_name, 
      get_and_update_meta)

    return pandoc.Pandoc(blocks, meta)
  end
}



-- -- Sample HTML comment
-- local comment = "<!-- { ['section-name-start'] = 'description', same = 2 } -->"

-- -- Define a pattern to capture the content inside the HTML comment
-- local pattern = "<!%-%-%s*{(.-)}%s*%-%->"

-- -- Extract the content inside the HTML comment
-- local content = string.match(comment, pattern)

-- print(content)

-- local table = load("return { " .. content .. '}')()

-- print(table)

-- -- Print the resulting table to verify
-- for k, v in pairs(table) do
--     print(k, v)
-- end