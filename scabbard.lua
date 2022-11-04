-- Scabbard
-- Dual Filter
--
-- Twin digitally modeled
-- analog stereo filters
-- with series, parallel, and
-- dual modes
--
-- Series: 
-- filter 1 feeds into filter 2
--
-- Parallel:
-- signal passes through both 
-- filters independently
--
-- Dual:
-- filter 1 is L channel
-- filter 2 is R channel
-- can also be used for
-- processing two mono signals
--
-- Adapted from justmat's 
-- Phyllis script
--
-- K1: (alt)
-- K2: focus (bypass filter 1)
-- K3: link (bypass filter 2)
--
-- E1: page (mode)
-- E2: filter 1 control (fine)
-- E3: filter 2 control (fine)
--
-- v1.0

engine.name = "Scabbard"

local UI = require "ui"
local FilterGraph = require "filtergraph"
local Graph = require "graph"
Formatters = require "formatters"

-- check = 0

local lfo = include("lib/hnds")

local function set_amp()
  if params:get("mode") == 1 then
    if params:get("enableL") == 1 and params:get("enableR") == 1 then
      engine.amp1(1)
      engine.amp2(1)
    elseif params:get("enableL") == 2 and params:get("enableR") == 2 then
      engine.amp1(1)
      engine.amp2(0.198)
    elseif params:get("enableL") == 1 and params:get("enableR") == 2 then
      engine.amp1(1)
      engine.amp2(0.445)
    elseif params:get("enableL") == 2 and params:get("enableR") == 1 then
      engine.amp1(1)
      engine.amp2(0.445)
    end
  elseif params:get("mode") == 2 then
    if params:get("enableL") == 1 and params:get("enableR") == 1 then
      engine.amp1(0.5)
      engine.amp2(0.5)
    elseif params:get("enableL") == 2 and params:get("enableR") == 2 then
      engine.amp1(0.5)
      engine.amp2(0.5)
    elseif params:get("enableL") == 1 and params:get("enableR") == 2 then
      engine.amp1(0.5)
      engine.amp2(0.2)
    elseif params:get("enableL") == 2 and params:get("enableR") == 1 then
      engine.amp1(0.2)
      engine.amp2(0.5)
    end
  elseif params:get("mode") == 3 then
    if params:get("enableL") == 1 and params:get("enableR") == 1 then
      engine.amp1(1)
      engine.amp2(1)
    elseif params:get("enableL") == 2 and params:get("enableR") == 2 then
      engine.amp1(0.445)
      engine.amp2(0.445)
    elseif params:get("enableL") == 1 and params:get("enableR") == 2 then
      engine.amp1(1)
      engine.amp2(0.445)
    elseif params:get("enableL") == 2 and params:get("enableR") == 1 then
      engine.amp1(0.445)
      engine.amp2(1)
    end
  end
end

-- update filter graphs
local function update_fg()
  local ftypeL
  local ftypeR
  
  if params:get("typeL") == 1 then ftypeL = "lowpass" elseif params:get("typeL") == 2 then ftypeL = "bandpass" elseif params:get("typeL") == 3 then ftypeL = "highpass" end
  if params:get("typeR") == 1 then ftypeR = "lowpass" elseif params:get("typeR") == 2 then ftypeR = "bandpass" elseif params:get("typeR") == 3 then ftypeR = "highpass" end
  
  filterL:edit(ftypeL, 12, params:get("freqL_crossover"), params:get("resL_crossover"))
  filterL:set_active(params:get("enableL") == 2)
  filterL_twin:edit(ftypeL, 12, params:get("peaksL_spread"), params:get("resL_crossover"))
  filterL_twin:set_active(nil)
  
  filterR:edit(ftypeR, 12, params:get("freqR_crossover"), params:get("resR_crossover"))
  filterR:set_active(params:get("enableR") == 2)
  filterR_twin:edit(ftypeR, 12, params:get("peaksR_spread"), params:get("resR_crossover"))
  filterR_twin:set_active(nil)
  
  if params:get("spread1") == 0 then
    params:set("peaksL", 1)
  else
    params:set("peaksL", 2)
  end
  
  if params:get("spread2") == 0 then
    params:set("peaksR", 1)
  else
    params:set("peaksR", 2)
  end
  
--  params:set("freqL_crossover", cutoff1_peak1)
--  params:set("peaksL_spread", cutoff1_peak2)
--  params:set("freqR_crossover", cutoff2_peak1)
--  params:set("peaksR_spread", cutoff2_peak2)
  
  
--  if params:get("peaksL_spread") >= 20 and params:get("peaksL_spread") <= params:get("freqL") then
--    if params:get("peaksL_spread") == 20 and diff_check == true then
--      diff_hi = params:get("freqL_crossover")
--      diff_check = false
--    elseif params:get("peaksL_spread") > 20 and params:get("freqL_crossover") < 20000 then
--      diff_check = true
--      diff_hi = 20000
--    end
--  else
--    params:set("peaksL_spread", params:get("freqL"))
---  end
  
