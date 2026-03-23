# RF Fundamentals

## The Electromagnetic Spectrum

Radio waves are electromagnetic radiation with frequencies ranging from about 3 kHz to 300 GHz. They travel at the speed of light (approximately 300,000,000 meters per second in a vacuum) and require no medium for propagation.

### Frequency Bands

| Designation | Abbreviation | Frequency Range     | Wavelength Range |
|------------|--------------|---------------------|------------------|
| Very Low Frequency | VLF | 3 - 30 kHz | 100 - 10 km |
| Low Frequency | LF | 30 - 300 kHz | 10 - 1 km |
| Medium Frequency | MF | 300 kHz - 3 MHz | 1000 - 100 m |
| High Frequency | HF | 3 - 30 MHz | 100 - 10 m |
| Very High Frequency | VHF | 30 - 300 MHz | 10 - 1 m |
| Ultra High Frequency | UHF | 300 MHz - 3 GHz | 1 m - 10 cm |
| Super High Frequency | SHF | 3 - 30 GHz | 10 - 1 cm |
| Extremely High Frequency | EHF | 30 - 300 GHz | 10 - 1 mm |

---

## Frequency vs. Wavelength

The fundamental relationship between frequency and wavelength:

```
λ = c / f
```

Where:
- **λ** (lambda) = wavelength in meters
- **c** = speed of light = 299,792,458 m/s (approximately 300,000,000 m/s)
- **f** = frequency in Hertz (Hz)

### Quick Calculation Examples

| Frequency | Wavelength | Common Use |
|-----------|-----------|------------|
| 1 MHz | 300 m | AM broadcast |
| 7 MHz | ~43 m | 40-meter ham band |
| 14 MHz | ~21 m | 20-meter ham band |
| 100 MHz | 3 m | FM broadcast |
| 146 MHz | ~2.05 m | 2-meter ham band |
| 440 MHz | ~0.68 m | 70-centimeter ham band |
| 462 MHz | ~0.65 m | FRS/GMRS |
| 1090 MHz | ~0.28 m | ADS-B |

### Practical Shortcut

For MHz to meters:
```
λ (meters) = 300 / f (MHz)
```

For antenna half-wave calculations:
```
Half-wave (meters) = 150 / f (MHz)
Quarter-wave (meters) = 75 / f (MHz)
```

---

## Propagation

How radio waves travel from transmitter to receiver depends heavily on frequency.

### Ground Wave Propagation

- Radio waves follow the curvature of the Earth along the surface.
- Dominant at **LF and MF frequencies** (below about 2 MHz).
- Range: tens to hundreds of kilometers depending on power, terrain, and ground conductivity.
- AM broadcast stations rely on ground wave for local coverage.

### Sky Wave (Ionospheric) Propagation

- Radio waves refracted (bent back toward Earth) by the ionosphere.
- Dominant at **HF frequencies** (3-30 MHz).
- The ionosphere has multiple layers (D, E, F1, F2) that vary with time of day, season, solar cycle.
- Can provide communication over thousands of kilometers (DX).
- **Skip zone**: the area between the end of ground wave coverage and where the sky wave returns to Earth. No signal received in this zone.
- Lower HF bands (80m, 40m) tend to work better at night when the D layer (which absorbs lower HF) disappears.
- Higher HF bands (20m, 15m, 10m) work better during the day and during high solar activity.

### Line of Sight (LOS) Propagation

- Radio waves travel in straight lines from transmitter to receiver.
- Dominant at **VHF, UHF, and above** (30 MHz and up).
- Range limited by the curvature of the Earth and obstructions (hills, buildings, trees).
- Approximate line-of-sight distance to the horizon:

```
d (miles) = 1.23 × √h (feet)
d (km) = 3.57 × √h (meters)
```

Where h = antenna height above ground.

- For two stations:
```
d = 1.23 × (√h1 + √h2)  [miles and feet]
```

- Typical range for handheld radios (5 feet antenna height to 5 feet): about 2.75 miles in ideal flat terrain.
- Height matters enormously. A hilltop or tall building can extend range dramatically.

### Other Propagation Modes

- **Tropospheric ducting**: Temperature inversions in the lower atmosphere can create ducts that carry VHF/UHF signals hundreds of miles.
- **Meteor scatter**: Brief reflections off ionized meteor trails. Useful at VHF, contacts last seconds.
- **Moonbounce (EME)**: Signals bounced off the Moon. Requires high power and directional antennas.
- **Knife-edge diffraction**: Signals bending around sharp obstacles like mountain ridges.
- **Repeaters**: Not a propagation mode, but a practical way to extend VHF/UHF range by placing a relay station at a high point.

