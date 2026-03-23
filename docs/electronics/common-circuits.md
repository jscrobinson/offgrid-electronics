# Common Practical Circuits

## Voltage Level Shifting (3.3V to 5V)

### Resistor Divider: 5V → 3.3V (Unidirectional, High to Low)

For converting 5V logic signals down to 3.3V inputs:

```
5V signal ──[10kΩ]──┬── 3.3V signal out
                    │
                 [20kΩ]
                    │
                   GND

Vout = 5V × 20k / (10k + 20k) = 3.33V
```

**Limitations:** Unidirectional only (5V→3.3V), slows signal edges (RC time constant with parasitic capacitance), not suitable for high-speed signals (>100kHz).

**Common alternative:** Use 1kΩ + 2kΩ for faster signals, or 4.7kΩ + 10kΩ for slightly off but adequate ratio.

### MOSFET Bidirectional Level Shifter (BSS138)

The standard circuit for bidirectional level shifting (works for I2C, SPI data lines, GPIO):

```
3.3V side                                    5V side
                     BSS138
LV device ──┬── S ──┤ N-ch ├── D ──┬── HV device
             │       Gate          │
          [10kΩ]      │         [10kΩ]
             │        │            │
           3.3V      3.3V         5V
```

**How it works:**

When LV side drives LOW:
- MOSFET body diode conducts, pulling HV side LOW
- MOSFET turns on (Vgs > Vth), clamping both sides LOW

When LV side drives HIGH (3.3V):
- Vgs = 0V, MOSFET OFF
- Both sides pulled HIGH by their respective pull-ups (3.3V and 5V)

When HV side drives LOW:
- Drain pulled LOW, Vgs > Vth, MOSFET ON, both sides LOW

When HV side drives HIGH (5V):
- MOSFET OFF (body diode reverse biased)
- LV side pulled to 3.3V by its pull-up

**Pre-built modules:** SparkFun BOB-12009, Adafruit BSS138 level shifter, cheap 4-channel modules from Amazon/AliExpress.

### Dedicated Level Shifter ICs

| Part        | Channels | Speed      | Notes                        |
|------------|----------|------------|------------------------------|
| TXB0104    | 4        | 100 Mbps   | Auto-direction, push-pull    |
| TXB0108    | 8        | 100 Mbps   | Auto-direction, push-pull    |
| 74LVC245   | 8        | ~100 MHz   | Unidirectional, OE pin       |
| 74HCT245   | 8        | ~25 MHz    | 3.3V→5V (treats 3.3V as HIGH)|
| GTL2003    | 8        | I2C/SMBus  | Open-drain, bidirectional    |

**Note on TXB0104/0108:** These can have issues with slow-rise signals or open-drain buses (I2C). Use BSS138 or GTL2003 for I2C.

---

## H-Bridge Motor Driver

An H-bridge allows bidirectional control of a DC motor.

```
       V_motor
      ┌───┼───┐
     [Q1]    [Q3]
      │       │
      ├──[M]──┤
      │       │
     [Q2]    [Q4]
      └───┼───┘
         GND

Q1+Q4 ON, Q2+Q3 OFF → Motor forward
Q2+Q3 ON, Q1+Q4 OFF → Motor reverse
Q1+Q3 ON or Q2+Q4 ON → SHORT CIRCUIT (never do this!)
All OFF → Motor coasts
Q1+Q2 ON or Q3+Q4 ON → Brake (motor shorted)
```

### Common H-Bridge Driver ICs/Modules

| Part/Module | Voltage | Current    | Features                          |
|------------|---------|------------|-----------------------------------|
| L298N      | 5-46V   | 2A per ch  | Dual H-bridge, high Vdrop (~2V), cheap module |
| L293D      | 4.5-36V | 600mA      | Dual H-bridge with internal diodes |
| DRV8833    | 2.7-10.8V | 1.5A per ch | Dual H-bridge, low Vdrop, PWM input |
| DRV8871    | 6.5-45V | 3.6A       | Single H-bridge, current limit    |
| TB6612FNG  | 2.5-13.5V | 1.2A per ch | Dual, MOSFET output, low Vdrop  |
| BTS7960    | 5.5-27V | 43A        | Single half-bridge, need 2 for full H |
| IBT-2 module | 6-27V | 43A       | BTS7960 dual half-bridge module    |

**L298N module is everywhere** but drops ~2V across the output transistors (bipolar, not MOSFET). For low-voltage motors (6V or less), use DRV8833 or TB6612FNG instead.

---

## Pull-Up and Pull-Down Resistors

### Pull-Up Resistor

Connects a signal line to V+ through a resistor. Default state is HIGH.

```
Vcc (3.3V or 5V)
    │
  [10kΩ] ← pull-up resistor
    │
    ├── Signal line (to MCU input)
    │
  [Switch/Button/Open-drain output]
    │
   GND
```

