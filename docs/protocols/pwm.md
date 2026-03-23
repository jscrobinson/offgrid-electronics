# PWM (Pulse Width Modulation)

## Overview

PWM is a technique for controlling the average power delivered to a load by rapidly switching a digital output between HIGH and LOW. By varying the ratio of ON time to OFF time (duty cycle), you can simulate analog output levels using a digital pin.

```
100% Duty Cycle (always ON):
──────────────────────────────────

75% Duty Cycle:
┌───────┐   ┌───────┐   ┌───────┐
│       └─┐ │       └─┐ │       └─┐

50% Duty Cycle:
┌────┐    ┌────┐    ┌────┐    ┌────┐
│    └────┘    └────┘    └────┘    └─

25% Duty Cycle:
┌──┐      ┌──┐      ┌──┐      ┌──┐
│  └──────┘  └──────┘  └──────┘  └──

0% Duty Cycle (always OFF):
_________________________________
```

**Key concepts:**
- **Duty cycle:** Percentage of time the signal is HIGH (0-100%)
- **Frequency:** How many complete ON/OFF cycles per second (Hz)
- **Resolution:** Number of discrete duty cycle steps (e.g., 8-bit = 256 steps)
- **Period:** 1 / frequency (total time for one cycle)

---

## Duty Cycle

```
        ┌─────────┐              ┌─────────┐
        │  T_on   │    T_off     │  T_on   │
   ─────┘         └──────────────┘         └──────

   Duty Cycle = T_on / (T_on + T_off) = T_on / T_period

   Average Voltage = Duty Cycle × V_high
```

| Duty Cycle | Average Voltage (5V) | Average Voltage (3.3V) |
|-----------|---------------------|------------------------|
| 0%        | 0 V                 | 0 V                    |
| 25%       | 1.25 V              | 0.825 V                |
| 50%       | 2.5 V               | 1.65 V                 |
| 75%       | 3.75 V              | 2.475 V                |
| 100%      | 5.0 V               | 3.3 V                  |

---

## Frequency Selection

The right frequency depends on the application:

| Application            | Typical Frequency  | Why                                      |
|-----------------------|-------------------|------------------------------------------|
| LED dimming           | 500 Hz - 5 kHz    | Above flicker perception (~100 Hz)       |
| Servo control         | 50 Hz              | Standard RC servo protocol               |
| DC motor speed        | 1 kHz - 20 kHz    | Above audible range preferred (>18 kHz)  |
| Audio generation      | Varies             | PWM frequency >> audio frequency         |
| Power supplies (SMPS) | 50 kHz - 500 kHz   | High efficiency, small inductors         |
| Heating elements      | 1 Hz - 10 Hz       | Slow thermal response, relay-safe        |
| Fan speed control     | 25 kHz              | PC fan standard (Intel 4-wire spec)      |

**Rules of thumb:**
- Motor/LED: Use the highest frequency your hardware supports without losing resolution. Higher frequency = less audible noise, smoother operation
- Servo: Must be exactly 50 Hz (20 ms period). Other frequencies may damage servos
- If you hear whining from a motor driver, the PWM frequency is in the audible range. Increase it above 18-20 kHz

---

## Resolution

Resolution determines how many discrete steps of duty cycle are available.

| Resolution | Steps | Example Use                |
|-----------|-------|----------------------------|
| 8-bit     | 256   | Arduino analogWrite()      |
| 10-bit    | 1024  | Arduino Mega Timer1        |
| 12-bit    | 4096  | STM32, some ESP32 configs  |
| 16-bit    | 65536 | STM32 advanced timers      |

**Resolution vs Frequency tradeoff (ESP32 example):**

The timer clock is divided into steps. More resolution means fewer available frequencies:
```
Max Frequency = Timer Clock / 2^resolution

ESP32 at 80 MHz APB clock:
  8-bit:  80 MHz / 256 = 312.5 kHz max
  10-bit: 80 MHz / 1024 = 78.125 kHz max
  12-bit: 80 MHz / 4096 = 19.53 kHz max
  16-bit: 80 MHz / 65536 = 1.22 kHz max
```

