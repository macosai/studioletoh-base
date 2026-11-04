-- color.lua -- RGB/HEX conversion and a small named-color palette
-- Pure Lua. No reaper.* dependency.
--
-- REAPER's native color integer format is a product-side detail. This module
-- only deals with RGB triples and #RRGGBB strings. Each product's adapter
-- converts those values to the integer format its API expects.

local M = {}

--- Parse an RGB triple or HEX string into {r, g, b}.
-- @param value {r,g,b} table, {r,g,b} array, "#RRGGBB", or "RRGGBB"
-- @return table {r, g, b} with values from 0 to 255
function M.normalize_rgb(value)
  if type(value) == "table" then
    local r = tonumber(value[1] or value.r)
    local g = tonumber(value[2] or value.g)
    local b = tonumber(value[3] or value.b)
    if r and g and b and r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
      return { r = math.floor(r), g = math.floor(g), b = math.floor(b) }
    end
    error("color: invalid RGB triple: " .. tostring(value), 2)
  end
  if type(value) == "string" then
    local hex = value:gsub("^#", "")
    if #hex == 6 then
      local r = tonumber(hex:sub(1, 2), 16)
      local g = tonumber(hex:sub(3, 4), 16)
      local b = tonumber(hex:sub(5, 6), 16)
      if r and g and b then
        return { r = r, g = g, b = b }
      end
    end
    error("color: invalid HEX string, expected #RRGGBB, got: " .. tostring(value), 2)
  end
  error("color: expected an RGB table or HEX string, got " .. type(value), 2)
end

--- Format a color as "#RRGGBB". Accepts the same inputs as normalize_rgb.
-- @param rgb table or string
-- @return string
function M.format_hex(rgb)
  local c = M.normalize_rgb(rgb)
  return string.format("#%02X%02X%02X", c.r, c.g, c.b)
end

--- A palette of named color slots.
M.palette = {}
M.palette.__index = M.palette

--- Create a palette.
-- @param opts table|nil { slots = { Lead = "#E2A13F", ... } }
-- @return palette
function M.palette.new(opts)
  if opts ~= nil and type(opts) ~= "table" then
    error("color: palette.new expects a table or nil, got " .. type(opts), 2)
  end
  local o = opts or {}
  local self = setmetatable({ slots = {} }, M.palette)
  for name, value in pairs(o.slots or {}) do
    self:set(name, value)
  end
  return self
end

--- Set a named color slot.
-- @param name string
-- @param value table or string
-- @return table {r, g, b} a copy of the stored color
function M.palette:set(name, value)
  if type(name) ~= "string" or #name == 0 then
    error("color: slot name must be a non-empty string", 3)
  end
  local rgb = M.normalize_rgb(value)
  self.slots[name] = rgb
  return { r = rgb.r, g = rgb.g, b = rgb.b }
end

--- Get a color by slot name. The returned table is a copy.
-- @param name string
-- @return table {r, g, b}
function M.palette:get(name)
  local v = self.slots[name]
  if v == nil then
    error("color: unknown slot: " .. tostring(name), 3)
  end
  return { r = v.r, g = v.g, b = v.b }
end

--- List slot names in sorted order.
-- @return table array of strings
function M.palette:names()
  local names = {}
  for name in pairs(self.slots) do
    table.insert(names, name)
  end
  table.sort(names)
  return names
end

--- Assign palette colors to target names in round-robin order.
-- @param targets table<string, any> target names
-- @param order table|nil explicit assignment order; nil uses sorted target names
-- @return table<string, table> target name -> {r, g, b}
function M.palette:apply_to(targets, order)
  if type(targets) ~= "table" then
    error("color: apply_to expects a table of targets, got " .. type(targets), 3)
  end
  local names = order
  if names == nil then
    names = {}
    for k in pairs(targets) do
      if type(k) ~= "string" then
        error("color: target names must be strings", 3)
      end
      table.insert(names, k)
    end
    table.sort(names)
  elseif type(names) ~= "table" then
    error("color: order must be a table or nil, got " .. type(names), 3)
  end
  local slot_names = self:names()
  if #slot_names == 0 then
    error("color: palette has no slots", 3)
  end
  local out = {}
  for i, name in ipairs(names) do
    if type(name) ~= "string" then
      error("color: order entries must be strings", 3)
    end
    if targets[name] == nil then
      error("color: order entry not found in targets: " .. name, 3)
    end
    out[name] = self:get(slot_names[((i - 1) % #slot_names) + 1])
  end
  return out
end

return M
