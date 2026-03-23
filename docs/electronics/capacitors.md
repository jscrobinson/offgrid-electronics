# Capacitors

## Capacitor Basics

A capacitor stores energy in an electric field between two conductive plates separated by a dielectric (insulating material).

```
Capacitance: C = Q / V  (charge stored per volt)
Energy stored: E = ½CV²
```

Key properties:
- **Capacitance** — measured in Farads (F). Practical values range from picofarads (pF) to millifarads (mF)
- **Voltage rating** — maximum voltage the capacitor can withstand. Always derate to 50-80% of rated voltage
- **ESR** (Equivalent Series Resistance) — parasitic resistance that causes power loss and heating
- **ESL** (Equivalent Series Inductance) — parasitic inductance, limits high-frequency performance
- **Polarity** — some types (electrolytic, tantalum) are polarized and will fail catastrophically if reversed

---

## Capacitor Markings

### Ceramic / Film Capacitor Code (3-digit)

The code follows the same pattern as resistors: first two digits are significant, third is the multiplier (number of zeros). **Result is in picofarads (pF).**

| Code | Calculation      | Value   |
|------|-----------------|---------|
| 100  | 10 × 10⁰ pF    | 10pF    |
| 101  | 10 × 10¹ pF    | 100pF   |
| 102  | 10 × 10² pF    | 1nF (1000pF) |
| 103  | 10 × 10³ pF    | 10nF    |
| 104  | 10 × 10⁴ pF    | 100nF (0.1μF) |
| 105  | 10 × 10⁵ pF    | 1μF     |
| 220  | 22 × 10⁰ pF    | 22pF    |
| 221  | 22 × 10¹ pF    | 220pF   |
| 222  | 22 × 10² pF    | 2.2nF   |
| 223  | 22 × 10³ pF    | 22nF    |
| 224  | 22 × 10⁴ pF    | 220nF   |
| 473  | 47 × 10³ pF    | 47nF    |
| 474  | 47 × 10⁴ pF    | 470nF   |
| 471  | 47 × 10¹ pF    | 470pF   |

### Quick Conversion

```
1F = 1,000mF = 1,000,000μF = 10⁹nF = 10¹²pF

1μF = 1000nF = 1,000,000pF
1nF = 1000pF
```

### Voltage Marking

Ceramic capacitors often have a voltage code letter:

| Code | Voltage |
|------|---------|
| 0G   | 4V      |
| 0J   | 6.3V    |
| 1A   | 10V     |
| 1C   | 16V     |
| 1E   | 25V     |
| 1H   | 50V     |
| 2A   | 100V    |
| 2D   | 200V    |

---

## Capacitor Types

### Ceramic Capacitors (MLCC)

Multi-Layer Ceramic Capacitors are the most commonly used type.

