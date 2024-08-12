-- This filter must be used in conjunction with `markdown_code_options.py`
-- It parses the markdown in code cells

local notebook_special_comments_walker = require "utils.notebook_special_comments_walker"

local MARKDOWN_CODE_CELL = 'is-a-markdown-code-cell'

---@param _attribute table<"key"|"value", string>
---@param div pandoc.Div
---@return pandoc.Div
local function code_to_markdown(_attribute, div)
    --- @type pandoc.CodeBlock
    local code_block = div.content[1]
    if code_block.text and code_block.t == "CodeBlock" then
        local blocks = quarto.utils.string_to_blocks(code_block.text)
        div.content = blocks
    end
    return div
end

---predicate
---@param attribute_key string
---@return boolean
local function predicate(attribute_key)
    return attribute_key == MARKDOWN_CODE_CELL
end

return notebook_special_comments_walker(predicate, code_to_markdown)