// "Boom Warren" - for Disquiet Junto 0578 submission. ###
// URL: https://llllllll.co/t/disquiet-junto-project-0578-rabbit-spirit-ally/60815
// 27 January 2023.

s.options.numOutputBusChannels = 6;
s.options.numInputBusChannels = 0;
// s.meter;
s.boot;

// Simple sine synth
(
SynthDef.new(\plonk, {
	arg out, low = 50, high = 100, rnd = low, decay = 0.3, vol = 1;
	var freq, trig, sig;
	freq = LFNoise0.kr(20).exprange(low, high).round(rnd);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(0.5);

	sig = sig * EnvGen.kr(Env.perc(0.01, decay), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(0.5));
	Out.ar(out, sig * vol);
}).add;


// String synth
SynthDef.new(\string, {
	arg out, freq = 100, r = 3;
	var trig, sig, mod;
	sig = VarSaw.ar(freq, 0.0, 0.5, 1.0, 0.0);
	mod = VarSaw.ar(10);
	sig = sig * mod;
	trig = Dust.kr(1);

	sig = sig * EnvGen.kr(Env.asr(0.1, 1, r, -1), trig) * 1.1;
	sig = Pan2.ar(sig, LFNoise1.kr(0.3));
	Out.ar(out, sig);
}).add;


// Reverb Bus
SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.5, LFNoise0.kr(3).exprange(0.1, 1.0), 0.2); //
	Out.ar(out, sig);
}).add;

// Crackles
SynthDef.new(\feet, {
	arg out, vol = 0.5, dust = 10, spin = 0.8, room_verb = 0.2;
	var sig;
	sig = Pan2.ar(Dust.ar(dust), FSinOsc.kr(0.2), 0.7);
	sig = FreeVerb.ar(sig, 0.5, room_verb, spin);

	Out.ar(out, sig * vol);
}).add;

)

// Initialise bus channels

~reverbBus1 = Bus.audio(s, 2); // this is a 2-ch bus

~bus1 = Synth.new(\reverb, [\in, ~reverbBus1]);

~bass = Synth.new(\plonk, [\low, 50, \high, 60, \decay, 1.9, \vol, 1, \out, ~reverbBus1]);
~ripple1 = Synth.new(\plonk, [\rate, 30, \low, 3500, \high, 3750, \decay, 1.2, \vol, 0.02,\out, ~reverbBus1]);
~ripple2 = Synth.new(\plonk, [\rate, 40, \low, 500, \high, 700, \decay, 2, \vol, 0.03,\out, ~reverbBus1]);
~string1 = Synth.new(\string, [\freq, 110, \out, ~reverbBus1]);
~string2 = Synth.new(\string, [\freq, 90, \out, ~reverbBus1]);
~crackle1 = Synth.new(\feet, [\dust, 10, \spin, 40, \room_verb, 0.2, \vol, 0.3, \out, ~reverbBus1]);
~crackle2 = Synth.new(\feet, [\dust, 1000, \spin, 0.05, \room_verb, 0.3, \vol, 0.05, \out, ~reverbBus1]);
~crackle3 = Synth.new(\feet, [\dust, 500, \spin, 0.03, \room_verb, 0.3, \vol, 0.05, \out, ~reverbBus1]);

~bus1.free;
~bass.free;
~ripple1.free;
~ripple2.free;
~string1.free;
~string2.free;
~crackle1.free;
~crackle2.free;
~crackle3.free;

r = Recorder(s);
r.record(numChannels:2);
r.stopRecording;

s.freeAll;
s.quit;

