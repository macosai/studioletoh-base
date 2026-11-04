-- db.lua -- decibel and amplitude helpers
-- Pure Lua. No reaper.* dependency.

local M = {}

--- Validate a finite dB value.
-- @param db number|string
-- @return number
function M.normalize_db(db)
  local n = tonumber(db)
  if n == nil or n ~= n or n == math.huge or n == -math.huge then
    error("db: dB value must be a finite number, got: " .. tostring(db), 2)
  end
  return n
end

--- Convert dB to linear amplitude.
-- @param db number|string
-- @return number
function M.db_to_amp(db)
  return 10 ^ (M.normalize_db(db) / 20)
end

--- Convert linear amplitude to dB. Zero maps to -inf.
-- @param amp number finite and >= 0
-- @return number
function M.amp_to_db(amp)
  if type(amp) ~= "number" or amp ~= amp or amp < 0 or amp == math.huge then
    error("db: amplitude must be a finite number >= 0, got: " .. tostring(amp), 2)
  end
  if amp == 0 then return -math.huge end
  -- The base-10 log function was removed in Lua 5.3. This form works on 5.1 and 5.4.
  return 20 * math.log(amp) / math.log(10)
end

--- Round a dB value to the nearest step.
-- @param db number|string
-- @param step number|string|nil step size in dB (default 0.1)
-- @return number
function M.round_to_step(db, step)
  local s = tonumber(step) or 0.1
  if s ~= s or s == math.huge or s == -math.huge or s <= 0 then
    error("db: step must be a finite positive number, got: " .. tostring(step), 2)
  end
  local d = M.normalize_db(db)
  return math.floor(d / s + 0.5) * s
end

--- Format a dB value for display.
-- @param db number|string
-- @return string
function M.format_db(db)
  local d = M.normalize_db(db)
  if math.abs(d) < 0.05 then return "+0.0 dB" end
  if d > 0 then return string.format("+%.1f dB", d) end
  return string.format("%.1f dB", d)
end

return M
