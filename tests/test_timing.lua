return function(t)
  local timing = require("letoh.base.timing")

  t.test("ms_per_beat at 120 BPM", function()
    t.near(timing.ms_per_beat(120), 500, 1e-9)
  end)

  t.test("ms_per_beat at 60 BPM", function()
    t.near(timing.ms_per_beat(60), 1000, 1e-9)
  end)

  t.test("delay_times at 120 BPM", function()
    local d = timing.delay_times(120)
    t.near(d["1/1"], 2000, 1e-9)
    t.near(d["1/2"], 1000, 1e-9)
    t.near(d["1/4"], 500, 1e-9)
    t.near(d["1/8"], 250, 1e-9)
    t.near(d["1/16"], 125, 1e-9)
    t.near(d["1/32"], 62.5, 1e-9)
  end)

  t.test("reverb_times at 120 BPM", function()
    local r = timing.reverb_times(120)
    t.near(r.pre_delay, 62.5, 1e-9)
    t.near(r.tail, 4000, 1e-9)
  end)

  t.test("bar_duration_ms at 120 BPM, 4/4", function()
    t.near(timing.bar_duration_ms(120, 4), 2000, 1e-9)
  end)

  t.test("bar_duration_ms at 120 BPM, 3/4", function()
    t.near(timing.bar_duration_ms(120, 3), 1500, 1e-9)
  end)

  t.test("ms_to_ppq", function()
    t.near(timing.ms_to_ppq(500, 120, 960), 960, 1e-9)
  end)

  t.test("ppq_to_ms", function()
    t.near(timing.ppq_to_ms(960, 120, 960), 500, 1e-9)
  end)

  t.test("format_ms", function()
    t.eq(timing.format_ms(123.456), "123.5 ms")
  end)

  t.test("rejects zero BPM", function()
    t.errors(function() timing.ms_per_beat(0) end, "bpm", "zero")
  end)

  t.test("rejects negative BPM", function()
    t.errors(function() timing.ms_per_beat(-120) end, "bpm", "negative")
  end)

  t.test("rejects non-numeric BPM", function()
    t.errors(function() timing.ms_per_beat("fast") end, "bpm", "text")
  end)

  t.test("rejects infinite BPM", function()
    t.errors(function() timing.ms_per_beat(math.huge) end, "bpm", "inf")
  end)

  t.test("rejects NaN BPM", function()
    t.errors(function() timing.ms_per_beat(0 / 0) end, "bpm", "nan")
  end)

  t.test("rejects zero beats_per_bar", function()
    t.errors(function() timing.bar_duration_ms(120, 0) end, "beats_per_bar", "zero")
  end)

  t.test("rejects negative ms", function()
    t.errors(function() timing.ms_to_ppq(-1, 120, 960) end, "ms", "negative")
  end)

  t.test("rejects zero ppq_qn", function()
    t.errors(function() timing.ms_to_ppq(500, 120, 0) end, "ppq_qn", "zero")
  end)
end
