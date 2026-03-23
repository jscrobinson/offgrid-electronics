# Motor Control

DC motors, servos, stepper motors, and brushless DC motors — wiring, drivers, and control.

---

## DC Motors

### Basics

DC motors spin when voltage is applied. Reverse polarity = reverse direction. Speed is proportional to voltage (up to rated voltage). They draw significant current, especially at stall — **never drive directly from a GPIO pin.**

### H-Bridge Motor Drivers

An H-bridge allows you to control both **direction** and **speed** (via PWM) of a DC motor.

#### L298N — Dual H-Bridge Module

**Specs:** 2 channels, 5-35V, 2A per channel (1A practical with heat), built-in 5V regulator.

**Wiring:**
```
L298N          Connection
-----          ----------
12V / VS       Motor power supply (up to 35V)
GND            Common ground (share with MCU)
5V             Can OUTPUT 5V (if jumper set) or INPUT 5V (if >12V supply)
IN1            GPIO — Motor A direction
IN2            GPIO — Motor A direction
IN3            GPIO — Motor B direction
IN4            GPIO — Motor B direction
ENA            PWM — Motor A speed (remove jumper first)
ENB            PWM — Motor B speed (remove jumper first)
OUT1/OUT2      Motor A terminals
OUT3/OUT4      Motor B terminals
```

**Control Logic:**
| IN1  | IN2  | Motor A     |
|------|------|-------------|
| HIGH | LOW  | Forward     |
| LOW  | HIGH | Reverse     |
| LOW  | LOW  | Stop (coast)|
| HIGH | HIGH | Brake       |

**Arduino Example:**
```cpp
#define IN1 16
#define IN2 17
#define ENA 25

void setup() {
    pinMode(IN1, OUTPUT);
    pinMode(IN2, OUTPUT);
    // ESP32 PWM
    ledcSetup(0, 1000, 8);  // 1kHz, 8-bit
    ledcAttachPin(ENA, 0);
}

void forward(uint8_t speed) {
    digitalWrite(IN1, HIGH);
    digitalWrite(IN2, LOW);
    ledcWrite(0, speed);  // 0-255
}

void reverse(uint8_t speed) {
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, HIGH);
    ledcWrite(0, speed);
}

void stop() {
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, LOW);
    ledcWrite(0, 0);
}
```

**L298N Gotchas:**
- Drops ~2V across the driver (bipolar transistors). A 6V motor on 6V supply only gets ~4V
- Gets very hot at higher currents. Practical limit ~1A without heatsink
- Remove the ENA/ENB jumpers to use PWM speed control
- The 5V regulator only works if VS ≤ 12V. Disable jumper if VS > 12V

#### DRV8833 — Dual H-Bridge (Better)

**Specs:** 2 channels, 2.7-10.8V, 1.5A per channel (peak 2A), MOSFET-based (low voltage drop).

**Advantages over L298N:**
- Much lower voltage drop (~0.5V vs ~2V)
- More efficient, less heat
- Works at lower voltages (down to 2.7V)
- Smaller form factor

**Wiring:**
```
DRV8833     Connection
-------     ----------
VCC         Motor power (2.7-10.8V)
GND         Ground
AIN1        PWM — Motor A
AIN2        PWM — Motor A
BIN1        PWM — Motor B
BIN2        PWM — Motor B
AOUT1/2     Motor A
BOUT1/2     Motor B
SLP         Sleep pin (tie HIGH for always on)
```

**Control:** Apply PWM to xIN1, hold xIN2 LOW for forward. Swap for reverse.

---

## Servo Motors

### How Servos Work

Servos contain a DC motor, gearbox, and position feedback (potentiometer). They accept a **50Hz PWM signal** where the pulse width determines position:

```
Pulse Width      Position
-----------      --------
~500μs           0° (or -90°)
~1500μs          90° (center)
~2500μs          180° (or +90°)
```

The 50Hz period = 20ms. The pulse width varies within that 20ms window.

### Common Servos

| Servo    | Torque     | Speed        | Voltage | Weight | Gears    |
|----------|------------|--------------|---------|--------|----------|
| SG90     | 1.8 kg·cm  | 0.1s/60°     | 4.8-6V  | 9g     | Plastic  |
| MG90S    | 1.8 kg·cm  | 0.1s/60°     | 4.8-6V  | 14g    | Metal    |
| MG996R   | 11 kg·cm   | 0.17s/60°    | 4.8-7.2V| 55g    | Metal    |
| DS3218   | 21 kg·cm   | 0.16s/60°    | 4.8-7.2V| 60g    | Metal    |

### Arduino Control

```cpp
#include <ESP32Servo.h>  // Use this for ESP32 (not standard Servo.h)
// Arduino Uno: use standard <Servo.h>

Servo myServo;

void setup() {
    myServo.attach(18);  // GPIO18
}

void loop() {
    myServo.write(0);     // Go to 0°
    delay(1000);
    myServo.write(90);    // Go to 90°
    delay(1000);
    myServo.write(180);   // Go to 180°
    delay(1000);
}
```

