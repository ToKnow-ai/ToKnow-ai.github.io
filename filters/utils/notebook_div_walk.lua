local ternary = require "utils.ternary"

-- Function to find and return an atribute
---@param attributes table<string, string>
---@param key string|function - a string key of a function that returns bool-ish!
---                             The function accepts a key,value pair and their result is returned
---                             If a string key is passed, only the value is returned
---@return string|nil
local function attributes_find(attributes, key)
  local predicate = ternary(
    type(key) == "string",
    ---@param k string
    ---@return string|boolean
    function (k, v)
      if k == key then
        return v
      end
      return false
    end,
    key)
  for k, v in pairs(attributes) do
    is_match = predicate(k, v)
    if is_match then
      return is_match
    end
  end
  return nil
end

-- Function to find cell output block
---@param div pandoc.Div
---@return boolean
local function is_output_cell(div)
  return div.attr.classes:includes("cell-output")
end

---div_walk_iterator
---@param attribute_value table<string, string>|string
---@param div pandoc.Div
---@param div_walk_callback function - a function that accepts a pandoc.Div and returns a pandoc.Div
---@return pandoc.Div
function div_walk_iterator(attribute_value, div, div_walk_callback)
  if div and is_output_cell(div) then
    div = div_walk_callback(div, attribute_value)
  elseif div and #div.content > 0 then
    div = div:walk{
      ---@param inner_div pandoc.Div
      ---@return pandoc.Div
      Div = function (inner_div)
        return div_walk_iterator(attribute_value, inner_div, div_walk_callback)
      end, 
    }
  end
  return div
end

-- Function to replace a base64 video with a youtube video
-- #| video-src: "https://www.youtube.com/watch?v=kCc8FmEb1nY"
---@param attribute_key string|function
---@param div pandoc.Div
---@param div_walk_callback function - a function that accepts a pandoc.Div and returns a pandoc.Div
---@return pandoc.Div
local function notebook_div_walk(attribute_key, div, div_walk_callback)
  local attribute_value = attributes_find(div.attr.attributes, attribute_key)
  if attribute_value then
    return div_walk_iterator(attribute_value, div, div_walk_callback)
  end
  return div
end

return notebook_div_walk