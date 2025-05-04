declare filename "popFilterDrum.dsp";
declare name "popFilterDrum";
import("stdfaust.lib");

declare author "JeremyWY";
declare copyright "GRAME";
declare license "LGPL with exception";

freq = hslider("freq", 440, 20, 2000, 0.01);
gate = button("gate");
gain = hslider("gain", 0, 0, 1, 0.001);
q = hslider("q", 5, 1, 100, 0.01);


// freq envelope
freqAtt = hslider("freqAtt", 0.001, 0.001, 1, 0.001);
freqDec = hslider("freqDec", 0.01, 0.001, 1, 0.001);
freqDepth = hslider("freqDepth", 30, -48, 48, 0.1);
freqEnv(d) = en.adsre(freqAtt, freqDec, 0, freqDec, gate) * d;
freqModder = ba.midikey2hz( ba.hz2midikey( freq ) + freqEnv(freqDepth));

ampEnv = en.adsre(att, dec, 0, dec, gate )
with {
    att = hslider("att", 0.01, 0.001, 2, 0.001);
    dec = hslider("dec", 0.1, 0.001, 6, 0.001);
};

process = (no.pink_noise * 0.5) * ampEnv : fi.resonbp(freqModder, q, gain);