--  if params:get("freqL_crossover") <= 20000 and params:get("freqL_crossover") >= params:get("freqL") then
--    if params:get("freqL_crossover") == 20000 and diff_check == true then
 --     diff_low = params:get("peaksL_spread")
 --     diff_check = false
--    elseif params:get("peaksL_spread") > 20 and params:get("freqL_crossover") < 20000 then
--      diff_check = true
--      diff_low = 20
--    end
--  else
--    params:set("freqL_crossover", params:get("freqL"))
--  end
  
 -- if params:get("peaksL_spread") >= params:get("freqL") then
 --   params:set("peaksL_spread", params:get("freqL"))
--    params:set("freqL_crossover", params:get("freqL"))
 --   params:set("peaksL", 1)

 -- elseif params:get("peaksL") == 2 then
 --   if params:get("peaksL_spread") < params:get("freqL") and params:get("peaksL_spread") > 20 then
--      local diff = params:get("freqL") - params:get("peaksL_spread")
--      local diff2 = params:get("freqL") + diff
      
--      params:set("freqL_crossover", diff2)
--    elseif params:get("peaksL_spread") > params:get("freqL") and params:get("peaksL_spread") < 20000 then
--      local diff = params:get("freqL") - params:get("freqL_crossover")
--      local diff2 = params:get("freqL") + diff
      
--      params:set("peaksL_spread", diff2)
 --   end
 -- end
  
 -- if params:get("freqL_crossover") <= params:get("freqL") then
--    params:set("peaksL_spread", params:get("freqL"))
--    params:set("freqL_crossover", params:get("freqL"))
--    params:set("peaksL", 1)
--  end
        
--  if check < params:get("spread") then
--    params:delta("peaksL_spread", -1)
--    check = params:get("spread")
--  end
  
--  if params:get("peaksL_spread") > params:get("freqL_crossover")
end

-- LFO targets
local lfo_targets = {
  "Cutoff 1",
  "Cutoff 2",
  "^Res 1",
  "^Res 2",
  "Gain 1",
  "Gain 2",
  "~Noise 1",
  "~Noise 2"
}

-- LFO modulation
function lfo.process()
  local lfo_num = { freqL = 0, freqR = 0, resL = 0, resR = 0, gainL = 0, gainR = 0, noiseL = 0, noiseR = 0 }

  local cutoff1_peak1 = params:get("freqL") + (params:get("spread1") * (params:get("freqL") / 10))
  local cutoff1_peak2 = params:get("freqL") - (params:get("spread1") * (params:get("freqL") / 10))
  local cutoff2_peak1 = params:get("freqR") + (params:get("spread2") * 10)
  local cutoff2_peak2 = params:get("freqR") - (params:get("spread2") * 10)
  
  for i = 1, 4 do
    if params:get(i .. "lfo_depth") > 0 then
      local target = params:get(i .. "lfo_target")
      
      -- frequency
      if target == 1 then
        lfo_num.freqL = lfo_num.freqL + 1
        params:set("freqL_crossover", lfo.scale(lfo[i].slope, -1.0, 1.0, cutoff1_peak1 - (lfo[i].depth * (params:get("freqL_crossover") / 100)), cutoff1_peak1 + (lfo[i].depth * (params:get("freqL_crossover") / 100))))
        params:set("peaksL_spread", lfo.scale(lfo[i].slope, -1.0, 1.0, cutoff1_peak2 - (lfo[i].depth * (params:get("peaksL_spread") / 100)), cutoff1_peak2 + (lfo[i].depth * (params:get("peaksL_spread") / 100))))
      end
      
      if target == 2 then
        lfo_num.freqR = lfo_num.freqR + 1
        params:set("freqR_crossover", lfo.scale(lfo[i].slope, -1.0, 1.0, cutoff2_peak1 - (lfo[i].depth * (params:get("freqR") / 100)), cutoff2_peak1 + (lfo[i].depth * (params:get("freqR") / 100))))
        params:set("peaksR_spread", lfo.scale(lfo[i].slope, -1.0, 1.0, cutoff2_peak2 - (lfo[i].depth * (params:get("freqR") / 100)), cutoff2_peak2 + (lfo[i].depth * (params:get("freqR") / 100))))
      end
      
      -- resonance
      if target == 3 then
        lfo_num.resL = lfo_num.resL + 1
        params:set("resL_crossover", lfo.scale(lfo[i].slope, -1.0, 1.0, params:get('resL') - lfo[i].depth * 0.0075, params:get('resL') + (lfo[i].depth * 0.0075)))
      end
      
      if target == 4 then
        lfo_num.resR = lfo_num.resR + 1
        params:set("resR_crossover", lfo.scale(lfo[i].slope, -1.0, 1.0, params:get('resR') - lfo[i].depth * 0.0075, params:get('resR') + lfo[i].depth * 0.0075))
      end
      
      -- input gain
      if target == 5 then
        lfo_num.gainL = lfo_num.gainL + 1
        params:set("gainL_crossover", lfo.scale(lfo[i].slope, -1.0, 1.0, params:get('gainL') - lfo[i].depth, params:get('gainL') + lfo[i].depth))
      end
      
      if target == 6 then
        lfo_num.gainR = lfo_num.gainR + 1
        params:set("gainR_crossover", lfo.scale(lfo[i].slope, -1.0, 1.0, params:get('gainR') - lfo[i].depth, params:get('gainR') + lfo[i].depth))
      end
      
      -- noise
      if target == 7 then
        lfo_num.noiseL = lfo_num.noiseL + 1
        params:set("noiseL_crossover", lfo.scale(lfo[i].slope, -1.0, 1.0, params:get('noiseL') - lfo[i].depth * 0.0075, params:get('noiseL') + lfo[i].depth * 0.0075))
      end
      
      if target == 8 then
        lfo_num.noiseR = lfo_num.noiseR + 1
        params:set("noiseR_crossover", lfo.scale(lfo[i].slope, -1.0, 1.0, params:get('noiseR') - lfo[i].depth * 0.0075, params:get('noiseR') + lfo[i].depth * 0.0075))
      end
    end
  end
  
  -- sync visuals to parameter values if not being modulated by lfo
  if lfo_num.freqL == 0 then
    params:set("freqL_crossover", cutoff1_peak1)
    params:set("peaksL_spread", cutoff1_peak2)
  end
  
  if lfo_num.freqR == 0 then
    params:set("freqR_crossover", cutoff2_peak1)
    params:set("peaksR_spread", cutoff2_peak2)
  end
  
  if lfo_num.resL == 0 then
    params:set("resL_crossover", params:get("resL"))
  end
  
  if lfo_num.resR == 0 then
    params:set("resR_crossover", params:get("resR"))
  end
  
  if lfo_num.gainL == 0 then
    params:set("gainL_crossover", params:get("gainL"))
  end
  
  if lfo_num.gainR == 0 then
    params:set("gainR_crossover", params:get("gainR"))
  end
  
  if lfo_num.noiseL == 0 then
    params:set("noiseL_crossover", params:get("noiseL"))
  end
  
  if lfo_num.noiseR == 0 then
    params:set("noiseR_crossover", params:get("noiseR"))
  end
