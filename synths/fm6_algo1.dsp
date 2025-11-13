declare filename "fm6_algo1.dsp";
declare name "fm6_algo1";
import("stdfaust.lib");

declare author "Jeremy WY";
declare copyright "GRAME";
declare license "LGPL with exception";

freq = hslider("freq", 440, 20, 2000, 0.01);
gate = button("gate");
gain = hslider("gain", 0.5, 0, 1, 0.001);

// Feedback function 
fb(ops, mul) = ops ~ mean *(mul) 
with {
    mean(x) = (x + x') / 2;
};

// Operator definition with modulation input, modulation output, and stereo main output
operator(i, modInput1, modInput2) = 
    (phaseMod( theFreq+freqEnv, fbAmt, (modInput1+modInput2)) * en.adsre(a,d,s,r,gate)) * amp : outlets
with {
    theFreq = (freq*index) + offset;
    pan =  hslider("op%i-pan", 0.5, 0, 1, 0.01);
    outlets = _ <: _*sqrt(1-pan),_*sqrt(pan);
    

    // oper_tor parameters 
    offset = hslider("offset%i", 0, -1000, 1000, 0.001);
    index = hslider("index%i", 1, 0.001, 12, 0.001);
    a = hslider("a%i", 0.01, 0.001, 4, 0.001);
    d = hslider("d%i", 0.4, 0.001, 4, 0.001);
    s = hslider("s%i", 0.5, 0, 1, 0.01);
    r = hslider("r%i", 2, 0.001, 4, 0.001);
    amp = hslider("amp%i", 0.5, 0, 5, 0.01);
    fa = hslider("f-a%i", 0.001, 0.001, 4, 0.001);
    fd = hslider("f-d%i", 0.1, 0.001, 4, 0.001);
    fs = hslider("f-s%i", 0, 0, 1, 0.01);
    fr = hslider("f-r%i", 0.1, 0.001, 4, 0.001);
    freqDepth = hslider("f-depth%i", 0, -1400, 1400, 0.1);
    fbAmt = hslider("fb%i", 0, 0, 18, 0.1);

    // modulation matrix
 
    
    // Frequency envelope
    freqEnv = en.adsre(fa,fd,fs,fr,gate) * freqDepth;
    

    // phase modulation (FM) oscillator with feedback algo
    phaseMod(f, fb, modd) = modd : fbFeedback( op(f), fb)
    with { 
        op(f, mod) = _, mod : + : os.oscp(f) * 0.25;

        fbFeedback(x, mul) = x ~ mean * mul 
        with {
            mean(x) = (x + x') / 2;
        };
    };
};

// process = sum(i, 6, operator(i));
algo1 = 0 <: operator(3) : operator(2) : operator(1) ;
algo2 = 0 <: operator(6) : operator(5) : operator(4) ;
process = algo1, algo2 :> _ ,_ <: _,_;
