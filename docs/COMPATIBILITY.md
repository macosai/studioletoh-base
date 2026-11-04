# Compatibility

## Lua

The library targets Lua 5.1 and later. It avoids syntax and library calls that were added after 5.1.

CI runs the tests on Lua 5.1 and Lua 5.4. REAPER 6.x and 7.x use Lua 5.4.

LuaJIT is not part of the CI matrix. The code uses Lua 5.1 syntax and standard functions, so it should work. If you depend on LuaJIT, run `tests/run.lua` with it before you ship.

## REAPER

The base layer does not call `reaper.*`. It does not need REAPER to run. The REAPER version only matters to the product that uses the library.

The example in `examples/reaper_demo.lua` uses `reaper.get_action_context`, `reaper.Master_GetTempo`, and `reaper.ShowConsoleMsg`. Those calls are in the example, not in `letoh/base`.

## Operating systems

The base layer has no path handling. It works on Windows, macOS, and Linux. The product adapter decides where files live and how paths are built.

## Floating point

`db.round_to_step` uses binary floating point. A value exactly on a step boundary can round either way. For example, `6.05` may become `6.0` or `6.1` depending on how the division lands.

If you compare rounded values in a test, use a tolerance instead of exact equality.

## Color

The library uses RGB triples with values from 0 to 255 and `#RRGGBB` strings. It does not know about REAPER's native color integer format. The product adapter converts RGB to that format.

## Config text

`letoh.base.registry` reads and writes simple `key=value` text.

- LF and CRLF line endings are accepted.
- A UTF-8 BOM at the start is ignored.
- Comments start with `--` at the beginning of a line.
- Values are strings. Leading and trailing whitespace is trimmed.
- Duplicate keys use the last value.
- `serialize` rejects values that would not round-trip.

The format is intentionally small. If you need nested data, quoting, or escaping, use a real format such as JSON and keep it in the product adapter.

## Versioning

The library uses semantic versioning.

- Patch releases fix bugs without changing the API.
- Minor releases add functions or optional behavior.
- Major releases change or remove existing behavior.

`letoh.base.version.api` goes up when the API breaks. A product can check it at load time if it needs a specific level.