end

function init()

  screen.aa(0)
  
  params:add_separator("Scabbard")
  -- mode
  params:add({
    id="mode",
    name="Mode",
    type="option",
    options={"Series", "Parallel", "Dual"},
    default=1,
    action=function(v)
      engine.set_mode(v)
      set_amp()
 --     if v == 1 then
--        engine.amp2(0.445)
--      elseif v == 2 then 
--        if params:get("enableL") == 1 then
--          engine.amp1(1)
--        elseif params:get("enableL") == 2 then
--          engine.amp1(0.5)
--        end
--      elseif v == 3 then 
--        amp = 1
--      end
    end
  })
  -- link
  params:add_option("link", "Link", {"Off", "On"}, 1)

  -- filter 1
  params:add_separator("Filter 1")
  -- filter 1 bypass
  params:add_option("enableL", "Enable", {"Off", "On"}, 2)
  params:set_action("enableL", 
    function(v)
      local mode = params:get("mode")
  --    if v == 1 then
--        engine.amp1(1)
 --     elseif v == 2 then
 --       engine.amp1(0.5)
 --     end
      engine.bypassL(v - 1)
      set_amp()
--      engine.set_amp(v)
    end)
  -- filter 1 cutoff
  params:add_control("freqL", "Cutoff", controlspec.new(20, 20000, "exp", 0, 20000, "Hz"), Formatters.format_freq)
  params:add_control("freqL_crossover", "Cutoff Crossover", controlspec.new(20, 20000, "exp", 0, 20000, "Hz"), Formatters.format_freq)
  params:set_action("freqL_crossover", function(v) engine.freqL(v) end)
  params:hide("freqL_crossover")
  -- filter 1 resonance
  params:add_control("resL", "Resonance", controlspec.UNIPOLAR)
  params:add_control("resL_crossover", "Resonance Crossover", controlspec.UNIPOLAR)
  params:set_action("resL_crossover", function(v) engine.resL(v) end)
  params:hide("resL_crossover")
  -- filter 1 resonant peaks
  params:add_number("peaksL", "Resonant Peaks", 1, 2, 1)
  params:set_action("peaksL", function(v) engine.mix1(v - 1) end)
  params:hide("peaksL")
  -- filter 1 resonant peak spread
  params:add_control("spread1", "Spread", controlspec.new(0, 100, "lin", 0, 0))
  params:add_control("peaksL_spread", "Resonant Peak Spread", controlspec.new(20, 20000, "exp", 0, 20000, "Hz"), Formatters.format_freq)
  params:set_action("peaksL_spread", function(v) engine.spreadL(v) end)
  params:hide("peaksL_spread")
  -- filter 1 type
  params:add_option("typeL", "Type", {"Low Pass", "Band Pass", "High Pass"}, 1)
  params:set_action("typeL", 
    function(v)
      if v == 1 then
        engine.typeL(0)
        engine.bandpassL(1)
      elseif v == 2 then
        engine.typeL(0)
--        engine.freqL(20000)
        engine.bandpassL(0)
      elseif v == 3 then
        engine.typeL(1)
        engine.bandpassL(1)
      end
    end)
  -- filter 1 pan
  params:add_control("panL", "Pan", controlspec.new(-1, 1, "lin", 0.01, -1))
  params:set_action("panL", function(v) engine.panL(v) engine.panR(v) end)
  -- filter 1 input gain
  params:add_control("gainL", "Input Gain", controlspec.new(-48, 12, 'db', 0.1, 0, "dB"))
  params:add_control("gainL_crossover", "Input Gain Crossover", controlspec.new(-48, 12, 'db', 0.1, 0, "dB"))
  params:set_action("gainL_crossover", function(v) engine.gainL(v) end)
