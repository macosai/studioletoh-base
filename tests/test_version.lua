return function(t)
  local version = require("letoh.base.version")

  t.test("version metadata", function()
    t.eq(version.name, "Studio LETOH Base", "name")
    t.eq(version.version, "0.1.0", "version")
    t.eq(version.api, 1, "api")
  end)
end
