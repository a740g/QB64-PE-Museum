#!/usr/bin/env python3
"""Writes Audio/zen.mid, the zen mode music: a slow ambient loop in D major.

64 bars at 66 BPM (about 3 m 53 s), in four 16-bar sections that build up and
thin out again, so the loop point is seamless:

  A  pads and bass, a few high bells
  B  adds a slow harp arpeggio
  C  adds a flute melody over the harp
  D  pads, bells and a high choir, back down to A

Run from the project root:  python3 tools/make_zen_music.py
No libraries needed. The output is deterministic (fixed random seed).
"""
import random
import struct

TPQ = 480            # ticks per quarter note
BPM = 66
BAR = 4 * TPQ
SECTION_BARS = 16
TOTAL = 4 * SECTION_BARS * BAR

rng = random.Random(2716)

# One chord per two bars: (bass root, upper voicing)
CHORDS = [
    (38, [62, 66, 69, 73, 76]),   # Dmaj9
    (35, [62, 66, 69, 71, 76]),   # Bm11
    (31, [59, 62, 66, 68, 73]),   # Gmaj7#11
    (33, [61, 64, 69, 71, 76]),   # A add9
    (40, [59, 62, 66, 67, 71]),   # Em9
    (42, [61, 64, 66, 69, 73]),   # F#m7
    (31, [62, 66, 69, 71, 74]),   # Gmaj9
    (33, [62, 64, 67, 69, 74]),   # A7sus4, leads back to D
]
PENTA = [62, 64, 66, 69, 71]      # D major pentatonic, for the bells

# Flute melody for section C: (beat in section, MIDI note, beats)
MELODY = [
    (0, 78, 2), (2, 76, 1), (3, 74, 1), (4, 69, 4),
    (8, 71, 2), (10, 74, 2), (12, 76, 3),
    (16, 78, 3), (19, 76, 1), (20, 71, 4),
    (24, 73, 2), (26, 76, 2), (28, 81, 2), (30, 76, 2),
    (32, 79, 2), (34, 78, 1), (35, 76, 1), (36, 71, 4),
    (40, 69, 2), (42, 73, 2), (44, 76, 3),
    (48, 74, 2), (50, 71, 1), (51, 69, 1), (52, 78, 4),
    (56, 76, 4), (60, 73, 3),
]


class Track:
    def __init__(self):
        self.events = []  # (tick, order, bytes)
        self.notes = []   # [channel, start, end, note, velocity]

    def add(self, tick, data, order=1):
        self.events.append((tick, order, bytes(data)))

    def note(self, ch, tick, note, length, vel):
        end = min(tick + length, TOTAL - 1)
        if end > tick:
            self.notes.append([ch, tick, end, note, vel])

    def flush_notes(self):
        # A repeated pitch cuts the previous one short instead of being cut off by it
        last = {}
        for n in sorted(self.notes, key=lambda n: n[1]):
            key = (n[0], n[3])
            if key in last and last[key][2] > n[1]:
                last[key][2] = max(last[key][1] + 1, n[1] - 1)
            last[key] = n
        for ch, start, end, note, vel in self.notes:
            self.add(start, [0x90 | ch, note, vel], 1)
            self.add(end, [0x80 | ch, note, 0], 0)
        self.notes = []

    def setup(self, ch, program, volume, reverb=100, chorus=30, pan=64):
        self.add(0, [0xC0 | ch, program], 0)
        self.add(0, [0xB0 | ch, 7, volume], 0)
        self.add(0, [0xB0 | ch, 10, pan], 0)
        self.add(0, [0xB0 | ch, 91, reverb], 0)
        self.add(0, [0xB0 | ch, 93, chorus], 0)

    def chunk(self):
        self.flush_notes()
        out = bytearray()
        last = 0
        for tick, _, data in sorted(self.events, key=lambda e: (e[0], e[1])):
            out += vlq(tick - last) + data
            last = tick
        out += vlq(TOTAL - last) + bytes([0xFF, 0x2F, 0x00])
        return b"MTrk" + struct.pack(">I", len(out)) + bytes(out)