--  params:set_action("gainL_crossover", function(v) engine.gainL(util.dbamp(v)) end)
  params:hide("gainL_crossover")
  -- filter 1 noise level
  params:add_control("noiseL", "Noise Level", controlspec.new(0.0, 1.0, "lin", 0, 0))
  params:add_control("noiseL_crossover", "Noise Level Crossover", controlspec.new(0.0, 1.0, "lin", 0, 0))
  params:set_action("noiseL_crossover", function(v) engine.noiseL(v * 0.01) end)
  params:hide("noiseL_crossover")
  
  -- filter 2
  params:add_separator("Filter 2")
  -- filter 2 bypass
  params:add_option("enableR", "Enable", {"Off", "On"}, 2)
  params:set_action("enableR", 
    function(v)
      local mode = params:get("mode")
      
  --    if v == 1 then
  --      engine.amp2(1)
 --     elseif mode == 2 and v == 2 then
 --       engine.amp2(0.5)
 --     end
      engine.bypassR(v - 1)
      set_amp()
    end)
  -- filter 2 cutoff
  params:add_control("freqR", "Cutoff", controlspec.new(20, 20000, "exp", 0, 20000, "Hz"), Formatters.format_freq)
  params:add_control("freqR_crossover", "Cutoff Crossover", controlspec.new(20, 20000, "exp", 0, 20000, "Hz"), Formatters.format_freq)
  params:set_action("freqR_crossover", function(v) engine.freqR(v) end)
  params:hide("freqR_crossover")
  -- filter 2 resonance
  params:add_control("resR", "Resonance", controlspec.UNIPOLAR)
  params:add_control("resR_crossover", "Resonance Crossover", controlspec.UNIPOLAR)
  params:set_action("resR_crossover", function(v) engine.resR(v) end)
  params:hide("resR_crossover")
  -- filter 2 resonant peaks
  params:add_number("peaksR", "Resonant Peaks", 1, 2, 1)
  params:set_action("peaksR", function(v) engine.mix2(v - 1) end)
  params:hide("peaksR")
  -- filter 2 resonant peak spread
  params:add_control("spread2", "Spread", controlspec.new(0, 100, "lin", 1, 0))
  params:add_control("peaksR_spread", "Resonant Peak Spread", controlspec.new(20, 20000, "exp", 0, 20000, "Hz"), Formatters.format_freq)
  params:set_action("peaksR_spread", function(v) engine.spreadR(v) end)
  params:hide("peaksR_spread")
  -- filter 2 type
  params:add_option("typeR", "Type", {"Low Pass", "Band Pass", "High Pass"}, 1)
  params:set_action("typeR", 
    function(v)
      if v == 1 then
        engine.typeR(0)
        engine.bandpassR(1)
      elseif v == 2 then
        engine.typeR(0)
--        engine.freqL(20000)
        engine.bandpassR(0)
      elseif v == 3 then
        engine.typeR(1)
        engine.bandpassR(1)
      end
    end)
  -- filter 2 input gain
  params:add_control("gainR", "Input Gain", controlspec.new(-48, 12, 'db', 0.1, 0, "dB"))
  params:add_control("gainR_crossover", "Input Gain Crossover", controlspec.new(-48, 12, 'db', 0.1, 0, "dB"))
  params:set_action("gainR_crossover", function(v) engine.gainR(v) end)
--  params:set_action("gainR_crossover", function(v) engine.gainR(util.dbamp(v)) end)
  params:hide("gainR_crossover")
  -- filter 2 noise level
  params:add_control("noiseR", "Noise Level", controlspec.new(0.0, 1.0, "lin", 0, 0))
  params:add_control("noiseR_crossover", "Noise Level Crossover", controlspec.new(0.0, 1.0, "lin", 0, 0))
  params:set_action("noiseR_crossover", function(v) engine.noiseR(v * 0.01) end)
  params:hide("noiseR_crossover")
  
  -- for hnds
  for i = 1, 4 do
    lfo[i].lfo_targets = lfo_targets
  end
  lfo.init()

  params:bang()

  norns.enc.sens(1, 5)
  
  -- pages
  pages = UI.Pages.new(1, 5)
  
  -- filter graphs
  filterL = FilterGraph.new(20, 20000)
  filterL:set_position_and_size(5, 6, 64, 25)
  filterL_twin = FilterGraph.new(20, 20000)
  filterL_twin:set_position_and_size(5, 6, 64, 25)
  
  filterR = FilterGraph.new(20, 20000)
  filterR:set_position_and_size(5, 39, 64, 25)
  filterR_twin = FilterGraph.new(20, 20000)
  filterR_twin:set_position_and_size(5, 39, 64, 25)
  
  -- dials
  gainL_dial = UI.Dial.new(81, 3, 15, params:get("gainL_crossover"), -48, 12, 0.1, nil, {0}, nil, "")
  gainL_dial.active = pages.index == 1 and focus == 4
  noiseL_dial = UI.Dial.new(108, 10, 15, params:get("noiseL_crossover"), 0, 1, 0.01, nil, {}, nil, "~")
  noiseL_dial.active = pages.index == 1 and focus == 5
  gainR_dial = UI.Dial.new(81, 36, 15, params:get("gainR_crossover"), -48, 12, 0.1, nil, {0}, nil, "")
  gainR_dial.active = pages.index == 1 and focus == 4
  noiseR_dial = UI.Dial.new(108, 43, 15, params:get("noiseR_crossover"), 0, 1, 0.01, nil, {}, nil, "~")
  noiseR_dial.active = pages.index == 1 and focus == 5
  
  -- lfo graphs