Choose resolution based on your needs. For LED dimming, 8-bit (256 steps) is usually enough. For precision motor control, use 10-12 bit.

---

## Hardware PWM vs Software PWM

### Hardware PWM

The MCU's timer peripheral generates the PWM signal autonomously. Once configured, the CPU does nothing — the timer toggles the pin automatically.

**Pros:**
- Precise, jitter-free timing
- Zero CPU overhead after setup
- Higher frequencies possible
- Consistent even during interrupts

**Cons:**
- Limited to specific pins (tied to timer outputs)
- Limited number of channels (depends on MCU timers)

### Software PWM

The CPU manually toggles GPIO pins in a loop or interrupt routine.

**Pros:**
- Any GPIO pin can be used
- Unlimited channels (limited by CPU time)

**Cons:**
- Jitter from interrupts and other tasks
- Consumes CPU time
- Lower practical frequency/resolution
- Not suitable for motor control or high-frequency applications

**Always use hardware PWM when available.** Software PWM is a last resort for non-critical tasks like LED indication.

---

## Arduino PWM

### analogWrite() — Basic PWM

```cpp
// 8-bit resolution (0-255), fixed frequency
analogWrite(pin, dutyCycle);  // dutyCycle: 0 (off) to 255 (full on)

// Example: LED at 50% brightness
analogWrite(9, 127);

// Example: Fade an LED
void loop() {
    for (int i = 0; i <= 255; i++) {
        analogWrite(9, i);
        delay(5);
    }
    for (int i = 255; i >= 0; i--) {
        analogWrite(9, i);
        delay(5);
    }
}
```

### Arduino PWM Pins and Frequencies

**Arduino Uno/Nano (ATmega328P):**

| Pins  | Timer   | Default Frequency | Notes                    |
|-------|---------|-------------------|--------------------------|
| 5, 6  | Timer0  | 976 Hz            | Shared with millis()/delay() — changing frequency breaks timing! |
| 9, 10 | Timer1  | 490 Hz            | 16-bit timer, can be reconfigured |
| 3, 11 | Timer2  | 490 Hz            | 8-bit timer              |

**Arduino Mega:**

| Pins      | Timer   | Default Frequency |
|-----------|---------|-------------------|
| 4, 13    | Timer0  | 976 Hz            |
| 11, 12   | Timer1  | 490 Hz            |
| 9, 10    | Timer2  | 490 Hz            |
| 2, 3, 5  | Timer3  | 490 Hz            |
| 6, 7, 8  | Timer4  | 490 Hz            |
| 44, 45, 46| Timer5 | 490 Hz            |

### Changing Arduino PWM Frequency

Modify the timer prescaler to change frequency. This affects ALL pins on that timer.

```cpp
// Timer1 (pins 9, 10) frequency options on Uno:
// Prescaler 1:    31372 Hz
// Prescaler 8:     3921 Hz
// Prescaler 64:     490 Hz (default)
// Prescaler 256:    122 Hz
// Prescaler 1024:    30 Hz

// Set Timer1 prescaler to 8 (3921 Hz) — for pins 9, 10
TCCR1B = (TCCR1B & 0b11111000) | 0x02;

// Set Timer2 prescaler to 1 (31372 Hz) — for pins 3, 11
TCCR2B = (TCCR2B & 0b11111000) | 0x01;

// WARNING: Changing Timer0 prescaler breaks millis(), delay(), etc.
```

---

## ESP32 LEDC (PWM)

The ESP32 has a dedicated LED Control (LEDC) peripheral with 16 independent PWM channels (8 high-speed, 8 low-speed). Any GPIO can output PWM.

### ESP32 Arduino Framework (v2.x / v3.x)

**Arduino-ESP32 v3.x (simplified API):**

```cpp
// v3.x API — analogWrite works directly
void setup() {
    // Optional: configure frequency and resolution
    analogWriteFrequency(25000);  // Set PWM frequency (Hz) — all pins
    analogWriteResolution(10);     // Set resolution (bits) — all pins
}

void loop() {
    analogWrite(LED_PIN, 512);  // 50% at 10-bit resolution (0-1023)
}
```

