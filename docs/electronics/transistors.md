# Transistors — BJT and MOSFET Guide

## BJT (Bipolar Junction Transistor)

### NPN Transistor

The most common type. Current flows from Collector to Emitter when a small current flows into the Base.

```
        Collector (C)
            │
            ▼
Base (B) ──►│   NPN Symbol
            │
            ▼
        Emitter (E)
```

**Key relationship:** I_C = β × I_B (β = current gain, typically 100-300)

### PNP Transistor

Current flows from Emitter to Collector when a small current flows *out of* the Base. Used for high-side switching.

```
        Emitter (E)
            │
            ▼
Base (B) ◄──│   PNP Symbol
            │
            ▼
        Collector (C)
```

### Common NPN Transistors

| Part     | V_CE max | I_C max | β (h_FE) | Package | Notes                 |
|----------|----------|---------|----------|---------|-----------------------|
| 2N2222   | 40V      | 800mA   | 100-300  | TO-92/TO-18 | Classic general purpose |
| 2N3904   | 40V      | 200mA   | 100-300  | TO-92   | Small signal, very common |
| BC547    | 45V      | 100mA   | 110-800  | TO-92   | European equivalent    |
| BC337    | 45V      | 800mA   | 100-600  | TO-92   | Higher current BC547   |
| TIP120   | 60V      | 5A      | 1000+    | TO-220  | Darlington, high current |
| S8050    | 25V      | 500mA   | 100-400  | TO-92   | Common in Asian circuits |

### Common PNP Transistors

| Part     | V_CE max | I_C max | β (h_FE) | Package | Notes              |
|----------|----------|---------|----------|---------|--------------------|
| 2N2907   | 60V      | 600mA   | 100-300  | TO-92   | Complement of 2N2222 |
| 2N3906   | 40V      | 200mA   | 100-300  | TO-92   | Complement of 2N3904 |
| BC557    | 45V      | 100mA   | 110-800  | TO-92   | Complement of BC547  |
| TIP125   | 60V      | 5A      | 1000+    | TO-220  | Complement of TIP120 |

---

### BJT as a Switch

To fully turn on (saturate) an NPN transistor switch:

```
         V+ (e.g., 12V)
          │
        [Load] (relay, LED, motor)
          │
          C
    R_B   │
MCU ──[R]──B  NPN (2N2222)
          E
          │
         GND
```

**Saturation:** V_CE(sat) is typically 0.2-0.3V for small signal BJTs, 1-2V for Darlingtons.

**Base Resistor Calculation:**

```
I_C = V_load / R_load          (required collector current)
I_B = I_C / β                  (minimum base current)
I_B(design) = I_C / 10         (use forced β of ~10 for reliable saturation)

R_B = (V_MCU - V_BE) / I_B(design)

V_BE ≈ 0.7V for silicon BJTs
```

### Worked Example: Driving a Relay

12V relay coil draws 60mA. MCU GPIO is 3.3V.

```
I_C = 60mA
I_B(design) = 60mA / 10 = 6mA   (forced β = 10)
R_B = (3.3V - 0.7V) / 6mA = 2.6V / 6mA = 433Ω → use 470Ω

Power in R_B: (2.6V)² / 470Ω = 14mW  (trivial)
```

Don't forget the **flyback diode** across the relay coil (cathode to V+, anode to collector).

### BJT as an Amplifier (Common Emitter)

```
         Vcc
          │
         [R_C]
          ├──── Vout
    R_B   │
Vin ──[R]──B  NPN
          E
          │
         [R_E]
          │
         GND
```

Voltage gain: A_v ≈ -R_C / R_E (with emitter resistor, stable but lower gain)

For a typical small-signal amplifier with R_C = 10kΩ and R_E = 1kΩ: gain ≈ -10 (inverting).

---

## MOSFET (Metal-Oxide-Semiconductor Field-Effect Transistor)

MOSFETs are voltage-controlled (no gate current in steady state) and are the preferred choice for power switching.

### N-Channel MOSFET (Low-Side Switch)