---

## Decibels (dB)

The decibel is a logarithmic ratio used extensively in radio to express gain, loss, and signal levels. It makes multiplicative relationships additive, which simplifies link budget calculations.

### Basic dB (ratio)

```
dB = 10 × log10(P2 / P1)    [for power]
dB = 20 × log10(V2 / V1)    [for voltage]
```

### Key dB Values to Memorize

| dB   | Power Ratio | Meaning |
|------|-------------|---------|
| 0 dB | 1:1 | No change |
| +3 dB | 2:1 | Double the power |
| +6 dB | 4:1 | Quadruple the power |
| +10 dB | 10:1 | Ten times the power |
| +20 dB | 100:1 | One hundred times the power |
| +30 dB | 1000:1 | One thousand times the power |
| -3 dB | 1:2 | Half the power |
| -10 dB | 1:10 | One-tenth the power |
| -20 dB | 1:100 | One-hundredth the power |

### dBm (Decibels relative to 1 milliwatt)

An absolute power measurement referenced to 1 milliwatt (0.001 watts).

```
dBm = 10 × log10(P / 0.001)
```

| dBm | Power |
|-----|-------|
| 0 dBm | 1 mW |
| 10 dBm | 10 mW |
| 20 dBm | 100 mW |
| 27 dBm | 500 mW |
| 30 dBm | 1 W |
| 33 dBm | 2 W |
| 36 dBm | 4 W |
| 37 dBm | 5 W |
| 40 dBm | 10 W |
| 47 dBm | 50 W |
| 50 dBm | 100 W |

### dBi (Decibels relative to isotropic)

Antenna gain measured against a theoretical isotropic antenna (radiates equally in all directions).

- A half-wave dipole has approximately **2.15 dBi** gain.
- A typical rubber duck antenna: **-2 to 0 dBi**.
- A Yagi antenna: **6-15 dBi** depending on number of elements.

### dBd (Decibels relative to a dipole)

Antenna gain relative to a half-wave dipole.
```
dBi = dBd + 2.15
```

---

## Gain and Loss

### Gain

An increase in signal strength. Sources of gain:
- **Amplifiers** (active electronic gain)
- **Antennas** (passive directional gain — concentrates energy in a direction)

### Loss

A decrease in signal strength. Sources of loss:
- **Feedline/coax cable** (increases with frequency and cable length)
- **Connectors** (each connector adds a small loss, typically 0.1-0.5 dB)
- **Filters** (insertion loss)
- **Free-space path loss** (signal weakening with distance)
- **Atmospheric absorption**
- **Obstacle attenuation** (walls, trees, buildings)

---

## Link Budget

A link budget accounts for all gains and losses between transmitter and receiver to determine if a communication link is viable.

```
Received Power (dBm) = Transmit Power (dBm)
                     + Transmit Antenna Gain (dBi)
                     - Transmit Feedline Loss (dB)
                     - Free Space Path Loss (dB)
                     - Other Losses (dB)
                     + Receive Antenna Gain (dBi)
                     - Receive Feedline Loss (dB)
```

### Free Space Path Loss (FSPL)

```
FSPL (dB) = 20 × log10(d) + 20 × log10(f) + 32.44
```

Where d = distance in km, f = frequency in MHz.

### Receiver Sensitivity

The minimum signal level a receiver can detect and demodulate. Typically expressed in dBm. A typical handheld VHF receiver might have sensitivity of -120 dBm.

### Fade Margin

The difference between received signal strength and receiver sensitivity. More margin = more reliable link.

```
Fade Margin = Received Power - Receiver Sensitivity
```

A fade margin of 10-20 dB is typical for a reliable link.

---

## Modulation Types

Modulation is the process of encoding information onto a carrier wave.

### Analog Modulation

**AM (Amplitude Modulation)**
- Information encoded by varying the amplitude (strength) of the carrier.
- Used in: AM broadcast (530-1700 kHz), aircraft communications, CB radio.
- Pros: Simple to demodulate, wide compatibility.
- Cons: Inefficient (carrier transmitted even with no signal), susceptible to noise.
- Bandwidth: approximately 2x audio bandwidth (typically 10 kHz for voice).

**FM (Frequency Modulation)**
- Information encoded by varying the frequency of the carrier.
- Used in: FM broadcast (87.5-108 MHz), VHF/UHF two-way radio, FRS/GMRS.
- Pros: Resistant to amplitude noise, better audio quality.
- Cons: Wider bandwidth than AM. Capture effect (stronger signal suppresses weaker one).
- **Narrowband FM (NFM)**: ±2.5 kHz deviation, used in two-way radio. ~12.5 kHz channel spacing.
- **Wideband FM (WFM)**: ±75 kHz deviation, used in FM broadcasting. 200 kHz channel spacing.

