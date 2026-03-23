# Relays, MOSFETs, and Switching Loads

How to safely switch high-current or high-voltage loads from a microcontroller.

---

## Mechanical Relays

### How They Work

A relay is an electromagnetically operated switch. A small current through the coil creates a magnetic field that physically moves a contact arm, connecting or disconnecting the load circuit. The control side and load side are **galvanically isolated** — no electrical connection between them.

### Relay Module Pinout

Most hobby relay modules (1/2/4/8 channel) have:

**Control side:**
- **VCC** — 5V (or 3.3V on some modules) to power the relay coil
- **GND** — Ground
- **IN** — Signal pin. Usually **active LOW** (LOW = relay ON)

**Load side (screw terminals):**
- **COM** — Common (always connected to one of the other two)
- **NO** — Normally Open (disconnected when relay is off, connected when on)
- **NC** — Normally Closed (connected when relay is off, disconnected when on)

### Wiring for Switching a Load

```
For a device that should be OFF by default and ON when activated:

    Power Supply (+) → COM
    NO → Load (+)
    Load (-) → Power Supply (-)

For a device that should be ON by default and OFF when deactivated:

    Power Supply (+) → COM
    NC → Load (+)
    Load (-) → Power Supply (-)
```

### Arduino/ESP32 Control

```cpp
#define RELAY_PIN 5

void setup() {
    pinMode(RELAY_PIN, OUTPUT);
    digitalWrite(RELAY_PIN, HIGH);  // HIGH = OFF (active low modules)
}

void relayOn() {
    digitalWrite(RELAY_PIN, LOW);   // LOW = ON
}

void relayOff() {
    digitalWrite(RELAY_PIN, HIGH);  // HIGH = OFF
}
```

### Relay Module Gotchas

- **Active LOW:** Most relay modules trigger when the input is LOW, not HIGH. This means the relay activates on boot (ESP32 GPIOs often start LOW). Fix: add pull-up resistor or choose GPIO that starts HIGH
- **Current draw:** Each relay coil draws 70-80mA. A 4-channel module draws ~320mA. Don't power from MCU 3.3V pin — use separate 5V supply
- **Voltage drop:** Relay contacts have ~0.1V drop. Fine for most loads
- **Contact ratings:** Check the relay's rated voltage AND current. "10A 250VAC" does not mean "10A at 250VAC" for all load types — derate for inductive loads
- **Coil voltage:** Most modules need 5V for the coil even if the signal input is 3.3V compatible. Check if your module has an optocoupler (isolates signal from coil)

### Flyback Diode

When driving a bare relay (not a module), **always** add a flyback diode across the coil:

```
         ┌──────────┐
GPIO → ──┤  Relay   ├──→ VCC
         │  Coil    │
         └──────────┘
              ↑ ↓
           1N4007 diode
         (cathode to VCC)
```

The diode absorbs the voltage spike when the coil de-energizes. Without it, the back-EMF spike can destroy your transistor or MCU. Module boards already include this diode.

---

## Solid State Relays (SSR)

### What They Are

SSRs use semiconductors (triac/MOSFET) instead of mechanical contacts. No moving parts, no contact bounce, silent, longer lifespan.

### Types

| Type     | Load     | Typical Part | Notes                        |
|----------|----------|--------------|------------------------------|
| DC SSR   | DC loads | SSR-25DD     | MOSFET-based                 |
| AC SSR   | AC loads | SSR-25DA     | Triac-based, zero-cross      |

### Wiring (SSR-25DA for AC)

```
Control side:
    (+) → GPIO (through current-limiting resistor if needed)
    (-) → GND
    Control voltage: 3-32V DC (check your module)

Load side:
    AC Line → SSR Input terminal
    SSR Output terminal → Load
    Load other wire → AC Neutral
```

### SSR Gotchas

- **Heat:** SSRs generate heat proportional to load current. Mount on heatsink for loads over 5A
- **Leakage current:** SSRs have a small leakage (~mA) when "off." This can keep LED bulbs dimly lit
- **Voltage drop:** ~1.5V across the SSR when conducting (generates heat)
- **No galvanic isolation** on cheap modules — check if optically isolated
- **Fake SSRs:** Many cheap SSRs on Amazon/AliExpress are repackaged with lower-rated components. Derate by 50% or buy from reputable sources

---

## N-Channel MOSFET — Low-Side Switching

The most common way to switch DC loads with a microcontroller.

### How It Works

The MOSFET goes between the load and ground. When the gate voltage is HIGH, current flows from drain to source, completing the circuit.

```
VCC ──→ Load ──→ DRAIN
                  │
                MOSFET
                  │
                SOURCE ──→ GND

GPIO ──→ GATE (with 10kΩ pull-down to GND)
```

### Common Logic-Level N-Channel MOSFETs

| Part      | Vds Max | Id Max | Rds(on) @ Vgs=3.3V | Package  |
|-----------|---------|--------|---------------------|----------|
| IRLZ44N   | 55V     | 47A    | ~0.022Ω             | TO-220   |
| IRL540N   | 100V    | 36A    | ~0.044Ω             | TO-220   |
| IRLB8721  | 30V     | 62A    | ~0.009Ω             | TO-220   |
| AO3400    | 30V     | 5.7A   | ~0.040Ω             | SOT-23   |
| Si2302    | 20V     | 2.6A   | ~0.055Ω             | SOT-23   |

