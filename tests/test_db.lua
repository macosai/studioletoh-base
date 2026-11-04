return function(t)
  local db = require("letoh.base.db")

  t.test("db_to_amp at 0 dB", function()
    t.near(db.db_to_amp(0), 1, 1e-12)
  end)

  t.test("db_to_amp at -6 dB", function()
    t.near(db.db_to_amp(-6), 0.5011872336, 1e-9)
  end)

  t.test("amp_to_db at 1", function()
    t.near(db.amp_to_db(1), 0, 1e-12)
  end)

  t.test("amp_to_db at 0.5", function()
    t.near(db.amp_to_db(0.5), -6.0205999133, 1e-9)
  end)

  t.test("amp_to_db at 0", function()
    t.eq(db.amp_to_db(0), -math.huge)
  end)

  t.test("round_to_step negative", function()
    t.near(db.round_to_step(-6.05, 0.1), -6.0, 1e-9)
  end)

  t.test("round_to_step positive", function()
    t.near(db.round_to_step(6.06, 0.1), 6.1, 1e-9)
  end)

  t.test("round_to_step default step", function()
    t.near(db.round_to_step(6.06), 6.1, 1e-9)
  end)

  t.test("format_db negative", function()
    t.eq(db.format_db(-6), "-6.0 dB")
  end)

  t.test("format_db positive", function()
    t.eq(db.format_db(6), "+6.0 dB")
  end)

  t.test("format_db zero", function()
    t.eq(db.format_db(0), "+0.0 dB")
  end)

  t.test("format_db near zero", function()
    t.eq(db.format_db(-0.01), "+0.0 dB")
  end)

  t.test("rejects non-numeric dB", function()
    t.errors(function() db.db_to_amp("loud") end, "dB", "text")
  end)

  t.test("rejects infinite dB", function()
    t.errors(function() db.db_to_amp(math.huge) end, "dB", "inf")
  end)

  t.test("rejects negative amplitude", function()
    t.errors(function() db.amp_to_db(-0.5) end, "amplitude", "negative")
  end)

  t.test("rejects NaN amplitude", function()
    t.errors(function() db.amp_to_db(0 / 0) end, "amplitude", "nan")
  end)

  t.test("rejects infinite amplitude", function()
    t.errors(function() db.amp_to_db(math.huge) end, "amplitude", "inf")
  end)

  t.test("rejects zero step", function()
    t.errors(function() db.round_to_step(0, 0) end, "step", "zero")
  end)

  t.test("rejects negative step", function()
    t.errors(function() db.round_to_step(0, -0.1) end, "step", "negative")
  end)
end
