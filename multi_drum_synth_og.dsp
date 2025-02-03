declare filename "multi_drum_synth.dsp";
declare name "multi_drum_synth";
import("stdfaust.lib");

declare author "Critter&Guitari";
declare copyright "GRAME";
declare license "LGPL with exception";

freq = hslider("freq", 440, 20, 2000, 0.01);
gate = button("gate");
gain = hslider("gain", 0, 0, 1, 0.001);

f1 = hslider("f1", 1, 0, 12, 0.001);
s1 = hslider("s1", 0.5, 0, 1, 0.001);
n1 = hslider("n1", 0.5, 0, 1, 0.001);
att1 = hslider("att1", 0.01, 0.001, 2, 0.001);
dec1 = hslider("dec1", 0.2, 0.001, 6, 0.001);
del1 = hslider("del1", 0, 0, 1000, 0.1) * (ma.SR/1000);
amp1 = hslider("amp1", 0, 0, 1, 0.001);

f2 = hslider("f2", 1, 0, 12, 0.001);
s2 = hslider("s2", 0.5, 0, 1, 0.001);
n2 = hslider("n2", 0.5, 0, 1, 0.001);
att2 = hslider("att2", 0.01, 0.001, 2, 0.001);
dec2 = hslider("dec2", 0.2, 0.001, 6, 0.001);
del2 = hslider("del2", 0, 0, 1000, 0.1) * (ma.SR/1000);
amp2 = hslider("amp2", 0, 0, 1, 0.001);

f3 = hslider("f3", 1, 0, 12, 0.001);
s3 = hslider("s3", 0.5, 0, 1, 0.001);
n3 = hslider("n3", 0.5, 0, 1, 0.001);
att3 = hslider("att3", 0.01, 0.001, 2, 0.001);
dec3 = hslider("dec3", 0.2, 0.001, 6, 0.001);
del3 = hslider("del3", 0, 0, 1000, 0.1) * (ma.SR/1000);
amp3 = hslider("amp3", 1, 0, 1, 0.001);

mod3 = hslider("mod3", 0, 0, 10, 0.01);
mod2 = hslider("mod2", 0, 0, 10, 0.01);

// freq envelope
freqAtt = hslider("freqAtt", 0.001, 0.001, 1, 0.001);
freqDec = hslider("freqDec", 0.05, 0.001, 1, 0.001);
freqDepth = hslider("freqDepth", 12, -24, 24, 0.1);
freqEnv(d) = en.adsre(freqAtt, freqDec, 0, freqDec, gate) * d;
freqModder = ba.midikey2hz( ba.hz2midikey( freq ) + freqEnv(freqDepth));

// filter stuff
hpF = hslider("hpF", 300, 10, 10000, 1);
hpQ = hslider("hpQ", 1, 1, 100, 0.1);
lpF = hslider("lpF", 300, 10, 10000, 1);
lpQ = hslider("lpQ", 1, 1, 100, 0.1);

osc(f, s, n, att, dec, del) = sine, noise :> _, en.adsre(att, dec, 0, dec, gate @(del) ) : *
with {
    sine = _ : (os.oscp(f) * 0.35) * s;
    noise = (no.noise * 0.1) * n;
};

op3 = 0 : (osc(freqModder*f3, s3, n3, att3, dec3, del3) * (gain)) <: _ *(amp3), _ *(mod3) ;
op2 = _, (_ : (osc(freqModder*f2, s2, n2, att2, dec2, del2) * (gain)) <: _ *(amp2), _ *(mod2));
op1 = _, _, ( _ : (osc(freqModder*f1, s1, n1, att1, dec1, del1) * (gain)) *(amp1));

oscBank = op3 : op2 : op1 : (_,_ : +), _ : +;


process = oscBank <: fi.resonhp( hpF, hpQ, 0.5) , fi.resonlp( lpF, lpQ, 0.5 ) :> _;

