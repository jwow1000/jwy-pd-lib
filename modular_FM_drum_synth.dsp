declare filename "modular_FM_drum_synth.dsp";
declare name "modular_FM_drum_synth";
import("stdfaust.lib");

declare author "Critter&Guitari";
declare copyright "GRAME";
declare license "LGPL with exception";

freq = hslider("freq", 440, 20, 2000, 0.01);
gate = button("gate");
gain = hslider("gain", 0, 0, 1, 0.001);


mod3 = hslider("mod3", 0, 0, 10, 0.01);
mod2 = hslider("mod2", 0, 0, 10, 0.01);

// freq envelope
freqAtt = hslider("freqAtt", 0.001, 0.001, 1, 0.001);
freqDec = hslider("freqDec", 0.1, 0.001, 1, 0.001);
freqDepth = hslider("freqDepth", 30, -48, 48, 0.1);
freqEnv(d) = en.adsre(freqAtt, freqDec, 0, freqDec, gate) * d;
freqModder = ba.midikey2hz( ba.hz2midikey( freq ) + freqEnv(freqDepth));

// filter stuff
hpF = hslider("hpF", 300, 10, 10000, 1);
hpQ = hslider("hpQ", 1, 1, 100, 0.1);
lpF = hslider("lpF", 300, 10, 10000, 1);
lpQ = hslider("lpQ", 1, 1, 100, 0.1);

osc(i) = synth <: *(amp), *(mod)
with {
    
    synth = sine, noise :> *(gain) * en.adsre(att, dec, 0, dec, gate @(del) ) ;
    freqEnvAmt = hslider("freqEnvAmt%i", 1, 0, 1, 0.001);
    f = hslider("f%i", 1, 0, 12, 0.001);
    sineAmp = hslider("sineAmp%i", 0.5, 0, 1, 0.001);
    noiseAmp = hslider("noiseAmp%i", 0, 0, 1, 0.001);
    att = hslider("att%i", 0.01, 0.001, 2, 0.001);
    dec = hslider("dec%i", 0.7, 0.001, 6, 0.001);
    del = hslider("del%i", 0, 0, 1000, 0.1) * (ma.SR/1000);
    amp = hslider("amp%i", 1, 0, 1, 0.001);
    mod = hslider("mod%i", 0, 0, 10, 0.01);
    
    freqModder = ba.midikey2hz( ba.hz2midikey( freq * f ) + (freqEnv(freqDepth) * freqEnvAmt) );
    sine = _ : (os.oscp(freqModder) * 0.35) * sineAmp;
    noise = (no.noise * 0.1) * noiseAmp;
};

oscBank = 0 : osc(3) : _, osc(2): _,_, osc(1) :> _;


process = oscBank <: fi.resonhp( hpF, hpQ, 0.25) , fi.resonlp( lpF, lpQ, 0.25 ) :> _;

