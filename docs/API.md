# API reference

All modules return a table. Functions raise a Lua error when the input is invalid. The error message starts with the module name, for example `timing: bpm must be a finite positive number`.

If you need to handle errors without stopping the script, wrap the call in `pcall`.

```lua
local timing = require("letoh.base.timing")

local ok, result = pcall(timing.ms_per_beat, 0)
if not ok then
  print(result)
end
```

## letoh.base.timing

### normalize_bpm(bpm)

Returns `bpm` as a number. Raises an error if the value is not a finite positive number.

### ms_per_beat(bpm)

Returns the number of milliseconds in one beat.

```lua
timing.ms_per_beat(120) -- 500.0
```

### delay_times(bpm)

Returns a table of tempo-synced delay times in milliseconds. The keys are `"1/1"`, `"1/2"`, `"1/4"`, `"1/8"`, `"1/16"`, and `"1/32"`.

```lua
local d = timing.delay_times(120)
print(d["1/4"]) -- 500.0
```

### reverb_times(bpm)

Returns a table with `pre_delay` and `tail` in milliseconds. These are starting points, not a rule. `pre_delay` is one eighth of a beat, and `tail` is eight beats.

```lua
local r = timing.reverb_times(120)
print(r.pre_delay) -- 62.5
print(r.tail)      -- 4000.0
```

### bar_duration_ms(bpm, beats_per_bar)

Returns the length of one bar in milliseconds.

```lua
timing.bar_duration_ms(120, 4) -- 2000.0
```

`beats_per_bar` must be a finite positive number. For 4/4, pass `4`. For 3/4, pass `3`.

### ms_to_ppq(ms, bpm, ppq_qn)

Converts milliseconds to PPQ. `ppq_qn` is the PPQ value for one quarter note, for example `960`.

```lua
timing.ms_to_ppq(500, 120, 960) -- 960.0
```

`ms` must be finite and at least 0. `ppq_qn` must be finite and greater than 0.

### ppq_to_ms(ppq, bpm, ppq_qn)

The inverse of `ms_to_ppq`.

```lua
timing.ppq_to_ms(960, 120, 960) -- 500.0
```

### format_ms(ms)

Returns a string with one decimal place and the `ms` suffix.

```lua
timing.format_ms(123.456) -- "123.5 ms"
```

## letoh.base.db

### normalize_db(db)

Returns `db` as a number. Raises an error if the value is not finite.

### db_to_amp(db)

Converts dB to linear amplitude.

```lua
db.db_to_amp(0)  -- 1.0
db.db_to_amp(-6) -- about 0.5012
```

### amp_to_db(amp)

Converts linear amplitude to dB. `amp` must be finite and at least 0. Zero returns `-math.huge`.

```lua
db.amp_to_db(0.5) -- about -6.0206
db.amp_to_db(0)   -- -math.huge
```

### round_to_step(db, step)

Rounds a dB value to the nearest step. The default step is `0.1`.

```lua
db.round_to_step(-6.05, 0.1) -- -6.0
db.round_to_step(6.06, 0.1)  -- 6.1
```

The result uses binary floating point. A value exactly on a step boundary can round either way. If you compare results in a test, use a tolerance.

### format_db(db)

Returns a display string with a sign and one decimal place.

```lua
db.format_db(-6)    -- "-6.0 dB"
db.format_db(0)     -- "+0.0 dB"
db.format_db(6)     -- "+6.0 dB"
db.format_db(-0.01) -- "+0.0 dB"
```

## letoh.base.color

### normalize_rgb(value)

Accepts an RGB table or a hex string and returns `{ r, g, b }` with values from 0 to 255.

```lua
color.normalize_rgb("#FF8000")          -- { r = 255, g = 128, b = 0 }
color.normalize_rgb("ff8000")           -- { r = 255, g = 128, b = 0 }
color.normalize_rgb({ r = 255, g = 128, b = 0 })
color.normalize_rgb({ 255, 128, 0 })
```

Fractional values are floored. Values outside 0 to 255 are rejected.

### format_hex(rgb)

Returns an uppercase `#RRGGBB` string. It accepts the same inputs as `normalize_rgb`.

```lua
color.format_hex({ r = 255, g = 128, b = 0 }) -- "#FF8000"
color.format_hex("#ff8000")                   -- "#FF8000"
```

### color.palette.new(opts)

Creates a palette. `opts` is optional. Use `opts.slots` to set initial colors.

```lua
local p = color.palette.new({
  slots = {
    Verse = "#5B8DBE",
    Chorus = "#E2A13F",
  },
})
```

### palette:set(name, value)

Sets a slot and returns a copy of the stored color. The name must be a non-empty string.

### palette:get(name)

Returns a copy of the color in a slot. Raises an error if the slot does not exist.

### palette:names()

Returns the slot names in sorted order.

### palette:apply_to(targets, order)

Assigns colors to target names in round-robin order.

- `targets` is a table. Its keys are the target names.
- `order` is optional. If you omit it, the target names are sorted. If you pass it, the order is used as given.
- Every name in `order` must exist in `targets`.
- The palette must have at least one slot.

```lua
local p = color.palette.new({
  slots = { A = "#000000", B = "#FFFFFF" },
})
local out = p:apply_to({ Verse = true, Chorus = true })
print(color.format_hex(out.Chorus)) -- "#000000"
print(color.format_hex(out.Verse))  -- "#FFFFFF"
```

## letoh.base.registry

### parse(text)

Parses `key=value` text and returns a table of strings.

Rules:

- Blank lines are ignored.
- Lines that start with `--` are comments.
- A line without `=` is an error.
- Keys and values are trimmed.
- If a key appears twice, the last value wins.
- A UTF-8 BOM at the start of the text is ignored.

```lua
local cfg = registry.parse("-- user config\nstep_db=0.5\n")
print(cfg.step_db) -- "0.5"
```

### serialize(data)

Builds stable `key=value` text. Keys are sorted, and the output ends with a newline.

```lua
registry.serialize({ b = 2, a = 1 }) -- "a=1\nb=2\n"
```

`serialize` rejects data that would produce text that `parse` cannot read back cleanly:

- keys that are not strings
- empty keys
- keys with leading or trailing whitespace
- keys that start with `--`
- keys that contain `=`, CR, or LF
- values that are not strings, numbers, or booleans
- values that contain CR or LF
- values with leading or trailing whitespace

An empty table returns an empty string.

### merge(base, override)

Returns a shallow copy of `base` with the values from `override` on top. The inputs are not changed.

```lua
local cfg = registry.merge({ step_db = "0.1" }, { step_db = "0.5" })
print(cfg.step_db) -- "0.5"
```

## letoh.base.version

The module returns a table:

```lua
local version = require("letoh.base.version")
print(version.name)    -- "Studio LETOH Base"
print(version.version) -- "0.1.0"
print(version.api)     -- 1
```

`version.version` is the library version. `version.api` goes up when the API breaks.