**Class 1 (C0G/NP0):**
- Temperature stable (±30ppm/°C)
- Low ESR, no piezoelectric effects
- No voltage coefficient (capacitance doesn't change with applied voltage)
- Available in small values: typically 1pF to 10nF
- Ideal for: timing circuits, filters, oscillator circuits, RF

**Class 2 (X5R, X7R, X5S, etc.):**
- Higher capacitance density
- Capacitance varies with temperature, voltage, and age
- X7R: ±15% over -55°C to +125°C
- X5R: ±15% over -55°C to +85°C
- **DC bias effect**: a 10μF X5R rated at 10V may have only 4-5μF actual capacitance at 8V applied. Always check the datasheet curves
- Available from 1nF to 100μF+ (in small packages)
- Ideal for: decoupling, bypass, bulk capacitance, general purpose

**Class 3 (Y5V, Z5U):**
- Very high capacitance density but terrible stability
- Can lose 50-80% of rated capacitance over temperature range
- Avoid unless you truly don't care about actual capacitance value

**Ceramic Capacitor Gotchas:**
- Small ceramics (0402, 0603) can crack from board flex
- Class 2 ceramics are piezoelectric — they can vibrate and produce audible noise in switching circuits ("singing capacitors")
- DC bias derating is a hidden trap — **always check the voltage coefficient**

### Electrolytic Capacitors

#### Aluminum Electrolytic
- Large capacitance: 0.1μF to 1F+
- **POLARIZED** — marked with a stripe indicating the **negative** terminal
- Higher ESR than ceramics
- Limited life (rated in hours at max temperature, typically 1000-10000 hours at 105°C)
- Dry out over time (capacitance decreases, ESR increases)
- Available voltages: 6.3V to 450V+
- Ideal for: bulk energy storage, power supply filtering, audio coupling

**Polarity matters!** Reverse-biasing an electrolytic capacitor can cause:
- Internal short circuit
- Rapid gas buildup
- **Explosive venting** — the top of the capacitor has vent scores for safety, but it's still dangerous

#### Tantalum Electrolytic
- Smaller size than aluminum for same capacitance
- **POLARIZED** — marked with a stripe or + indicating the **positive** terminal (opposite convention from aluminum!)
- Lower ESR than aluminum electrolytic
- More stable over temperature and time
- **Failure mode is a short circuit** — can catch fire if overvoltaged or reverse-biased
- Must be derated aggressively: use at 50% of rated voltage or less
- Available: 0.1μF to 1000μF, typically up to 50V
- Ideal for: compact power supply filtering, places where low ESR matters

### Film Capacitors

- Non-polarized
- Very low ESR and ESL
- Excellent stability and long life
- Self-healing: if dielectric breaks down, the thin metal film vaporizes and clears the fault
- Types: polyester (Mylar), polypropylene, polycarbonate
- Available: 100pF to ~100μF
- Larger physical size than ceramics or electrolytics for same capacitance
- Ideal for: audio signal path, AC mains filtering (X/Y safety rated), precision timing, snubber circuits

### Supercapacitors (EDLC)

- Enormous capacitance: 0.1F to 3000F+
- Low voltage: typically 2.5V or 2.7V per cell (series for higher voltage)
- High ESR compared to regular capacitors
- Moderate energy density (between batteries and regular capacitors)
- Can charge/discharge thousands of times with no degradation
- Ideal for: backup power (RTC, SRAM), energy harvesting buffer, high-current pulse delivery, bridge power during supply switching

---

## Applications

### Bypass / Decoupling

**Purpose:** Provide a local charge reservoir for IC power pins, filtering high-frequency noise.

**Rules:**
1. Place a **100nF (0.1μF) ceramic** capacitor as close as physically possible to every IC power pin
2. Use short, wide traces to the power and ground pins
3. For higher-current ICs, add a **10μF ceramic or tantalum** nearby for lower-frequency filtering
4. For the overall power rail, add **bulk capacitance** (47-470μF electrolytic) near where power enters the board

```
Typical decoupling arrangement:

Power In → [100μF electrolytic] → trace → [10μF ceramic] → [100nF ceramic] → IC Vcc pin
                                                                               |
                                                                              GND
```

The 100nF handles fast transients (MHz), the 10μF handles medium transients, and the 100μF provides bulk energy.

### Coupling (AC Coupling / DC Blocking)

A capacitor in series blocks DC while passing AC:

```
Signal with DC offset → [C] → AC signal only → next stage
```

The capacitor and the load form a high-pass filter. The cutoff frequency is:

```
f_c = 1 / (2π × R_load × C)
```

For audio coupling (pass everything above 20Hz) with 10kΩ load:
```
C = 1 / (2π × 10000 × 20) = 0.8μF → use 1μF
```

### Timing Circuits

RC time constant: **τ = R × C**

A capacitor charges to ~63% of the applied voltage in one time constant.

```
Charge:    V(t) = V_supply × (1 - e^(-t/RC))
Discharge: V(t) = V_initial × e^(-t/RC)
```

| Time | Charge Level | Discharge Level |
|------|-------------|-----------------|
| 1τ   | 63.2%       | 36.8%           |
| 2τ   | 86.5%       | 13.5%           |
| 3τ   | 95.0%       | 5.0%            |
| 4τ   | 98.2%       | 1.8%            |
| 5τ   | 99.3%       | 0.7%            |

Practical rule: the capacitor is "fully" charged/discharged after **5τ**.

**Example:** 10kΩ and 100μF → τ = 1 second. Full charge in ~5 seconds.

### Energy Storage

```
E = ½CV²
```

**Example:** How much energy in a 1000μF capacitor charged to 12V?

```
E = 0.5 × 0.001 × 144 = 0.072 J = 72 mJ
```

For a supercapacitor: 1F charged to 2.7V:
```
E = 0.5 × 1 × 7.29 = 3.645 J
```

---

## ESR (Equivalent Series Resistance)

ESR causes power dissipation as heat when current flows through the capacitor:

```
P_loss = I_rms² × ESR
```

**Why ESR matters:**
- In switching power supplies, high ripple current through output capacitors causes heating
- Low ESR → less voltage ripple → better filtering
- Aluminum electrolytic: ESR typically 0.05Ω to 5Ω (decreasing with capacitance)
- Ceramic: ESR typically 0.001Ω to 0.1Ω
- Tantalum: ESR typically 0.05Ω to 1Ω

**Measuring ESR:** Standard multimeters cannot measure ESR. Use a dedicated ESR meter or an impedance analyzer. ESR meters are useful for diagnosing failed electrolytic capacitors in repair work.

---

## Selection Guide

| Application               | Type                    | Typical Value      |
|--------------------------|-------------------------|-------------------|
| IC decoupling            | Ceramic X7R/X5R         | 100nF per pin     |
| MCU bulk decoupling      | Ceramic + electrolytic  | 10μF + 100μF      |
| Crystal load capacitors  | Ceramic C0G/NP0         | 12-22pF           |
| Audio coupling           | Film or electrolytic    | 1-10μF            |
| Power supply output      | Electrolytic + ceramic  | 100-1000μF + 100nF|
| RTC backup               | Supercapacitor          | 0.1-1F            |
| Motor noise suppression  | Ceramic                 | 100nF across motor |
| RC timing                | Ceramic C0G or Film     | depends on timing  |
| EMI filtering            | Ceramic (feed-through)  | 100pF-10nF        |
