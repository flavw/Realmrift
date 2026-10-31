"""Gera o efeito curto de Fúria e Clamor em Ogg Vorbis."""
import math
import struct
from pathlib import Path

from audio_encoding import write_ogg

rate = 44100
duration = 0.55
samples = []
for index in range(round(rate * duration)):
    time = index / rate
    envelope = (1 - math.exp(-time * 85)) * math.exp(-time * 5.5)
    sweep = math.sin(2 * math.pi * (150 * time + 370 * time * time))
    horn = math.sin(2 * math.pi * 220 * time) + 0.4 * math.sin(2 * math.pi * 330 * time)
    value = max(-1, min(1, (sweep * 0.48 + horn * 0.27) * envelope))
    samples.append(round(value * 23000))
pcm = struct.pack("<" + "h" * len(samples), *samples)
target = Path(__file__).resolve().parents[1] / "assets/audio/fury.ogg"
write_ogg(target, pcm, rate)
