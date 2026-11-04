-- pure_lua.lua -- run the base modules without REAPER
-- Usage:
--   lua examples/pure_lua.lua
--   lua5.4 examples/pure_lua.lua

local info = debug.getinfo(1, "S")
local script_path = info.source:match("^@?(.*)$")
local script_dir = script_path:match("^(.*)[/\\][^/\\]*$") or "."
local root = script_dir:match("^(.*)[/\\][^/\\]*$") or "."
package.path = root .. "/?.lua;" .. package.path

local timing = require("letoh.base.timing")
local db = require("letoh.base.db")
local color = require("letoh.base.color")
local registry = require("letoh.base.registry")
local version = require("letoh.base.version")

print(version.name .. " " .. version.version)
print("")

local bpm = 96
local delays = timing.delay_times(bpm)
print("delay 1/4   = " .. timing.format_ms(delays["1/4"]))
print("delay 1/8   = " .. timing.format_ms(delays["1/8"]))
local reverb = timing.reverb_times(bpm)
print("reverb pre  = " .. timing.format_ms(reverb.pre_delay))
print("reverb tail = " .. timing.format_ms(reverb.tail))
print("")

print("volume step = " .. db.format_db(db.round_to_step(-6.05, 0.1)))
print("")

local palette = color.palette.new({ slots = {
  Verse = "#5B8DBE",
  Chorus = "#E2A13F",
  Bridge = "#7BA05B",
  Drop = "#B15B5B",
}})
local assigned = palette:apply_to({ Verse = true, Chorus = true, Bridge = true, Drop = true })
for _, name in ipairs(palette:names()) do
  print(name .. " -> " .. color.format_hex(assigned[name]))
end
print("")

local defaults = { step_db = "0.1", palette = "LETOH" }
local cfg = registry.merge(defaults, registry.parse("-- user config\nstep_db=0.5\n"))
print("merged step = " .. cfg.step_db)
