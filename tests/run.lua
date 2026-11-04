-- run.lua -- pure Lua test runner
-- Usage:
--   lua tests/run.lua
--   lua5.4 tests/run.lua

local info = debug.getinfo(1, "S")
local script_path = info.source:match("^@?(.*)$")
local tests_dir = script_path:match("^(.*)[/\\][^/\\]*$") or "."
local root = tests_dir:match("^(.*)[/\\][^/\\]*$") or "."
package.path = root .. "/?.lua;" .. package.path

local passed, failed = 0, 0

local function fail(message)
  error(message, 2)
end

local t = {}

function t.test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    passed = passed + 1
    print("ok   " .. name)
  else
    failed = failed + 1
    print("FAIL " .. name)
    print("     " .. tostring(err))
  end
end

function t.eq(actual, expected, label)
  if actual ~= expected then
    fail((label or "eq") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
  end
end

function t.near(actual, expected, tolerance, label)
  if type(actual) ~= "number" then
    fail((label or "near") .. ": expected a number, got " .. type(actual))
  end
  if math.abs(actual - expected) > tolerance then
    fail((label or "near") .. ": expected " .. tostring(expected) .. " +/- " .. tostring(tolerance) .. ", got " .. tostring(actual))
  end
end

function t.errors(fn, pattern, label)
  local ok, err = pcall(fn)
  if ok then
    fail((label or "errors") .. ": expected an error, but the call succeeded")
  end
  if pattern and not tostring(err):find(pattern, 1, true) then
    fail((label or "errors") .. ": expected error containing '" .. pattern .. "', got: " .. tostring(err))
  end
end

function t.truthy(value, label)
  if not value then
    fail((label or "truthy") .. ": expected a truthy value")
  end
end

local modules = {
  "test_version",
  "test_timing",
  "test_db",
  "test_color",
  "test_registry",
}

for _, name in ipairs(modules) do
  local file = tests_dir .. "/" .. name .. ".lua"
  local chunk, err = loadfile(file)
  if not chunk then
    failed = failed + 1
    print("FAIL " .. name .. " (could not load)")
    print("     " .. tostring(err))
  else
    local ok, test_fn = pcall(chunk)
    if not ok then
      failed = failed + 1
      print("FAIL " .. name .. " (crashed)")
      print("     " .. tostring(test_fn))
    elseif type(test_fn) ~= "function" then
      failed = failed + 1
      print("FAIL " .. name .. " (did not return a function)")
    else
      local ok2, run_err = pcall(test_fn, t)
      if not ok2 then
        failed = failed + 1
        print("FAIL " .. name .. " (crashed)")
        print("     " .. tostring(run_err))
      end
    end
  end
end

print("")
print(string.format("%d passed, %d failed", passed, failed))
if failed > 0 then
  os.exit(1)
end