**Arduino-ESP32 v2.x (LEDC API):**

```cpp
#define LED_PIN     2
#define PWM_CHANNEL 0
#define PWM_FREQ    5000    // 5 kHz
#define PWM_RES     8       // 8-bit resolution (0-255)

void setup() {
    ledcSetup(PWM_CHANNEL, PWM_FREQ, PWM_RES);
    ledcAttachPin(LED_PIN, PWM_CHANNEL);
}

void loop() {
    // Fade LED
    for (int duty = 0; duty <= 255; duty++) {
        ledcWrite(PWM_CHANNEL, duty);
        delay(5);
    }
    for (int duty = 255; duty >= 0; duty--) {
        ledcWrite(PWM_CHANNEL, duty);
        delay(5);
    }
}
```

### ESP32 LEDC Details

- 16 channels: 0-7 (high speed, 80 MHz clock), 8-15 (low speed, 1 MHz or 8 MHz clock)
- Any GPIO output pin can be assigned to any channel
- Multiple pins can share one channel (same duty cycle and frequency)
- Frequency and resolution are per-channel
- Hardware fade support (automatic duty cycle ramping)

### ESP32 Hardware Fade

```cpp
// Automatic fade using LEDC hardware (no CPU involvement)
ledcSetup(0, 5000, 8);
ledcAttachPin(LED_PIN, 0);

// Fade to target duty over time
ledcFadeWithTime(0, 0, 255, 3000);    // Channel 0: fade from 0 to 255 over 3 seconds
// or
ledcFadeWithStep(0, 0, 255, 1, 10);   // Channel 0: fade from 0 to 255, step 1, every 10 cycles
```

---

## Servo Control

Standard RC servos use a specific PWM signal:

```
                 ┌─────┐
50 Hz (20ms)     │1-2ms│
─────────────────┘     └──────────────────────

Position mapping:
1.0 ms pulse → 0°   (full left)
1.5 ms pulse → 90°  (center)
2.0 ms pulse → 180° (full right)

Some servos accept 0.5-2.5 ms for extended range.
```

**Requirements:**
- Frequency: 50 Hz (20 ms period) — MUST be 50 Hz for standard servos
- Pulse width: 1.0 ms to 2.0 ms (duty cycle ~5% to ~10% at 50 Hz)
- Voltage: 4.8-6.0 V for the servo motor (NOT from MCU pin — use separate power)

### Arduino Servo Library

```cpp
#include <Servo.h>

Servo myServo;

void setup() {
    myServo.attach(9);  // Attach to pin 9
}

void loop() {
    myServo.write(0);     // Move to 0°
    delay(1000);
    myServo.write(90);    // Move to 90°
    delay(1000);
    myServo.write(180);   // Move to 180°
    delay(1000);
}
```

**Note:** The Servo library uses Timer1 on Uno, which disables analogWrite() on pins 9 and 10.

### ESP32 Servo Control

```cpp
// Using LEDC for servo on ESP32
#define SERVO_PIN    18
#define SERVO_CH     0
#define SERVO_FREQ   50     // 50 Hz for servos
#define SERVO_RES    16     // 16-bit for fine control

void setup() {
    ledcSetup(SERVO_CH, SERVO_FREQ, SERVO_RES);
    ledcAttachPin(SERVO_PIN, SERVO_CH);
}

// Convert angle (0-180) to duty cycle value
uint32_t angleToDuty(int angle) {
    // 1ms = 0°, 2ms = 180° at 50Hz with 16-bit resolution
    // 1ms / 20ms * 65536 = 3277
    // 2ms / 20ms * 65536 = 6554
    return map(angle, 0, 180, 3277, 6554);
}

void loop() {
    ledcWrite(SERVO_CH, angleToDuty(0));
    delay(1000);
    ledcWrite(SERVO_CH, angleToDuty(90));
    delay(1000);
    ledcWrite(SERVO_CH, angleToDuty(180));
    delay(1000);
}
```

Or use the ESP32Servo library: `#include <ESP32Servo.h>` which provides the same API as the Arduino Servo library.