```
        Drain (D)
          │
Gate (G)──┤  N-ch MOSFET
          │
        Source (S)
```

Turns ON when V_GS > V_GS(th). Used for low-side switching (load between V+ and Drain, Source to GND).

### P-Channel MOSFET (High-Side Switch)

```
        Source (S) ── connected to V+
          │
Gate (G)──┤  P-ch MOSFET
          │
        Drain (D) ── connected to Load → GND
```

Turns ON when V_GS < -|V_GS(th)| (Gate pulled below Source). Used for high-side switching.

### Key MOSFET Parameters

- **V_GS(th)** — Gate threshold voltage. The *minimum* V_GS to start conducting. For full conduction, you need significantly more (see R_DS(on) curves)
- **R_DS(on)** — Drain-Source on-resistance when fully enhanced. Lower is better. Always check at your actual V_GS
- **V_DS max** — Maximum drain-source voltage
- **I_D max** — Maximum continuous drain current (usually thermally limited)
- **Logic Level** — A logic-level MOSFET has low R_DS(on) at V_GS = 3.3V or 4.5V (for driving from MCUs without a gate driver)

### Common N-Channel MOSFETs

| Part      | V_DS | I_D   | R_DS(on)        | V_GS(th) | Logic Level? | Package |
|-----------|------|-------|-----------------|-----------|-------------|---------|
| 2N7000    | 60V  | 200mA | 1.8Ω @ 4.5V    | 1-3V      | Yes         | TO-92   |
| IRLZ44N   | 55V  | 47A   | 0.022Ω @ 5V    | 1-2V      | Yes         | TO-220  |
| IRF540N   | 100V | 33A   | 0.044Ω @ 10V   | 2-4V      | No          | TO-220  |
| IRL540N   | 100V | 36A   | 0.044Ω @ 5V    | 1-2V      | Yes         | TO-220  |
| IRLB8721  | 30V  | 62A   | 0.008Ω @ 4.5V  | 1-2.3V    | Yes         | TO-220  |
| AO3400    | 30V  | 5.7A  | 0.040Ω @ 4.5V  | 0.9-1.5V  | Yes         | SOT-23  |
| BSS138    | 50V  | 200mA | 3.5Ω @ 4.5V    | 0.8-1.5V  | Yes         | SOT-23  |
| Si2302    | 20V  | 2.6A  | 0.085Ω @ 4.5V  | 0.7-1.4V  | Yes         | SOT-23  |

### Common P-Channel MOSFETs

| Part      | V_DS  | I_D   | R_DS(on)        | V_GS(th) | Package |
|-----------|-------|-------|-----------------|-----------|---------|
| IRF9540   | -100V | -23A  | 0.117Ω @ -10V  | -2 to -4V | TO-220  |
| AO3401    | -30V  | -4A   | 0.068Ω @ -4.5V | -0.7 to -1.5V | SOT-23 |
| DMG2305UX | -20V  | -4.2A | 0.055Ω @ -4.5V | -0.4 to -0.9V | SOT-23 |
| FQP27P06  | -60V  | -27A  | 0.070Ω @ -10V  | -2 to -4V | TO-220  |

---

### MOSFET as a Switch

#### N-Channel Low-Side Switch

```
         V+ (e.g., 12V)
          │
        [Load]
          │
          D
    [R_G] │
MCU ──[R]──G  N-ch MOSFET (IRLZ44N)
          S
          │
         GND

Optional: 10kΩ pull-down from G to S (ensures OFF when MCU pin is floating)
```

**Gate Resistor (R_G):** 100-470Ω. Limits inrush current to the gate capacitance and prevents ringing. Not strictly required for slow switching but good practice.

**Pull-down Resistor:** 10kΩ from Gate to Source. Ensures the MOSFET stays OFF during MCU boot or when the pin is in high-impedance state.

#### P-Channel High-Side Switch

