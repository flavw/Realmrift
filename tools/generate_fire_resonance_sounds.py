"""Original synthesized fire and resonance sound cues, Ogg Vorbis."""
import math, random, struct
from pathlib import Path
from audio_encoding import write_ogg
rate=44100
rng=random.Random(6321)
noise=0.0
for name,duration in [('fire',0.72),('resonance',0.65)]:
    samples=[]
    for i in range(round(rate*duration)):
        t=i/rate
        env=min(1,t/.02,(duration-t)/.12)
        if name=='fire':
            noise=noise*.88+rng.uniform(-1,1)*.12
            v=(noise*1.5+0.1*math.sin(2*math.pi*(85*t-20*t*t)))*math.exp(-t*2)
            if rng.random()<.002:v+=rng.uniform(-.3,.3)
        else:
            v=sum(.19*math.sin(2*math.pi*f*t)*math.exp(-t*d) for f,d in [(440,4),(660,4.5),(880,5)])
            v+=.1*math.sin(2*math.pi*(600*t+360*t*t))*math.exp(-t*5)
        samples.append(round(max(-1,min(1,v*env))*26000))
    write_ogg(Path(__file__).resolve().parents[1]/'assets/audio'/(name+'.ogg'),struct.pack('<'+'h'*len(samples),*samples),rate)
    print(name)