---

## DC Motor Control with PWM

### Basic Motor Control (MOSFET)

For a single-direction motor, use an N-channel MOSFET:

```
             V_motor (12V, etc.)
                  │
              [Motor]
                  │
                Drain
MCU PWM ──[1kΩ]── Gate    N-MOSFET (IRLZ44N, IRF540, etc.)
                Source
                  │
                 GND

+ Flyback diode across motor (cathode to V+, anode to Drain)
```

**MOSFET selection:**
- Logic-level gate (Vgs_th < 3.3V for ESP32, < 5V for Arduino): IRLZ44N, IRL540N, AO3400
- Standard MOSFETs (need 10V gate drive): IRF540, IRF3205 — need a gate driver with 5V MCU

### H-Bridge Motor Control (Bidirectional)

Use an H-bridge driver IC for bidirectional motor control:

**L298N:**
```cpp
#define ENA 9   // PWM speed control
#define IN1 8   // Direction
#define IN2 7   // Direction

void setup() {
    pinMode(ENA, OUTPUT);
    pinMode(IN1, OUTPUT);
    pinMode(IN2, OUTPUT);
}

void motorForward(int speed) {  // speed: 0-255
    digitalWrite(IN1, HIGH);
    digitalWrite(IN2, LOW);
    analogWrite(ENA, speed);
}

void motorReverse(int speed) {
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, HIGH);
    analogWrite(ENA, speed);
}

void motorStop() {
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, LOW);
    analogWrite(ENA, 0);
}
```

**Common motor driver ICs:**

| Driver    | Voltage    | Current (per ch) | PWM Freq  | Notes                          |
|-----------|-----------|-------------------|-----------|--------------------------------|
| L298N     | 5-35V     | 2A               | 25 kHz    | Cheap, inefficient (1.4V drop) |
| L293D     | 4.5-36V   | 600 mA           | 5 kHz     | Low current, built-in diodes   |
| TB6612FNG | 2.5-13.5V | 1.2A (3.2A peak) | 100 kHz   | Efficient, small, recommended  |
| DRV8833   | 2.7-10.8V | 1.5A             | 250 kHz   | Good for small robots          |
| DRV8871   | 6.5-45V   | 3.6A             | 200 kHz   | Single channel, simple         |
| BTS7960   | 5.5-27V   | 43A              | 25 kHz    | High power, half-bridge module |
| IBT-2     | 6-27V     | 43A              | 25 kHz    | BTS7960-based full module      |

**PWM frequency for motors:**
- Below 1 kHz: Audible whining
- 1-18 kHz: Audible buzzing, decreasing
- 20+ kHz: Silent operation (above human hearing)
- Too high: Switching losses increase, driver may not support it

---

## LED Dimming with PWM

### Linear vs Perceived Brightness

Human eyes perceive brightness logarithmically, not linearly. A 50% duty cycle does NOT look like 50% brightness — it looks much brighter.

**Gamma correction for natural-looking LED fading:**

```cpp
// Gamma correction lookup table (gamma = 2.2)
const uint8_t gamma8[] = {
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,
    1,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,
    2,  3,  3,  3,  3,  3,  3,  3,  4,  4,  4,  4,  4,  5,  5,  5,
    5,  6,  6,  6,  6,  7,  7,  7,  7,  8,  8,  8,  9,  9,  9, 10,
   10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16,
   17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 24, 24, 25,
   25, 26, 27, 27, 28, 29, 29, 30, 31, 32, 32, 33, 34, 35, 35, 36,
   37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 50,
   51, 52, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68,
   69, 70, 72, 73, 74, 75, 77, 78, 79, 81, 82, 83, 85, 86, 87, 89,
   90, 92, 93, 95, 96, 98, 99,101,102,104,105,107,109,110,112,114,
  115,117,119,120,122,124,126,127,129,131,133,135,137,138,140,142,
  144,146,148,150,152,154,156,158,160,162,164,167,169,171,173,175,
  177,180,182,184,186,189,191,193,196,198,200,203,205,208,210,213,
  215,218,220,223,225,228,231,233,236,239,241,244,247,249,252,255
};

// Use it:
analogWrite(LED_PIN, gamma8[brightness]);  // brightness: 0-255
```

