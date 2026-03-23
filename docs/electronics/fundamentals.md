# Electronics Fundamentals

## Ohm's Law

The most fundamental relationship in electronics:

```
V = I × R
I = V / R
R = V / I
```

Where:
- **V** = Voltage (Volts, V) — electrical "pressure" or potential difference
- **I** = Current (Amperes, A) — flow of charge
- **R** = Resistance (Ohms, Ω) — opposition to current flow

### Worked Example: Ohm's Law

A 12V battery drives current through a 1kΩ resistor. Find the current.

```
I = V / R = 12V / 1000Ω = 0.012A = 12mA
```

---

## Power

Electrical power — the rate of energy consumption or delivery:

```
P = V × I          (fundamental)
P = I² × R         (substituting V = IR)
P = V² / R         (substituting I = V/R)
```

Where **P** = Power (Watts, W).

### Worked Example: Resistor Power Dissipation

A 470Ω resistor carries 20mA. What power does it dissipate? What resistor wattage rating do you need?

```
P = I² × R = (0.020)² × 470 = 0.000400 × 470 = 0.188W ≈ 188mW
```

You'd need at least a 1/4W (250mW) resistor. Always derate — run at no more than 50-70% of rated power for reliability. A 1/2W resistor would be a safer choice.

### Common Resistor Power Ratings

| Package      | Power Rating |
|-------------|-------------|
| 0402 SMD    | 1/16W (63mW) |
| 0603 SMD    | 1/10W (100mW) |
| 0805 SMD    | 1/8W (125mW) |
| 1/4W axial  | 250mW |
| 1/2W axial  | 500mW |
| 1W axial    | 1000mW |
| 2W axial    | 2000mW |

---

## Kirchhoff's Voltage Law (KVL)

**The sum of all voltages around any closed loop in a circuit equals zero.**

Equivalently: the sum of voltage drops equals the sum of voltage sources.

```
Loop: +V_source - V_R1 - V_R2 - V_R3 = 0

Therefore: V_source = V_R1 + V_R2 + V_R3
```

### Worked Example: KVL

A 9V battery drives current through three series resistors: 100Ω, 220Ω, and 330Ω. Find the voltage across each resistor.

Total resistance: R_total = 100 + 220 + 330 = 650Ω

Current (same through all, since series): I = 9V / 650Ω = 13.85mA

Voltage drops:
```
V_R1 = 13.85mA × 100Ω = 1.385V
V_R2 = 13.85mA × 220Ω = 3.046V
V_R3 = 13.85mA × 330Ω = 4.569V

Check: 1.385 + 3.046 + 4.569 = 9.000V  ✓
```

---

## Kirchhoff's Current Law (KCL)

**The sum of all currents entering a node equals the sum of all currents leaving that node.**

Or equivalently: the algebraic sum of currents at any node is zero.

```
I_in1 + I_in2 = I_out1 + I_out2 + I_out3
```

### Worked Example: KCL

A node has two branches coming in carrying 30mA and 20mA, and two branches going out. One outgoing branch has a 1kΩ resistor with 15V across it. Find the current in the other outgoing branch.

```
I_in = 30mA + 20mA = 50mA
I_out1 = 15V / 1kΩ = 15mA
I_out2 = 50mA - 15mA = 35mA
```

---

## Voltage Dividers

Two resistors in series create a voltage divider — one of the most common circuits:

```
Vin ──┬── R1 ──┬── R2 ──┬── GND
      │        │        │
      Vin      Vout     0V

Vout = Vin × R2 / (R1 + R2)
```

### Key Properties
- **Unloaded** voltage divider follows the formula exactly
- **Loading** (connecting a load across R2) changes the output — the load resistance is effectively in parallel with R2
- A voltage divider is **not** a voltage regulator — output voltage drops significantly under load unless R1 and R2 are much smaller than the load
- Rule of thumb: divider current should be at least 10× the load current for <10% error

### Worked Example: Voltage Divider

Scale a 5V signal to 3.3V for an ESP32 ADC input (high impedance load):

```
Desired ratio: 3.3/5.0 = 0.66

Pick R2 = 20kΩ, then:
0.66 = 20k / (R1 + 20k)
R1 + 20k = 20k / 0.66 = 30.3kΩ
R1 = 10.3kΩ → use 10kΩ (standard value)

Actual Vout = 5V × 20k / (10k + 20k) = 5V × 0.667 = 3.33V  ✓
```

---

## Current Dividers

When resistors are in parallel, current divides inversely proportional to resistance:

```
For two parallel resistors sharing total current I_total:

I_R1 = I_total × R2 / (R1 + R2)
I_R2 = I_total × R1 / (R1 + R2)
```

Note: the current through R1 depends on R2, and vice versa (inverse relationship).

### Worked Example: Current Divider

100mA flows into a parallel combination of 100Ω and 300Ω.

```
I_100Ω = 100mA × 300 / (100 + 300) = 100mA × 0.75 = 75mA
I_300Ω = 100mA × 100 / (100 + 300) = 100mA × 0.25 = 25mA

Check: 75mA + 25mA = 100mA  ✓
```

More current flows through the lower resistance.

---

## Series and Parallel Resistance

### Series Resistors

```
R_total = R1 + R2 + R3 + ...
```

Current is the same through all. Voltage divides proportionally.

### Parallel Resistors

```
1/R_total = 1/R1 + 1/R2 + 1/R3 + ...

For two resistors:
R_total = (R1 × R2) / (R1 + R2)
```

Voltage is the same across all. Current divides inversely.

### Quick Parallel Shortcuts

