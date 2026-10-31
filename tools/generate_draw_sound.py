"""Gera um som curto e discreto de carta deslizando, em Ogg Vorbis."""
import math
import random
import struct
from pathlib import Path
from audio_encoding import write_ogg

rate=44100
rng=random.Random(42)
samples=[]
filtered=0.0
for index in range(int(rate*0.22)):
    t=index/rate
    filtered=0.85*filtered+0.15*rng.uniform(-1,1)
    envelope=math.sin(math.pi*t/0.22)**1.4
    value=filtered*envelope*0.6+math.sin(2*math.pi*620*t)*envelope*0.025
    samples.append(round(value*18000))
write_ogg(Path(__file__).resolve().parents[1]/"assets/audio/draw.ogg",struct.pack("<"+"h"*len(samples),*samples),rate)