**For fine control with microseconds:**
```cpp
myServo.writeMicroseconds(1500);  // Exact center
```

### Servo Gotchas

- **Power:** NEVER power servos from the MCU's 5V/3.3V pin. Use a separate 5-6V supply. Even an SG90 can draw 500mA+ under load
- **Brown-out:** Servo stall current can brown-out your MCU. Separate power rails are essential
- **Jitter:** If servo jitters at rest, the PWM signal may be noisy. Add a 100-470μF capacitor on the servo power rails
- **SG90 quality:** Cheap SG90 clones have terrible accuracy. The dead band and range vary between units
- **Continuous rotation servos:** Modified servos that spin freely. `write(90)` = stop, `write(0)` = full CCW, `write(180)` = full CW
- **ESP32 Servo library:** The standard Arduino `Servo.h` doesn't work on ESP32. Use `ESP32Servo` library
- **Angle limits:** Don't command angles beyond the servo's physical range — it'll stall and draw max current

---

## Stepper Motors

### How Steppers Work

Stepper motors move in discrete steps (typically 200 steps/revolution = 1.8°/step). Energizing coils in sequence rotates the shaft by precise amounts without feedback.

### Types

**Bipolar** (4 wires): More torque, requires H-bridge driver. Examples: NEMA17.
**Unipolar** (5 or 6 wires): Simpler to drive, less torque. Examples: 28BYJ-48.

### NEMA 17 + A4988/DRV8825 Driver

NEMA 17 is the standard stepper for 3D printers, CNC, and robotics. 1.8°/step, typically 1.5-2A per phase.

#### A4988 Stepper Driver

**Specs:** Up to 2A/phase (with cooling), 8-35V, 1/16 microstepping.

**Wiring:**
```
A4988 Pin       Connection
---------       ----------
VMOT            Motor power supply (8-35V)
GND (motor)     Ground
2B, 2A          Stepper coil 2
1A, 1B          Stepper coil 1
VDD             3.3V or 5V (logic supply)
GND (logic)     Ground
STEP            GPIO — pulse to step
DIR             GPIO — direction
ENABLE          GPIO or GND (LOW = enabled)
MS1/MS2/MS3     Microstepping selection (see table)
RESET           Tie to SLEEP if not used
SLEEP           Tie to RESET if not used
```

**Microstepping (A4988):**
| MS1 | MS2 | MS3 | Step Mode   |
|-----|-----|-----|-------------|
| LOW | LOW | LOW | Full step   |
| HIGH| LOW | LOW | 1/2 step    |
| LOW | HIGH| LOW | 1/4 step    |
| HIGH| HIGH| LOW | 1/8 step    |
| HIGH| HIGH| HIGH| 1/16 step   |

**CRITICAL: Set current limit** before connecting stepper. Measure voltage on the potentiometer's wiper:
```
Vref = Imax × 8 × Rsense
(Rsense is typically 0.068Ω or 0.1Ω — check your board)

For 1A limit with 0.1Ω sense resistors:
Vref = 1.0 × 8 × 0.1 = 0.8V
```

Adjust the potentiometer until you measure that voltage. **Do this before powering the stepper or you risk burning the driver.**

**Arduino Example:**
```cpp
#define STEP_PIN 25
#define DIR_PIN  26
#define ENABLE_PIN 27

void setup() {
    pinMode(STEP_PIN, OUTPUT);
    pinMode(DIR_PIN, OUTPUT);
    pinMode(ENABLE_PIN, OUTPUT);
    digitalWrite(ENABLE_PIN, LOW);  // Enable driver
}

void moveSteps(int steps, bool clockwise, int delayUs) {
    digitalWrite(DIR_PIN, clockwise ? HIGH : LOW);
    for (int i = 0; i < steps; i++) {
        digitalWrite(STEP_PIN, HIGH);
        delayMicroseconds(delayUs);
        digitalWrite(STEP_PIN, LOW);
        delayMicroseconds(delayUs);
    }
}

void loop() {
    moveSteps(200, true, 1000);   // One revolution CW, 1ms per step
    delay(1000);
    moveSteps(200, false, 1000);  // One revolution CCW
    delay(1000);
}
```

#### DRV8825 — Higher Current Alternative

**Specs:** Up to 2.5A/phase, 8.2-45V, 1/32 microstepping. Pin-compatible with A4988.

Same wiring as A4988. Current limit formula:
```
Vref = Imax / 2
For 1.5A: Vref = 0.75V
```

#### TMC2209 — Silent Stepper Driver

**Specs:** Up to 2.8A (peak), 4.75-29V, up to 1/256 microstepping, StealthChop (silent), UART configuration.

**Advantages:**
- Nearly silent operation (StealthChop mode)
- Sensorless homing via StallGuard
- UART interface for runtime configuration
- Much cooler operation than A4988/DRV8825