- Two equal resistors in parallel: R_total = R/2
- N equal resistors in parallel: R_total = R/N
- A very large resistor in parallel with a small one ≈ the small one

### Worked Example: Series-Parallel

Find total resistance:
```
R1=100Ω in series with (R2=220Ω parallel R3=330Ω)

R2||R3 = (220 × 330) / (220 + 330) = 72600 / 550 = 132Ω

R_total = 100 + 132 = 232Ω
```

---

## Series and Parallel Capacitance

Capacitors combine **opposite** to resistors:

### Parallel Capacitors (values add)

```
C_total = C1 + C2 + C3 + ...
```

This is intuitive — larger plate area = more capacitance.

### Series Capacitors (reciprocal formula)

```
1/C_total = 1/C1 + 1/C2 + 1/C3 + ...

For two capacitors:
C_total = (C1 × C2) / (C1 + C2)
```

### Worked Example

100nF in parallel with 220nF: C_total = 320nF

100nF in series with 220nF: C_total = (100 × 220)/(100 + 220) = 68.75nF

---

## Thevenin Equivalent Circuits

Any linear circuit with two terminals can be replaced by:
- A single voltage source (V_th) in series with
- A single resistance (R_th)

### Finding Thevenin Equivalent

1. **V_th** = Open-circuit voltage across the two terminals (remove the load, measure voltage)
2. **R_th** = Resistance seen from the terminals with all independent sources turned off (voltage sources → short circuit, current sources → open circuit)

### Worked Example: Thevenin Equivalent

Circuit: 12V source in series with 4kΩ, with 6kΩ from the junction to ground. Find Thevenin equivalent across the 6kΩ.

```
Step 1: V_th (open circuit voltage across 6kΩ)
V_th = 12V × 6k / (4k + 6k) = 12V × 0.6 = 7.2V

Step 2: R_th (short voltage source, look into terminals)
R_th = 4kΩ || 6kΩ = (4k × 6k) / (4k + 6k) = 24M / 10k = 2.4kΩ

Thevenin equivalent: 7.2V source in series with 2.4kΩ
```

**Why useful?** Simplifies circuit analysis, especially when calculating the effect of connecting different loads to the same circuit.

---

## Basic AC Concepts

### Frequency and Period

```
f = 1/T       T = 1/f

f = frequency in Hz (cycles per second)
T = period in seconds
```

Common frequencies:
- Mains power: 50Hz (Europe, Asia, Africa, Australia) or 60Hz (Americas, some Asia)
- Audio range: 20Hz - 20kHz
- Radio: kHz to GHz
- Microcontroller PWM: typically 1kHz - 100kHz

### Sinusoidal Voltage/Current

```
v(t) = V_peak × sin(2π × f × t)
```

- **V_peak** = maximum amplitude
- **V_pp** (peak-to-peak) = 2 × V_peak
- **V_rms** (root mean square) = V_peak / √2 ≈ V_peak × 0.707
- Mains voltage (e.g., 120V or 230V) is specified as V_rms

### Impedance

Impedance (Z) is the AC equivalent of resistance. It has magnitude and phase:

```
Z = R + jX

|Z| = √(R² + X²)
```

Where X = reactance (the imaginary/reactive component).

### Capacitive Reactance

Capacitors **oppose changes in voltage** and pass AC while blocking DC:

```
Xc = 1 / (2π × f × C)
```

- At DC (f=0): Xc = ∞ (open circuit)
- At high frequency: Xc → 0 (short circuit)

### Inductive Reactance

Inductors **oppose changes in current** and block AC while passing DC:

```
XL = 2π × f × L
```

- At DC (f=0): XL = 0 (short circuit)
- At high frequency: XL → ∞ (open circuit)

### Worked Example: Capacitive Reactance

What is the impedance of a 100nF capacitor at 1kHz?

```
Xc = 1 / (2π × 1000 × 100×10⁻⁹) = 1 / (6.28 × 10⁻⁴) = 1592Ω
```

At 1MHz:
```
Xc = 1 / (2π × 1×10⁶ × 100×10⁻⁹) = 1 / (0.628) = 1.59Ω
```

This is why 100nF decoupling capacitors are effective at high frequencies — they look like a near short-circuit to high-frequency noise, shunting it to ground.

---

## Quick Reference Table: Unit Prefixes

| Prefix | Symbol | Multiplier  | Example         |
|--------|--------|------------|-----------------|
| pico   | p      | 10⁻¹²     | 22pF capacitor  |
| nano   | n      | 10⁻⁹      | 100nF capacitor |
| micro  | μ (u)  | 10⁻⁶      | 470μF capacitor |
| milli  | m      | 10⁻³      | 20mA current    |
| —      | —      | 10⁰ = 1   | 5V, 2A          |
| kilo   | k      | 10³       | 10kΩ resistor   |
| mega   | M      | 10⁶       | 1MΩ resistor    |
| giga   | G      | 10⁹       | 2.4GHz WiFi     |

---

## Common Sense-Check Values

Memorize these to sanity-check your calculations:

- A standard LED needs ~10-20mA and ~2V
- A USB port provides 5V at up to 500mA (USB 2.0) or 900mA (USB 3.0)
- A typical ESP32 draws ~80mA active, ~240mA peak during WiFi TX
- A typical Arduino Uno draws ~45mA
- 1 amp through 1 meter of 22AWG wire drops ~0.05V
- A CR2032 coin cell has ~230mAh capacity, max ~15mA continuous
- Mains AC in the US: 120V RMS at 60Hz
- Mains AC in Europe: 230V RMS at 50Hz
