local ternary = require "utils.ternary"

-- Function to find and return an atribute
---@param attributes table<string, string>
---@param key string|function - a string key of a function that returns bool-ish!
---                             The function accepts a key,value pair and their result is returned
---                             If a string key is passed, only the value is returned
---@return string|nil|table<string, string>
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
    local is_match = predicate(k, v)
    if is_match then
      return is_match
    end
  end
  return nil
end

-- Function to get
---@param block pandoc.Block
---@param attribute_key string|function - a string key of a function that returns bool-ish!
---                             The function accepts a key,value pair and their result is returned
---                             If a string key is passed, only the value is returned
---@return boolean|string|nil|table<string, string>
local get_attribute_value = function(block, attribute_key)
  if block.attr and block.attr.attributes then
    return attributes_find(block.attr.attributes, attribute_key)
  end
  return false
end

---comment
---@param attribute_value boolean|string|table<string, string>
---@param block pandoc.Block
---@param main_meta pandoc.MetaBlocks
---@param walk_callback function
---@return pandoc.Block,pandoc.MetaBlocks
local walk_callback_proxy = function (attribute_value, block, main_meta, walk_callback)
  local nparams = debug.getinfo(walk_callback).nparams
  if nparams == 3 then
    return walk_callback(attribute_value, block, main_meta)
  else
    local sub_block = walk_callback(attribute_value, block)
    return sub_block, main_meta
  end
end

-- Function to parse quarto special comments, such as:
--        #| video-src: "https://www.youtube.com/watch?v=kCc8FmEb1nY"
--        #| output-when-format: "{format}"
--        #| output-when-format-{format}: "{template}"
---@param attribute_key string|function - comment name: video-src, output-when-format, output-when-format-{format}
---@param walk_callback function - a function that receives a pandoc.Block and returns a pandoc.Block, or
--                               - a function that receives (pandoc.Block,pandoc.MetaBlocks) and returns (pandoc.Block,pandoc.MetaBlocks)
---@param predicate function|nil - an optional predicate function that receives pandoc.Block and returns a boolean
---@return table<pandoc.Pandoc, function>
local notebook_special_comments_walker = function(attribute_key, walk_callback, predicate)
  return {
    Pandoc = function(doc)
      local main_meta = doc.meta
      local new_doc = doc:walk{
        ---@param blocks pandoc.Blocks
        Blocks = function (blocks)
          local new_blocks = pandoc.List:new{}
          ---@param block pandoc.Block
          for _, block in ipairs(blocks) do
            local attribute_value = get_attribute_value(block, attribute_key)
            if attribute_value then
              if predicate and block.walk then
                local new_block = block:walk {
                  ---@param sub_blocks pandoc.Blocks
                  Blocks = function (sub_blocks)
                    local new_sub_blocks = pandoc.List:new{}
                    for _, sub_block in ipairs(sub_blocks) do
                      if (predicate(sub_block)) then
                        local new_sub_block, new_sub_block_meta = walk_callback_proxy(attribute_value, sub_block, main_meta, walk_callback)
                        main_meta = new_sub_block_meta
                        new_sub_blocks:insert(new_sub_block)
                      else
                        new_sub_blocks:insert(sub_block)
                      end
                    end
                    return new_sub_blocks
                  end
                }
                new_blocks:insert(new_block)
              else
                local new_block, new_block_meta = walk_callback_proxy(attribute_value, block, main_meta, walk_callback)
                main_meta = new_block_meta
                new_blocks:insert(new_block)
              end
            else
              new_blocks:insert(block)
            end
          end
          return new_blocks
        end
      }
      return pandoc.Pandoc(new_doc.blocks, main_meta)
    end
  }
end

return notebook_special_comments_walker