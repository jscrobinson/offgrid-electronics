# Operational Amplifiers (Op-Amps)

## Ideal Op-Amp Rules

An ideal op-amp has:
1. **Infinite input impedance** — no current flows into the input pins
2. **Zero output impedance** — can drive any load without voltage drop
3. **Infinite open-loop gain** — amplifies the difference between inputs infinitely
4. **Infinite bandwidth** — works at all frequencies
5. **Virtual short** — when negative feedback is applied, the op-amp drives its output to make V+ = V- (the two inputs are at the same voltage)

These ideal rules are accurate enough for most practical circuit analysis.

```
Non-inverting input (+) ──┐
                          │ Triangle  ──── Output
Inverting input (-)  ─────┘

     V+
      │
    ──┤     Typical pinout (8-pin DIP)
    ──┤     Pin 1: Offset null
    ──┤     Pin 2: Inverting input (-)
    ──┤     Pin 3: Non-inverting input (+)
      │     Pin 4: V- (or GND)
      │     Pin 5: Offset null
      │     Pin 6: Output
      │     Pin 7: V+
      │     Pin 8: NC (or second op-amp)
```

---

## Common Configurations

### Inverting Amplifier

```
            Rf
        ┌──[R]──┐
        │       │
Vin ──[Rin]──(-)│
              │  ├── Vout
         V_ref──(+)│
                │
```

```
Gain: Av = -Rf / Rin

Vout = -Vin × (Rf / Rin) + V_ref × (1 + Rf/Rin)
       (when V_ref is at the + input; if + input is at GND, Vout = -Vin × Rf/Rin)

Input impedance: Rin (the input resistor)
```

**Example:** Rin = 10kΩ, Rf = 100kΩ
- Gain = -100k/10k = -10 (inverts and amplifies by 10)
- 0.1V input → -1.0V output (with + input at GND, needs dual supply)

### Non-Inverting Amplifier

```
Vin ──(+)│
         ├── Vout
    ┌──(-)│
    │       │
   [R1]    [Rf]
    │       │
   GND     (from output back to -)
```

Actually:
```
                 Rf
             ┌──[R]──┐
             │       │
         ┌──(-)     │
         │   │  ├── Vout
Vin ────(+)  │
         │  [R1]
        GND  │
            GND
```

```
Gain: Av = 1 + Rf / R1

Vout = Vin × (1 + Rf / R1)

Input impedance: Very high (op-amp input impedance)
```

**Example:** R1 = 10kΩ, Rf = 47kΩ
- Gain = 1 + 47k/10k = 5.7
- 0.5V input → 2.85V output

### Voltage Follower (Unity Gain Buffer)

```
Vin ──(+)│
         ├── Vout ──┐
     ┌──(-)         │
     │              │
     └──────────────┘
```

```
Gain: Av = 1 (unity)
Vout = Vin
```

**Purpose:** Impedance transformation. Converts a high-impedance source to a low-impedance output.

**Use cases:**
- Buffer a voltage divider before driving a load
- Buffer a sensor signal before long cable run
- Buffer ADC input to prevent loading the source
- Isolate circuit stages from each other

### Differential Amplifier

```
            Rf
        ┌──[R]──┐
        │       │
V1 ──[R1]──(-)  │
              │  ├── Vout
V2 ──[R2]──(+)│
              │
            [R3]
              │
             GND
```

When R1 = R2 and Rf = R3:
```
Vout = (Rf / R1) × (V2 - V1)
```

Amplifies the difference between two signals while rejecting common-mode signals (noise that appears equally on both inputs).

**Use cases:**
- Measuring current via shunt resistor voltage
- Rejecting ground noise between two circuits
- Bridge sensor (strain gauge, load cell) amplification

### Comparator (Open-Loop)

```
V_in ────(+)│
            ├── Vout
V_ref ───(-)│
```

No feedback resistor. The infinite open-loop gain means:
- If V+ > V-: output swings to positive supply rail
- If V+ < V-: output swings to negative supply rail

**Output is digital: HIGH or LOW.** Used for threshold detection.

**Note:** While op-amps can be used as comparators in a pinch, dedicated comparator ICs (LM339, LM393) have open-drain/open-collector outputs and faster response. Using a standard op-amp as a comparator can cause oscillation near the threshold — add hysteresis with positive feedback.

### Comparator with Hysteresis (Schmitt Trigger)

```
            R2
V_in ──[R1]──(+)──[R2]──┐
              │          │
         V_ref──(-)      │
              │   ├── Vout ──┘
```

Actually implemented as:
```
V_in ────(+)│
            ├── Vout
V_ref ───(-)│    │
   (+)───[R1]────┘
         │
        [R2]
         │
        GND
```

This adds positive feedback creating two thresholds (upper and lower), preventing oscillation when the input is near the threshold.

---

## Common Op-Amp ICs