def vlq(n):
    b = [n & 0x7F]
    n >>= 7
    while n:
        b.insert(0, (n & 0x7F) | 0x80)
        n >>= 7
    return bytes(b)


def chord_at(bar):
    return CHORDS[(bar // 2) % len(CHORDS)]


def build():
    tempo = Track()
    tempo.add(0, [0xFF, 0x51, 0x03] + list(struct.pack(">I", 60_000_000 // BPM)[1:]), 0)
    tempo.add(0, [0xFF, 0x58, 0x04, 4, 2, 24, 8], 0)

    pad, bass, harp, bells, flute, choir = (Track() for _ in range(6))
    pad.setup(0, 89, 92, chorus=70, pan=54)      # Warm Pad
    bass.setup(1, 32, 88, reverb=70, chorus=0)   # Acoustic Bass
    harp.setup(2, 46, 76, pan=80)                # Orchestral Harp
    bells.setup(3, 8, 70, reverb=120, pan=40)    # Celesta
    flute.setup(4, 73, 84, pan=70)               # Flute
    choir.setup(5, 91, 64, chorus=60, pan=64)    # Choir Pad

    for bar in range(0, 64, 2):
        section = bar // SECTION_BARS
        t = bar * BAR
        root, voicing = chord_at(bar)
        swell = 50 if section in (0, 3) else 58

        # Pads: two-bar chords, slight stagger so they bloom
        for i, n in enumerate(voicing):
            pad.note(0, t + i * 20, n, 2 * BAR - 30 - i * 20, swell + rng.randint(-4, 4))

        # Bass: long root, plus a soft fifth halfway in sections B and C
        bass.note(1, t, root, BAR + BAR // 2, 62)
        if section in (1, 2):
            bass.note(1, t + BAR + BAR // 2, root + 7, BAR // 2 - 20, 48)

        # Harp: rising eighth-note arpeggio in B and C
        if section in (1, 2):
            tones = sorted(set([root + 12] + voicing + [voicing[1] + 12, voicing[2] + 12]))
            step = TPQ // 2
            for k in range(16):
                n = tones[k % len(tones)] if k < 8 else tones[(15 - k) % len(tones)]
                vel = 44 + (10 if k % 4 == 0 else 0) - (8 if section == 2 else 0)
                harp.note(2, t + k * step, n, step * 3, vel + rng.randint(-3, 3))

        # Bells: sparse high pentatonic notes (more of them in D)
        chance = {0: .18, 1: .12, 2: .08, 3: .3}[section]
        for beat in range(8):
            if rng.random() < chance:
                n = rng.choice(PENTA) + 12 * rng.choice([1, 2])
                bells.note(3, t + beat * TPQ + rng.choice([0, TPQ // 2]), n, TPQ * 3, 40 + rng.randint(0, 18))

        # Choir: a held high fifth in section D
        if section == 3:
            choir.note(5, t, voicing[0] + 12, 2 * BAR - 40, 44)
            choir.note(5, t, voicing[2] + 12, 2 * BAR - 40, 40)

    # Flute melody over section C
    base = 2 * SECTION_BARS * BAR
    for beat, n, length in MELODY:
        flute.note(4, base + beat * TPQ, n, length * TPQ - 40, 70 + rng.randint(-6, 6))

    tracks = [tempo, pad, bass, harp, bells, flute, choir]
    head = b"MThd" + struct.pack(">IHHH", 6, 1, len(tracks), TPQ)
    return head + b"".join(t.chunk() for t in tracks)


if __name__ == "__main__":
    data = build()
    with open("Audio/zen.mid", "wb") as f:
        f.write(data)
    secs = TOTAL / TPQ * 60 / BPM
    print(f"Audio/zen.mid: {len(data)} bytes, {secs // 60:.0f} m {secs % 60:.0f} s loop")
