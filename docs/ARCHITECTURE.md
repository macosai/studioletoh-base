# Architecture

The library is the bottom layer. Products sit on top.

```
REAPER project
    |
    v
product adapter (private)
    | reads tempo, writes files, draws UI, converts colors
    v
letoh.base (this repo)
    timing / db / color / registry / version
```

## The boundary

The base layer does math and text. It does not know about REAPER.

- It does not call `reaper.*`.
- It does not read or write files.
- It does not know where a config file lives.
- It does not know the project tempo. The product reads the tempo and passes it in.
- It does not know REAPER's native color integer format. The product converts RGB to that format.

That boundary is the point. The base can run in plain Lua, and the tests do not need REAPER.

## Why the modules are independent

`timing`, `db`, `color`, and `registry` do not require each other. `version` is metadata only.

This keeps the dependency graph flat. A product can use `db` without loading `color`, and a test for `timing` cannot fail because of a change in `registry`.

## What stays in the product

The product owns everything that touches REAPER or the user's machine:

- `reaper.*` calls
- ImGui windows and widgets
- action registration
- file paths and file I/O
- installers and manuals
- license checks
- REAPER color integer conversion

The product also owns its defaults. The base has no opinion about a good delay time, a default palette, or a config file name.

## Rules for changes

1. Do not add `reaper.*` calls to `letoh/base`.
2. Do not add file I/O to `letoh/base`.
3. Do not add global state.
4. Do not make one base module require another unless there is a strong reason.
5. Keep the tests runnable with plain Lua.
6. Keep error messages specific. Start them with the module name.

If a change needs REAPER, a file, or a product default, it belongs in a product adapter.

## Public and private

This repo contains the foundation only. Product source stays private. The public repo is useful on its own, and it does not replace a product.
