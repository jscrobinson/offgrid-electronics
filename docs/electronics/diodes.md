# Diodes

## Diode Basics

A diode allows current to flow in one direction (anode to cathode) and blocks it in the reverse direction.

```
Anode (+) ──►|── Cathode (-)

Forward biased: current flows (V_anode > V_cathode + V_f)
Reverse biased: no current flows (until breakdown voltage)
```

**Key parameters:**
- **V_f** (Forward Voltage) — voltage drop across the diode when conducting
- **I_f max** — maximum continuous forward current
- **V_R max** (or V_RRM) — maximum reverse voltage before breakdown
- **I_R** — reverse leakage current (ideally zero, practically nanoamps to microamps)
- **t_rr** — reverse recovery time (how fast it switches off)

---

## Standard Rectifier Diodes

Used for AC-to-DC conversion, reverse polarity protection, and general purpose.

### 1N400x Series (Most Common)

| Part   | V_R max | I_f max | V_f    | Notes             |
|--------|---------|---------|--------|-------------------|
| 1N4001 | 50V     | 1A      | 1.0V   | Low voltage       |
| 1N4002 | 100V    | 1A      | 1.0V   |                   |
| 1N4004 | 400V    | 1A      | 1.0V   |                   |
| 1N4007 | 1000V   | 1A      | 1.0V   | Universal choice  |

**The 1N4007 is the go-to** — it handles the highest voltage and costs the same. Use it anywhere you need a basic rectifier at 1A or less.

For higher current:
- **1N5400 series** — 3A rectifiers (1N5401 = 100V, 1N5408 = 1000V)
- **Bridge rectifiers** — 4 diodes in a package (e.g., KBP307 = 3A 700V)

---

## Schottky Diodes

Lower forward voltage drop (0.15-0.45V vs 0.6-1.0V for silicon) and faster switching. Use a metal-semiconductor junction instead of P-N junction.

| Part      | V_R max | I_f max | V_f (typical) | Notes                    |
|-----------|---------|---------|---------------|--------------------------|
| 1N5817    | 20V     | 1A      | 0.32V         | Low voltage general use  |
| 1N5818    | 30V     | 1A      | 0.35V         |                          |
| 1N5819    | 40V     | 1A      | 0.40V         | Most popular Schottky    |
| BAT85     | 30V     | 200mA   | 0.25V         | Small signal Schottky    |
| SS14      | 40V     | 1A      | 0.50V         | SMD (SMA package)        |
| SS34      | 40V     | 3A      | 0.50V         | SMD (SMA package)        |
| MBR20100  | 100V    | 20A     | 0.70V         | High current             |
| SB560     | 60V     | 5A      | 0.55V         | TO-220 package           |

**Advantages:**
- Lower power loss (important in power supplies, battery circuits)
- Fast switching (no minority carrier storage) — ideal for switching regulators
- Lower voltage drop means more voltage reaches the load

**Disadvantages:**
- Higher reverse leakage current than silicon diodes
- Lower reverse voltage ratings (typically max 100-200V)
- Cannot replace silicon rectifiers in high-voltage applications

**Use Schottky when:** power efficiency matters, forward voltage drop is critical (battery systems), high switching frequency.

---

## Zener Diodes

Designed to operate in reverse breakdown at a specific voltage. Used for voltage regulation and clamping.

```
                  ┌── Zener breakdown at V_Z
                  │
Reverse ──────────┤── Forward (same as regular diode)
voltage           │
                  └──
```

**Common Zener voltages:** 3.3V, 5.1V, 6.2V, 9.1V, 12V, 15V, 24V

### Basic Zener Voltage Regulator

```
V_in ──[R_series]──┬── V_out (≈ V_Z)
                   │
                 Zener (cathode to +, anode to GND)
                   │
                  GND
```

**R_series calculation:**
```
R = (V_in - V_Z) / (I_Z + I_load)

Where I_Z should be at least 5-10mA for stable regulation
```

**Worked Example:** Regulate 12V down to 5.1V, load draws 10mA:

```
R = (12 - 5.1) / (10mA + 10mA) = 6.9V / 20mA = 345Ω → use 330Ω

Power in resistor: (6.9V)² / 330 = 144mW
Power in Zener: 5.1V × 10mA = 51mW (at no load: 5.1V × 20.9mA = 107mW)
```

**Zener regulation is inefficient** — only practical for low-current applications (reference voltages, indicator circuits). Use a proper voltage regulator for anything drawing significant current.

### Zener as Voltage Clamp

Protect an MCU input from overvoltage:

```
Signal ──[1kΩ]──┬── MCU GPIO (max 3.3V)
                │
              3.3V Zener
                │
               GND
```

Any voltage above 3.3V is clamped by the Zener conducting.

---

## LEDs (Light Emitting Diodes)

### Forward Voltage by Color

| Color        | V_f (typical) | V_f (range)    | Wavelength    |
|-------------|---------------|----------------|---------------|
| Infrared    | 1.2V          | 1.0-1.6V       | >760nm        |
| Red         | 1.8V          | 1.6-2.2V       | 620-750nm     |
| Orange      | 2.0V          | 1.8-2.2V       | 590-620nm     |
| Yellow      | 2.0V          | 1.8-2.2V       | 570-590nm     |
| Green       | 2.2V          | 1.8-3.5V       | 495-570nm     |
| Blue        | 3.0V          | 2.5-3.5V       | 450-495nm     |
| White       | 3.2V          | 2.8-3.5V       | Broad spectrum |
| UV          | 3.3V          | 3.0-4.0V       | <400nm        |

