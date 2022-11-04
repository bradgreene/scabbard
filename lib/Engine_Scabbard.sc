Engine_Scabbard : CroneEngine {
  
  var buses;
  var input;
  var output;
  var filter1;
//  var spread1;
  var filter2;
  
  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    // Passthrough
    SynthDef(\passThru, {|inL, inR, out, spread = -1, amp = 1|
      var inputL, inputR, spread1, spread2;
      
//      inputL = In.ar(inL);
//      inputR = In.ar(inR);
      
//      spread1 = LinXFade2.ar(inputL, Silent.ar(1), spread);
//      spread2 = LinXFade2.ar(inputR, Silent.ar(1), spread);
    
      Out.ar(out, [In.ar(inL), In.ar(inR)] * amp);
    }).add;
    context.server.sync;
    
    // Create buses
    buses = List.new;
    buses.add(Bus.audio(context.server, 2));
    buses.add(Bus.audio(context.server, 2));
    buses.add(Bus.audio(context.server, 2));
//    buses.add(Bus.audio(context.server, 2));
    
    // Spread 1
//    SynthDef(\Spread1, {|inL, inR, out, spread = -1|
//      var inputL, inputR, signal;
      
//      inputL = In.ar(inL);
//      inputR = In.ar(inR);
      
 //     signal = Mix.new([inputL, inputR]);
      
 //     signal = LinXFade2.ar(inputL, signal, spread);
    
 //     Out.ar(out, signal);
//    }).add;
    
    // Filter 1
    SynthDef(\Filter1, {|inL, inR, out, pan, mix, parallel, bypass, bypass2, bandpass, bandpass2, freqL = 20000, resL = 0, inputGainL = 1, fTypeL = 0, noiseLevelL = 0, noiseLevelL2 = 0, spread, amp, modeAmp = 1|
      var inputs, inputL, inputL_pan, inputR, inputR_pan, signal, signal2, controlLag = 0.01;
      
      inputs = [In.ar(inL), In.ar(inR)];
      inputL = In.ar(inL);
 //     inputL_pan = LinXFade2.ar(inputL, Silent.ar(1), pan);
      inputR = In.ar(inR);
//      inputR_pan = LinXFade2.ar(inputR, Silent.ar(1), pan);
//      signal = [inputL, inputR_pan];
//      signal2 = [inputL_pan, inputR];

      signal = [inputL, inputR];
      
      inputGainL = inputGainL.dbamp;
      
      signal = DFM1.ar(signal, freqL.lag(controlLag), resL.lag(controlLag), inputGainL.lag(controlLag), fTypeL, noiseLevelL.lag(controlLag));
			  
			signal = Select.ar(bandpass, [
				  BPF.ar(signal, freqL.lag(controlLag), 1),
				  signal
			  ]);
			  
	//		signal2 = DFM1.ar(signal2, spread.lag(controlLag), resL.lag(controlLag), inputGainL.lag(controlLag), fTypeL, noiseLevelL.lag(controlLag));
			  
	//		signal2 = Select.ar(bandpass, [
  //        BPF.ar(signal2, freqL.lag(controlLag), 1),
  //        signal2
	//		  ]);
			  
	//		signal = Select.ar(mix, [
  //        signal,
  //        Mix.new([signal, signal2]) * 0.8
	//		  ]);
			  
			signal = Select.ar(bypass, [
          inputs,
          signal
			  ]);
				
			signal = signal.softclip;

      Out.ar(out, signal * amp);
    }).add;

    // Filter 2
    SynthDef(\Filter2, {|inL, inR, out, pan, mix, bypass, bypass_2, bandpass, bandpass_2, freqR = 20000, resR = 0, inputGainR = 1, fTypeR = 0, noiseLevelR = 0, spread, amp, modeAmp = 1|
      var inputs, inputL, inputL_pan, inputR, inputR_pan, signal, signal2, controlLag = 0.01;
      
      inputs = [In.ar(inL), In.ar(inR)];
      inputL = In.ar(inL);
//      inputL_pan = LinXFade2.ar(inputL, Silent.ar(1), pan);
      inputR = In.ar(inR);
//      inputR_pan = LinXFade2.ar(inputR, Silent.ar(1), pan);
//      signal = [inputL, inputR_pan];
//      signal2 = [inputL_pan, inputR];

      signal = [inputL, inputR];
      
      inputGainR = inputGainR.dbamp;
      
      signal = DFM1.ar(signal, freqR.lag(controlLag), resR.lag(controlLag), inputGainR.lag(controlLag), fTypeR, noiseLevelR.lag(controlLag));
			  
			signal = Select.ar(bandpass, [
				  BPF.ar(signal, freqR.lag(controlLag), 1),
				  signal
			  ]);
			  
//			signal2 = DFM1.ar(signal2, spread.lag(controlLag), resR.lag(controlLag), inputGainR.lag(controlLag), fTypeR, noiseLevelR.lag(controlLag));
			  
//			signal2 = Select.ar(bandpass, [
//          BPF.ar(signal2, freqR.lag(controlLag), 1),
//          signal2
//			  ]);
			  
//			signal = Select.ar(mix, [
 //         signal,
 //         Mix.new([signal, signal2]) * 0.8
//			  ]);
			  
			signal = Select.ar(bypass, [
          inputs,
          signal
			  ]);
        
      signal = signal.softclip;
        
      Out.ar(out, signal * amp);
    }).add;
    
    // change mode
    this.addCommand("set_mode", "i", {|msg| this.setMode(msg[1]);});

 //   this.addCommand("set_amp", "i", {|msg| this.setAmp(msg[1]);});

    // filter commands
    this.addCommand("panL", "f", {|msg|
      filter1.set(\pan, msg[1]);
    });
    
    this.addCommand("panR", "f", {|msg|
      filter2.set(\pan, msg[1]);
    });
    
    this.addCommand("amp1", "f", {|msg|
      filter1.set(\amp, msg[1]);
    });
    
    this.addCommand("amp2", "f", {|msg|
      filter2.set(\amp, msg[1]);
    });
    
    this.addCommand("bypassL", "i", {|msg|
      filter1.set(\bypass, msg[1]);
    });
    
    this.addCommand("mix1", "i", {|msg|
      filter1.set(\mix, msg[1]);
    });
    
    this.addCommand("mix2", "i", {|msg|
      filter2.set(\mix, msg[1]);
    });
    
    this.addCommand("bypassL_2", "i", {|msg|
      filter1.set(\bypass2, msg[1]);
    });
    
    this.addCommand("bypassR", "i", {|msg|
      filter2.set(\bypass, msg[1]);
    });
    
    this.addCommand("freqL", "f", {|msg|
      filter1.set(\freqL, msg[1]);
    });
    
    this.addCommand("freqR", "f", {|msg|
      filter2.set(\freqR, msg[1]);
    });
    
    this.addCommand("resL", "f", {|msg|
      filter1.set(\resL, msg[1]);
    });
    
    this.addCommand("spreadL", "f", {|msg|
      filter1.set(\spread, msg[1]);
    });
    
    this.addCommand("spreadR", "f", {|msg|
      filter2.set(\spread, msg[1]);
    });
    
    this.addCommand("resR", "f", {|msg|
      filter2.set(\resR, msg[1]);
    });
    
    this.addCommand("gainL", "f", {|msg|
      filter1.set(\inputGainL, msg[1]);
    });
    
    this.addCommand("gainR", "f", {|msg|
      filter2.set(\inputGainR, msg[1]);
    });
    
    this.addCommand("typeL", "f", {|msg|
      filter1.set(\fTypeL, msg[1]);
    });
    
    this.addCommand("bandpassL", "i", {|msg|
      filter1.set(\bandpass, msg[1]);
    });
    
    this.addCommand("bandpassL_2", "i", {|msg|
      filter1.set(\bandpass2, msg[1]);
    });
    
    this.addCommand("typeR", "f", {|msg|
      filter2.set(\fTypeR, msg[1]);
    });
    
    this.addCommand("bandpassR", "i", {|msg|
      filter2.set(\bandpass, msg[1]);
    });
    
    this.addCommand("noiseL", "f", {|msg|
      filter1.set(\noiseLevelL, msg[1]);
    });
    
    this.addCommand("noiseR", "f", {|msg|
      filter2.set(\noiseLevelR, msg[1]);
    });
    
    this.routing;
  }
  
  routing {
    input = Synth.new(\passThru, [
      \inL, context.in_b[0].index,
      \inR, context.in_b[1].index,
      \out, buses[0].index,
    ], context.xg);
    context.server.sync;

    filter1 = Synth.new(\Filter1, [
      \inL, buses[0].index,
      \inR, buses[0].index + 1,
      \out, buses[1].index,
      \amp, 1
    ], input, \addAfter);
    
//    spread1 = Synth.new(\Spread1, [
//      \inL, buses[1].index,
//      \inR, buses[1].index + 1,
//      \out, buses[2].index,
//    ], filter1, \addAfter);
    
    filter2 = Synth.new(\Filter2, [
      \inL, buses[1].index,
      \inR, buses[1].index + 1,
      \out, buses[2].index,
      \amp, 1
    ], filter1, \addAfter);
    
    output = Synth.new(\passThru, [
      \inL, buses[2].index,
      \inR, buses[2].index + 1,
      \out, context.out_b.index,
      \amp, 1
    ], filter2, \addAfter);
  }
  
  setMode {|modeArg|
    var mode = modeArg;
   
    if (mode == 1, {
      filter1.set(\inL, buses[0].index, \inR, buses[0].index + 1, \out, buses[1].index);
//      spread1.set(\inL, buses[1].index, \inR, buses[1].index + 1, \out, buses[2].index);
      filter2.set(\inL, buses[1].index, \inR, buses[1].index + 1, \out, buses[2].index);
    });
    
    if (mode == 2, {
      filter1.set(\inL, buses[0].index, \inR, buses[0].index + 1, \out, buses[2].index);
      filter2.set(\inL, buses[0].index, \inR, buses[0].index + 1, \out, buses[2].index);
    });
    
    if (mode == 3, {
      filter1.set(\inL, buses[0].index, \inR, nil, \out, buses[2].index);
      filter2.set(\inL, nil, \inR, buses[0].index + 1, \out, buses[2].index);
    });
  }
  
 // setAmp {|bypassArg|
 //   var bypass = bypassArg;
   
 //   if (bypass == 1, {
 //     filter1.set(\amp, 1);
 //     filter2.set(\amp, 1);
 //   });
    
//    if (bypass == 2, {
//      filter1.set(\amp, 0.5);
//      filter2.set(\amp, 0.5);
//    });
//  }

//  getInL {
//    ^context.in_b[0].index;
//  }

// if adding mono mode
//  getInR {
//    if (numInputChannels == 1, {
//      ^context.in_b[0].index;
//    }, {
//      ^context.in_b[1].index;
//    });
//  }

  free {
    buses.do({|bus| bus.free;});
    filter1.free;
    filter2.free;
    output.free;
    input.free;
  }
}