--  lfo_1_graph = Graph.new(0, 1, "lin", -1, 1, "lin", "line", true, false)
--  lfo_1_graph:set_position_and_size(70, 21, 56, 34)
--  lfo_1_graph:add_function(generate_lfo_wave())

  -- lfo parameters
--  lfo_parameters = {"freq", "val"}
  
--  lfo_list = UI.List.new (85, 30, 1, lfo_parameters)
--  lfo_list.index = focus == 4
  
  -- lfo dials
  for i = 1, 4 do
    lfo[i].freq_dial = UI.Dial.new(81, 36, 15, params:get(i .. "lfo_freq"), 0.01, 10, 0.01, nil, {}, "Hz")
    lfo[i].freq_dial.active = pages.index > 1 and focus == 4
    lfo[i].depth_dial = UI.Dial.new(108, 43, 15, params:get(i .. "lfo_depth"), 0, 100, 1, nil, {}, "%")
    lfo[i].depth_dial.active = pages.index > 1 and focus == 5
  end
  
  -- redraw metro
  local norns_redraw_timer = metro.init()
  norns_redraw_timer.time = 0.025
  norns_redraw_timer.event = function() update_fg() redraw() end
  norns_redraw_timer:start()
end

-- focus
focus = 1

function set_focus(id)
    focus = util.clamp(id, 1, 5)
    
    gainL_dial.active =  focus == 4
    gainR_dial.active = focus == 4
    noiseL_dial.active = focus == 5
    noiseR_dial.active = focus == 5
    
  for i = 1, 4 do
    lfo[i].freq_dial.active = pages.index > 1 and focus == 4
    lfo[i].depth_dial.active = pages.index > 1 and focus == 5
  end
end

local alt = false

-- keys
function key(n, z)
  -- K1 is alt
  if n == 1 then
    if z == 1 then
      alt = true
    else
      alt = false
    end
  end
  
  -- K2 is focus (alt: filter 1 bypass)
  if n == 2 and alt == false then
    if z == 1 then
      set_focus(focus % 5 + 1)
    end
  elseif n == 2 and alt == true then
    if z == 1 then
      local bypass1 = params:get("enableL") % 2 + 1
      params:set("enableL", bypass1)
      filterL:set_active(params:get("enableL") == 2)
    end
  end
  
  
  -- K3 is link (alt: filter 2 bypass)
  if n == 3 and alt == false then
    if z == 1 then
      local link = params:get("link") % 2 + 1
      params:set("link", link)
    end
  elseif n == 3 and alt == true then
    if z == 1 then
      local bypass2 = params:get("enableR") % 2 + 1
      params:set("enableR", bypass2)
      filterR:set_active(params:get("enableR") == 2)
    end
  end
end

-- encoders
function enc(n, d)
  -- E1 changes page / mode
  if n == 1 and alt == false then
    pages:set_index_delta(d, false)
  elseif n == 1 and alt == true then
    params:delta("mode", d)
  end
  redraw()
  
  -- E2 is filter 1 control / lfo target
  if n == 2 then
    if focus == 1 then -- cutoff
      if alt == false and params:get("link") == 1 then
        params:delta("freqL", d)
      elseif alt == true and params:get("link") == 1 then
        params:delta("freqL", d * 0.1)
      elseif alt == false and params:get("link") == 2 then
        params:delta("freqL", d)
        params:delta("freqR", d)
      elseif alt == true and params:get("link") == 2 then
        params:delta("freqL", d * 0.1)
        params:delta("freqR", d * 0.1)
      end
    elseif focus == 2 then -- resonance
      if alt == false and params:get("link") == 1 then
        params:delta("resL", d)
        params:delta("resL_crossover", d)
      elseif alt == true and params:get("link") == 1 then
        if params:get("peaksL") == 1 then
          params:delta("peaksL", d)
        end
        if params:get("peaksL") == 2 then
          params:delta("spread1", d)
