declare filename "organ_12_4.dsp";
declare name "organ_12_4";
import("stdfaust.lib");

declare author "emi wy";
declare version "1.4";
declare copyright "GRAME";
declare license "LGPL with exception";

freq = hslider("freq", 440, 20, 2000, 0.01);
gate = button("gate");
gain = hslider("gain", 0, 0, 1, 0.001) : si.smoo;

oscAmt = 12;

fFreq = hslider("filterFreq", 0.1, 0, 1, 0.001) : si.polySmooth(gate, 0.999, 10);
fRez = hslider("filterRez", 4, 0, 120, 1) : si.polySmooth(gate, 0.999, 10);
port = hslider("port", 0, 0, 0.9999, 0.0001);

// Frequency envelope
fa = hslider("freqEnvA", 0.001, 0.001, 12, 0.001);
fdec = hslider("freqEnvD", 0.05, 0.001, 12, 0.001);
fs = hslider("freqEnvS", 0, 0, 1, 0.001);
fr = hslider("freqEnvR", 0.01, 0.001, 12, 0.001);
freqDepth = hslider("freqDepth", 12, -48, 48, 0.001);

freqEnv = en.adsre(fa,fdec,fs,fr,gate) * freqDepth;

slideFreq = freq : si.smooth(port);

// Amp LFO global phasor
ampLFOrate = hslider("ampLFORate", 0.45, 0, 2000, 0.001);

ampLFOEnv = (en.adsre(a,d,s,r,gate @del) * depth) + ampLFOrate
with {
    del = hslider("ampLFOdelay", 500, 0, 1000, 0.1) * (ma.SR/1000);
    a = hslider("ampLFOattack", 2, 0.001, 12, 0.001);
    d = hslider("ampLFOdecay", 2, 0.001, 12, 0.001);
    s = hslider("ampLFOsustain", 0.06, 0, 1, 0.001);
    r = hslider("ampLFOrelease", 2, 0.001, 12, 0.001);
    depth= hslider("ampLFOdepth", 0.9, -20, 20, 0.001);
};

lfoPhasor = os.phasor(1.0, ampLFOEnv);

// process LFO
processLFO(p, offset) =  sin( ((p + offset) % 1) * (ma.PI*2));

// bandlimited simple osc for additive
osc( i ) = bLimit(newFreq * idx, 18000) : (os.osc * 0.25) * lfoReceive : _ * en.adsre(a,d,s,r,gate @(del)) : filtBP
with {
    lfoPhase = hslider("lfoPhase%i", 0, 0, 1, 0.001);
    lfoAmt = hslider("lfoAmt%i", (i+1)*(1/12), 0, 1, 0.001);
    
    lfoReceive = (processLFO(lfoPhasor, lfoPhase) * lfoAmt) + (1-lfoAmt);
    
    newFreq = ba.midikey2hz( ba.hz2midikey(slideFreq) + (freqEnv * fEnvAmt));
    fEnvAmt = hslider("fEnvAmt%i", 0, 0, 1, 0.001);
    idx = hslider("idx%i", i, -48, 48, 0.001) : si.polySmooth(gate, 0.999, 10);
    amp = hslider("amp%i", 1/(i+1), 0, 1, 0.001) : si.polySmooth(gate, 0.999, 10);
    a = hslider("a%i", .001, 0.001, 12, 0.001);
    d = hslider("d%i", 2, 0.001, 12, 0.001);
    s = hslider("s%i", 0.7, 0.001, 1, 0.001);
    r = hslider("r%i", 0.01, 0.001, 12, 0.001);
    del = hslider("del%i", i*1, 0, 1000, 0.1) * (ma.SR/1000);
    
    // if freq is above 19,000 output 0
    bLimit(fr,x) = fr < (x), fr : *;
    // 'filter'
    range = i/oscAmt;
    sweep = (fFreq/2) - 0.5;
    scale = abs( sweep - range );
    //filtBP = 
    filtBP = _, pow( sin( ((scale + 0.5) / 2) * ma.PI ), fRez): *;
};

process = sum(i, oscAmt, osc( i )) :> _ * (gain) <: _ , _;