### Key Concepts

- **Vgs(th)** — Gate threshold voltage. The MOSFET starts turning on here, but is NOT fully on
- **Rds(on) @ Vgs** — On-resistance at a specific gate voltage. Lower = less heat. Check at YOUR gate voltage (3.3V or 5V), not 10V
- **Logic-level MOSFET** — Fully turns on at 3.3-5V gate voltage. Standard MOSFETs (like IRF540N without the L) need 10V+ on the gate and WON'T work with 3.3V directly

### Wiring Best Practices

```cpp
// Basic PWM control of a load via N-channel MOSFET
#define MOSFET_PIN 25

void setup() {
    // ESP32: use LEDC for PWM
    ledcSetup(0, 25000, 8);  // Channel 0, 25kHz, 8-bit
    ledcAttachPin(MOSFET_PIN, 0);
}

void loop() {
    ledcWrite(0, 128);  // 50% duty cycle
}
```

**Gate resistor (100-220Ω):** Optional but recommended between GPIO and gate. Limits inrush current to gate capacitance, protects GPIO.

**Pull-down resistor (10kΩ):** Between gate and source (GND). Ensures MOSFET stays OFF when GPIO is floating (during boot/reset).

### Low-Side Switching Limitations

- Load connects between VCC and drain — **load's ground is not common ground** when MOSFET is off
- Cannot switch the high side (between supply and load)
- If the load has its own ground reference (e.g., logic circuits), low-side switching can cause issues

---

## P-Channel MOSFET — High-Side Switching

Switches the positive supply to the load. Less common in hobby projects because P-channel MOSFETs have higher Rds(on) and fewer logic-level options.

### Wiring

```
VCC ──→ SOURCE
          │
        MOSFET
          │
        DRAIN ──→ Load ──→ GND

Gate control:
    GPIO LOW = MOSFET ON (Vgs is negative for P-channel)
    GPIO HIGH = MOSFET OFF
```

**Problem:** If VCC > 3.3V, you can't drive the gate directly from a 3.3V MCU. Need a level-shifting circuit (often an NPN transistor or N-channel MOSFET to pull the gate to VCC or GND).

### When to Use P-Channel

- Need to switch the high side (positive rail)
- Load requires a common ground
- Power distribution/switching applications

---

## When to Use What

| Scenario                          | Best Choice                              |
|-----------------------------------|------------------------------------------|
| DC load, < 30V, moderate current  | N-channel MOSFET (low-side)              |
| DC load, needs common ground      | P-channel MOSFET (high-side)             |
| AC mains load (lights, heaters)   | SSR (AC type) or mechanical relay        |
| Infrequent switching, isolation   | Mechanical relay                         |
| PWM control (motors, LEDs)        | N-channel MOSFET                         |
| High voltage DC (>60V)            | Relay                                    |
| Very low current signal switching | Relay or analog switch IC                |
| Bidirectional AC switching        | SSR or relay                             |

---

## AC Safety

**WARNING: Mains voltage (120V/240V AC) can kill you.**

### Rules for AC Projects

1. **Use enclosed relay modules** — never expose mains wiring
2. **Use proper wire gauges** — 14 AWG for 15A, 12 AWG for 20A circuits (US)
3. **Always fuse the circuit** — fuse on the live/hot wire before the relay
4. **Keep low-voltage and high-voltage separated** — minimum 6mm clearance on PCBs
5. **Ground everything** — metal enclosures MUST be earth grounded
6. **Use strain relief** — on all cables entering/exiting enclosures
7. **Never work on live circuits** — unplug first, verify with a non-contact voltage tester
8. **Double-insulate** — use sleeving on exposed terminals
9. **Use GFCI/RCD protection** — upstream of your project
10. **When in doubt, use a commercially rated smart relay** (like a Sonoff with Tasmota)

### Creepage and Clearance

For mains voltage on custom PCBs:
- **Clearance** (through air): minimum 3mm for 240VAC
- **Creepage** (along surface): minimum 6mm for 240VAC
- Use slots/cutouts in PCB to increase creepage distance

---

## Practical Examples

### Switching a 12V LED Strip with ESP32

```
12V PSU (+) ──→ LED Strip (+)
LED Strip (-) ──→ IRLB8721 Drain
                    │
                  Source ──→ GND (common with ESP32 GND)

ESP32 GPIO25 ──[220Ω]──→ Gate
                          │
                        [10kΩ]
                          │
                         GND
```

Use PWM on GPIO25 to dim the LED strip.

### Switching a 5V Fan with Relay

```
5V Supply ──→ Relay COM
Relay NO  ──→ Fan (+)
Fan (-)   ──→ GND

ESP32 GPIO5 ──→ Relay IN
ESP32 GND   ──→ Relay GND
5V          ──→ Relay VCC
```

### Power Budget for Multiple Relays

| Component         | Current Draw |
|-------------------|--------------|
| 1 relay coil      | ~70mA        |
| 4-ch relay module | ~320mA       |
| 8-ch relay module | ~640mA       |

Never power relay modules from the MCU's voltage regulator. Use separate 5V supply.