--          check = params:get("spread")
        
 --         if params:get("freqL_crossover") <= diff_hi then
 --           params:delta("spread", d)
  --          if check < params:get("spread") then
      --        params:delta("peaksL_spread", -10)
     --       end
  --        end
   --       if params:get("peaksL_spread") >= diff_low then
   --         params:delta("freqL_crossover", d)
   --       end
        end
      elseif alt == false and params:get("link") == 2 then
        params:delta("resL", d)
        params:delta("resL_crossover", d)
        params:delta("resR", d)
        params:delta("resR_crossover", d)
      elseif alt == true and params:get("link") == 2 then
        if params:get("peaksL") == 1 then
          params:delta("peaksL", d)
        end
        if params:get("peaksR") == 1 then
          params:delta("peaksR", d)
        end
        if params:get("peaksL") == 2 then
          params:delta("spread1", d)
        end
        if params:get("peaksR") == 2 then
          params:delta("spread2", d)
        end
      end
    elseif focus == 3 then -- filter type
      if alt == false and params:get("link") == 1 then
        params:delta("typeL", d)
      elseif alt == true and params:get("link") == 1 then
        params:delta("panL", d)
 --       redraw()
      elseif alt == false and params:get("link") == 2 then
        params:delta("typeL", d)
        params:delta("typeR", d)
      end
    elseif focus == 4 then -- input gain
      if pages.index == 1 then
        if alt == false and params:get("link") == 1 then
          params:delta("gainL", d)
          params:delta("gainL_crossover", d)
          gainL_dial:set_value(params:get("gainL_crossover"))
        elseif alt == true and params:get("link") == 1 then
          params:delta("gainL", d * 0.1)
          params:delta("gainL_crossover", d * 0.1)
          gainL_dial:set_value(params:get("gainL_crossover"))
        elseif alt == false and params:get("link") == 2 then
          params:delta("gainL", d)
          params:delta("gainL_crossover", d)
          gainL_dial:set_value(params:get("gainL_crossover"))
          params:delta("gainR", d)
          params:delta("gainR_crossover", d)
          gainR_dial:set_value(params:get("gainR_crossover"))
        elseif alt == true and params:get("link") == 2 then
          params:delta("gainL", d * 0.1)
          params:delta("gainL_crossover", d * 0.1)
          gainL_dial:set_value(params:get("gainL_crossover"))
          params:delta("gainR", d * 0.1)
          params:delta("gainR_crossover", d * 0.1)
          gainR_dial:set_value(params:get("gainR_crossover"))
        end
      else -- lfo target
        for i = 1, 4 do
          if pages.index == i + 1 then
            params:delta(i .. "lfo_target", d)
          end
        end
      end
    elseif focus == 5 then -- noise level
      if pages.index == 1 then
        if alt == false and params:get("link") == 1 then
          params:delta("noiseL", d)
          params:delta("noiseL_crossover", d)
          noiseL_dial:set_value(params:get("noiseL_crossover"))
        elseif alt == true and params:get("link") == 1 then
          params:delta("noiseL", d * 0.1)
          params:delta("noiseL_crossover", d * 0.1)
          noiseL_dial:set_value(params:get("noiseL_crossover"))
        elseif alt == false and params:get("link") == 2 then
          params:delta("noiseL", d)
          params:delta("noiseL_crossover", d)
          noiseL_dial:set_value(params:get("noiseL_crossover"))
          params:delta("noiseR", d)
          params:delta("noiseR_crossover", d)
          noiseR_dial:set_value(params:get("noiseR_crossover"))
        elseif alt == true and params:get("link") == 2 then
          params:delta("noiseL", d * 0.1)
          params:delta("noiseL_crossover", d * 0.1)
          noiseL_dial:set_value(params:get("noiseL_crossover"))
          params:delta("noiseR", d * 0.1)
          params:delta("noiseR_crossover", d * 0.1)
          noiseR_dial:set_value(params:get("noiseR_crossover"))
        end
      else -- lfo target
        for i = 1, 4 do
          if pages.index == i + 1 then
            params:delta(i .. "lfo_target", d)
          end
        end
      end
    end
  end
  
  -- E3 is filter 2 control / lfo parameters
  if n == 3 then
    if focus == 1 then -- cutoff
      if alt == false and params:get("link") == 1 then
--        if params:get("peaksR") == 2 then
--          if params:get("peaksR_spread") > 20 and params:get("freqR_crossover") < 20000 then
 --           params:delta("freqR", d)
 --           params:delta("peaksR_spread", d)
 --         elseif params:get("peaksR_spread") == 20 and d > 0 then
--            params:delta("freqR", d)
--          elseif params:get("freqR_crossover") == 20000 and d < 0 then
 --           dtest = d
 --           params:delta("freqR", d)
--          end
--        else
          params:delta("freqR", d)
