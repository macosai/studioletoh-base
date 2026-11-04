-- reaper_demo.lua -- a small REAPER example for the base modules
-- This is an example, not a product. It reads the project tempo, calls the
-- base modules, and prints the results to the REAPER console.
--
-- To run it: open the Actions window, choose "New action" > "Load ReaScript",
-- and select this file. Then run it and open the console.

local script_path = ({reaper.get_action_context()})[2]
if not script_path then
  reaper.ShowConsoleMsg("Could not find the script path. Load this file from the Actions window.\n")
  return
end
local script_dir = script_path:match("^(.*)[/\\][^/\\]*$") or "."
local root = script_dir:match("^(.*)[/\\][^/\\]*$") or "."
package.path = root .. "/?.lua;" .. package.path

local timing = require("letoh.base.timing")
local db = require("letoh.base.db")
local color = require("letoh.base.color")
local registry = require("letoh.base.registry")

local function console(msg)
  reaper.ShowConsoleMsg(msg .. "\n")
end

local bpm = reaper.Master_GetTempo()
if not bpm or bpm <= 0 then bpm = 120 end

console("project tempo = " .. string.format("%.2f", bpm))
console("")

local delays = timing.delay_times(bpm)
console("delay 1/4   = " .. timing.format_ms(delays["1/4"]))
console("delay 1/8   = " .. timing.format_ms(delays["1/8"]))
local reverb = timing.reverb_times(bpm)
console("reverb pre  = " .. timing.format_ms(reverb.pre_delay))
console("reverb tail = " .. timing.format_ms(reverb.tail))
console("")

console("volume step = " .. db.format_db(db.round_to_step(-6.05, 0.1)))
console("")

local palette = color.palette.new({ slots = {
  Verse = "#5B8DBE",
  Chorus = "#E2A13F",
  Bridge = "#7BA05B",
  Drop = "#B15B5B",
}})
local assigned = palette:apply_to({ Verse = true, Chorus = true, Bridge = true, Drop = true })
console("Verse  -> " .. color.format_hex(assigned.Verse))
console("Chorus -> " .. color.format_hex(assigned.Chorus))
console("")

local defaults = { step_db = "0.1", palette = "LETOH" }
local cfg = registry.merge(defaults, registry.parse("-- user config\nstep_db=0.5\n"))
console("merged step = " .. cfg.step_db)

console("")
console("base demo finished.")
