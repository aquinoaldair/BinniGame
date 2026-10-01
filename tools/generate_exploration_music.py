"""Render BINNI's original ambient loop using Python's standard library and ffmpeg.
Run from the repository root: python3 tools/generate_exploration_music.py
No recordings, borrowed melodies, or traditional music claims are used.
"""
import math
import subprocess
import tempfile
import wave
from array import array
from pathlib import Path

RATE = 22050
BEAT = 0.75  # 80 BPM, sixteen 4/4 bars = 48 seconds.
LENGTH = int(RATE * BEAT * 64)
left = array('f', [0]) * LENGTH
right = array('f', [0]) * LENGTH


def note(midi, beat, duration, gain, pan=0, flute=False):
    frequency = 440 * 2 ** ((midi - 69) / 12)
    count = int(duration * RATE)
    offset = round(beat * BEAT * RATE)
    for i in range(count):
        t = i / RATE
        if flute:
            envelope = min(t / 0.12, 1) * min((duration - t) / 0.4, 1)
            phase = math.tau * frequency * t + 0.018 * math.sin(math.tau * 4.5 * t)
            value = (math.sin(phase) + 0.13 * math.sin(2 * phase)) * envelope
        else:
            envelope = min(t / 0.008, 1) * math.exp(-t * 2.5) * min((duration - t) / 0.12, 1)
            phase = math.tau * frequency * t
            value = (math.sin(phase) + 0.32 * math.sin(2 * phase) + 0.12 * math.sin(3 * phase)) * envelope
        sample = value * gain
        index = (offset + i) % LENGTH
        left[index] += sample * (1 - pan * 0.35)
        right[index] += sample * (1 + pan * 0.35)
        # Quiet circular echoes preserve natural tails at the loop boundary.
        for delay, strength in [(0.225, 0.12), (0.45, 0.06)]:
            echo = (index + int(delay * RATE)) % LENGTH
            left[echo] += sample * strength * (1 + pan * 0.35)
            right[echo] += sample * strength * (1 - pan * 0.35)


chords = [(48, 55, 60, 64), (45, 52, 57, 60), (41, 48, 57, 60), (43, 50, 55, 62)]
melodies = [(76, 74, 72), (72, 69, 67), (69, 72, 74), (74, 71, 67),
            (79, 76, 74), (76, 72, 69), (72, 74, 69), (71, 74, 72)]
for bar in range(16):
    chord = chords[bar % 4]
    start = bar * 4
    note(chord[0], start, 2.8, 0.09)
    for step, tone in enumerate([chord[1], chord[2], chord[3], chord[2]]):
        note(tone + 12, start + step + 0.5, 2.1, 0.055, -0.5 if step % 2 == 0 else 0.5)
    if bar % 2 == 0:
        for step, tone in enumerate(melodies[bar // 2]):
            note(tone, start + step * 1.5, 0.95 if step < 2 else 1.5, 0.055, 0.15, True)

peak = max(max(abs(x) for x in left), max(abs(x) for x in right))
scale = 0.75 * 32767 / peak
pcm = array('h')
for lvalue, rvalue in zip(left, right):
    pcm.extend((int(lvalue * scale), int(rvalue * scale)))
with tempfile.TemporaryDirectory(prefix='binni-music-') as directory:
    source = Path(directory) / 'exploration.wav'
    with wave.open(str(source), 'wb') as output:
        output.setnchannels(2)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(pcm.tobytes())
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', str(source), '-c:a', 'libvorbis',
                    '-q:a', '4', 'assets/audio/exploration.ogg'], check=True)
print('Rendered assets/audio/exploration.ogg (48 seconds, stereo).')