```
         V+ (e.g., 12V)
          │
          S
          │
    R_G   G  P-ch MOSFET
          │
          D
          │
        [Load]
          │
         GND

Gate driver:
- To turn ON: pull gate to GND (or close to it)
- To turn OFF: pull gate to V+ (through pull-up resistor)
```

For V+ > MCU voltage, use an NPN transistor or N-channel MOSFET to pull the P-channel gate low:

```
V+ ──[10kΩ]──┬── G (P-ch)
              │
              C (NPN 2N3904)
     MCU ──[1kΩ]── B
              E
              │
             GND
```

MCU HIGH → NPN ON → Gate pulled to GND → P-MOSFET ON → Load powered.

---

### Gate Drive Requirements

**MOSFET gates are capacitive.** Switching speed depends on how fast you can charge/discharge the gate.

- **Gate charge (Q_g):** Total charge needed to fully turn on. Typically 10-100nC for power MOSFETs
- **Switching time:** t ≈ Q_g / I_gate
- For slow switching (kHz), MCU GPIO can drive small MOSFETs directly
- For fast switching (>100kHz), use a gate driver IC (e.g., TC4427, IR2110)
- **Never leave a MOSFET gate floating** — it can pick up noise and oscillate between on/off, causing shoot-through and overheating

---

## BJT vs MOSFET — When to Use Which

| Factor              | BJT                          | MOSFET                           |
|--------------------|------------------------------|----------------------------------|
| Drive              | Current-driven (I_B)         | Voltage-driven (V_GS)           |
| Input impedance    | Low (draws base current)     | Very high (no DC gate current)  |
| Switching speed    | Moderate                     | Fast (limited by gate charge)   |
| Saturation voltage | 0.2-0.3V (low current)       | I_D × R_DS(on) (can be <0.01V) |
| High current       | Limited, needs Darlington    | Excellent, low R_DS(on)         |
| Cost               | Very cheap                   | Cheap (slightly more)           |
| Thermal runaway    | Yes (positive temp coefficient)| Self-limiting (negative temp)  |
| Analog/linear use  | Good for amplifiers          | Used but trickier biasing       |

**Rules of thumb:**
- Switching loads > 500mA → use MOSFET
- 3.3V logic driving high power → use logic-level MOSFET
- Simple small-signal amplifier → BJT is easier
- Battery-powered (minimize quiescent current) → MOSFET (no gate current)
- PWM motor control → MOSFET (lower losses)

---

## Common Circuits

### LED Driver (NPN)

```
5V ──[R_LED = 150Ω]── LED ──┬── C (2N3904)
                             │
         MCU ──[1kΩ]──────── B
                             │
                             E ── GND
```
R_LED = (5V - V_LED - V_CE(sat)) / I_LED = (5V - 2V - 0.2V) / 20mA = 140Ω → 150Ω

### Relay Driver (NPN + Flyback Diode)

```
12V ──┬──────┬── Relay Coil ──┬── C (2N2222)
      │      │                │
      │   Diode (1N4007)      B ──[470Ω]── MCU
      │   (cathode to 12V)    │
      │      │                E
      └──────┘                │
                             GND
```

### Motor Driver (N-Channel MOSFET)

```
12V ──┬──────┬── Motor ──┬── D (IRLZ44N)
      │      │           │
      │   Diode          G ──[220Ω]── MCU
      │   (1N5819)       │
      │      │           S ──┬── GND
      └──────┘               │
                         [10kΩ] pull-down
                             │
                            GND
```

### High-Side Load Switch (P-Channel MOSFET)

```
V_batt ──── S (AO3401 P-ch)
             │
             G ──┬──[10kΩ]── V_batt  (pull-up, default OFF)
             │   │
             │   C (2N7000 N-ch)
             │   │
             │   G ──[10kΩ]── MCU_GPIO
             │   S ── GND
             │
             D
             │
           [Load]
             │
            GND
```

MCU HIGH → 2N7000 ON → P-ch gate pulled to GND → P-ch ON → Load powered.
MCU LOW/floating → 2N7000 OFF → P-ch gate pulled to V_batt → P-ch OFF.