**UART Configuration (Arduino):**
```cpp
#include <TMCStepper.h>

#define SERIAL_PORT Serial2
#define DRIVER_ADDRESS 0b00  // MS1/MS2 set address
#define R_SENSE 0.11f

TMC2209Stepper driver(&SERIAL_PORT, R_SENSE, DRIVER_ADDRESS);

void setup() {
    SERIAL_PORT.begin(115200);
    driver.begin();
    driver.toff(4);           // Enable driver
    driver.rms_current(800);  // Set current in mA
    driver.microsteps(16);    // Set microstepping
    driver.pwm_autoscale(true);
    driver.en_spreadCycle(false); // StealthChop mode
}
```

**Library:** `TMCStepper`

### 28BYJ-48 + ULN2003 Driver

**Specs:** 5V unipolar stepper, 4096 steps/revolution (with internal gearing), very low speed, ~5 RPM max.

**Wiring:**
```
ULN2003 Board    Connection
-------------    ----------
IN1-IN4          4 GPIO pins
VCC              5V (separate supply recommended)
GND              Ground
Motor connector  28BYJ-48 (keyed, can only fit one way)
```

**Arduino (using Stepper library):**
```cpp
#include <Stepper.h>

// 2048 steps per revolution in full-step mode
// Wire order matters: IN1, IN3, IN2, IN4
Stepper stepper(2048, 16, 18, 17, 19);

void setup() {
    stepper.setSpeed(10);  // RPM (max ~15)
}

void loop() {
    stepper.step(2048);   // One revolution
    delay(1000);
    stepper.step(-2048);  // Reverse
    delay(1000);
}
```

**Better option:** Use `AccelStepper` library for acceleration/deceleration:
```cpp
#include <AccelStepper.h>

AccelStepper stepper(AccelStepper::HALF4WIRE, 16, 18, 17, 19);

void setup() {
    stepper.setMaxSpeed(1000);
    stepper.setAcceleration(500);
}

void loop() {
    stepper.moveTo(2048);
    while (stepper.distanceToGo() != 0) {
        stepper.run();
    }
}
```

**28BYJ-48 Gotchas:**
- Pin order is NOT sequential — use IN1, IN3, IN2, IN4 (library-dependent)
- Very slow — designed for positioning, not speed
- Draws ~240mA — use external power, not MCU pin
- Internal gearing has backlash — not suitable for precision work
- 5V only — don't run at 3.3V

---

## Brushless DC (BLDC) Motors + ESC

### Overview

BLDC motors are used in drones, electric vehicles, and high-speed applications. They require an Electronic Speed Controller (ESC) to commutate the three phases.

### ESC Control

ESCs accept the same 50Hz PWM servo signal:
- **1000μs** = Minimum throttle (stopped)
- **1500μs** = Mid throttle
- **2000μs** = Maximum throttle

**Arduino:**
```cpp
#include <ESP32Servo.h>

Servo esc;

void setup() {
    esc.attach(18, 1000, 2000);  // Pin, min μs, max μs

    // ESC arming sequence (varies by ESC)
    esc.writeMicroseconds(1000);  // Send minimum throttle
    delay(3000);                   // Wait for ESC to arm (beep sequence)
}

void loop() {
    esc.writeMicroseconds(1200);  // Low speed
    delay(3000);
    esc.writeMicroseconds(1500);  // Medium speed
    delay(3000);
    esc.writeMicroseconds(1000);  // Stop
    delay(3000);
}
```

### BLDC Gotchas

- **ESC arming:** Every ESC has an arming sequence. Usually: power on with throttle at minimum, wait for confirmation beeps
- **Dangerous:** BLDC motors + propellers can cause serious injury. Remove props during testing
- **Back-EMF:** Stopping quickly generates voltage — ESC handles this but be aware for power supply sizing
- **BEC:** Many ESCs include a Battery Eliminator Circuit that outputs 5V to power your flight controller/MCU
- **Calibration:** ESCs need throttle range calibration. Procedure: full throttle on power-up, then minimum throttle after beeps

---

## Motor Selection Guide

| Application              | Motor Type   | Driver         | Notes                      |
|--------------------------|-------------|----------------|----------------------------|
| Wheels (robot)           | DC motor     | L298N/DRV8833  | Simple, bidirectional      |
| Pan/tilt camera mount    | Servo        | Direct PWM     | Position feedback built-in |
| 3D printer axis          | NEMA17       | TMC2209        | Precise positioning        |
| Valve/dial positioning   | 28BYJ-48     | ULN2003        | Cheap, slow, adequate      |
| Drone propulsion         | BLDC         | ESC            | High speed, high power     |
| Pump (peristaltic)       | DC motor     | MOSFET/H-bridge| Speed control via PWM      |
| Linear actuator          | DC motor     | Relay/H-bridge | Usually just fwd/rev       |

## Power Considerations

- **Stall current** is 5-10x running current. Size your driver and power supply for stall current
- **Decoupling:** Add large capacitors (100-1000μF) on motor power rails to absorb voltage spikes
- **Separate power rails:** Motor power should be separate from logic power. Share only GND
- **Fuse protection:** Always fuse the motor power supply
- **Snubber diodes:** For DC motors without an H-bridge, add a flyback diode across the motor terminals
