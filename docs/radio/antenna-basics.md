# Antenna Fundamentals

## Core Concepts

An antenna converts electrical energy from a transmitter into electromagnetic waves (radio waves) and vice versa. The antenna is the most critical component in any radio system — a good antenna makes more difference than raw transmitter power.

### Wavelength and Antenna Length

Antenna dimensions are directly related to the operating wavelength:

```
Wavelength (meters) = 300 / Frequency (MHz)
```

Most antenna designs are based on fractions of a wavelength:
- **Full wavelength (λ)**: Rarely used as a simple antenna
- **Half wavelength (λ/2)**: The fundamental resonant antenna
- **Quarter wavelength (λ/4)**: Common for vertical antennas

### Practical Length Formulas (Accounting for End Effects)

For a **half-wave dipole** (total length, both sides):
```
Length (feet) = 468 / Frequency (MHz)
Length (meters) = 142.65 / Frequency (MHz)
```

For a **quarter-wave vertical**:
```
Length (feet) = 234 / Frequency (MHz)
Length (meters) = 71.3 / Frequency (MHz)
```

The 468 and 234 constants (rather than 492 and 246) account for the "end effect" — real antennas are electrically longer than their physical length due to capacitance at the tips.

### Quick Reference: Antenna Lengths by Frequency

| Frequency | Band | Half-Wave Dipole | Quarter-Wave |
|-----------|------|-----------------|--------------|
| 3.75 MHz | 80m | 124.8 ft (38.0 m) | 62.4 ft (19.0 m) |
| 7.15 MHz | 40m | 65.5 ft (19.9 m) | 32.7 ft (10.0 m) |
| 14.175 MHz | 20m | 33.0 ft (10.1 m) | 16.5 ft (5.0 m) |
| 21.225 MHz | 15m | 22.0 ft (6.7 m) | 11.0 ft (3.4 m) |
| 28.4 MHz | 10m | 16.5 ft (5.0 m) | 8.2 ft (2.5 m) |
| 50.125 MHz | 6m | 9.3 ft (2.8 m) | 4.7 ft (1.4 m) |
| 146.52 MHz | 2m | 38.3 in (97 cm) | 19.2 in (49 cm) |
| 446.0 MHz | 70cm | 12.6 in (32 cm) | 6.3 in (16 cm) |
| 462.5625 MHz | FRS 1 | 12.1 in (31 cm) | 6.1 in (15 cm) |

---

## Common Antenna Types

### Half-Wave Dipole

The most fundamental antenna. Two conductors (wires, rods, or tubes), each approximately λ/4 long, extending in opposite directions from a center feedpoint.

```
                  ←— λ/4 —→←— λ/4 —→
    ================|================
                  Feedpoint
                  (coax connects here)
```

- **Impedance**: ~73 ohms at the center feedpoint (close enough to 50Ω for most practical purposes)
- **Gain**: 2.15 dBi (used as the reference for dBd measurements)
- **Pattern**: Bidirectional figure-eight (maximum radiation broadside to the wire, nulls off the ends)
- **Polarization**: Matches the wire orientation (horizontal wire = horizontal polarization)
- **Construction**: Can be made from wire, coax, aluminum tubing. The simplest effective antenna to build.
- **Variants**: Inverted-V (center high, ends sloping down at 30-45 degrees — easier to support with one mast)

**When to use**: Excellent general-purpose HF antenna. Easy to build for any band. The inverted-V is perhaps the most practical HF antenna for beginners.

### Quarter-Wave Vertical (Ground Plane)

A vertical conductor approximately λ/4 long, mounted above a ground plane (radial wires, metal surface, or the Earth itself).

```
         |
         |  ← λ/4 vertical element
         |
    _____|_____
   /     |     \  ← Ground plane radials (3-4 minimum)
  /      |      \    Each λ/4 long
```

- **Impedance**: ~36 ohms with horizontal radials, ~50 ohms with radials drooping at 45 degrees
- **Gain**: ~2.15 dBi (with perfect ground plane) to ~5.15 dBi (over perfect ground)
- **Pattern**: Omnidirectional (horizontal plane). Good for all-direction coverage.
- **Polarization**: Vertical
- **Ground radials**: At least 3-4 radials, each λ/4 long. More radials = better performance and closer to ideal impedance.

**When to use**: Good for VHF/UHF base stations. On HF, a vertical with many ground radials can be effective for DX (low radiation angle).

### J-Pole Antenna