--        end
      elseif alt == true and params:get("link") == 1 then
        params:delta("freqR", d * 0.1)
      elseif alt == false and params:get("link") == 2 then
        params:delta("freqL", d)
        params:delta("freqR", d)
      elseif alt == true and params:get("link") == 2 then
        params:delta("freqL", d * 0.1)
        params:delta("freqR", d * 0.1)
      end
    elseif focus == 2 then -- resonance
      if alt == false and params:get("link") == 1 then
        params:delta("resR", d)
        params:delta("resR_crossover", d)
      elseif alt == true and params:get("link") == 1 then
        if params:get("peaksR") == 1 then
          params:delta("peaksR", d)
        end
        if params:get("peaksR") == 2 then
          params:delta("spread2", d)
        end
      elseif alt == false and params:get("link") == 2 then
        params:delta("resL", d)
        params:delta("resL_crossover", d)
        params:delta("resR", d)
        params:delta("resR_crossover", d)
      elseif alt == true and params:get("link") == 2 then
        if params:get("peaksL") == 1 then
          params:delta("peaksL", d)
        end
        if params:get("peaksR") == 1 then
          params:delta("peaksR", d)
        end
        if params:get("peaksL") == 2 then
          params:delta("spread1", d)
        end
        if params:get("peaksR") == 2 then
          params:delta("spread2", d)
        end
      end
    elseif focus == 3 then -- filter type
      if params:get("link") == 1 then
        params:delta("typeR", d)
      elseif params:get("link") == 2 then
        params:delta("typeL", d)
        params:delta("typeR", d)
      end
    elseif focus == 4 then -- input gain
      if pages.index == 1 then
        if alt == false and params:get("link") == 1 then
          params:delta("gainR", d)
          params:delta("gainR_crossover", d)
          gainR_dial:set_value(params:get("gainR_crossover"))
        elseif alt == true and params:get("link") == 1 then
          params:delta("gainR", d * 0.1)
          params:delta("gainR_crossover", d * 0.1)
          gainR_dial:set_value(params:get("gainR_crossover"))
        elseif alt == false and params:get("link") == 2 then
          params:delta("gainL", d)
          params:delta("gainL_crossover", d)
          gainL_dial:set_value(params:get("gainL_crossover"))
          params:delta("gainR", d)
          params:delta("gainR_crossover", d)
          gainR_dial:set_value(params:get("gainR_crossover"))
        elseif alt == true and params:get("link") == 2 then
          params:delta("gainL", d * 0.1)
          params:delta("gainL_crossover", d * 0.1)
          gainL_dial:set_value(params:get("gainL_crossover"))
          params:delta("gainR", d * 0.1)
          params:delta("gainR_crossover", d * 0.1)
          gainR_dial:set_value(params:get("gainR_crossover"))
        end
      else -- lfo frequency
        for i = 1, 4 do
          if pages.index == i + 1 then
            if alt == false then
              params:delta(i .. "lfo_freq", d * 10)
              lfo[i].freq_dial:set_value(params:get(i .. "lfo_freq"))
            elseif alt == true then
              params:delta(i .. "lfo_freq", d)
              lfo[i].freq_dial:set_value(params:get(i .. "lfo_freq"))
            end
          end
        end
      end
    elseif focus == 5 then -- noise level
      if pages.index == 1 then
        if alt == false and params:get("link") == 1 then
          params:delta("noiseR", d)
          params:delta("noiseR_crossover", d)
          noiseR_dial:set_value(params:get("noiseR_crossover"))
        elseif alt == true and params:get("link") == 1 then
          params:delta("noiseR", d * 0.1)
          params:delta("noiseR_crossover", d * 0.1)
          noiseR_dial:set_value(params:get("noiseR_crossover"))
        elseif alt == false and params:get("link") == 2 then
          params:delta("noiseL", d)
          params:delta("noiseL_crossover", d)
          noiseL_dial:set_value(params:get("noiseL_crossover"))
          params:delta("noiseR", d)
          params:delta("noiseR_crossover", d)
          noiseR_dial:set_value(params:get("noiseR_crossover"))
        elseif alt == true and params:get("link") == 2 then
          params:delta("noiseL", d * 0.1)
          params:delta("noiseL_crossover", d * 0.1)
          noiseL_dial:set_value(params:get("noiseL_crossover"))
          params:delta("noiseR", d * 0.1)
          params:delta("noiseR_crossover", d * 0.1)
          noiseR_dial:set_value(params:get("noiseR_crossover"))
        end
      else -- lfo depth
        for i = 1, 4 do
          if pages.index == i + 1 then
            if alt == false then
              params:delta(i .. "lfo_depth", d)
              lfo[i].depth_dial:set_value(params:get(i .. "lfo_depth"))
            elseif alt == true then
              params:delta(i .. "lfo_depth", d * 0.1)
              lfo[i].depth_dial:set_value(params:get(i .. "lfo_depth"))
            end
          end
        end
      end
    end
  end
end


function redraw()
  screen.clear()
  screen.font_face(25)
  screen.font_size(6)

  -- pages
  pages:redraw()
  
  -- update dials
  gainL_dial:set_value(params:get("gainL_crossover"))
  gainR_dial:set_value(params:get("gainR_crossover"))
  noiseL_dial:set_value(params:get("noiseL_crossover"))
  noiseR_dial:set_value(params:get("noiseR_crossover"))
  
  for i = 1, 4 do
    lfo[i].freq_dial:set_value(params:get(i .. "lfo_freq"))
    lfo[i].depth_dial:set_value(params:get(i .. "lfo_depth"))
  end
  
  if pages.index == 1 then
    -- filter dials
    gainL_dial:redraw()
    gainR_dial:redraw()
    screen.font_face(1)
    screen.font_size(8)
    noiseL_dial:redraw()
    noiseR_dial:redraw()
    
    screen.font_face(25)
    screen.font_size(6)
    
    -- input gain text
    screen.level(focus == 4 and 15 or 3)
    screen.move(88, 24)
    screen.text_center(params:string('gainL'))
    screen.move(88, 57)
    screen.text_center(params:string('gainR'))
  elseif pages.index > 1 then
    -- lfo graph
