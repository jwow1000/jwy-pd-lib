declare filename "add_free.dsp";
declare name "add_free";
import("stdfaust.lib");

declare author "remy wy";
declare title "additive free";
declare copyright "GRAME";
declare license "LGPL with exception";

freq = hslider("freq", 440, 20, 2000, 0.01);
gate = button("gate");
gain = hslider("gain", 0, 0, 1, 0.001);

oscAmt = 24;

// adsre(attT60,decT60,susLvl,relT60,gate) = envelope 
// with {
//   ugate = gate>0;
//   samps = ugate : +~(*(ugate)); // ramp time in samples
//   attSamps = int(attT60 * ma.SR);
//   // if attSamps==0, go straight into the decay phase
//   attPhase = (samps<attSamps) | (ugate:ba.impulsify);
//   target = select2(ugate, 0.0,
//            select2(attPhase, susLvl*float(ugate), ugate));
//   t60 = select2(ugate, relT60, select2(attPhase, decT60, attT60));
//   pole = ba.tau2pole(t60/6.91);
//   envelope = target : si.smooth(pole);
// };


att = hslider("att", 0.01, 0.001, 4, 0.001);
dec = hslider("dec", 0.01, 0.001, 4, 0.001);
sus = hslider("sus", 0.5, 0, 1, 0.001);
rel = hslider("rel", 0.1, 0.001, 4, 0.001);
skewAmt = hslider("skewAmt", 0, 0, 1, 0.001);
waveSel = nentry("Waveform[style:menu{'Triangle':0;'Saw':1;'Square':2;'Mix':3}]", 0, 0, 3, 1);


detune = hslider("detune", 0, -2, 2, 0.001);
port = hslider("port", 2000, 0.001, 2000, 0.001);

fFreq = hslider("fFreq", 0.1, 0, 1, 0.001) : si.polySmooth(gate, 0.999, 10);
fRez = hslider("fRez", 4, 0, 120, 1) : si.polySmooth(gate, 0.999, 10);

// bandlimited simple osc for additive
osc(num, i, amp, a,d,s,r, f, rez) = bLimit(_ * i, 18,000), 0 : ((os.oscp*0.5) * amp) * en.adsre(a,d,s,r,gate) : filtBP
with{
    // if freq is above 19,000 output 0
    bLimit(fr,x) = fr < (x), fr : *;
    // 'filter'
    range = num/oscAmt;
    sweep = (f/2) - 0.5;
    scale = abs( sweep - range );
    //filtBP = 
    filtBP = _, pow( sin( ((scale + 0.5) / 2) * ma.PI ), rez): *;
};




/*theTab(i,sel) = it.interpolate_cubic(sel, rdtable(wave1,i), rdtable(wave2,i), rdtable(wave3,i),rdtable(wave4,i) );
*/
triangle(i,d) = (odd + d) * every
with{
    odd = ((i*2) + 1);
    every = ((i%2)*2) - 1;
    det = d;
};

saw(i,d) = i + det
with {
    det = d; 
};

square(i, d) = odd + det
with {
    det = d;
    odd = ((i*2) + 1);
};

waveformMixer(i, d) = square(i, d) * sqAmp, saw(i, d) * sawAmp, triangle(i, d) * triAmp :> _
with {  
    sqAmp = hslider("SquareVol", 0, 0, 1, 0.01);
    sawAmp = hslider("SawVol", 0, 0, 1, 0.01);
    triAmp = hslider("TriangleVol", 1, 0, 1, 0.01);
};

wave(i, d) = ba.selectn(4, waveSel,
                     triangle(i, d),
                     saw(i, d),
                     square(i, d),
                     waveformMixer(i, d)
                    );

skew(amt, i, sAmt) = max( (amt * (1-sAmt)) + amount, 0.001)
with {
    amount = amt * ((1 / (i+1)) * sAmt);
};

// add skew params for adsr, like higher partials shorter attack and release
synth(dt) = freq : fi.lowpass(1, port) <: sum(i, oscAmt, osc( i,
                                
                                wave(i, dt), 
                                pow(0.7/(i+1),1), 
                                skew(att, i, skewAmt)   ,
                                skew(dec, i, skewAmt)        ,
                                sus    ,
                                skew(rel, i, skewAmt)    ,
                                fFreq            ,
                                fRez   
                                )       
                    ) :> _ * (gain);

process = synth(detune);