When switch is open: signal is HIGH (pulled to Vcc through resistor)
When switch is closed: signal is LOW (directly connected to GND)

### Pull-Down Resistor

Connects a signal line to GND through a resistor. Default state is LOW.

```
Vcc
    │
  [Switch/Button]
    │
    ├── Signal line (to MCU input)
    │
  [10kΩ] ← pull-down resistor
    │
   GND
```

### Typical Values

| Application            | Pull-up/down Value | Notes                     |
|-----------------------|-------------------|---------------------------|
| General GPIO          | 10kΩ              | Standard choice            |
| I2C bus               | 4.7kΩ             | Standard mode (100kHz)     |
| I2C fast mode         | 2.2kΩ             | 400kHz, more current       |
| SPI CS line           | 10kΩ              | Keep CS high when inactive |
| Reset pin             | 10kΩ              | To Vcc, keeps chip running |
| MOSFET gate           | 10-100kΩ          | To GND, ensures OFF        |
| Weak pull-up          | 47-100kΩ          | Save power, slow edges     |
| Strong pull-up        | 1-4.7kΩ           | Faster edges, more current |

**Rule of thumb:** 10kΩ works for almost everything. Use lower values only when you need faster signal edges or when the bus specification requires it.

---

## RC Low-Pass Filter

```
Vin ──[R]──┬── Vout
           │
          [C]
           │
          GND
```

```
Cutoff frequency: fc = 1 / (2πRC)

At fc: signal is attenuated by -3dB (70.7% of input)
Above fc: -20dB per decade rolloff (first order)
```

### Design Examples

| Application              | fc Target | R       | C       | Actual fc |
|-------------------------|-----------|---------|---------|-----------|
| Audio anti-aliasing     | 10kHz     | 1kΩ     | 15nF    | 10.6kHz   |
| ADC noise filter        | 1kHz      | 10kΩ    | 15nF    | 1.06kHz   |
| Power supply ripple     | 10Hz      | 100Ω    | 100μF   | 15.9Hz    |
| Sensor smoothing        | 100Hz     | 10kΩ    | 150nF   | 106Hz     |
| PWM to DC (for DAC)     | 50Hz      | 10kΩ    | 330nF   | 48.2Hz    |

### RC High-Pass Filter

Swap R and C:

```
Vin ──[C]──┬── Vout
           │
          [R]
           │
          GND
```

Same cutoff formula: fc = 1 / (2πRC). Passes frequencies above fc, blocks DC.

---

## LED with Current Limiting Resistor

```
V+ ──[R]── LED ── GND
         (anode) (cathode)
```

```
R = (V_supply - V_LED) / I_LED
```

### Quick Reference

| Supply | Red LED (1.8V, 10mA) | Green (2.2V, 10mA) | Blue/White (3.2V, 10mA) |
|--------|----------------------|---------------------|--------------------------|
| 3.3V   | 150Ω                 | 110Ω                | 10Ω (marginal - use 5V)  |
| 5V     | 320Ω → 330Ω          | 280Ω → 270Ω         | 180Ω                     |
| 12V    | 1020Ω → 1kΩ          | 980Ω → 1kΩ          | 880Ω → 1kΩ              |

### Multiple LEDs in Series

LEDs in series share the same current. Add up the forward voltages:

```
R = (V_supply - V_LED1 - V_LED2 - V_LED3) / I_LED
```

3 red LEDs in series on 12V at 10mA: R = (12 - 1.8 - 1.8 - 1.8) / 0.01 = 660Ω → 680Ω

---

## Voltage Divider for ADC Input

Scale a higher voltage signal to match your MCU's ADC range:

```
V_sensor ──[R1]──┬── ADC pin
                 │
               [R2]
                 │
                GND
```

```
V_ADC = V_sensor × R2 / (R1 + R2)
```

### Design Example: 0-25V to 0-3.3V for ESP32

```
Ratio needed: 3.3/25 = 0.132

Pick R2 = 10kΩ
R1 = R2 × (V_sensor_max / V_ADC_max - 1) = 10k × (25/3.3 - 1) = 10k × 6.576 = 65.76kΩ

Use R1 = 68kΩ (standard value)
Actual V_ADC_max = 25 × 10k / (68k + 10k) = 3.205V ✓ (under 3.3V limit)

Add 100nF capacitor across R2 for noise filtering.
```

**Important:** Add a Zener diode (3.3V) or TVS across the ADC input for overvoltage protection. Sensor faults could exceed expected range.

---

## Relay Driver with Flyback Diode

