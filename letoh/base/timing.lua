-- timing.lua -- tempo math for ReaScripts
-- Pure Lua. No reaper.* dependency.
--
-- These functions take a BPM value from the caller. They do not read the
-- project tempo. The product-side adapter does that and passes the value in.

local M = {}

local function finite_positive(value, label)
  local n = tonumber(value)
  if n == nil or n ~= n or n == math.huge or n == -math.huge or n <= 0 then
    error("timing: " .. label .. " must be a finite positive number, got: " .. tostring(value), 2)
  end
  return n
end

--- Validate a BPM value.
-- @param bpm number|string
-- @return number
function M.normalize_bpm(bpm)
  return finite_positive(bpm, "bpm")
end

--- Milliseconds per beat.
-- @param bpm number|string
-- @return number
function M.ms_per_beat(bpm)
  return 60000.0 / M.normalize_bpm(bpm)
end

--- Tempo-synced delay times in milliseconds.
-- @param bpm number|string
-- @return table with keys "1/1", "1/2", "1/4", "1/8", "1/16", "1/32"
function M.delay_times(bpm)
  local beat = M.ms_per_beat(bpm)
  return {
    ["1/1"] = beat * 4,
    ["1/2"] = beat * 2,
    ["1/4"] = beat,
    ["1/8"] = beat / 2,
    ["1/16"] = beat / 4,
    ["1/32"] = beat / 8,
  }
end

--- A simple reverb timing suggestion. These are starting points, not rules.
-- @param bpm number|string
-- @return table { pre_delay = number, tail = number }
function M.reverb_times(bpm)
  local beat = M.ms_per_beat(bpm)
  return {
    pre_delay = beat / 8,
    tail = beat * 8,
  }
end

--- Duration of one bar in milliseconds.
-- @param bpm number|string
-- @param beats_per_bar number|string (for example 4 for 4/4)
-- @return number
function M.bar_duration_ms(bpm, beats_per_bar)
  local beats = finite_positive(beats_per_bar, "beats_per_bar")
  return M.ms_per_beat(bpm) * beats
end

--- Convert milliseconds to PPQ.
-- @param ms number
-- @param bpm number|string
-- @param ppq_qn number|string PPQ per quarter note (for example 960)
-- @return number
function M.ms_to_ppq(ms, bpm, ppq_qn)
  local value = tonumber(ms)
  if value == nil or value ~= value or value == math.huge or value == -math.huge or value < 0 then
    error("timing: ms must be a finite number >= 0, got: " .. tostring(ms), 2)
  end
  local ppq = finite_positive(ppq_qn, "ppq_qn")
  return (value * M.normalize_bpm(bpm) * ppq) / 60000.0
end

--- Convert PPQ to milliseconds.
-- @param ppq number
-- @param bpm number|string
-- @param ppq_qn number|string
-- @return number
function M.ppq_to_ms(ppq, bpm, ppq_qn)
  local value = tonumber(ppq)
  if value == nil or value ~= value or value == math.huge or value == -math.huge or value < 0 then
    error("timing: ppq must be a finite number >= 0, got: " .. tostring(ppq), 2)
  end
  local ppq_qn_value = finite_positive(ppq_qn, "ppq_qn")
  return (value * 60000.0) / (M.normalize_bpm(bpm) * ppq_qn_value)
end

--- Format milliseconds for display.
-- @param ms number
-- @return string
function M.format_ms(ms)
  local value = tonumber(ms)
  if value == nil or value ~= value or value == math.huge or value == -math.huge then
    error("timing: format_ms expects a finite number, got: " .. tostring(ms), 2)
  end
  return string.format("%.1f ms", value)
end

return M
