# Arduino Interrupts and Timers

## Hardware Interrupts

Hardware interrupts allow the processor to immediately respond to external events by pausing the main program and executing an Interrupt Service Routine (ISR).

### Available External Interrupt Pins

| Board | INT0 | INT1 | INT2 | INT3 | INT4 | INT5 |
|-------|------|------|------|------|------|------|
| Uno/Nano | Pin 2 | Pin 3 | - | - | - | - |
| Mega 2560 | Pin 2 | Pin 3 | Pin 21 | Pin 20 | Pin 19 | Pin 18 |

### attachInterrupt()

```cpp
attachInterrupt(digitalPinToInterrupt(pin), ISR_function, mode);
```

**Trigger modes:**

| Mode | Triggers when... |
|------|-----------------|
| `LOW` | Pin is LOW (fires continuously while low) |
| `CHANGE` | Pin changes state (rising or falling) |
| `RISING` | Pin goes from LOW to HIGH |
| `FALLING` | Pin goes from HIGH to LOW |

**Always use `digitalPinToInterrupt(pin)`** to convert the pin number to the interrupt number. Do not hardcode interrupt numbers — they differ between boards.

### Basic Interrupt Example

```cpp
const int BUTTON_PIN = 2;

volatile bool buttonPressed = false;  // MUST be volatile

void setup() {
    Serial.begin(9600);
    pinMode(BUTTON_PIN, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(BUTTON_PIN), buttonISR, FALLING);
}

void buttonISR() {
    buttonPressed = true;  // Set flag, do NOT do heavy work here
}

void loop() {
    if (buttonPressed) {
        buttonPressed = false;
        Serial.println(F("Button pressed!"));
        // Do your actual work here in the main loop
    }
}
```

### ISR Best Practices

**1. Keep ISRs as short as possible.**

The processor disables all other interrupts while an ISR is running. Long ISRs cause missed interrupts, broken millis() timing, and serial data loss.

```cpp
// GOOD: Set a flag, handle in loop()
volatile bool dataReady = false;

void myISR() {
    dataReady = true;
}

// BAD: Doing real work in the ISR
void myISR() {
    int value = analogRead(A0);    // ~100us - too slow!
    Serial.println(value);         // NEVER use Serial in ISR
    delay(10);                     // NEVER use delay in ISR
}
```

**2. Use `volatile` for shared variables.**

The `volatile` keyword tells the compiler that a variable can change at any time (from an ISR), preventing dangerous optimizations.

```cpp
volatile int encoderCount = 0;   // Shared between ISR and loop()
volatile unsigned long lastPulseTime = 0;

void encoderISR() {
    encoderCount++;
    lastPulseTime = micros();
}

void loop() {
    // Disable interrupts while reading multi-byte volatile variables
    noInterrupts();
    int count = encoderCount;
    unsigned long pulseTime = lastPulseTime;
    interrupts();

    Serial.println(count);
}
```

**Why `noInterrupts()` for reading?** On an 8-bit AVR, a 16-bit or 32-bit variable is read in multiple clock cycles. An interrupt could fire between those cycles, changing the value mid-read (called a "torn read"). Disabling interrupts briefly prevents this.

**3. What you CANNOT do in an ISR:**

| Function | Problem |
|----------|---------|
| `delay()` | Depends on interrupts, which are disabled |
| `millis()` | Returns stale value (no updates during ISR) but won't crash |
| `Serial.print()` | Uses interrupts internally, may corrupt data |
| `analogRead()` | Takes ~100 us, too slow |
| `digitalWrite()` | OK but slow; direct port manipulation is better |
| `tone()` | Uses Timer interrupts |

`micros()` works in an ISR on AVR but the value may be imprecise.

**4. Detaching interrupts:**

```cpp
detachInterrupt(digitalPinToInterrupt(2));  // Stop responding to interrupt
```

### Interrupt Debouncing

Mechanical buttons generate electrical noise (bouncing) that triggers multiple interrupts per press.

```cpp
volatile unsigned long lastInterruptTime = 0;

void buttonISR() {
    unsigned long now = micros();
    if (now - lastInterruptTime > 200000) {  // 200ms debounce (in microseconds)
        // Valid press
        buttonPressed = true;
    }
    lastInterruptTime = now;
}
```