| Part       | Supply     | GBW    | Slew Rate | I_q   | Rail-to-Rail | Notes                          |
|-----------|-----------|--------|-----------|-------|-------------|-------------------------------|
| LM741     | ±5 to ±18V | 1MHz  | 0.5V/μs   | 1.7mA | No          | Classic, obsolete but educational |
| LM358     | 3-32V (single) or ±1.5-16V | 1MHz | 0.6V/μs | 0.5mA | No (output) | Dual, single-supply capable, cheap |
| LM324     | 3-32V     | 1MHz   | 0.5V/μs   | 0.8mA | No          | Quad version of LM358          |
| TL072     | ±6 to ±18V | 3MHz  | 13V/μs    | 2.5mA | No          | JFET input, good for audio     |
| MCP6002   | 1.8-6V    | 1MHz   | 0.6V/μs   | 100μA | Yes (R-R)   | 3.3V friendly, dual, low power |
| MCP6004   | 1.8-6V    | 1MHz   | 0.6V/μs   | 100μA | Yes (R-R)   | Quad version of MCP6002        |
| OPA344    | 2.5-5.5V  | 1MHz   | 0.8V/μs   | 250μA | Yes (R-R)   | Single supply, rail-to-rail    |
| OPA2340   | 2.7-5.5V  | 5.5MHz | 6V/μs     | 750μA | Yes (R-R)   | Dual, fast, 3.3V friendly     |
| LMV321    | 2.7-5.5V  | 1MHz   | 1V/μs     | 130μA | Yes (R-R)   | Single, SOT-23, ultra cheap    |
| AD8605    | 2.7-5.5V  | 10MHz  | 5V/μs     | 1.5mA | Yes (R-R)   | Precision, low noise           |
| NE5532    | ±5 to ±15V | 10MHz | 9V/μs     | 8mA   | No          | Audio standard, low noise      |

---

## Rail-to-Rail Op-Amps

Standard op-amps cannot swing their output all the way to the supply rails. The LM358, for example, cannot output closer than ~1.5V below V+ or ~0V above V-.

**Rail-to-rail output** means the output can swing within millivolts of both supply rails.
**Rail-to-rail input** means the inputs can accept signals from V- to V+.
**Rail-to-rail input AND output (RRIO)** is ideal for single-supply, low-voltage designs.

For 3.3V or 5V single-supply circuits, **always use rail-to-rail op-amps** (MCP6002, OPA344, LMV321, etc.).

---

## Single Supply Biasing

When using op-amps with a single supply (0V and V+) instead of dual supply (±V), you need to bias the signal to the middle of the supply range.

### Creating a Virtual Ground (V_ref = Vcc/2)

```
Vcc ──[R]──┬──[R]── GND     (R = 10kΩ to 100kΩ)
           │
         [C]                  (C = 10-100μF, for low impedance AC ground)
           │
          GND

V_ref = Vcc / 2
```

Use equal resistors to create a mid-supply reference, buffer it with an op-amp voltage follower if it needs to drive anything.

### Single Supply Inverting Amplifier

```
            100kΩ
        ┌──[Rf]──┐
        │        │
Vin ──[10kΩ]──(-)│
  (AC coupled)│   ├── Vout (centered at Vcc/2)
      Vcc/2──(+) │
              │
```

The input is AC-coupled through a capacitor, the non-inverting input is biased to Vcc/2, and the output swings around Vcc/2.

---

## Applications

### Signal Conditioning for ADC

Scale a 0-10V sensor signal to 0-3.3V for an ESP32 ADC:

```
Method 1: Resistor divider + buffer
Sensor (0-10V) ──[20kΩ]──┬──(+) op-amp ──── ADC input
                          │     buffer
                       [10kΩ]
                          │
                         GND

Vout = Vin × 10k/(20k+10k) = Vin × 0.33
10V → 3.3V, 0V → 0V
```

The buffer prevents the ADC from loading the divider.

### Active Low-Pass Filter (First Order)

```
            Cf
        ┌──[C]──┐
        │       │
        ├──[Rf]─┤
        │       │
Vin ──[Rin]──(-)│
              │  ├── Vout
         GND──(+)│
```

```
DC gain: Av = -Rf / Rin
Cutoff frequency: fc = 1 / (2π × Rf × Cf)
Roll-off: -20dB/decade (first order)
```

**Example:** Anti-aliasing filter for ADC sampling at 1kHz. Want cutoff at 500Hz.
- Rf = 10kΩ, Cf = 1/(2π × 10000 × 500) = 31.8nF → use 33nF
- Rin = 10kΩ (unity gain)

### Current Sense Amplifier

Measure current through a shunt resistor:

```
V+ power rail ──[R_shunt (0.1Ω)]──┬── Load
                                    │
              Differential amp      │
              measures voltage      │
              across R_shunt        │
```

At 1A through 0.1Ω shunt: V_shunt = 0.1V
With differential gain of 20: Vout = 2.0V → feed to ADC

### Instrumentation Amplifier

For precision differential measurements (strain gauges, thermocouples), use a dedicated instrumentation amp IC:
- **INA128** — general purpose
- **INA219** — I2C digital output current/power monitor
- **AD623** — single supply, rail-to-rail
- **INA333** — micro-power, rail-to-rail

---

## Practical Tips

1. **Always decouple the power pins** — 100nF ceramic as close as possible to V+ and V- pins
2. **Unused op-amps** in a quad/dual package: connect as voltage follower with input tied to GND (or V_ref). Do NOT leave inputs floating
3. **Output current limit** — most op-amps can only source/sink 10-40mA. For higher current loads, add a transistor output stage
4. **Capacitive loads** — driving long cables or large capacitive loads can cause oscillation. Add a small series resistor (10-100Ω) at the output
5. **Bandwidth (GBW)** — Gain-Bandwidth Product is constant. A 1MHz GBW op-amp at gain of 10 has only 100kHz bandwidth. Choose accordingly
6. **Input bias current** — can cause offset errors with high-impedance sources. Use FET-input op-amps (TL072, MCP6002) for high-impedance applications
7. **Slew rate** — limits how fast the output can change. For audio (20kHz), 10V peak-to-peak requires at least: SR = 2π × f × Vpeak = 2π × 20000 × 5 = 0.63V/μs
