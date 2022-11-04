-- hnds
--
-- Lua lfo's for script
-- parameters.
-- ----------
--
-- Adapted from hnds v0.4 by @justmat

local number_of_outputs = 4

local tau = math.pi * 2

local options = {
  lfotypes = {
    "sine",
    "square",
    "s+h"
  }
}

local lfo = {}
for i = 1, number_of_outputs do
  lfo[i] = {
    freq = 0.01,
    counter = 1,
    waveform = options.lfotypes[1],
    slope = 0,
    depth = 100,
    freq_dial = 0,
    depth_dial = 0
  }
end

-- redefine in user script ---------
--for i = 1, number_of_outputs do
--  lfo[i].lfo_targets = {"none"}
--end

--function lfo.process()
--end
------------------------------------

function lfo.scale(old_value, old_min, old_max, new_min, new_max)
  -- scale ranges
  local old_range = old_max - old_min

  if old_range == 0 then
    old_range = new_min
  end

  local new_range = new_max - new_min
  local new_value = (((old_value - old_min) * new_range) / old_range) + new_min

  return new_value
end

local function make_sine(n)
  return 1 * math.sin(((tau / 100) * (lfo[n].counter)) - (tau / (lfo[n].freq)))
end

local function make_square(n)
  return make_sine(n) >= 0 and 1 or -1
end

local function make_sh(n)
  local polarity = make_square(n)
  if lfo[n].prev_polarity ~= polarity then
    lfo[n].prev_polarity = polarity
    return math.random() * (math.random(0, 1) == 0 and 1 or -1)
  else
    return lfo[n].prev
  end
end

function lfo.init()
  params:add_separator("LFOs")
  
  for i = 1, number_of_outputs do
    params:add_group("LFO " .. i, 4)
    -- lfo on/off
--    params:add_option(i .. "lfo", "Enable", {"off", "on"}, 1)
    -- lfo shape
    params:add_option(i .. "lfo_shape", "Shape", options.lfotypes, 1)
    params:set_action(i .. "lfo_shape", function(value) lfo[i].waveform = options.lfotypes[value] end)
    -- lfo modulation destination
    params:add_option(i .. "lfo_target", "Target", lfo[i].lfo_targets, 1)
    -- params:set_action(i .. "lfo_shape", function(v) engine.lfo1WaveShape(v) end)
    -- lfo speed
    params:add_control(i .. "lfo_freq", "Frequency", controlspec.new(0.01, 10.00, "lin", 0.01, 1.00, "", 0.001))
    params:set_action(i .. "lfo_freq", function(value) lfo[i].freq = value end)
    -- params:set_action(i .. "lfo_freq", function(v) engine.lfo1Freq(v) end)
    -- lfo depth
    params:add_number(i .. "lfo_depth", "Depth", 0, 100, 0)
    params:set_action(i .. "lfo_depth", function(value) lfo[i].depth = value end)
    -- params:set_action(i .. "lfo_depth", function(v) engine.lfo1Depth(v) end)
  end

  local lfo_metro = metro.init()
  lfo_metro.time = .01
  lfo_metro.count = -1
  lfo_metro.event = function()
    for i = 1, number_of_outputs do
 --     if params:get(i .. "lfo") == 2 then
        local slope
        if lfo[i].waveform == "sine" then
          slope = make_sine(i)
        elseif lfo[i].waveform == "square" then
          slope = make_square(i)
        elseif lfo[i].waveform == "s+h" then
          slope = make_sh(i)
        end
        lfo[i].prev = slope
        lfo[i].slope = math.max(-1.0, math.min(1.0, slope)) * (lfo[i].depth * 0.01)
        lfo[i].counter = lfo[i].counter + lfo[i].freq
--      end
    end
    lfo.process()
  end
  lfo_metro:start()
end
 
return lfo