Alternatively, debounce in hardware with a 100nF capacitor across the switch contacts, or debounce in the main loop using millis().

### Rotary Encoder Example

Rotary encoders are a common use case for interrupts.

```cpp
const int ENCODER_A = 2;  // Must be interrupt pin
const int ENCODER_B = 3;  // Must be interrupt pin

volatile long encoderPosition = 0;

void setup() {
    Serial.begin(115200);
    pinMode(ENCODER_A, INPUT_PULLUP);
    pinMode(ENCODER_B, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(ENCODER_A), encoderA_ISR, CHANGE);
    attachInterrupt(digitalPinToInterrupt(ENCODER_B), encoderB_ISR, CHANGE);
}

void encoderA_ISR() {
    if (digitalRead(ENCODER_A) == digitalRead(ENCODER_B)) {
        encoderPosition++;
    } else {
        encoderPosition--;
    }
}

void encoderB_ISR() {
    if (digitalRead(ENCODER_A) != digitalRead(ENCODER_B)) {
        encoderPosition++;
    } else {
        encoderPosition--;
    }
}

void loop() {
    noInterrupts();
    long pos = encoderPosition;
    interrupts();

    Serial.println(pos);
    delay(100);
}
```

---

## Pin Change Interrupts

Beyond the dedicated external interrupt pins, AVR microcontrollers support Pin Change Interrupts (PCINT) on every I/O pin. These are grouped into port-based vectors and require more code to determine which pin triggered.

```cpp
// Using the EnableInterrupt library (recommended)
#include <EnableInterrupt.h>

void setup() {
    pinMode(A0, INPUT_PULLUP);
    enableInterrupt(A0, myISR, FALLING);
}

void myISR() {
    // Triggered on A0 falling edge
}
```

Without a library, you must configure PCINT registers manually:

```cpp
// Enable PCINT on pin A0 (PCINT8, port C, bit 0)
void setup() {
    pinMode(A0, INPUT_PULLUP);
    PCICR |= (1 << PCIE1);       // Enable PCINT[14:8] (port C)
    PCMSK1 |= (1 << PCINT8);     // Enable PCINT8 (A0)
}

ISR(PCINT1_vect) {
    // This fires for ANY pin change on port C (A0-A5)
    // You must check which pin changed
    static byte lastState = 0xFF;
    byte currentState = PINC;
    byte changed = lastState ^ currentState;
    lastState = currentState;

    if (changed & (1 << 0)) {  // A0 changed
        if (!(currentState & (1 << 0))) {
            // A0 went LOW (falling edge)
        }
    }
}
```

---

## Timer Interrupts

The ATmega328P has three hardware timers that can generate periodic interrupts independently of the main loop.

### Timer Overview (ATmega328P / Uno / Nano)

| Timer | Bits | Used By | Output Pins |
|-------|------|---------|-------------|
| Timer0 | 8-bit | `millis()`, `micros()`, `delay()`, PWM 5/6 | OC0A (pin 6), OC0B (pin 5) |
| Timer1 | 16-bit | Servo library, PWM 9/10 | OC1A (pin 9), OC1B (pin 10) |
| Timer2 | 8-bit | `tone()`, PWM 3/11 | OC2A (pin 11), OC2B (pin 3) |

**Warning:** Modifying Timer0 breaks `millis()`, `micros()`, and `delay()`. Avoid unless you really know what you are doing.

### Timer1 — 16-bit Timer (Recommended for User Interrupts)

```cpp
// Manual configuration: 1 Hz interrupt (1 second period)
void setup() {
    Serial.begin(9600);

    noInterrupts();          // Disable interrupts during config

    TCCR1A = 0;             // Clear control registers
    TCCR1B = 0;
    TCNT1 = 0;              // Clear counter

    // Set CTC mode (Clear Timer on Compare Match)
    TCCR1B |= (1 << WGM12);

    // Set prescaler to 256
    TCCR1B |= (1 << CS12);

    // Set compare match value: 16MHz / 256 / 1Hz - 1 = 62499
    OCR1A = 62499;

    // Enable Timer1 compare match interrupt
    TIMSK1 |= (1 << OCIE1A);

    interrupts();            // Re-enable interrupts
}

ISR(TIMER1_COMPA_vect) {
    // This runs exactly once per second
    // Keep it short! Set a flag if needed.
    digitalWrite(13, !digitalRead(13));  // Toggle LED
}

void loop() {
    // Main code runs uninterrupted
}
```

