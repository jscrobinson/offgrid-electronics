# Voltage Regulators

## Linear Regulators

Linear regulators reduce voltage by dissipating the excess as heat. Simple, low noise, but inefficient when the input-output voltage difference is large.

### How They Work

A linear regulator is essentially a variable resistor controlled by a feedback loop. It adjusts its resistance to maintain a constant output voltage.

```
V_in ──[Regulator]── V_out (regulated)
           │
          GND

Heat dissipation: P = (V_in - V_out) × I_out
```

### Dropout Voltage

The minimum difference between V_in and V_out for the regulator to maintain regulation.

- **Standard regulators:** 2-3V dropout (e.g., LM7805 needs 7V+ input for 5V output)
- **LDO (Low Dropout):** 0.1-0.7V dropout (e.g., AMS1117-3.3 needs ~3.5V+ for 3.3V)

### Common Linear Regulators

| Part         | V_out | I_out max | Dropout | Package      | Notes                         |
|-------------|-------|-----------|---------|-------------|-------------------------------|
| LM7805      | 5.0V  | 1.5A      | 2V      | TO-220      | Classic, needs heatsink       |
| LM7812      | 12V   | 1.5A      | 2V      | TO-220      | 12V version                   |
| LM7833      | 3.3V  | 1.5A      | 2V      | TO-220      | 3.3V version                  |
| AMS1117-3.3 | 3.3V  | 1A        | 1.3V    | SOT-223     | Popular LDO for 3.3V MCUs    |
| AMS1117-5.0 | 5.0V  | 1A        | 1.3V    | SOT-223     | 5V LDO version                |
| AMS1117-ADJ | Adj   | 1A        | 1.3V    | SOT-223     | Adjustable 1.25-12V           |
| LD1117-3.3  | 3.3V  | 800mA     | 1.2V    | SOT-223     | Similar to AMS1117            |
| MCP1700-3.3 | 3.3V  | 250mA     | 178mV   | SOT-23      | True LDO, ultra-low dropout  |
| MCP1702-3.3 | 3.3V  | 250mA     | 625mV   | SOT-23      | Low quiescent current (2μA)  |
| AP2112K-3.3 | 3.3V  | 600mA     | 250mV   | SOT-23-5    | Common on ESP32 boards        |
| HT7833      | 3.3V  | 500mA     | 300mV   | SOT-89      | Low Iq (4μA), good for battery|
| LP2985-3.3  | 3.3V  | 150mA     | 280mV   | SOT-23-5    | Ultra-low noise               |

### LM7805 Typical Circuit

```
V_in (7-35V) ──┬──[LM7805]──┬── V_out (5V)
               │     │       │
             [0.33μF] │    [0.1μF]
               │    GND      │
              GND           GND
```

Input capacitor: 0.33μF minimum (ceramic) close to input pin
Output capacitor: 0.1μF minimum (ceramic) close to output pin
Larger capacitors (10-100μF electrolytic) improve transient response.

### Heat Dissipation Calculation

```
P_dissipated = (V_in - V_out) × I_out

Example: 12V to 5V at 500mA
P = (12V - 5V) × 0.5A = 3.5W  ← That's a LOT of heat!
```

**Thermal resistance (TO-220 package):**
- Junction-to-ambient (no heatsink): ~65°C/W
- With small heatsink: ~15-25°C/W
- With large heatsink + forced air: ~5°C/W

**Temperature rise:** ΔT = P × θ_JA

```
Without heatsink: 3.5W × 65°C/W = 227.5°C rise → WAY TOO HOT
With heatsink (20°C/W): 3.5W × 20°C/W = 70°C rise → 95°C junction at 25°C ambient
```

**Rule of thumb:** If P > 1W, either use a heatsink or switch to a switching regulator.

### Efficiency

```
η = V_out / V_in × 100%

12V to 5V: η = 5/12 = 41.7%   ← terrible
5V to 3.3V: η = 3.3/5 = 66%   ← acceptable for low current
3.6V to 3.3V (LDO): η = 3.3/3.6 = 91.7%   ← good
```

---

## Switching Regulators

Switching regulators use an inductor, switch (MOSFET), and diode to convert voltage efficiently. They switch on and off rapidly (100kHz-2MHz) and use the inductor to store and transfer energy.

### Advantages over Linear
- High efficiency (80-97%)
- Can step up (boost) or step down (buck)
- Can handle large input-output voltage differences without excessive heat
- Can deliver higher current without massive heatsinks

### Disadvantages vs Linear
- Electrical noise (switching frequency and harmonics)
- More components needed (inductor, diode, capacitors)
- More complex PCB layout requirements
- Potential EMI issues
- Minimum load requirements on some designs

### Buck Converter (Step-Down)

Output voltage is lower than input. Most common type.

```
V_in > V_out

V_in ──[Switch]──┬──[Inductor]──┬── V_out
                 │               │
              [Diode]          [C_out]
                 │               │
                GND             GND
```

**Duty cycle:** D = V_out / V_in (ideal)

### Boost Converter (Step-Up)

Output voltage is higher than input.

```
V_in < V_out

V_in ──[Inductor]──┬──[Diode]──┬── V_out
                   │            │
                [Switch]     [C_out]
                   │            │
                  GND          GND
```

**Duty cycle:** D = 1 - (V_in / V_out) (ideal)

### Buck-Boost Converter

Output can be higher or lower than input. Also includes inverting topologies.

Used when the input voltage range spans the desired output (e.g., single Li-ion cell 3.0-4.2V to regulated 3.3V).

---

## Common Switching Regulator Modules

