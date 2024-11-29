declare filename "fm6synth.dsp";
declare name "fm6synth";
// 6 operator fm synth

// declare options "[midi:on][nvoices:12]";
// faust library
import("stdfaust.lib");

declare author "Critter&Guitari";
declare copyright "GRAME";
declare license "LGPL with exception";

freq = hslider("freq", 440, 20, 2000, 0.01);
gate = button("gate");
gain = hslider("gain", 0.5, 0, 1, 0.001) : si.polySmooth(gate, 0.999, 64);

modAmt = hslider("[2]modAmt", 0.5, 0, 18, 0.001) : si.polySmooth(gate, 0.999, 64);
feed = hslider("[1]feed", 1, 0, 18, 0.01) : si.polySmooth(gate, 0.999, 64);

operator(i) = _ : os.oscp((freq*f) + freqEnv) * en.adsre(a,d,s,r,gate) * amp
with{
    // params
    f = hslider("f%i", 1, 0.001, 12, 0.001);
    a = hslider("a%i", 0.001, 0.001, 4, 0.001);
    d = hslider("d%i", 0.1, 0.001, 4, 0.001);
    s = hslider("s%i", 0.2, 0, 1, 0.01);
    r = hslider("r%i", 0.5, 0.001, 4, 0.001);
    amp = hslider("amp%i", 0.1, 0, 1, 0.01);
    fa = hslider("fa%i", 0.001, 0.001, 4, 0.001);
    fd = hslider("fd%i", 0.1, 0.001, 4, 0.001);
    fs = hslider("fs%i", 0.2, 0, 1, 0.01);
    fr = hslider("fr%i", 0.5, 0.001, 4, 0.001);
    freqDepth = hslider("freqDepth%i", 10, 0, 1400, 0.1);

    freqEnv = en.adsre(fa,fd,fs,fr,gate) * freqDepth;
};

fb(ops, mul) = ops ~ mean *(mul) 
with {
    mean(x) = (x + x') / 2; // 'Tomisawa's anti-hunting filter', as in yamaha pm; reduce noisiness of   feedback
    // https://www.reddit.com/r/FMsynthesis/comments/85jfrb/dx7_feedback_implementation/
    // https://yamahamusicians.com/forum/viewtopic.php?p=33749&sid=80d2ff7f41f9d9e76318151768c53c78#p33749 (thread now blocked to outsiders and not on wayback machine)
};

chunk1 = 0 : operator(3) : operator(2) *(modAmt) : operator(1);

chunk2 = operator(6) : operator(5) *(modAmt) : operator(4) ;

//chunk2 = (operator(6) : operator(5) : operator(1)) ~ *(feed) ;
process = fb(chunk2,feed) + chunk1;
 