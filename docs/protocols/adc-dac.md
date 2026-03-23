# ADC and DAC — Analog-to-Digital and Digital-to-Analog Conversion

## Overview

**ADC (Analog-to-Digital Converter):** Converts a continuous analog voltage into a discrete digital number.
**DAC (Digital-to-Analog Converter):** Converts a digital number into an analog voltage.

```
Analog World                    Digital World
                  ┌─────┐
Sensor voltage ──►│ ADC │──► Digital value (0-1023, 0-4095, etc.)
                  └─────┘

                  ┌─────┐
Digital value ───►│ DAC │──► Analog voltage
                  └─────┘
```

---

## ADC Fundamentals

### Resolution

Resolution determines how many discrete levels the ADC can represent.

| Resolution | Levels | Example Platform          |
|-----------|--------|---------------------------|
| 8-bit     | 256    | ATtiny, some cheap ADCs   |
| 10-bit    | 1024   | Arduino Uno/Nano/Mega     |
| 12-bit    | 4096   | ESP32, STM32, SAM D21     |
| 16-bit    | 65536  | ADS1115 (external)        |
| 24-bit    | 16.7M  | HX711, ADS1256 (precision)|

**Voltage per step (LSB):**
```
Step size = V_ref / 2^n

Examples (V_ref = 3.3V):
  10-bit: 3.3V / 1024 = 3.22 mV per step
  12-bit: 3.3V / 4096 = 0.806 mV per step
  16-bit: 3.3V / 65536 = 0.050 mV per step
```

### Reference Voltage (Vref)

The ADC converts the input voltage relative to a reference voltage. The reference defines what voltage corresponds to the maximum digital value.

```
Digital value = (V_input / V_ref) × (2^n - 1)

V_input = (Digital value / (2^n - 1)) × V_ref
```

**Common reference sources:**
- **Vcc (supply voltage):** Simple but noisy and may drift. Arduino default
- **Internal reference:** Built into many MCUs (1.1V on ATmega328P, varies on others). More stable
- **External reference:** Dedicated voltage reference IC (e.g., REF3030 for 3.0V). Best accuracy

**Arduino reference options:**
```cpp
analogReference(DEFAULT);    // Vcc (5V on Uno, 3.3V on 3.3V boards)
analogReference(INTERNAL);   // 1.1V internal reference (ATmega328P)
analogReference(EXTERNAL);   // Voltage on AREF pin (DO NOT exceed Vcc!)
```

### Sampling Rate

How many conversions per second the ADC can perform.

| Platform           | Max Sample Rate | Notes                        |
|-------------------|----------------|------------------------------|
| Arduino Uno       | ~9.6 kHz        | 104 us per conversion        |
| Arduino Due       | ~1 MHz          | 12-bit SAR ADC               |
| ESP32             | ~6 kHz (Arduino)| Faster with IDF API (~2 MHz) |
| ADS1115           | 860 SPS         | High precision, slow         |
| ADS1256           | 30 kSPS         | 24-bit, very precise         |
| MCP3008 (SPI)     | 200 kSPS        | 10-bit, 8 channels           |

---

## Arduino ADC (ATmega328P)

### Basic Usage

```cpp
void setup() {
    Serial.begin(115200);
}

void loop() {
    int raw = analogRead(A0);           // 0-1023 (10-bit)
    float voltage = raw * (5.0 / 1023.0);  // Convert to voltage

    Serial.print("Raw: ");
    Serial.print(raw);
    Serial.print("  Voltage: ");
    Serial.print(voltage, 3);
    Serial.println(" V");

    delay(100);
}
```

**Arduino Uno analog pins:** A0-A5 (6 channels)
**Arduino Mega analog pins:** A0-A15 (16 channels)

### Improving Arduino ADC Accuracy

**1. Use the internal 1.1V reference for small signals:**
```cpp
analogReference(INTERNAL);  // 1.1V reference
// Now full scale (1023) = 1.1V
// Resolution: 1.1V / 1024 = ~1.07 mV per step
```

**2. Oversampling for extra resolution:**
```cpp
// Oversample 4x readings and average for ~1 extra bit of resolution
uint32_t sum = 0;
for (int i = 0; i < 64; i++) {
    sum += analogRead(A0);
}
uint16_t avg = sum / 64;  // Effectively ~13-bit noise reduction
```

**3. Discard the first reading after switching channels:**
```cpp
analogRead(A0);  // Dummy read — allows sample-and-hold to settle
int value = analogRead(A0);  // Real reading
```

**4. Reduce ADC clock speed for more accuracy:**
```cpp
// Set ADC prescaler to 128 (default is 128 on Arduino, 125 kHz ADC clock)
// For better accuracy, this is already the slowest. For speed, reduce prescaler:
// ADCSRA = (ADCSRA & 0xF8) | 0x06;  // Prescaler 64 = 250 kHz ADC clock
```