A half-wave antenna fed at the bottom through a quarter-wave matching section (shaped like the letter J). No ground plane or radials required.

```
    |
    |  ← λ/2 radiating element
    |
    |----
    |   |  ← λ/4 matching stub
    |   |
    Feed point (bottom of the J)
```

- **Impedance**: ~50 ohms (when tuned correctly)
- **Gain**: ~2.15 dBi (similar to dipole)
- **Pattern**: Omnidirectional
- **Polarization**: Vertical
- **Advantages**: No ground plane needed, can be built from copper pipe (for VHF/UHF), ladder line, or even a tape measure.

**When to use**: Popular for 2m and 70cm. The "Slim Jim" variant (folded J-pole from ladder line) is an excellent lightweight portable antenna. Roll it up and deploy by hanging from a tree branch.

### Yagi-Uda (Yagi) Antenna

A directional antenna with multiple elements: one driven element (dipole), one reflector behind it, and one or more directors in front.

```
    Reflector   Driven    Directors →
        |         |        |    |    |
        |         |        |    |    |
    ← slightly    ↑     slightly shorter →
      longer   feedpoint
```

- **Impedance**: Varies with design (typically 20-50 ohms, matching may be needed)
- **Gain**: 6-15+ dBi depending on number of elements (3-element ~8 dBi, 5-element ~11 dBi)
- **Pattern**: Highly directional. Strong forward gain, reduced side and rear response.
- **Polarization**: Matches element orientation
- **Beamwidth**: Gets narrower with more elements

**When to use**: When you need to focus signal in one direction — DX on HF, satellite tracking, weak-signal VHF/UHF, point-to-point links. Must be aimed at the target.

### Collinear Vertical Antenna

Multiple half-wave or 5/8-wave elements stacked vertically in a single assembly. Common commercial base station antenna.

- **Gain**: 3-9+ dBi depending on number of stacked elements
- **Pattern**: Omnidirectional, but the radiation pattern is compressed toward the horizon (lower radiation angle)
- **Polarization**: Vertical

**When to use**: Excellent for VHF/UHF base stations where omnidirectional coverage is needed with more gain than a simple ground plane. Common for repeaters.

### Rubber Duck Antenna

The short, flexible antenna included with handheld radios. Technically a "helical" or "normal mode helix" antenna.

- **Gain**: Typically -2 to 0 dBi (significantly less than a quarter-wave whip)
- **Efficiency**: Very low. Most of the transmitted power is wasted as heat.
- **Advantage**: Compact, flexible, won't break easily
- **Disadvantage**: Poor performance

**Practical note**: Replacing a rubber duck with even a modest aftermarket whip antenna (like a Nagoya NA-771) typically improves signal by 3-6 dB — equivalent to doubling or quadrupling transmitter power.

### Other Notable Antenna Types

**Vertical Dipole (End-Fed Half-Wave)**:
- A half-wave antenna fed at one end through a matching transformer (typically 49:1 or 64:1 unun).
- Popular for portable/stealth HF operation. Run a single wire up a tree or mast.

**Loop Antenna**:
- Wire formed into a loop (circle, square, triangle). Full-wave loop has gain similar to dipole.
- Magnetic loop (small loop, << λ): Very compact for HF. Narrowband but effective. Good for stealth/indoor use.

**Random Wire**:
- Any length of wire fed through an antenna tuner. Not resonant on any particular frequency.
- Works but is a compromise. Requires a good ground and a capable tuner.

**Discone**:
- Wideband receive antenna. A disc over a cone shape.
- Very popular for SDR and scanner use. Covers 25-1300 MHz continuously.
- Moderate gain, omnidirectional.

---

## Impedance Matching and SWR

### Why Matching Matters

The transmitter, feedline, and antenna all have characteristic impedances. When these are matched (all 50 ohms in most amateur systems), maximum power transfers from transmitter to antenna.

When mismatched:
- Power is reflected back toward the transmitter
- Standing waves form on the feedline
- The transmitter may overheat or reduce power
- Feedline losses increase

### SWR (Standing Wave Ratio)

Measures the quality of the impedance match.

```
SWR = (1 + |Γ|) / (1 - |Γ|)

where Γ (gamma) = reflection coefficient = (ZL - Z0) / (ZL + Z0)
```

