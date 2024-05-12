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

-- Function to replace a base64 video with a youtube video
-- #| video-src: "https://www.youtube.com/watch?v=kCc8FmEb1nY"
---@param attribute_key string|function
---@param div pandoc.Div
---@param walk_block 'RawBlock'|'CodeBlock'
---@param walk_block_callback function
---@return pandoc.Div
local function notebook_div_walk(attribute_key, div, walk_block, walk_block_callback)
  local is_prod = (not PANDOC_STATE.trace) -- quarto preview --trace
  if not is_prod then
    return div
  end

  local attribute_value = attributes_find(div.attr.attributes, attribute_key)
  if attribute_value then
    local walker = {
      ---@param block pandoc.RawBlock|pandoc.CodeBlock
      ---@return pandoc.RawBlock|pandoc.CodeBlock
      [walk_block] = function (block)
        return walk_block_callback(block, attribute_value)
      end,  
    }
    
    if is_output_cell(div) then
      div = div:walk(walker)
    else
      -- This is a flag to ensure we duscard other output cells if more than one exist.
      -- If we need more than one output cell, we will create a setting/config for that
      local has_matched = false
      div = div:walk{
        ---@param inner_div pandoc.Div
        ---@return pandoc.Div
        Div = function (inner_div)
          if is_output_cell(inner_div) then
            if not has_matched then
              has_matched = true
              inner_div = inner_div:walk(walker)
            else
              inner_div = pandoc.Str ''
            end
          end
          return inner_div
        end, 
      }
    end
  end
  return div
end

return notebook_div_walk