### PWM for RGB LEDs

```cpp
#define RED_PIN   9
#define GREEN_PIN 10
#define BLUE_PIN  11

void setColor(uint8_t r, uint8_t g, uint8_t b) {
    // For common-anode RGB LEDs, invert the values
    // analogWrite(RED_PIN, 255 - r);

    // For common-cathode:
    analogWrite(RED_PIN, r);
    analogWrite(GREEN_PIN, g);
    analogWrite(BLUE_PIN, b);
}
```

---

## PCA9685 — 16-Channel PWM Driver (I2C)

When you need more PWM channels than your MCU provides, the PCA9685 adds 16 channels of 12-bit PWM over I2C.

```cpp
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();  // Default address 0x40

void setup() {
    pwm.begin();
    pwm.setPWMFreq(50);  // 50 Hz for servos (or 1000 for LEDs)
}

void loop() {
    // Set channel 0 to 50% duty
    pwm.setPWM(0, 0, 2048);  // 12-bit: 0-4095

    // For servo on channel 0 (pulse 1ms-2ms at 50 Hz):
    // 1ms = 4096 * (1/20) = 205
    // 2ms = 4096 * (2/20) = 410
    pwm.setPWM(0, 0, 307);  // ~1.5ms = center
}
```

---

## Raspberry Pi PWM

### Hardware PWM (Limited)

Raspberry Pi has only 2 hardware PWM channels:
- PWM0: GPIO 12 or GPIO 18
- PWM1: GPIO 13 or GPIO 19

### pigpio Library (Recommended)

pigpio provides hardware-timed PWM on any GPIO with excellent accuracy:

```python
import pigpio

pi = pigpio.pi()

# Hardware PWM (GPIO 18, 25kHz, 50% duty)
pi.hardware_PWM(18, 25000, 500000)  # frequency Hz, duty 0-1000000

# Software PWM on any pin (less precise but usually adequate)
pi.set_PWM_frequency(17, 1000)    # 1 kHz
pi.set_PWM_range(17, 255)         # 0-255 range
pi.set_PWM_dutycycle(17, 128)     # 50% duty

# Servo control
pi.set_servo_pulsewidth(18, 1500)  # 1500 us = center position
# 0 = off, 500-2500 = servo range

pi.stop()
```

Install: `sudo apt install pigpio python3-pigpio` then `sudo pigpiod`

### RPi.GPIO PWM (Basic)

```python
import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)
GPIO.setup(18, GPIO.OUT)

pwm = GPIO.PWM(18, 1000)  # Pin 18, 1 kHz
pwm.start(50)              # 50% duty cycle

pwm.ChangeDutyCycle(75)    # Change to 75%
pwm.ChangeFrequency(2000)  # Change to 2 kHz

pwm.stop()
GPIO.cleanup()
```

Note: RPi.GPIO uses software PWM — it can have jitter. Use pigpio for better precision.

---

## Troubleshooting

| Problem                     | Likely Cause                         | Fix                                    |
|----------------------------|--------------------------------------|----------------------------------------|
| LED flickers               | PWM frequency too low                | Increase to 1+ kHz                     |
| Motor whines/buzzes        | PWM frequency in audible range       | Increase to 20+ kHz                    |
| Servo jitters              | Unstable PWM signal (software PWM)   | Use hardware PWM or Servo library      |
| Servo doesn't move         | Wrong frequency (not 50 Hz)          | Set exactly 50 Hz                      |
| Motor runs at wrong speed  | Non-linear MOSFET response           | Ensure MOSFET is fully enhanced (Vgs)  |
| PWM output is always HIGH  | Duty cycle set to max / pin config   | Check duty value and pin mode          |
| analogWrite has no effect  | Pin doesn't support PWM              | Check PWM-capable pins for your board  |
| Timer conflict             | Two libraries using same timer       | Reassign pins to different timers      |
| millis() broken after changing freq | Changed Timer0 prescaler    | Don't modify Timer0, use Timer1/Timer2 |