--  lfo_1_graph:redraw()
    
    for i = 1, 4 do
      if pages.index == i + 1 then
        -- lfo dials
        lfo[i].freq_dial:redraw()
        lfo[i].depth_dial:redraw()
      
        -- lfo number
        screen.level(3)
        screen.move(100, 5)
        screen.text_center("LFO " .. i)
        
        -- lfo target
        if focus == 4 or focus == 5 then
          screen.level(15)
          screen.move(100, 25)
          screen.text_center(params:string(i .. "lfo_target"))
        else
          screen.level(3)
          screen.move(100, 25)
          screen.text_center(params:string(i .. "lfo_target"))
        end
      end
    end
  end
  
  -- alt
  if alt == true then
      screen.level(3)
      screen.move(0, 5)
      screen.text("*")
--      screen.move(128, 5)
--    if focus == 2 then
--      screen.text_right("peaks")
--    else
--      screen.text_right("fine")
--    end
  end
  
  -- mode background
  screen.level(params:get("enableL") == 2 and 15 or 1)
  screen.rect(0, 6, 5, 7)
  screen.fill()
  screen.level(params:get("enableR") == 2 and 15 or 1)
  screen.rect(0, 39, 5, 7)
  screen.fill()
  
  -- mode
  if params:get("mode") == 1 then -- series
    screen.level(0)
    screen.move(1, 12)
    screen.text("1")
    screen.move(1, 45)
    screen.text("2")
  elseif params:get("mode") == 2 then -- parallel
    screen.level(0)
    screen.move(1, 12)
    screen.text("P")
    screen.move(1, 45)
    screen.text("P")
  elseif params:get("mode") == 3 then -- dual
    screen.level(0)
    screen.move(1, 12)
    screen.text("L")
    screen.move(1, 45)
    screen.text("R")
  end
  
  -- link
  if params:get("link") == 2 then
    screen.level(15)
    screen.move(1, 20)
    screen.text("*")
    screen.move(1, 53)
    screen.text("*")
  end
  
  -- filter graphs
  if params:get("peaksL") == 2 then
    filterL_twin:redraw()
  end
  if params:get("peaksR") == 2 then
    filterR_twin:redraw()
  end
  filterL:redraw()
  filterR:redraw()
  
  -- filter 1 cutoff
  screen.level(focus == 1 and 15 or 3)
  screen.move(6, 5)
  screen.text(params:string('freqL'))
  
  -- filter 1 resonance
  screen.level(focus == 2 and 15 or 3)
  if params:get("peaksL") == 1 then
    screen.move(51, 5)
    screen.text_right("^")
  elseif params:get("peaksL") == 2 then
    screen.move(51, 5)
    screen.text_right("^^")
  end
  screen.move(53, 5)
  screen.text(string.format("%.2f", params:get('resL')))
  
  -- filter 1 type
  screen.level(focus == 3 and 15 or 3)
  if params:get("typeL") == 1 then
    screen.move(8, 12)
    screen.text("LP")
  elseif params:get("typeL") == 2 then
    screen.move(34, 12)
    screen.text("BP")
  elseif params:get("typeL") == 3 then
    screen.move(60, 12)
    screen.text("HP")
  end
  
  -- filter 1 pan
--  screen.level(params:get("panL"))
--  screen.move(4, 25)
--  screen.line(4, 20)
--  screen.line_rel(-3, 2)
--  screen.fill()
  
--  screen.move(4, 25)
--  screen.text(params:get("panL"))
--  screen.move(95, 5)
--  screen.text(params:string("peaksR_spread"))
--  screen.move(95, 35)
--  screen.text(params:string("freqR_crossover"))
  
  -- filter 2 cutoff
  screen.level(focus == 1 and 15 or 3)
  screen.move(6, 38)
  screen.text(params:string('freqR'))
  
  -- filter 2 resonance
  screen.level(focus == 2 and 15 or 3)
  if params:get("peaksR") == 1 then
    screen.move(51, 38)
    screen.text_right("^")
  elseif params:get("peaksR") == 2 then
    screen.move(51, 38)
    screen.text_right("^^")
  end
  screen.move(53, 38)
  screen.text(string.format("%.2f", params:get('resR')))

  -- filter 2 type
  screen.level(focus == 3 and 15 or 3)
  if params:get("typeR") == 1 then
    screen.move(8, 45)
    screen.text("LP")
  elseif params:get("typeR") == 2 then
    screen.move(34, 45)
    screen.text("BP")
  elseif params:get("typeR") == 3 then
    screen.move(60, 45)
    screen.text("HP")
  end

  screen.update()
end
