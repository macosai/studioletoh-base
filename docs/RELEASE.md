# Release checklist

The repository stays private until this list is done. Do not change the visibility first and fix the rest later.

1. Update `letoh/base/version.lua`.
2. Update `CHANGELOG.md` with the release date and the changes.
3. Run the tests on Lua 5.1 and Lua 5.4:

   ```sh
   lua tests/run.lua
   lua5.4 tests/run.lua
   ```

4. Check that every Lua file parses:

   ```sh
   find letoh tests examples -name '*.lua' -print0 | xargs -0 -n1 luac -p
   ```

5. Run the pure-Lua example:

   ```sh
   lua examples/pure_lua.lua
   ```

6. Check the design rules:
   - `letoh/base` has no `reaper.*` calls.
   - `letoh/base` has no file I/O.
   - The modules do not require each other.
7. Read the README and docs once more. Fix stale links, old version numbers, and claims that no longer match the code.
8. Compare `LICENSE.md` with the store Terms. If the store wording changed, update the license before publishing.
9. Commit the release and tag it:

   ```sh
   git add -A
   git commit -m "release: vX.Y.Z"
   git tag vX.Y.Z
   git push origin master
   git push origin vX.Y.Z
   ```

10. Create a GitHub release from the tag. Use the changelog entry as the release notes.
11. Confirm with Studio LETOH that the store copy and the repo agree. Then change the repository visibility to public.
12. Add the repository link to the GitHub section of the store.

## Before the first public release

The first public release should have a clean history. The current `master` branch was rebuilt from a clean initial commit before publication. The old concept-demo history is not in this repository. If you need to change the history, do it while the repo is still private.

## After the release

- Keep the tag. Do not move it.
- If you find a bug, fix it on `master`, bump the patch version, and tag again.
- Do not rewrite a published tag. Users may have downloaded it.
