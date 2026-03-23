# Test Equipment Guide

## Multimeter

The most essential electronics tool. Every workbench needs one.

### Key Functions

| Function        | What It Measures            | Typical Range       |
|----------------|----------------------------|---------------------|
| DC Voltage     | Potential difference (DC)   | 200mV to 1000V     |
| AC Voltage     | Potential difference (AC)   | 200mV to 750V      |
| DC Current     | Current flow (DC)           | 200μA to 10A       |
| AC Current     | Current flow (AC)           | 200μA to 10A       |
| Resistance     | Resistance (Ω)              | 200Ω to 200MΩ      |
| Continuity     | Low resistance path         | Beeps below ~30Ω   |
| Diode Test     | Forward voltage of diode    | 0-2V typical        |
| Capacitance    | Capacitor value             | nF to mF (some meters)|
| Frequency      | Signal frequency            | Hz to MHz (some meters)|
| Temperature    | Via thermocouple probe      | -40 to 1000°C (some meters)|

### Auto-Ranging vs Manual Ranging

- **Auto-ranging:** Meter automatically selects the best range. Easier to use, slightly slower
- **Manual-ranging:** You select the range (200Ω, 2kΩ, 20kΩ, etc.). Faster readings, needed for some measurements

Most modern meters are auto-ranging. Manual ranging is fine for budget meters.

### How to Measure

#### DC Voltage

```
Set to V DC (V with straight line)
Red lead to V/Ω jack
Black lead to COM jack
Touch probes across the component or points being measured (in parallel)
```

**Never exceed the meter's voltage rating.** CAT III 600V means it's safe for 600V measurements in distribution panels.

#### DC Current

```
Set to A DC
Red lead to mA jack (for <200mA) or 10A jack (for higher current)
Black lead to COM jack
BREAK the circuit and insert meter IN SERIES with the current path
```

**CRITICAL:** The ammeter has near-zero impedance. If connected in parallel (across a voltage source), it creates a short circuit and blows the fuse (or worse). Always connect in series.

#### Resistance

```
Set to Ω
Red lead to V/Ω jack
Black lead to COM jack
DISCONNECT power from the circuit
Touch probes across the component
```

**Never measure resistance in a powered circuit** — it will give false readings and may damage the meter.

#### Continuity

```
Set to continuity (diode/beep symbol)
Touch probes to two points
Beep = connection exists (typically < 30Ω)
No beep = no connection or high resistance
```

Use continuity to:
- Trace wires and connections
- Check for broken traces on a PCB
- Verify solder joints
- Find short circuits

#### Diode Test

```
Set to diode test (diode symbol)
Red probe on anode, black on cathode
Reading shows forward voltage (0.4-0.7V for silicon, 0.15-0.4V for Schottky)
Reversed probes should show OL (open line / overrange)
```

Also useful for testing LEDs (they may light dimly) and identifying BJT terminals.

### Recommended Multimeters

| Budget        | Model                | Notes                                    |
|--------------|---------------------|------------------------------------------|
| $15-25       | UNI-T UT61E+        | Excellent value, true RMS, auto-range    |
| $15-20       | ANENG AN8008        | Good budget auto-ranging                  |
| $50-80       | Brymen BM235        | Excellent mid-range, same as Greenlee    |
| $50          | UNI-T UT61E+        | USB data logging, great for the price    |
| $150-200     | Fluke 117           | True RMS, CAT III, bulletproof           |
| $300+        | Fluke 87V           | Industrial standard, temperature, min/max|

**For hobbyists:** The UNI-T UT61E+ or similar is excellent value. Spend more on probes and accessories rather than the meter itself.

### Safety

- **Fuses:** Check that your meter has fused current inputs. Replace blown fuses with the correct rating — never bypass
- **CAT rating:** Indicates voltage spike protection level. CAT III 600V for household mains work
- **Probe condition:** Inspect leads for damaged insulation. Replace if cracked or broken
- **One hand rule:** When measuring high voltage, keep one hand in your pocket to avoid current path through your heart

---

## Oscilloscope

An oscilloscope displays voltage over time — essential for debugging signals, timing, and analog circuits.

### Key Specifications

| Spec            | What It Means                       | Minimum Useful |
|----------------|-------------------------------------|----------------|
| Bandwidth      | Maximum frequency it can display accurately (-3dB point) | 50MHz for digital, 200MHz for RF |
| Sample Rate    | How many samples per second         | 5-10× bandwidth |
| Memory Depth   | How many samples can be stored      | 1M points min   |
| Channels       | Number of simultaneous inputs       | 2 minimum, 4 preferred |
| Resolution     | Vertical resolution (bits)          | 8-bit standard, 12-bit for precision |

**Rule of thumb:** Oscilloscope bandwidth should be at least 5× the fundamental frequency of the signal you're measuring. For a 16MHz SPI clock, you want at least 80MHz bandwidth.

### Probes