These pre-built modules are convenient for prototyping and many production designs.

### Buck (Step-Down) Modules

| Module     | Chip    | V_in      | V_out     | I_out | Efficiency | Notes                    |
|-----------|---------|-----------|-----------|-------|------------|--------------------------|
| LM2596 module | LM2596 | 4.5-40V | 1.25-37V (adj) | 3A | ~80% | Very common, trimpot adj |
| Mini360   | MP2307  | 4.75-23V | 1-17V (adj) | 1.8A | ~90% | Tiny, fixed-freq 360kHz |
| D-SUN     | MP1584  | 4.5-28V  | 0.8-20V (adj) | 3A | ~92% | Small, efficient         |
| Pololu D24V10F5 | TPS62132 | 3.2-36V | 5V fixed | 1A | ~93% | High quality, tiny     |
| Pololu D36V6F3 | — | 3.7-36V | 3.3V fixed | 600mA | ~90% | Quality module          |

### Boost (Step-Up) Modules

| Module      | Chip    | V_in     | V_out      | I_out | Notes                    |
|------------|---------|----------|------------|-------|--------------------------|
| MT3608 module | MT3608 | 2-24V | 5-28V (adj) | 2A  | Cheap, common            |
| XL6009 module | XL6009 | 5-32V | 5-35V (adj) | 4A  | Higher power than MT3608 |
| Pololu U3V70F5 | — | 2.9-12V | 5V fixed | 10A peak | High current boost     |

### Buck-Boost Modules

| Module     | V_in     | V_out     | I_out | Notes                        |
|-----------|----------|-----------|-------|------------------------------|
| XL6009 (buck-boost config) | 5-32V | 1.25-35V | 4A | Adjustable, common |
| S13V20F5 (Pololu) | 2.8-22V | 5V fixed | 2A | Clean output            |
| TPS63020 module | 1.8-5.5V | 3.3V/5V | 2A | Ideal for single Li-ion |

---

## Capacitor Requirements for Regulators

### Linear Regulators
- Input: 0.33μF ceramic minimum, 10μF recommended
- Output: 0.1μF ceramic minimum, 10-22μF recommended
- Some LDOs are **unstable without proper output capacitance** (check ESR requirements in datasheet)

### Switching Regulators
- Input: low ESR ceramic 10-22μF (handles pulsed input current)
- Output: low ESR ceramic or electrolytic 22-100μF (filters output ripple)
- Inadequate capacitors cause: excessive ripple, instability, noise, poor transient response

---

## Linear vs Switching: Decision Guide

| Scenario                                    | Recommendation            |
|--------------------------------------------|---------------------------|
| 5V to 3.3V, <200mA                         | Linear LDO               |
| 12V to 5V, >100mA                          | Switching (buck)          |
| 12V to 3.3V, any current                   | Switching (buck)          |
| Battery (3.7V) to 3.3V                     | LDO or buck-boost         |
| Low noise required (analog/audio)          | Linear LDO               |
| Battery life critical                       | Switching                 |
| Minimal components                          | Linear                   |
| Cost sensitive, simple                      | Linear                   |
| High current (>1A)                          | Switching                 |
| V_in close to V_out, moderate current       | LDO                      |
| Need V_out > V_in                           | Switching (boost)         |

---

## USB Power Delivery

### USB Power Specifications

| Standard    | Voltage | Current | Power    |
|-----------|---------|---------|----------|
| USB 2.0    | 5V      | 500mA   | 2.5W     |
| USB 3.0    | 5V      | 900mA   | 4.5W     |
| USB BC 1.2 | 5V      | 1.5A    | 7.5W     |
| USB-C (default) | 5V | 3A      | 15W      |
| USB-PD 2.0 | 5/9/15/20V | up to 5A | up to 100W |
| USB-PD 3.1 | up to 48V | up to 5A | up to 240W |

### Requesting Higher Voltages via USB-C PD

To get more than 5V from a USB-C PD charger, you need a PD trigger/negotiation IC:

- **IP2721** — Simple PD trigger, selectable voltages via resistors
- **CH224K** — Configurable PD sink, supports 5V/9V/12V/15V/20V
- **STUSB4500** — Programmable PD sink IC (I2C configurable)
- **ZY12PDN** — Ready-made module with display, selectable voltage

### USB-C CC Resistors

For a USB-C device to receive 5V/3A without PD negotiation:
- 5.1kΩ pull-down on each CC pin to GND (on the device/sink side)

For a USB-C device to be recognized as a basic USB device (5V/500mA):
- 5.1kΩ pull-down on each CC pin

---

## Practical Tips

### Common Mistakes

1. **Using a linear regulator where a switcher should be used** — 12V to 3.3V at 200mA = 1.7W of heat. Use a buck converter
2. **Forgetting input/output capacitors** — Regulators can oscillate without proper capacitors
3. **Not checking dropout voltage** — An LDO rated at 3.3V with 1.1V dropout needs at least 4.4V input. A dying battery at 3.5V won't work
4. **Exceeding power dissipation** — Calculate thermal load before building
5. **Using the wrong capacitor type** — Some LDOs require ESR within a specific range for stability (check the datasheet)
6. **Ignoring quiescent current** — In battery applications, a regulator drawing 5mA quiescent current wastes 120mAh/day even with no load

### Layout Tips

- Place decoupling capacitors as close to the regulator as physically possible
- Use wide, short traces for power paths
- Provide adequate ground plane copper for heat dissipation (especially for SMD regulators using thermal pads)
- Keep switching regulator inductors close to the IC, minimize the hot loop area
- Route feedback traces away from noisy switching nodes
