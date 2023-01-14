// "Sounding out" - for Disquiet Junto 0576 submission.                           ###
// https://llllllll.co/t/disquiet-junto-project-0576-casual-resolution/60604/10.  ###
// My first proper SC script (it's a little rough.)                               ###
// 14 Jan 2023. Tristan Louth-Robins                                              ###

s.boot;

// Synth: Mettalic 'blip' impulse --------------------------------
(
SynthDef.new(\blip1, {
	arg out;
	var freq, temp, sum, trig, sig;
    freq = LFNoise0.kr(1).exprange(110,2000).round(30);
	trig = Dust.kr(1.33);
	sum = 0;
	10.do{
		temp = SinOsc.ar(freq * {Rand(0.99, 5.01)}!2);
		sum = sum + temp;
	};

	sig = sum * EnvGen.kr(Env.perc(0.01, 0.5), trig);
	sig = sig * 0.05; // <-- minimise clipping
	sig = Splay.ar(sig);
	Out.ar(out, sig);
}).add;

// Bus 1: Reverb ---------------------------------------------
SynthDef.new(\reverb1, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.5, 0.4, 0.01);
	Out.ar(out,sig);
}).add;
)

// Synth: Mettalic 'drone' --------------------------------
(
SynthDef.new(\blip2, {
	arg out;
	var freq, temp, sum, trig, sig;
    freq = LFNoise0.kr(1).exprange(88,99).round(3);
	trig = Dust.kr(1);
	sum = 0;
	10.do{
		temp = SinOsc.ar(freq * {Rand(0.99, 10.01)}!2);
		sum = sum + temp;
	};

	sig = sum * EnvGen.kr(Env.perc(0.5, 0.5), trig);
	sig = sig * 0.05; // <-- minimise clipping
	sig = Splay.ar(sig);
	Out.ar(out, sig);
}).add;

// Bus 2: Reverb ---------------------------------------------
SynthDef.new(\reverb2, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.5, 0.4, 0.01);
	Out.ar(out,sig);
}).add;
)

// Synth: filtered Brownian noise controlled my mouse position ---
(
SynthDef.new(\noise, {
	arg out;
	var sig;
	sig = { BPF.ar(BrownNoise.ar(0.1.dup), MouseX.kr(40, 17000, 1), 0.2) };
	Out.ar(out,sig);
}).add;
)

// Synth: Ominous saw --------------------------------------------
(
SynthDef.new(\saw, {
	arg out;
	var freq, temp, sum, trig, sig;
	freq = LFNoise0.kr(3).exprange(220,225).round(200);
	trig = Dust.kr(0.5);
	sum = 0;
	10.do{
		temp = VarSaw.ar(freq * {Rand(0.99, 2.01)}!2);
		sum = sum + temp;
	};

	sig = sum * EnvGen.kr(Env.triangle({Rand(0.2, 1)}!2, 1), trig);
	sig = sig * 0.05; // <-- minimise clipping
	sig = Splay.ar(sig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);
}).add;

// Bus 3: Reverb ---------------------------------------------

SynthDef.new(\reverb3, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.5, 1, 0.3);
	Out.ar(out,sig);
}).add;
)

// Initialise Bus Channels ----------------------------------

s.options.numOutputBusChannels = 6;
s.options.numInputBusChannels = 0;

s.reboot;
s.meter;

~reverbBus1 = Bus.audio(s, 2);
~reverbBus2 = Bus.audio(s, 2);
~reverbBus3 = Bus.audio(s, 2);

~bus1 = Synth.new(\reverb1, [\in, ~reverbBus1]);
~bus2 = Synth.new(\reverb1, [\in, ~reverbBus2]);
~bus3 = Synth.new(\reverb3, [\in, ~reverbBus3]);
~blip1 = Synth.new(\blip1, [\out, ~reverbBus1]);
~blip2 = Synth.new(\blip2, [\out, ~reverbBus2]);
~buzz = Synth.new(\saw, [\out, ~reverbBus3]);
~noise = Synth.new(\noise, [\out, ~reverbBus3]);

~bus1.free;
~bus2.free;
~blip1.free;
~blip2.free;
~buzz.free;
~noise.free;

r = Recorder(s);

{ Pan2.ar(Dust.ar(8), FSinOsc.kr(50), 0.3) }.play
{ Pan2.ar(Dust.ar(12), FSinOsc.kr(10), 0.5) }.play
{ Pan2.ar(Dust.ar(20), FSinOsc.kr(5.5), 0.66) }.play
{ Pan2.ar(Dust.ar(60), FSinOsc.kr(2), 0.77) }.play


r.record(numChannels:2);
r.stopRecording;

s.freeAll;

s.quit;
