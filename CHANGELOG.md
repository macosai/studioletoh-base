# Changelog

All notable changes to this project are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-11-04

### Added

- `letoh.base.timing` with BPM, delay, reverb, bar, and PPQ helpers.
- `letoh.base.db` with dB/amplitude conversion, step rounding, and display formatting.
- `letoh.base.color` with RGB/HEX parsing, formatting, and a named-color palette.
- `letoh.base.registry` with a small `key=value` parser and serializer.
- `letoh.base.version` with the library name, version, and API level.
- Pure-Lua tests for all modules.
- A pure-Lua example and a REAPER example.
- CI for Lua 5.1 and Lua 5.4.
- A source-available license.

### Changed

- The modules now live under the `letoh.base` namespace.
- The README and docs are written for public use.

### Fixed

- `timing` rejects infinite BPM values.
- `db` rejects infinite amplitude values.
- `color.palette:get` returns a copy, so callers cannot change the stored color by accident.
- `registry.serialize` rejects values that would not survive a parse.
