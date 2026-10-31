"""Sons originais sintetizados para Devoção, regeneração, frasco e melhorias."""
import math, random, struct
from pathlib import Path
from audio_encoding import write_ogg

RATE=44100
OUT=Path(__file__).resolve().parents[1]/'assets/audio'
rng=random.Random(81326)
def chime(t, notes):
    return sum(a*math.sin(2*math.pi*f*(t-start))*math.exp(-decay*(t-start))*(1-math.exp(-80*(t-start))) for start,f,a,decay in notes if t>=start)
def devotion(t):
    return chime(t,[(0,523.25,.38,4.0),(.07,659.25,.32,4.2),(.14,783.99,.34,3.8),(.20,1046.5,.22,4.5)])
def regeneration(t):
    return chime(t,[(0,392,.38,7),(.09,493.88,.3,7),(.17,587.33,.26,6)])+.08*math.sin(2*math.pi*(190*t+260*t*t))*math.exp(-5*t)
def poison_throw(t):
    return .32*rng.uniform(-1,1)*math.exp(-12*t)+.35*math.sin(2*math.pi*(450*t+700*t*t))*math.exp(-10*t)
def buff(t):
    return chime(t,[(0,440,.4,8),(.08,659.25,.35,7),(.15,880,.25,7)])+.12*math.sin(2*math.pi*165*t)*math.exp(-8*t)
for name, duration, fn in [('devotion',.75,devotion),('regeneration',.48,regeneration),('poison_throw',.3,poison_throw),('buff',.46,buff)]:
    samples=[]
    for i in range(round(RATE*duration)):
        t=i/RATE
        envelope=min(1,t/.006,(duration-t)/.04)
        samples.append(max(-1,min(1,fn(t)*max(0,envelope))))
    pcm=struct.pack('<'+'h'*len(samples),*(round(v*22000) for v in samples))
    write_ogg(OUT/(name+'.ogg'),pcm,RATE)
    print(name)