#### 1X Probe
- No attenuation — signal passes straight through
- Adds significant capacitive loading (~100pF) to the circuit
- Limited bandwidth (usually ~6MHz)
- Use for: low-frequency, low-voltage signals where you need maximum sensitivity

#### 10X Probe (default choice)
- Attenuates signal by 10× (divide by 10)
- Much lower capacitive loading (~10-15pF)
- Full bandwidth of the oscilloscope
- **Always use 10X mode** unless you need to see very small signals

**Probe Compensation:** Before using a 10X probe, adjust the compensation trimmer on the probe by connecting to the scope's calibration output (square wave). Adjust until the square wave has perfectly flat tops — no overshoot or undershoot.

```
Overcompensated:  ┌─╲          (overshoot — turn trimmer down)
                  │  ─────

Correct:          ┌──────      (flat top — perfect)
                  │

Undercompensated: ┌╱           (rounded — turn trimmer up)
                  │──────
```

### Basic Oscilloscope Operation

1. **Connect probe** to the signal, ground clip to circuit ground
2. **Set coupling:** DC (shows DC offset + AC signal) or AC (removes DC, shows only AC component)
3. **Set vertical scale** (V/div) to fit the signal on screen
4. **Set horizontal scale** (time/div) to see a few cycles
5. **Set trigger:**
   - Source: the channel you're measuring
   - Type: Edge (rising or falling)
   - Level: roughly mid-point of the signal
   - This stabilizes the display so the waveform doesn't roll

### Common Measurements

| Measurement       | How                                           |
|------------------|-----------------------------------------------|
| Frequency/period | Use frequency measurement or count divisions  |
| Amplitude        | Measure peak-to-peak with cursors or auto     |
| Rise time        | 10% to 90% of signal transition               |
| Duty cycle       | High time / period × 100%                     |
| Phase difference | Compare two channels on same timebase         |
| Ringing          | Look for oscillation after edges              |
| Noise            | AC couple, measure peak-to-peak noise         |
| I2C/SPI/UART     | Use protocol decoder (if available)           |

### Budget Oscilloscope Recommendations

| Model          | Bandwidth | Channels | Sample Rate | Price   | Notes                     |
|---------------|-----------|----------|-------------|---------|---------------------------|
| Rigol DS1054Z | 50MHz*    | 4        | 1 GSa/s     | ~$400   | *Hackable to 100MHz, best value |
| Rigol DHO804  | 70MHz     | 4        | 1.25 GSa/s  | ~$400   | Newer model, 12-bit, great |
| Siglent SDS1104X-E | 100MHz | 4     | 1 GSa/s     | ~$400   | Excellent, large memory   |
| Hantek DSO2D10| 100MHz    | 2        | 1 GSa/s     | ~$150   | Budget, basic but works   |
| Fnirsi 1014D  | 100MHz    | 2        | 1 GSa/s     | ~$80    | Ultra budget, limited     |

**The Rigol DS1054Z (or newer DHO804) is the standard hobbyist recommendation.** Four channels, adequate bandwidth, protocol decoding, and well-supported by the community.

### Ground Clip Warning

The oscilloscope ground clip is connected to mains earth through the scope's power cord. **Never connect the ground clip to anything that is not at ground potential** in a mains-connected circuit — you will create a short circuit through the earth wire.

For floating measurements, use differential probes or battery-powered scopes.

---

## Logic Analyzer

A logic analyzer captures digital signals (HIGH/LOW) on many channels simultaneously. It's essential for debugging digital protocols.

### Hardware Logic Analyzers

| Device              | Channels | Sample Rate | Price    | Notes                        |
|--------------------|----------|-------------|---------|------------------------------|
| Saleae Logic 8     | 8        | 100 MSa/s   | $480    | Professional, excellent software |
| Saleae clone (FX2) | 8        | 24 MSa/s    | $8-15   | Use with sigrok/PulseView, works well |
| DSLogic Plus       | 16       | 400 MSa/s   | $150    | Good value, good software     |
| Saleae Logic Pro 16| 16       | 500 MSa/s   | $1000   | Professional, analog + digital|

**For hobbyists:** A $10 Saleae clone with PulseView software handles I2C, SPI, UART, and other protocols at typical speeds perfectly well.

### Software: PulseView (sigrok)

PulseView is free, open-source logic analyzer software that supports many hardware devices.

- Works with Saleae clones (FX2-based), DSLogic, and many others
- Protocol decoders for 100+ protocols: I2C, SPI, UART, 1-Wire, WS2812, JTAG, etc.
- Available on Linux, Windows, macOS

### Protocol Decoding

| Protocol | Channels Needed | Min Sample Rate | Notes                     |
|----------|----------------|-----------------|---------------------------|
| I2C      | 2 (SDA, SCL)   | 4× clock rate   | Shows address, R/W, data  |
| SPI      | 3-4 (SCK, MOSI, MISO, CS) | 4× clock rate | Shows bytes transferred |
| UART     | 1 (TX or RX)   | 4× baud rate    | Shows decoded characters  |
| 1-Wire   | 1 (DQ)          | 1 MSa/s+        | Shows ROM commands, data  |
| WS2812   | 1 (DIN)         | 10 MSa/s+       | Shows RGB data per LED    |
| PWM      | 1               | 10× frequency   | Shows duty cycle          |