| SWR | Reflected Power | Assessment |
|-----|----------------|------------|
| 1.0:1 | 0% | Perfect match |
| 1.2:1 | 0.8% | Excellent |
| 1.5:1 | 4% | Very good |
| 2.0:1 | 11% | Good, acceptable for most use |
| 3.0:1 | 25% | Marginal. Radio may reduce power. |
| 5.0:1 | 44% | Poor. Risk of transmitter damage. |
| 10:1 | 67% | Very poor. Do not transmit. |

### Measuring SWR

- **SWR meter**: Inline device placed between transmitter and feedline. Reads forward and reflected power.
- **Antenna analyzer**: Standalone device (e.g., NanoVNA, RigExpert) that sweeps frequencies and shows SWR, impedance, and resonant frequency. Invaluable for antenna building and troubleshooting.
- **Built-in SWR meter**: Many modern transceivers display SWR while transmitting.

### Antenna Tuners

An antenna tuner (more accurately, a "transmatch") is an adjustable impedance matching network placed between the transmitter and feedline. It does NOT make the antenna more efficient — it matches the impedance so the transmitter sees 50 ohms and operates happily.

- **Manual tuner**: Adjust inductance and capacitance controls for minimum SWR.
- **Automatic tuner**: Built into many modern transceivers or available as external units. Adjusts automatically when you press "TUNE."
- A tuner is especially useful for multi-band operation with non-resonant antennas (random wires, long wires, G5RV, etc.).

---

## Feedline (Coaxial Cable)

Coaxial cable carries RF energy between the transmitter and antenna. The quality of your feedline matters — losses in the coax waste your transmitted power.

### Common Coaxial Cables