### Prescaler Reference

The timer clock is divided by the prescaler before counting.

**Timer frequency formula:** `f = F_CPU / (prescaler * (1 + OCR))`

**Rearranged to find OCR:** `OCR = (F_CPU / (prescaler * f)) - 1`

| Prescaler | Timer1 max period (16-bit) | Timer2 max period (8-bit) |
|-----------|---------------------------|---------------------------|
| 1 | 4.096 ms | 16 us |
| 8 | 32.768 ms | 128 us |
| 64 | 262.14 ms | 1.024 ms |
| 256 | 1.048 s | 4.096 ms |
| 1024 | 4.194 s | 16.384 ms |

### Common Timer1 Periods

| Desired Frequency | Prescaler | OCR1A Value | Actual Frequency |
|---|---|---|---|
| 1 Hz | 256 | 62499 | 1.000 Hz |
| 10 Hz | 256 | 6249 | 10.000 Hz |
| 100 Hz | 64 | 2499 | 100.000 Hz |
| 1 kHz | 8 | 1999 | 1.000 kHz |
| 10 kHz | 8 | 199 | 10.000 kHz |
| 100 kHz | 1 | 159 | 100.000 kHz |

### Using the TimerOne Library (Easier)

```cpp
#include <TimerOne.h>

void setup() {
    Timer1.initialize(1000000);    // Period in microseconds (1 second)
    Timer1.attachInterrupt(timerISR);
}

void timerISR() {
    digitalWrite(13, !digitalRead(13));
}

void loop() {
    // Your main code
}

// Change period dynamically:
Timer1.setPeriod(500000);  // 500ms
```

### Timer2 (8-bit)

Timer2 is often used for higher-frequency interrupts. Same concept as Timer1 but only 8-bit counter (0-255).

```cpp
// Timer2: ~1kHz interrupt
void setup() {
    noInterrupts();
    TCCR2A = 0;
    TCCR2B = 0;
    TCNT2 = 0;

    TCCR2A |= (1 << WGM21);         // CTC mode
    TCCR2B |= (1 << CS22);          // Prescaler 64
    OCR2A = 249;                     // 16MHz / 64 / 250 = 1kHz
    TIMSK2 |= (1 << OCIE2A);        // Enable compare match interrupt
    interrupts();
}

ISR(TIMER2_COMPA_vect) {
    // Runs at 1kHz
}
```

---

## Watchdog Timer

The watchdog timer resets the microcontroller if the main program hangs (infinite loop, deadlock, etc.). It is an independent timer with its own oscillator.

### Basic Watchdog Usage

```cpp
#include <avr/wdt.h>

void setup() {
    Serial.begin(9600);
    Serial.println(F("Starting up..."));

    wdt_enable(WDTO_2S);  // Enable watchdog, 2-second timeout
}

void loop() {
    wdt_reset();  // "Kick the dog" — must call within timeout period

    // Your normal code here
    readSensors();
    updateDisplay();
    // If any of these functions hangs, the watchdog will reset the board
}
```

### Watchdog Timeout Values

| Constant | Timeout |
|----------|---------|
| `WDTO_15MS` | 15 ms |
| `WDTO_30MS` | 30 ms |
| `WDTO_60MS` | 60 ms |
| `WDTO_120MS` | 120 ms |
| `WDTO_250MS` | 250 ms |
| `WDTO_500MS` | 500 ms |
| `WDTO_1S` | 1 second |
| `WDTO_2S` | 2 seconds |
| `WDTO_4S` | 4 seconds |
| `WDTO_8S` | 8 seconds |

### Watchdog as a Wake-Up Timer

The watchdog can wake the MCU from sleep mode, useful for low-power applications:

```cpp
#include <avr/sleep.h>
#include <avr/wdt.h>
#include <avr/power.h>

volatile bool watchdogFired = false;

ISR(WDT_vect) {
    watchdogFired = true;
}

void enterSleep() {
    // Configure watchdog for interrupt (not reset) mode
    noInterrupts();
    MCUSR &= ~(1 << WDRF);           // Clear watchdog reset flag
    WDTCSR |= (1 << WDCE) | (1 << WDE);  // Enable changes
    WDTCSR = (1 << WDIE) | (1 << WDP3) | (1 << WDP0);  // Interrupt mode, 8 seconds
    interrupts();

    set_sleep_mode(SLEEP_MODE_PWR_DOWN);
    sleep_enable();
    sleep_mode();       // Enters sleep here, wakes on watchdog interrupt

    sleep_disable();    // Execution continues here after wake
}

void loop() {
    // Do useful work
    readAndTransmitSensor();

    // Sleep for ~8 seconds
    enterSleep();
}
```

Power consumption in POWER_DOWN sleep: ~4.2 uA (ATmega328P without peripherals).

### Watchdog Pitfalls

1. **Old bootloaders and watchdog:** Some older Uno bootloaders do not properly disable the watchdog after reset, causing an infinite reset loop. The Optiboot bootloader (shipped with current Unos) handles this correctly. If you have an old board, burn the current Optiboot bootloader.

2. **Watchdog and Serial uploads:** If the watchdog fires during a serial upload, it will reset and abort the upload. Always disable the watchdog early in setup() if you are debugging:
   ```cpp
   void setup() {
       wdt_disable();  // Disable watchdog first thing
       // ... rest of setup
       wdt_enable(WDTO_2S);  // Re-enable after setup complete
   }
   ```

3. **Do not use delay() as your primary timing with watchdog.** If `delay(5000)` is in your loop and watchdog is set to 2 seconds, the board will reset during the delay. Use `millis()` instead and call `wdt_reset()` in the loop.

---

## Common Pitfalls Summary

| Pitfall | Consequence | Solution |
|---------|-------------|----------|
| Long ISR | Missed interrupts, broken millis() | Set flag in ISR, process in loop() |
| Serial in ISR | Corruption, hangs | Never use Serial in an ISR |
| delay() in ISR | Infinite hang (delay needs interrupts) | Never use delay() in an ISR |
| Forgetting volatile | Compiler optimizes out variable reads | Always declare shared variables volatile |
| Torn reads | Corrupted multi-byte values | Disable interrupts while reading shared multi-byte vars |
| Modifying Timer0 | millis() and delay() break | Use Timer1 or Timer2 instead |
| Too many interrupts | CPU spends all time in ISRs | Reduce interrupt frequency or use polling |
| Watchdog + old bootloader | Infinite reset loop | Burn current Optiboot bootloader |
| Floating interrupt pin | Random triggering | Use INPUT_PULLUP or external pull-up/down |
| Bouncing switches on interrupt | Multiple false triggers | Debounce in software or hardware |

---

## Interrupt Priority (ATmega328P)

When multiple interrupts fire simultaneously, they are serviced in order of vector number (lower = higher priority):

1. RESET (highest priority)
2. INT0 (External Interrupt 0, pin 2)
3. INT1 (External Interrupt 1, pin 3)
4. PCINT0 (Pin Change Interrupt, Port B)
5. PCINT1 (Pin Change Interrupt, Port C)
6. PCINT2 (Pin Change Interrupt, Port D)
7. WDT (Watchdog Timer)
8. TIMER2_COMPA
9. TIMER2_COMPB
10. TIMER2_OVF
11. TIMER1_CAPT (Input Capture)
12. TIMER1_COMPA
13. TIMER1_COMPB
14. TIMER1_OVF
15. TIMER0_COMPA
16. TIMER0_COMPB
17. TIMER0_OVF
18. SPI_STC (SPI Transfer Complete)
19. USART_RX (Serial Receive)
20. USART_UDRE (Serial Data Register Empty)
21. USART_TX (Serial Transmit)
22. ADC (ADC Conversion Complete)
23. EE_READY (EEPROM Ready)
24. ANALOG_COMP (Analog Comparator)
25. TWI (I2C)

Nested interrupts (interrupting an ISR) do not happen by default on AVR — interrupts are automatically disabled when entering an ISR. You can enable them manually with `interrupts()` inside an ISR, but this is rarely advisable.
