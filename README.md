# Studio LETOH Base

[![test](https://github.com/macosai/studioletoh-base/actions/workflows/test.yml/badge.svg)](https://github.com/macosai/studioletoh-base/actions/workflows/test.yml)

Studio LETOH Base is a small Lua library for the parts of ReaScript work that keep coming back: tempo math, dB conversion, RGB/HEX colors, and a simple key=value config format.

It has no `reaper.*` calls. It does not draw a UI, read project files, or install anything. Those jobs belong to the product that uses the library.

## Who this is for

This is for Lua developers who write ReaScripts and want tested helpers for tempo math, dB conversion, colors, and simple config text. It is also for people who want to see the foundation we are building for the Studio LETOH tools.

If you want a finished tool, use the [Studio LETOH store](https://store.letoh.jp). If you bought a product, its complete Lua source is in the download.

## What is in here

| Module                | What it does                                                                  |
| --------------------- | ----------------------------------------------------------------------------- |
| `letoh.base.timing`   | BPM to milliseconds, delay and reverb suggestions, bar length, PPQ conversion |
| `letoh.base.db`       | dB to amplitude and back, step rounding, display formatting                   |
| `letoh.base.color`    | RGB/HEX parsing, formatting, and a small named-color palette                  |
| `letoh.base.registry` | Parse and serialize `key=value` text                                          |
| `letoh.base.version`  | Name, version, and API level                                                  |

The modules do not require each other. You can use `timing` without pulling in `color`, and the tests run each module on its own.

## Documentation

- [API reference](docs/API.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Compatibility](docs/COMPATIBILITY.md)
- [Release checklist](docs/RELEASE.md)

## What this is not

This is not a ReaScript product. It has no windows, actions, installers, or manuals. If you want a finished tool, look at the [Studio LETOH store](https://store.letoh.jp).

This is not the product source. The product code stays private. The public repo is the foundation layer only.

This is not the [Palette](https://store.letoh.jp/b/palette) product. `color.palette` is a small helper for named color slots. The Palette product is an action palette, and its code is not in this repo.

This is not a REAPER wrapper. If a function needs the project tempo, the product reads it and passes it in. If a function needs a REAPER color integer, the product converts it.

## Products

The product code is not in this repository. These are the finished tools that ship with their own source, installers, and manuals:

- [HueGuide](https://store.letoh.jp/b/hueguide) and [HueGuide Free](https://store.letoh.jp/b/hueguide-free)
- [Palette](https://store.letoh.jp/b/palette)
- [Scribe](https://store.letoh.jp/b/scribe)
- [Gauge](https://store.letoh.jp/b/gauge)
- [RDMetric](https://store.letoh.jp/b/rdmetric)
- [Chisel](https://store.letoh.jp/b/chisel) and [Chisel Free](https://store.letoh.jp/b/chisel-free)

The base is the foundation we are building for these tools. It is not a product.

## Requirements

- Lua 5.1 or later. REAPER 6.x and 7.x use Lua 5.4.
- No external Lua modules.
- No REAPER installation for the tests or the pure-Lua example.

## Install

Copy the `letoh/` folder into your script folder, or keep this repo next to your script. Then add the parent folder to `package.path`.

```lua
package.path = "/path/to/studioletoh-base/?.lua;" .. package.path

local timing = require("letoh.base.timing")
local db = require("letoh.base.db")
```

On Windows, use forward slashes or escape the backslashes. `package.path` follows the same rules as any other Lua path.

## Quick start

```lua
local timing = require("letoh.base.timing")
local db = require("letoh.base.db")

local bpm = 120
print(timing.format_ms(timing.ms_per_beat(bpm))) -- 500.0 ms
print(db.format_db(db.round_to_step(-6.05, 0.1))) -- -6.0 dB
```

## Examples

`examples/pure_lua.lua` runs without REAPER:

```sh
lua examples/pure_lua.lua
lua5.4 examples/pure_lua.lua
```

`examples/reaper_demo.lua` is a small REAPER script. Load it from the Actions window and run it. It reads the project tempo and prints the results to the console. It does not change the project.

## Tests

```sh
lua tests/run.lua
lua5.4 tests/run.lua
```

CI runs the same tests on Lua 5.1 and 5.4. It also checks that every Lua file parses and that `letoh/base` has no `reaper.*` calls.

## Design rules

1. `letoh/base` does not call `reaper.*`.
2. `letoh/base` does not read or write files.
3. The modules do not keep global state.
4. The modules do not require each other.
5. Product-specific defaults stay in the product.
6. Tests must run with plain Lua.

These rules are what make the library testable outside REAPER. If a change breaks one of them, it probably belongs in a product adapter instead.

## License

Source-available, not open-source. You can read, run, and modify the code for your own personal use. Resale, sublicensing, and redistribution are not allowed. Commercial use needs a separate written license. The code comes as-is, with no support or warranty.

See [LICENSE.md](LICENSE.md) for the full terms. Product support is separate and comes with a paid product.

## Support

Use [GitHub Issues](https://github.com/macosai/studioletoh-base/issues) for bugs in the base library. For product support, use the contact page on the [Studio LETOH store](https://store.letoh.jp).

If you find a security problem, contact us through the store instead of opening a public issue.

## Contributing

Bug reports and documentation fixes are welcome. Pull requests are not accepted by default. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Versioning

The library uses semantic versioning. `letoh.base.version.api` goes up when the API breaks. See [CHANGELOG.md](CHANGELOG.md).

## About Studio LETOH

Studio LETOH is a sound studio in Japan. We make music, sound design, spatial audio, and data sonification, and we run a small recording studio. We also build tools for REAPER. The links below cover the studio, the services, and the store.

## Links

- Studio: https://letoh.jp
- Profile: https://letoh.jp/profile/
- Services: https://letoh.jp/order/
- Store: https://store.letoh.jp
- Terms: https://store.letoh.jp/legal-disclosure-based-on-japan-s-specified-commercial-transactions-act
- Issues: https://github.com/macosai/studioletoh-base/issues