| Type | Impedance | Outer Diameter | Loss at 146 MHz (per 100 ft) | Loss at 440 MHz (per 100 ft) | Use |
|------|-----------|---------------|-------------------------------|-------------------------------|-----|
| **RG-174** | 50 Ω | 0.110 in (2.8 mm) | 8.4 dB | 14.5 dB | Short jumpers only. Very lossy. |
| **RG-58** | 50 Ω | 0.195 in (5 mm) | 4.9 dB | 8.5 dB | Short runs, portable use, HF. |
| **RG-8X (Mini-8)** | 50 Ω | 0.242 in (6.1 mm) | 3.6 dB | 6.0 dB | Moderate runs. Good compromise. |
| **RG-8/U** | 50 Ω | 0.405 in (10.3 mm) | 2.0 dB | 3.6 dB | Longer runs. Standard feedline. |
| **RG-213** | 50 Ω | 0.405 in (10.3 mm) | 2.0 dB | 3.5 dB | Similar to RG-8. Mil-spec. |
| **LMR-240** | 50 Ω | 0.240 in (6.1 mm) | 2.7 dB | 4.6 dB | Better than RG-8X. Flexible. |
| **LMR-400** | 50 Ω | 0.405 in (10.3 mm) | 1.5 dB | 2.7 dB | Excellent. Best for long VHF/UHF runs. |
| **LMR-600** | 50 Ω | 0.590 in (15 mm) | 1.0 dB | 1.8 dB | Low loss. Stiff and heavy. |
| **Hardline (7/8")** | 50 Ω | 0.875 in+ | <0.5 dB | <1.0 dB | Used for repeater/tower installations. |
| **RG-6** | 75 Ω | 0.270 in (6.9 mm) | — | — | TV/video. NOT for 50Ω transmit use. |
| **RG-59** | 75 Ω | 0.242 in (6.1 mm) | — | — | TV/video. NOT for 50Ω transmit use. |

### Feedline Selection Rules of Thumb

1. **Use the lowest-loss cable you can afford and physically manage** for the run length.
2. **Loss increases with frequency.** A cable that is fine at HF may be unacceptably lossy at UHF.
3. **Loss increases with length.** Keep runs as short as practical.
4. **RG-58 is acceptable for short runs** (under 25 feet) at VHF and for HF.
5. **LMR-400 (or equivalent) is the standard** for permanent VHF/UHF installations.
6. **Never use 75-ohm cable** (RG-6, RG-59) for transmitting into a 50-ohm system.
7. **Moisture is the enemy.** Seal outdoor connections with self-amalgamating tape or heat shrink. Water in coax dramatically increases loss.

### Ladder Line / Window Line

An alternative to coax for HF antennas fed with a tuner:
- **Impedance**: 300-600 ohms (typically 450 ohms for "window" line)
- **Loss**: Extremely low, even at high SWR (much lower than coax under mismatch)
- **Disadvantage**: Must be kept away from metal, cannot be routed through conduit, not suitable for VHF/UHF
- **Best use**: Feeding a multi-band dipole with an antenna tuner at the station

---

## RF Connectors

### Common Connector Types

| Connector | Impedance | Frequency Range | Cable Type | Use |
|-----------|-----------|----------------|------------|-----|
| **PL-259 / SO-239** | 50 Ω (nominal) | DC to ~150 MHz reliably | RG-8, RG-213, LMR-400 | Most common HF connector. Used on most HF transceivers. Male=PL-259, Female=SO-239. |
| **BNC** | 50 Ω | DC to 4 GHz | RG-58, RG-8X | Quick-connect bayonet. Test equipment, some VHF radios. Easy to connect/disconnect. |
| **N-Type** | 50 Ω | DC to 11 GHz | RG-8, LMR-400, LMR-600 | High quality, weatherproof. Standard for UHF and microwave. Repeater equipment. |
| **SMA** | 50 Ω | DC to 18 GHz | RG-174, small coax | Small connector. Handheld radios, SDR dongles, GPS. |
| **SMA-Female** | — | — | — | On the radio body (Baofeng, most HTs). Requires SMA-Male antenna/cable. |
| **SMA-Male** | — | — | — | On the antenna. Screws into the radio's SMA-Female. |
| **Reverse SMA (RP-SMA)** | 50 Ω | DC to 18 GHz | — | Common on Wi-Fi equipment. Pin is on the "female" shell. NOT compatible with standard SMA. |
| **F-Type** | 75 Ω | DC to 1 GHz | RG-6, RG-59 | TV/cable connectors. SDR dongles sometimes use these. |
| **MCX** | 50 Ω | DC to 6 GHz | Miniature coax | Some older RTL-SDR dongles. Snap-on connection. |

### Connector Notes

1. **PL-259/SO-239** are not truly constant-impedance connectors. They work well at HF but introduce some impedance bump at VHF/UHF. Perfectly fine for most amateur use up to 2 meters. Use N-type for serious UHF work.
2. **Always use the correct adapter** rather than forcing mismatched connectors. Common adapters: SMA-to-BNC, PL-259-to-N, BNC-to-SMA.
3. **SMA connectors on Baofeng radios**: The radio has SMA-Female (threaded barrel with center pin). Antennas need SMA-Male (threaded nut with center hole).
4. **Every connector and adapter adds loss** (typically 0.1-0.5 dB each). Minimize the number of connections in your feedline system.
5. **Weatherproof outdoor connections** with self-amalgamating tape, silicone sealant, or waterproof coax seal.

---

## Practical Antenna Projects

### Wire Dipole for HF (Any Band)

The simplest and most effective antenna you can build:

1. Calculate length: `Total length (feet) = 468 / Frequency (MHz)`
2. Cut two pieces of wire, each half of the total length.
3. Connect to a center insulator with a SO-239 connector or a balun.
4. Attach coax feedline to the center.
5. String between two supports (trees, masts, building).
6. Trim for lowest SWR at your desired frequency.

Cost: Under $20 in materials.

### Slim Jim for 2m/70cm

A portable roll-up antenna made from 450-ohm ladder line:

1. Total length for 2m: approximately 58 inches (147 cm).
2. Cut a piece of 450-ohm ladder line.
3. Short one end, leave the other end open.
4. Make a gap in one conductor about 1/3 from the shorted end.
5. Solder coax feedpoint at the gap.
6. Hang vertically from a tree branch or improvised mast.

Gain: approximately 3 dBi. Far superior to a rubber duck. Rolls up to pocket size.

### V-Dipole for Weather Satellites (137 MHz)

Two telescopic whips or rigid wires at 120 degrees angle:

1. Each element approximately 21 inches (53 cm) long.
2. Mount at 120 degrees apart, tips pointing roughly toward the sky.
3. Feed with coax at the center.
4. Lay the antenna flat, tilted slightly up, for overhead satellite passes.

Simple, effective, and good enough to receive NOAA APT images with an RTL-SDR.

---

## Key Takeaways

1. **Antenna height matters most for VHF/UHF.** Getting your antenna up higher improves range more than anything else.
2. **A resonant antenna matched to 50 ohms is the goal.** SWR below 2:1 is fine.
3. **Use low-loss feedline**, especially for longer runs and higher frequencies.
4. **A simple dipole at a good height beats an expensive antenna at a poor height.**
5. **Build and experiment.** Wire antennas are cheap and forgiving. The best antenna is the one you put up and use.
