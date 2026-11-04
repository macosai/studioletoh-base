return function(t)
  local registry = require("letoh.base.registry")

  t.test("parse basic", function()
    local cfg = registry.parse("a=1\nb=2\n")
    t.eq(cfg.a, "1")
    t.eq(cfg.b, "2")
  end)

  t.test("parse comments and blank lines", function()
    local cfg = registry.parse("-- comment\n\na=1\n\n")
    t.eq(cfg.a, "1")
    t.eq(cfg["-- comment"], nil)
  end)

  t.test("parse CRLF", function()
    local cfg = registry.parse("a=1\r\nb=2\r\n")
    t.eq(cfg.a, "1")
    t.eq(cfg.b, "2")
  end)

  t.test("parse UTF-8 BOM", function()
    local cfg = registry.parse("\239\187\191a=1\n")
    t.eq(cfg.a, "1")
  end)

  t.test("parse trims key and value", function()
    local cfg = registry.parse("  a  =  1  \n")
    t.eq(cfg.a, "1")
  end)

  t.test("parse keeps internal spaces", function()
    local cfg = registry.parse("name=Studio LETOH\n")
    t.eq(cfg.name, "Studio LETOH")
  end)

  t.test("parse last duplicate wins", function()
    local cfg = registry.parse("a=1\na=2\n")
    t.eq(cfg.a, "2")
  end)

  t.test("parse value with equals", function()
    local cfg = registry.parse("query=a=b=c\n")
    t.eq(cfg.query, "a=b=c")
  end)

  t.test("serialize sorts keys", function()
    t.eq(registry.serialize({ b = 2, a = 1 }), "a=1\nb=2\n")
  end)

  t.test("serialize empty table", function()
    t.eq(registry.serialize({}), "")
  end)

  t.test("round trip", function()
    local text = registry.serialize({ b = "two", a = "one" })
    local cfg = registry.parse(text)
    t.eq(cfg.a, "one")
    t.eq(cfg.b, "two")
  end)

  t.test("merge override wins", function()
    local cfg = registry.merge({ a = 1, b = 2 }, { b = 3, c = 4 })
    t.eq(cfg.a, 1)
    t.eq(cfg.b, 3)
    t.eq(cfg.c, 4)
  end)

  t.test("merge does not mutate inputs", function()
    local base = { a = 1 }
    local override = { b = 2 }
    local cfg = registry.merge(base, override)
    cfg.a = 99
    t.eq(base.a, 1)
  end)

  t.test("rejects malformed line", function()
    t.errors(function() registry.parse("not a pair\n") end, "malformed", "malformed")
  end)

  t.test("rejects empty key", function()
    t.errors(function() registry.parse("=value\n") end, "key", "empty")
  end)

  t.test("rejects non-string key", function()
    t.errors(function() registry.serialize({ [1] = "x" }) end, "keys", "number")
  end)

  t.test("rejects table value", function()
    t.errors(function() registry.serialize({ a = {} }) end, "value", "table")
  end)

  t.test("rejects newline in value", function()
    t.errors(function() registry.serialize({ a = "x\ny" }) end, "CR or LF", "newline")
  end)

  t.test("rejects leading whitespace in value", function()
    t.errors(function() registry.serialize({ a = " x" }) end, "whitespace", "leading")
  end)

  t.test("rejects equals in key", function()
    t.errors(function() registry.serialize({ ["a=b"] = "x" }) end, "key", "equals")
  end)
end