**SSB (Single Sideband)**
- A form of AM where the carrier and one sideband are suppressed, transmitting only one sideband.
- **USB (Upper Sideband)**: Used on frequencies above 10 MHz by convention.
- **LSB (Lower Sideband)**: Used on frequencies below 10 MHz by convention.
- Used in: HF amateur radio, marine HF, military HF.
- Pros: Very efficient — all transmitted power carries information. Narrow bandwidth (~2.4 kHz).
- Cons: Requires more precise tuning. Sounds "Donald Duck" if off-frequency.

**CW (Continuous Wave)**
- On-off keying of an unmodulated carrier (Morse code).
- The narrowest mode — bandwidth as low as 100-500 Hz.
- Can be copied at very low signal levels due to narrow bandwidth.
- Used in: Amateur radio, especially for weak-signal work.

### Digital Modulation

**FSK (Frequency Shift Keying)**
- Digital data encoded by shifting between two or more frequencies.
- Used in RTTY (radioteletype), AX.25 packet radio.

**PSK (Phase Shift Keying)**
- Data encoded by changing the phase of the carrier.
- PSK31: popular amateur digital mode, very narrow bandwidth (31 Hz).

**QAM (Quadrature Amplitude Modulation)**
- Combines amplitude and phase variations. Used in higher-speed digital modes and Wi-Fi.

**Common Amateur Digital Modes**
- **FT8**: Extremely popular weak-signal mode. 15-second transmit/receive cycles. Can decode signals far below the noise floor. Uses GFSK modulation.
- **WSPR**: Weak Signal Propagation Reporter. Used to map propagation paths.
- **JS8Call**: Keyboard-to-keyboard messaging built on FT8 modulation.
- **Winlink**: Email over radio using various digital modes.
- **APRS**: Automatic Packet Reporting System. Position reporting and messaging on 144.390 MHz (North America).

---

## Impedance

### What Is Impedance

Impedance is the total opposition to alternating current flow in a circuit, measured in ohms (Ω). In RF systems, it has both resistive and reactive components.

### The 50-Ohm Standard

Most amateur and commercial radio equipment is designed for **50-ohm impedance**. This includes:
- Transmitters (output impedance = 50Ω)
- Coaxial cables (characteristic impedance = 50Ω)
- Antennas (designed to present 50Ω at the feedpoint)

The 50Ω standard is a compromise between the impedance that minimizes loss in coax (~77Ω) and the impedance that maximizes power handling (~30Ω).

**75-ohm** systems are used for TV/video distribution (RG-6, RG-59) and some receive-only applications.

### Why Impedance Matching Matters

When impedance is mismatched, some of the transmitted power is reflected back toward the transmitter instead of being radiated by the antenna. This:
- Reduces radiated power (wasted energy)
- Can damage the transmitter's final amplifier
- Creates standing waves on the feedline

### SWR (Standing Wave Ratio)

SWR measures the impedance match between a transmitter, feedline, and antenna.

| SWR | Reflected Power | Condition |
|-----|----------------|-----------|
| 1.0:1 | 0% | Perfect match |
| 1.5:1 | 4% | Excellent |
| 2.0:1 | 11% | Good, most radios operate fine |
| 3.0:1 | 25% | Acceptable but not ideal. Some radios reduce power. |
| 5.0:1 | 44% | Poor. Most radios will fold back power significantly. |
| ∞:1 | 100% | Open or short circuit. No power radiated. |

Most radios have built-in SWR protection that reduces transmit power as SWR increases above 2:1 or 3:1.

---

## Practical Takeaways

1. **Higher frequency = shorter range** (generally) for a given power level at VHF/UHF due to path loss, but better with directional antennas.
2. **HF can go worldwide** thanks to ionospheric propagation, but is unreliable and band-dependent.
3. **VHF/UHF is line-of-sight** — antenna height is the single most important factor for range.
4. **Every 3 dB doubles or halves power.** Going from 5W to 10W is only 3 dB — barely noticeable. A better antenna often gives more dB improvement per dollar than higher power.
5. **A good antenna and feedline matter more than raw power.** Fixing a bad coax connection or upgrading from a rubber duck to an external antenna can improve your signal far more than doubling transmit power.
6. **Match your impedance.** Keep SWR below 2:1 to protect your radio and get maximum power to the antenna.