---

## ESP32 ADC

The ESP32 has two ADC units with 18 channels total at 12-bit resolution.

### ESP32 ADC Channels

| ADC Unit | GPIO Pins                              | Notes                          |
|----------|----------------------------------------|--------------------------------|
| ADC1     | 32, 33, 34, 35, 36, 37, 38, 39       | Always available               |
| ADC2     | 0, 2, 4, 12, 13, 14, 15, 25, 26, 27  | **Cannot use when WiFi is active!** |

**Critical: ADC2 + WiFi conflict.** When WiFi is enabled, ADC2 channels return garbage or errors. Always use ADC1 pins for analog readings in WiFi projects.

### Basic ESP32 ADC Usage

```cpp
void setup() {
    Serial.begin(115200);
    analogReadResolution(12);  // 12-bit (0-4095), default
    analogSetAttenuation(ADC_11db);  // Full range ~0-3.3V
}

void loop() {
    int raw = analogRead(34);  // ADC1 channel
    float voltage = raw * (3.3 / 4095.0);

    Serial.printf("Raw: %d  Voltage: %.3f V\n", raw, voltage);
    delay(100);
}
```

### ESP32 ADC Attenuation Settings

The ESP32 ADC has configurable input attenuation:

| Attenuation | Input Range  | Notes                          |
|-------------|-------------|--------------------------------|
| ADC_0db     | 0 - 1.1V   | Most linear, best accuracy     |
| ADC_2_5db   | 0 - 1.5V   | Good linearity                 |
| ADC_6db     | 0 - 2.2V   | Moderate linearity             |
| ADC_11db    | 0 - 3.3V   | Full range but least linear    |

### ESP32 ADC Nonlinearity Problem

The ESP32 ADC is notoriously nonlinear, especially at the extremes (near 0V and near 3.3V with 11dB attenuation). The response curve is S-shaped:

```
Expected (linear):  ────────────────────/
                                       /
                                      /
                                     /
                                    /
                                   /

Actual ESP32:       ──────────────/──── (saturates early)
                                 /
                               /  (roughly linear in middle)
                              /
                           /
                    ──────/  (dead zone near 0V)
```

**Practical impact:**
- Readings below ~100 mV are unreliable (dead zone)
- Readings above ~3.1V saturate (never reach 4095)
- Mid-range (0.2V to 2.8V) is roughly usable
- Raw readings can be off by 100+ mV

### ESP32 ADC Calibration

**Using ESP-IDF calibration (recommended):**
```cpp
#include <esp_adc_cal.h>

esp_adc_cal_characteristics_t adc_chars;

void setup() {
    Serial.begin(115200);

    // Characterize ADC at 11dB attenuation
    esp_adc_cal_characterize(ADC_UNIT_1, ADC_ATTEN_DB_11, ADC_WIDTH_BIT_12, 1100, &adc_chars);
}

void loop() {
    uint32_t raw = analogRead(34);
    uint32_t voltage_mv = esp_adc_cal_raw_to_voltage(raw, &adc_chars);

    Serial.printf("Raw: %d  Calibrated: %d mV\n", raw, voltage_mv);
    delay(100);
}
```

**Multisampling for noise reduction:**
```cpp
uint32_t readADC_Avg(int pin, int samples) {
    uint32_t sum = 0;
    for (int i = 0; i < samples; i++) {
        sum += analogRead(pin);
    }
    return sum / samples;
}
// Use 64 samples for good noise reduction
int smoothed = readADC_Avg(34, 64);
```

**When accuracy matters, use an external ADC** (see ADS1115 below).

---

## ADS1115 — External 16-bit ADC (I2C)

The ADS1115 is a 16-bit, 4-channel, delta-sigma ADC. It is the go-to external ADC for hobby and professional projects needing accuracy beyond what MCU ADCs provide.

### Specifications

| Feature          | Value                              |
|-----------------|------------------------------------|
| Resolution      | 16-bit (15-bit effective + sign)   |
| Channels        | 4 single-ended or 2 differential  |
| Sample rate     | 8 to 860 SPS (configurable)       |
| Input range     | Programmable gain: ±0.256V to ±6.144V |
| Interface       | I2C (address: 0x48-0x4B)          |
| Supply          | 2.0V to 5.5V                      |
| Accuracy        | ~0.01% at low sample rates        |

### Programmable Gain Amplifier (PGA)