```
V_coil (e.g., 5V or 12V)
    │
    ├──── Diode (1N4007) cathode
    │                │
  Relay              │ anode
  Coil               │
    │                │
    ├────────────────┘
    │
    C (NPN: 2N2222 or 2N3904)
    │
    B ──[1kΩ]── MCU GPIO
    │
    E
    │
   GND
```

**Base resistor calculation (for 5V relay coil, ~80mA):**
```
I_B = I_C / 10 = 80mA / 10 = 8mA
R_B = (3.3V - 0.7V) / 8mA = 325Ω → use 330Ω
```

For higher-current relays or solenoids, use a MOSFET instead of BJT.

**The flyback diode is mandatory.** Without it, the voltage spike from the relay coil (which can reach 50-100V+) will destroy the transistor.

---

## Transistor as a Switch

### NPN Low-Side Switch

```
V_load ──[Load]── C (NPN)
                   │
                   B ──[R_B]── MCU
                   │
                   E ── GND
```

**Design steps:**
1. Determine load current (I_C)
2. Choose transistor rated for I_C (with margin)
3. Calculate R_B = (V_MCU - 0.7V) / (I_C / 10)
4. Add flyback diode if load is inductive

### N-Channel MOSFET Low-Side Switch

```
V_load ──[Load]── D (N-ch MOSFET)
                   │
                   G ──[220Ω]── MCU
                   │
                   S ── GND
                   │
                 [10kΩ] (G to S pull-down)
```

**Design steps:**
1. Choose logic-level MOSFET rated for load voltage and current
2. Verify R_DS(on) at your V_GS (MCU voltage) — check the datasheet curves, not just the headline spec
3. Add gate pull-down (10kΩ) to ensure OFF during MCU boot
4. Optional gate resistor (100-470Ω) limits current spikes
5. Add flyback diode if load is inductive

---

## Button Debouncing

Mechanical switches bounce — they make and break contact multiple times when pressed, generating spurious pulses over 1-50ms.

### Hardware Debounce: RC Filter + Schmitt Trigger

```
Vcc ──[10kΩ]──┬── Button ── GND
              │
              ├──[10kΩ]──┬── MCU input (Schmitt trigger)
              │           │
              │        [100nF]
              │           │
              │          GND
```

Time constant: τ = 10kΩ × 100nF = 1ms
Debounce time ≈ 5τ = 5ms (enough for most switches)

The Schmitt trigger input (most MCU GPIO pins have Schmitt trigger inputs) provides clean HIGH/LOW transitions.

### Software Debounce (Arduino Example)

```cpp
const int BUTTON_PIN = 2;
const unsigned long DEBOUNCE_MS = 50;

bool buttonState = HIGH;
bool lastButtonState = HIGH;
unsigned long lastDebounceTime = 0;

void loop() {
    bool reading = digitalRead(BUTTON_PIN);

    if (reading != lastButtonState) {
        lastDebounceTime = millis();
    }

    if ((millis() - lastDebounceTime) > DEBOUNCE_MS) {
        if (reading != buttonState) {
            buttonState = reading;
            if (buttonState == LOW) {
                // Button was pressed — do something
            }
        }
    }

    lastButtonState = reading;
}
```

### Software Debounce (ESP32/Arduino with Interrupt)

```cpp
volatile unsigned long lastISR = 0;
volatile bool buttonPressed = false;

void IRAM_ATTR buttonISR() {
    unsigned long now = millis();
    if (now - lastISR > 200) {  // 200ms debounce
        buttonPressed = true;
        lastISR = now;
    }
}

void setup() {
    pinMode(BUTTON_PIN, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(BUTTON_PIN), buttonISR, FALLING);
}

void loop() {
    if (buttonPressed) {
        buttonPressed = false;
        // Handle press
    }
}
```

---

## Summary: "I need to..." Quick Reference

| Task                                | Circuit / Component                     |
|------------------------------------|----------------------------------------|
| Shift 5V signal to 3.3V           | Resistor divider (10kΩ + 20kΩ)         |
| Bidirectional level shift          | BSS138 MOSFET circuit                   |
| Drive a relay from MCU             | NPN + flyback diode                     |
| Drive a motor forward/reverse      | H-bridge (L298N, DRV8833)              |
| Default pin state HIGH             | 10kΩ pull-up to Vcc                     |
| Default pin state LOW              | 10kΩ pull-down to GND                   |
| Filter noise from signal           | RC low-pass filter                      |
| Light an LED from MCU              | GPIO → resistor → LED → GND            |
| Read high voltage with ADC         | Resistor divider + protection           |
| Control high-current load          | MOSFET switch + pull-down               |
| Debounce a button                  | RC + Schmitt trigger or software        |
| Switch power to a subsystem        | P-channel MOSFET high-side switch       |
| Protect against reverse polarity   | Series Schottky or P-channel MOSFET     |
| Protect against voltage spikes     | TVS diode                               |