### Usage Tips

- Connect the logic analyzer ground to the circuit ground
- Use short probe wires to minimize noise pickup
- Set appropriate voltage thresholds (3.3V logic: threshold ~1.65V; 5V logic: ~2.5V)
- Trigger on the CS line going low (for SPI) or start condition (for I2C) to capture complete transactions

---

## Bench Power Supply

A controllable DC power supply with adjustable voltage and current limiting.

### Key Features

| Feature              | What It Does                                |
|---------------------|---------------------------------------------|
| Voltage adjustment  | Set output voltage (0-30V typical)           |
| Current limiting    | Caps maximum current to protect circuit      |
| CV mode             | Constant Voltage — maintains set voltage     |
| CC mode             | Constant Current — limits to set current     |
| Display             | Shows actual V and I being delivered         |
| Multiple channels   | Independent outputs (e.g., 5V + 3.3V)       |

### Constant Voltage (CV) vs Constant Current (CC)

In **CV mode** (normal operation): supply maintains the set voltage, current varies based on load.

In **CC mode** (current limit reached): supply reduces voltage to maintain the set current limit. This protects your circuit from overcurrent.

**How to use current limiting:**
1. Before connecting your circuit, set the desired voltage
2. Set the current limit to slightly above what your circuit should draw
3. Connect circuit
4. If the supply drops into CC mode, your circuit is drawing too much current — investigate

### Recommended Bench Power Supplies

| Model              | Specs              | Price    | Notes                     |
|-------------------|--------------------|----------|---------------------------|
| RD6006/RD6006P    | 60V 6A (360W)     | $55-80   | Module — needs case + AC supply |
| Riden RD6012      | 60V 12A (720W)    | $80-110  | Module, more power         |
| KORAD KA3005D     | 30V 5A             | $100-140 | Complete unit, SCPI control|
| Rigol DP832       | 30V×2 + 5V (3ch)  | $400     | Professional, programmable |
| UNI-T UTP1306S    | 32V 6A             | $80-100  | Good budget complete unit  |
| Wanptek WPS3010H  | 30V 10A            | $50-70   | Budget, adequate           |

**RD6006 is excellent value** — pair it with a $15-25 switching AC-DC supply (like a server PSU) and a 3D-printed/metal case. App control via WiFi or USB.

### USB Power for Prototyping

For 5V/3.3V circuits, a USB charger + breakout board can substitute for a bench supply:
- USB Type-A breakout: 5V, limited current info
- USB-C PD trigger module: configurable 5V/9V/12V/15V/20V
- INA219 module in-line for current monitoring

---

## Function / Signal Generator

Generates test signals for circuit stimulation and testing.

### Common Signal Types

- **Sine wave** — pure tone for audio, filter testing
- **Square wave** — digital signal simulation, clock replacement
- **Triangle/Ramp** — sweep signals, analog testing
- **Arbitrary** — custom waveforms, modulated signals

### Specifications

| Spec                | Budget        | Mid-range      |
|--------------------|---------------|----------------|
| Frequency range    | 0-1MHz        | 0-25MHz        |
| Sample rate        | 10-50 MSa/s   | 125-250 MSa/s  |
| Channels           | 1             | 2              |
| Amplitude          | 0-10Vpp       | 0-20Vpp        |
| Output impedance   | 50Ω           | 50Ω            |

### Recommended Signal Generators

| Model              | Max Freq  | Price    | Notes                        |
|-------------------|-----------|---------|-----------------------------|
| FY6900 (FeelTech) | 20-60MHz  | $50-80  | Dual channel, arbitrary waveform |
| JDS2800           | 15-60MHz  | $60-90  | Good display, dual output    |
| Rigol DG1022Z     | 25MHz     | $350    | Professional, 2-ch           |
| Siglent SDG1032X  | 30MHz     | $400    | Professional, 2-ch           |

**For hobbyists:** The FY6900 or JDS2800 handles most needs. Many oscilloscopes (like the Rigol DS1054Z) also include a basic built-in signal generator.

**Cheap alternative:** For simple square wave testing, an MCU (Arduino, ESP32) generating PWM on a GPIO pin works for many situations.

---

## Equipment Priority (What to Buy First)

1. **Multimeter** — absolutely essential, buy first ($20-50)
2. **Bench power supply** or good USB-C PD setup — power your projects safely ($50-100)
3. **Logic analyzer** — $10 Saleae clone, invaluable for digital protocols
4. **Oscilloscope** — when you need to debug analog signals, timing issues, or noise ($150-400)
5. **Signal generator** — when you need to test filters, amplifiers, or simulate inputs ($50-80)

The multimeter and logic analyzer together cost under $30 and cover 80% of debugging needs.