### Current Limiting Resistor

**Every LED needs a current-limiting resistor** (unless the driving circuit already limits current).

```
R = (V_supply - V_f) / I_LED

Typical I_LED = 10-20mA for standard 5mm/3mm LEDs
I_LED = 5mA often sufficient for indicator LEDs (and saves power)
```

### Quick Reference: LED Resistor Values

| Supply | LED Color (V_f) | 20mA    | 10mA    | 5mA     |
|--------|-----------------|---------|---------|---------|
| 3.3V   | Red (1.8V)      | 75Ω     | 150Ω    | 300Ω    |
| 3.3V   | Blue (3.0V)     | 15Ω     | 30Ω     | 60Ω     |
| 5V     | Red (1.8V)      | 160Ω    | 320Ω    | 640Ω    |
| 5V     | Green (2.2V)    | 140Ω    | 280Ω    | 560Ω    |
| 5V     | Blue (3.0V)     | 100Ω    | 200Ω    | 400Ω    |
| 5V     | White (3.2V)    | 90Ω     | 180Ω    | 360Ω    |
| 12V    | Red (1.8V)      | 510Ω    | 1kΩ     | 2kΩ     |
| 12V    | White (3.2V)    | 440Ω    | 880Ω    | 1.8kΩ   |

Use the nearest standard resistor value equal to or greater than the calculated value.

---

## TVS Diodes (Transient Voltage Suppressors)

Designed to absorb high-energy transient voltage spikes. Much faster response than Zeners (nanoseconds vs microseconds).

**Unidirectional:** for DC circuits. Acts like a high-power Zener.
**Bidirectional:** for AC or signal lines where polarity can be either way.

### Common TVS Diodes

| Part       | Standoff V | Breakdown V | Peak Pulse | Notes              |
|------------|-----------|-------------|------------|--------------------|
| SMBJ5.0A   | 5.0V      | 6.4V        | 600W       | Unidirectional SMB |
| SMBJ3.3CA  | 3.3V      | 4.2V        | 600W       | Bidirectional SMB  |
| P6KE6.8A   | 6.8V      | 7.1V        | 600W       | Axial, uni         |
| PESD5V0    | 5V        | 6.4V        | —          | ESD protection SOT |

**Use for:**
- Protecting data lines (USB, UART, SPI) from ESD
- Protecting power inputs from voltage spikes
- Lightning/surge protection on outdoor sensor lines
- Automotive transient protection

---

## Diode Applications

### Polarity Protection — Series Diode (Simple)

```
V_in ──►|── V_out
    (1N5819)

If V_in connected backwards, diode blocks.
Drops ~0.3V (Schottky) or ~0.7V (silicon).
```

**Pro:** Simple, cheap
**Con:** Voltage drop wastes power (at 1A, a 0.3V Schottky drop = 0.3W wasted)

### Polarity Protection — P-Channel MOSFET (Efficient)

```
V_in ──── S ── D ──── V_out
          │
          G
          │
         GND

(P-channel MOSFET, gate to GND, source to V_in)
```

When V_in is correct polarity: V_GS is negative, MOSFET turns ON, V_drop = I × R_DS(on) (millivolts).
When V_in is reversed: V_GS is positive, MOSFET stays OFF.

With R_DS(on) = 0.05Ω at 1A: V_drop = 50mV, P = 50mW (vs 300mW for Schottky). Far more efficient.

### Flyback / Freewheeling Diode

When switching an inductive load (relay, motor, solenoid), the collapsing magnetic field creates a voltage spike that can destroy the switching transistor.

```
V+ ──┬──────┬── Coil ── C (transistor switch)
     │      │          │
     │   Diode         E
     │ (cathode to V+) │
     │      │         GND
     └──────┘
```

The diode provides a path for the current to circulate and dissipate safely.

**Use 1N4007** for relays and solenoids (slow switching).
**Use 1N5819** (Schottky) for faster switching or when you want the energy to dissipate more quickly.

### OR-ing Diodes (Power Supply Selection)

Automatically select the higher voltage from two sources:

```
Source 1 ──►|──┬── V_out
               │
Source 2 ──►|──┘
```

Each diode blocks reverse current from one supply to the other. Output is the higher voltage minus one diode drop. Use Schottky diodes to minimize loss.

### Half-Wave Rectifier

```
AC ──►|── [C] ── DC out

Peak DC out ≈ V_peak - V_f
Ripple is high; needs large filter capacitor.
```

### Full-Wave Bridge Rectifier

```
AC ~  ──►|──┬──►|── + DC out
            │
     ──|◄──┘──|◄── - DC out (GND)

Peak DC out ≈ V_peak - 2×V_f
Lower ripple than half-wave; two diode drops.
```

Use Schottky bridge rectifiers for low-voltage AC (e.g., from small transformers or energy harvesting) to minimize the 2×V_f loss.