| Gain | Full Scale Range | LSB Size   | Best For                    |
|------|-----------------|------------|------------------------------|
| 2/3x | ±6.144V        | 187.5 uV  | General purpose (default)    |
| 1x   | ±4.096V        | 125 uV    | 0-3.3V signals               |
| 2x   | ±2.048V        | 62.5 uV   | 0-2V signals                 |
| 4x   | ±1.024V        | 31.25 uV  | Millivolt-level signals      |
| 8x   | ±0.512V        | 15.625 uV | Thermocouples, load cells    |
| 16x  | ±0.256V        | 7.8125 uV | Very small signals           |

**Note:** The ±6.144V range does NOT mean you can apply 6V to the input. The input voltage must never exceed Vcc + 0.3V. The gain just sets the ADC's full-scale range.

### Arduino Example

```cpp
#include <Wire.h>
#include <Adafruit_ADS1X15.h>

Adafruit_ADS1115 ads;  // Default address 0x48

void setup() {
    Serial.begin(115200);
    ads.begin();
    ads.setGain(GAIN_ONE);  // ±4.096V range
}

void loop() {
    int16_t raw = ads.readADC_SingleEnded(0);  // Channel 0
    float voltage = ads.computeVolts(raw);

    Serial.print("Raw: ");
    Serial.print(raw);
    Serial.print("  Voltage: ");
    Serial.print(voltage, 4);
    Serial.println(" V");

    delay(100);
}
```

### Differential Reading

```cpp
// Measure voltage difference between A0 and A1
int16_t diff = ads.readADC_Differential_0_1();
float voltage = ads.computeVolts(diff);
// Useful for: load cells, Wheatstone bridges, current shunts
```

### Multiple ADS1115 on One Bus

Set different I2C addresses using the ADDR pin:

| ADDR Pin  | I2C Address |
|-----------|-------------|
| GND       | 0x48        |
| VDD       | 0x49        |
| SDA       | 0x4A        |
| SCL       | 0x4B        |

Four ADS1115 chips = 16 single-ended channels on one I2C bus.

---

## Signal Conditioning

Raw analog signals often need conditioning before feeding into an ADC.

### Voltage Divider (Scale Down)

To read voltages higher than the ADC reference:

```
V_in (e.g., 12V battery) ──[R1]──┬── ADC pin
                                   │
                                 [R2]
                                   │
                                  GND

V_out = V_in × R2 / (R1 + R2)
```

**Example: Read 0-25V with 3.3V ADC:**
```
R1 = 100kΩ, R2 = 15kΩ
V_out = 25 × 15k / (100k + 15k) = 3.26V (fits in 3.3V range)

Scale factor: V_in = V_out × (R1 + R2) / R2
                    = V_out × 7.667
```

**Use high-value resistors** (100kΩ+) to minimize current draw from the measured source.

Add a 100nF capacitor across R2 for noise filtering.

### Low-Pass Filter (Anti-Aliasing)

Before any ADC, filter out frequencies above half the sample rate (Nyquist):

```
Signal ──[R]──┬── ADC pin
              │
            [C]
              │
             GND

Cutoff frequency: f_c = 1 / (2π × R × C)
```

**Example:** R = 10kΩ, C = 100nF → f_c = 159 Hz

### Current Sensing with Shunt Resistor

```
V+ ──[R_shunt]──┬── Load ── GND
                 │
              V_sense (to ADC or INA219)

V_sense = I_load × R_shunt

For 0-5A range with R_shunt = 0.1Ω:
  V_sense = 5A × 0.1Ω = 0.5V
  Power dissipated: I² × R = 25 × 0.1 = 2.5W (use rated resistor!)
```

For precise current measurement, use an **INA219** (I2C current/power monitor) which includes a precision ADC and programmable gain:

```cpp
#include <Adafruit_INA219.h>

Adafruit_INA219 ina219;

void setup() {
    Serial.begin(115200);
    ina219.begin();
}

void loop() {
    float busVoltage = ina219.getBusVoltage_V();
    float current_mA = ina219.getCurrent_mA();
    float power_mW = ina219.getPower_mW();

    Serial.printf("%.2f V  %.1f mA  %.1f mW\n", busVoltage, current_mA, power_mW);
    delay(500);
}
```

### Op-Amp Buffer

If the signal source has high impedance, buffer it with a unity-gain op-amp before the ADC:

```
Signal ──[+]─┐
              │ Op-Amp ──── ADC pin
         [-]─┘
          │
          └──── (output fed back to inverting input)
```

Rail-to-rail op-amps for 3.3V/5V: MCP6001, OPA344, LM358 (not rail-to-rail but works for mid-range).

### Protecting ADC Inputs

Always protect ADC pins from overvoltage:

```
Signal ──[Series R (1-10kΩ)]──┬── ADC pin
                               │
                         [Clamp diodes]
                         to Vcc and GND

Or use Schottky diodes:
                ┌── Vcc
Signal ─[1kΩ]─┬─|── (Schottky to Vcc)
               │
               ├─|── (Schottky to GND)
               │  └── GND
               └── ADC pin
```

