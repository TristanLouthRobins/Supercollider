// "Evo Compressor" - for Disquiet Junto 0580 submission. ###
// URL: https://llllllll.co/t/disquiet-junto-project-0580-evo-evol-evolve/61049/5
// 10 February 2023.

s.boot;
s.plotTree;

// Dictionary to store samples:
(
~combo = Dictionary.new;

// Add Kalimba samples to dictionary
~combo.add(\kal ->
PathName("/Users/tristanlouth-robins/Documents/Documents - MacBook Pro/Supercollider/youtube tutorial/perc_data/kal").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
    });
);

// Add Woodblock samples to dictionary
~combo.add(\slab ->
PathName("/Users/tristanlouth-robins/Documents/Documents - MacBook Pro/Supercollider/youtube tutorial/perc_data/slab").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
    });
);
)

(
~guiro = Dictionary.new;

// Add Guiro samples to dictionary
~guiro.add(\guiro ->
PathName("/Users/tristanlouth-robins/Documents/Documents - MacBook Pro/Supercollider/youtube tutorial/perc_data/guiro").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
    });
);
)

// Instatiate Synths ----------


// Sine Synth (~), (.)
(
SynthDef.new(\sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;

// Kalimba, woodblock combo (*, //)
SynthDef.new(\percCombo, {
	arg buf=0, out=0, rate=1, amp=1, pan=0;
	var sig;
	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;

// Guiro (^^^)
SynthDef.new(\guiro, {
	arg buf=0, out=0, rate=1, amp=1, pan=0;
	var sig;
	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)



// Patterns for performance -------

// Languid sine (~)
(
Pdef(
	\sineLanguid,
	Pbind(
		\type, \note,
		\instrument, \sine,
		\dur, Pseq([1/1], inf), // incr/decr note freq
		\midinote, Pseq([33], inf).trace,
		\harmonic, Pexprand(1, 3, inf).round,
		\atk, Pwhite(1, 2, inf),
		\rel, Pwhite(2, 5, inf),
		\amp, Pseq([0.2, Pexprand(0.05, 0.2), 7], inf),
		\pan, Pwhite(-0.8, 0.8, inf),
	);
).stop
)

// Blip sine (.)
(
Pdef(
	\sineBlip,
	Pbind(
		\type, \note,
		\instrument, \sine,
		\dur, Pseq([1/1], inf), // incr/decr note freq
		\midinote, Pseq([50], inf),
		\harmonic, Pexprand(60, 80, inf).round.trace,
		\atk, Pwhite(2, 3, inf),
		\rel, Pwhite(2, 3, inf),
		\amp, Pkey(\harmonic).reciprocal * 0.3, // this makes the higher harmonics quieter than the lower ones.
		\pan, Pwhite(-0.8, 0.8, inf),
	);
).play
)

// Kalimba, woodblock percussion (*, //)
(
Pdef(
	\percRhythm,
	Pbind(
		\instrument, \percCombo,
		\dur, Pseq([1/1], inf), // incr/decr note freq
		\stretch, 1.875,
		\buf, Prand(~combo[\kal]++d[\slab], inf),
		\rate, Pexprand(0.1, 0.3, inf),
		\amp, Pseq([0.1, Pexprand(0.1, 0.2, 7)], inf),
		\pan, Pwhite(-0.8, 0.8, inf),
	);
).play(quant:1.875);
)

// Guiro percussion 1 (^^^)
(
Pdef(
	\percRhythm,
	Pbind(
		\instrument, \percCombo,
		\dur, Pseq([1/3], inf), // incr/decr note freq
		\stretch, 1.875,
		\buf, Prand(~guiro[\guiro], inf),
		\rate, Pexprand(3, 6, inf),
		\amp, Pseq([0.1, Pexprand(0.1, 0.1, 7)], inf),
		\pan, Pwhite(-0.8, 0.8, inf),
	);
).play(quant:1.875);
)

///


r = Recorder(s);
r.record(numChannels:2);
r.stopRecording;

s.freeAll;
s.quit;
