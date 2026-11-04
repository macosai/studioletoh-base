-- registry.lua -- a small key=value config parser
-- Pure Lua. No reaper.* dependency.
--
-- This module only parses and builds text. Where the file lives, and when it
-- is read or written, is up to the product-side adapter.
--
-- Format:
--   key=value
--   -- comment
--   blank lines are ignored
-- Parsed values are strings. Leading and trailing whitespace is trimmed. If
-- the same key appears twice, the last value wins.

local M = {}

--- Parse key=value text.
-- @param text string
-- @return table<string, string>
function M.parse(text)
  if type(text) ~= "string" then
    error("registry: parse expects a string, got " .. type(text), 2)
  end
  if text:sub(1, 3) == "\239\187\191" then
    text = text:sub(4)
  end
  local out = {}
  for line in text:gmatch("[^\r\n]+") do
    local trimmed = line:match("^%s*(.-)%s*$")
    if #trimmed > 0 and trimmed:sub(1, 2) ~= "--" then
      local key, value = trimmed:match("^([^=]+)=(.*)$")
      if key == nil then
        error("registry: malformed line (expected key=value): " .. trimmed, 2)
      end
      local clean_key = key:match("^%s*(.-)%s*$")
      if #clean_key == 0 then
        error("registry: key must not be empty", 2)
      end
      out[clean_key] = value:match("^%s*(.-)%s*$")
    end
  end
  return out
end

--- Serialize a table into stable key=value text. Keys are sorted.
-- @param data table<string, string|number|boolean>
-- @return string
function M.serialize(data)
  if type(data) ~= "table" then
    error("registry: serialize expects a table, got " .. type(data), 2)
  end
  local keys = {}
  for k in pairs(data) do
    if type(k) ~= "string" then
      error("registry: keys must be strings, got " .. type(k), 2)
    end
    if #k == 0 then
      error("registry: key must not be empty", 2)
    end
    if k ~= k:match("^%s*(.-)%s*$") then
      error("registry: key has leading or trailing whitespace: " .. k, 2)
    end
    if k:sub(1, 2) == "--" then
      error("registry: key must not start with '--': " .. k, 2)
    end
    if k:find("[=\r\n]") then
      error("registry: key contains '=', CR, or LF: " .. k, 2)
    end
    table.insert(keys, k)
  end
  table.sort(keys)
  local parts = {}
  for _, k in ipairs(keys) do
    local raw = data[k]
    local kind = type(raw)
    if kind ~= "string" and kind ~= "number" and kind ~= "boolean" then
      error("registry: value for '" .. k .. "' must be a string, number, or boolean, got " .. kind, 2)
    end
    local v = tostring(raw)
    if v:find("[\r\n]") then
      error("registry: value for '" .. k .. "' contains CR or LF", 2)
    end
    if v ~= v:match("^%s*(.-)%s*$") then
      error("registry: value for '" .. k .. "' has leading or trailing whitespace", 2)
    end
    table.insert(parts, k .. "=" .. v)
  end
  if #parts == 0 then return "" end
  return table.concat(parts, "\n") .. "\n"
end

--- Shallow merge. Values from override win.
-- @param base table|nil
-- @param override table|nil
-- @return table
function M.merge(base, override)
  local out = {}
  if type(base) == "table" then
    for k, v in pairs(base) do out[k] = v end
  end
  if type(override) == "table" then
    for k, v in pairs(override) do out[k] = v end
  end
  return out
end

return M