---

## DAC (Digital-to-Analog Converter)

### Built-in DACs

| Platform    | DAC Channels | Resolution | Output Range | Notes                       |
|------------|-------------|-----------|-------------|------------------------------|
| ESP32      | 2 (GPIO 25, 26) | 8-bit | 0-3.3V     | Usable for audio, not precise|
| Arduino Due| 2 (DAC0, DAC1)  | 12-bit| 0-3.3V     | Good for waveform generation |
| STM32      | 1-2             | 12-bit| 0-3.3V     | Varies by model              |
| Arduino Uno| None            | —     | —           | Use PWM + filter instead     |

### ESP32 DAC

```cpp
void setup() {
    // GPIO 25 = DAC1, GPIO 26 = DAC2
}

void loop() {
    dacWrite(25, 128);  // Output ~1.65V (mid-range, 8-bit: 0-255)
    delay(1000);
    dacWrite(25, 255);  // Output ~3.3V
    delay(1000);
    dacWrite(25, 0);    // Output 0V
    delay(1000);
}
```

### External DAC: MCP4725 (I2C, 12-bit)

```cpp
#include <Wire.h>
#include <Adafruit_MCP4725.h>

Adafruit_MCP4725 dac;

void setup() {
    dac.begin(0x60);  // Default I2C address
}

void loop() {
    // Output 0-4095 (12-bit) → 0-Vcc voltage
    dac.setVoltage(2048, false);  // Mid-range (~1.65V at 3.3V Vcc)
    delay(1000);

    // Generate a sine wave
    for (int i = 0; i < 360; i++) {
        float rad = i * 3.14159 / 180.0;
        uint16_t val = (uint16_t)(2048 + 2047 * sin(rad));
        dac.setVoltage(val, false);
        delayMicroseconds(100);
    }
}
```

### PWM as a Poor Man's DAC

If no DAC is available, filter PWM output through a low-pass RC filter:

```
PWM pin ──[10kΩ]──┬── Analog output
                   │
                [10uF]
                   │
                  GND

Time constant: τ = R × C = 10k × 10µF = 100ms
Cutoff: f_c = 1/(2πRC) = ~1.6 Hz

For faster response, use smaller values:
PWM pin ──[1kΩ]──┬── Analog output
                  │
               [1uF]
                  │
                 GND
f_c = ~159 Hz
```

The PWM frequency must be much higher than the filter cutoff for a smooth DC output. Arduino's ~490 Hz PWM works with the 1.6 Hz filter but gives noticeable ripple with the 159 Hz filter. ESP32 at 5+ kHz gives cleaner results.

---

## Comparison of ADC Options

| ADC             | Resolution | Channels | Speed     | Interface | Cost   | Best For                    |
|----------------|-----------|----------|-----------|-----------|--------|-----------------------------|
| ATmega328P     | 10-bit    | 6        | 9.6 kHz  | Built-in  | —      | Simple analog readings       |
| ESP32          | 12-bit    | 18       | ~6 kHz   | Built-in  | —      | General purpose (with cal.)  |
| MCP3008        | 10-bit    | 8        | 200 kSPS | SPI       | ~$2    | Multiple channels, fast      |
| ADS1115        | 16-bit    | 4        | 860 SPS  | I2C       | ~$3    | Precision voltage measurement|
| ADS1256        | 24-bit    | 8        | 30 kSPS  | SPI       | ~$15   | High precision, load cells   |
| HX711          | 24-bit    | 2 diff   | 80 SPS   | Proprietary| ~$1   | Load cells / scales          |
| MAX31855       | 14-bit    | 1        | ~10 SPS  | SPI       | ~$5    | Thermocouple temperature     |

---

## Troubleshooting

| Problem                          | Likely Cause                          | Fix                                    |
|---------------------------------|---------------------------------------|----------------------------------------|
| Readings jump around            | Noise on ADC input                    | Add filtering cap, oversample, shield  |
| Readings stuck at max           | Input exceeds Vref                    | Add voltage divider, check Vref        |
| Readings stuck at 0             | Pin not connected, wrong pin number   | Verify wiring and pin assignment       |
| Readings nonlinear (ESP32)      | ESP32 ADC characteristic              | Use calibration API or external ADC    |
| ADC2 returns errors (ESP32)     | WiFi is active                        | Use ADC1 pins only with WiFi           |
| Values drift over time          | Vref changing with temperature        | Use external Vref or internal reference|
| Cross-channel interference      | ADC multiplexer settling time         | Add dummy read when switching channels |
| Different readings on same input| ADC noise floor                       | Average multiple readings              |
