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

ramp(x) = max(pow(x/100, 2) * 10, 0.001);

// envelope dx style
envelopeDX(g) = en.dx7envelope(aR, dR, sR, rR, aL, dL, sL, rL, gate @ delaySamps(del))
with {
    aL = hslider("attack-level", 0.9, 0, 1, 0.001);
    aR = ramp(hslider("attack-rate", 0, 0, 100, 1));
    
    dL = hslider("decay-level", 0.1, 0, 1, 0.001);
    dR = ramp(hslider("decay-rate", 0, 0, 100, 1));

    sL = hslider("sustain-level", 0, 0, 1, 0.001);
    sR = ramp(hslider("sustain-rate", 0, 0, 100, 1));

    rL = hslider("release-level", 0, 0, 1, 0.001);
    rR = ramp(hslider("release-rate", 0, 0, 100, 1));

    del = hslider("del(ms)", 0, 0, 500, 0.001);

};

process = (_ * envelopeDX(gate)) * gain;