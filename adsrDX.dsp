declare filename "adsrDX.dsp";
declare name "adsrDX";
import("stdfaust.lib");

declare author "Jeremy WY";
declare copyright "GRAME";
declare license "LGPL with exception";

freq = hslider("freq", 440, 20, 2000, 0.01);
gate = button("gate");
gain = hslider("gain", 0.5, 0, 1, 0.001);

delaySamps(ms) = int(ms * 0.001 * ma.SR);

// envelope dx style
envelopeDX(g) = en.dx7envelope(aR, dR, sR, rR, aL, dL, sL, rL, gate @ delaySamps(del))
with {
    aL = hslider("attack-level", 0.9, 0, 1, 0.001);
    aR = hslider("attack-rate", 0.001, 0, 20, 0.001);
    
    dL = hslider("decay-level", 0.1, 0, 1, 0.001);
    dR = hslider("decay-rate", 0.1, 0, 20, 0.001);

    sL = hslider("sustain-level", 0.5, 0, 1, 0.001);
    sR = hslider("sustain-rate", 0, 0, 20, 0.001);

    rL = hslider("release-level", 0, 0, 1, 0.001);
    rR = hslider("release-rate", 0.5, 0, 20, 0.001);

    del = hslider("del(ms)", 0, 0, 500, 1);

};

process = (_ * envelopeDX(gate)) * gain;