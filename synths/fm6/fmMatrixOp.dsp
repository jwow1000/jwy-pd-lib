declare filename "fmMatrixOp.dsp";
declare name "fmMatrixOp";
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

// envelope dx style
envelopeDX(g) = en.dx7envelope(aR, dR, sR, rR, aL, dL, sL, rL, g)
with {
    aL =  hslider("aL", 0.9, 0, 1, 0.001);
    aR =  hslider("aR", 0.006, 0.001, 12, 0.001);
    dL =  hslider("dL", 0.1, 0, 1, 0.001);
    dR =  hslider("dR", 1, 0.001, 12, 0.001);
    sL =  hslider("sL", 0.5, 0, 1, 0.001);
    sR =  hslider("sR", 1, 0.001, 12, 0.001);
    rL =  hslider("rL", 0, 0, 1, 0.001);
    rR =  hslider("rR", 0.1, 0.001, 12, 0.001);

};

// // LFO - Single output signal (unipolar: 0 to 1)
// lfoSignal = vgroup("LFO", op )
// with {
//     rate = hslider("LFO-rate", 0.1, 0, 200, 0.001);
//     rateEnvAmt = hslider("LFO-env-amt", 3, 0, 200, 0.01);
//     env = envelopeDX(gate);
    
//     op = os.phasor(1.0, rate + (env * rateEnvAmt)); 
// };

// Operator definition with modulation input and LFO input
operator(modInput, lfoIn) = 
    
        (phaseMod(ba.midikey2hz(ba.hz2midikey(theFreq) + freqEnv), fbAmt, modInput) 
        * amp
        * vgroup("amp-envelope", envelopeDX(gate)))
        * ((theLFO*lfoAmt)+(1-lfoAmt))
     : outlets
with {
    lfoPhase = hslider("lfo-phase", 0, 0, 1, 0.001);
    lfoAmt = hslider("lfo-amt", 0, 0, 1, 0.01);
    theLFO = (lfoIn + lfoPhase) * (ma.PI*2) : cos : (_ * 0.5) + 0.5;

    theFreq = (freq * index) + offset;
    pan = hslider("pan", 0.5, 0, 1, 0.01);
    outlets = _ <: _ * sqrt(1 - pan), _ * sqrt(pan);
    
    // operator parameters 
    offset = hslider("offset", 0, -1000, 1000, 0.001);
    index = hslider("index", 1, 0.001, 12, 0.001);
    amp = hslider("amp", 0.5, 0, 5, 0.01);
    fbAmt = hslider("fb", 0, 0, 18, 0.1);
    depth = hslider("freq-depth", 0, 0, 48, 0.01);
    center = hslider("freq-center", 0, -48, 48, 0.01);
    
    // Frequency envelope in semitones
    freqEnv = vgroup("freq-envelope", (envelopeDX(gate) * depth) + center);
    
    // phase modulation (FM) oscillator with feedback algo
    phaseMod(f, fb, modd) = modd : fbFeedback(op(f), fb)
    with { 
        op(f, mod) = _, (mod + 0) : + : os.oscp(f) * 0.25;

        fbFeedback(x, mul) = x ~ mean * mul 
        with {
            mean(x) = (x + x') / 2;
        };
    };
};

silent = 0;

// Voice architecture - LFO signal is generated once and passed to all operators
// voice(lfoSig) = algo4(lfoSig)
// with {
     
//     algo1(lfo) = operator(3, silent, silent, lfo) : operator(2, _, _, lfo) : operator(1, _, _, lfo);
//     algo2(lfo) = operator(3, silent, silent, lfo) : operator(2, _, _, lfo) <: operator(1, _, _, lfo), _, _ :> _, _;
//     algo3(lfo) = operator(3, silent, silent, lfo), operator(2, silent, silent, lfo), operator(1, silent, silent, lfo) :> _, _;
//     algo4(lfo) = operator(3, silent, silent, lfo) <: operator(2, _, _, lfo), operator(1, _, _, lfo) :> _,_ ;
    
// };

// Generate LFO once, pass to voice
process = operator;