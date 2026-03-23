# Field Repair Guide

> Essential tools, spare parts, and techniques for fixing electronics without a workshop.

## Field Repair Kit

### Essential Tools

| Tool | Purpose | Notes |
|---|---|---|
| Digital multimeter | Voltage, current, resistance, continuity | Auto-ranging, CAT III rated (e.g., Aneng AN8008) |
| Soldering iron (portable) | Solder repairs | TS100/TS101 (USB-C powered, 65W) or butane iron |
| Solder (leaded) | Connections | 63/37 tin-lead, 0.8mm. Leaded flows easier in field conditions |
| Flux pen | Improve solder flow | Kester 951 or similar no-clean flux |
| Solder wick | Remove solder | 2-3mm width |
| Wire strippers | Strip wire insulation | 20-30 AWG range |
| Flush cutters | Cut leads, wire | Precision tip |
| Tweezers | SMD work, small parts | Anti-static, fine tip (ESD-safe) |
| Helping hands / clamp | Hold PCBs | Small clip stand or blue tack |
| Heat shrink tubing | Insulate connections | Assorted sizes, include lighter or heat gun |
| Electrical tape | Quick insulation | Black vinyl, quality brand (3M Super 33+) |
| Precision screwdriver set | Open enclosures | Phillips, flat, Torx, hex (iFixit kit) |
| Needle-nose pliers | Bend, grip, pull | Small, with wire cutter |
| USB microscope/magnifier | Inspect solder joints | Phone camera with macro works too |
| Butane lighter | Heat shrink, emergency solder | Windproof |

### Spare Components Kit

Keep in a small organizer box:

**Passives**:
- Resistors: 100Ω, 220Ω, 1kΩ, 4.7kΩ, 10kΩ, 100kΩ (10 each)
- Capacitors: 100nF ceramic (×10), 10μF electrolytic (×5), 100μF (×5)
- LEDs: red, green, blue (5 each)

**Semiconductors**:
- 2N2222 NPN transistors (×5)
- 2N7000 N-channel MOSFET (×5)
- 1N4007 rectifier diodes (×10)
- 1N5819 Schottky diodes (×5)
- AMS1117-3.3V regulator (×5)
- 7805 5V regulator (×3)

**Connectors**:
- Dupont jumper wires (M-M, M-F, F-F, 10 each)
- Header pins (male and female, 40-pin strips ×3)
- JST 2-pin connectors (×5)
- USB-C cables (×2)
- Micro-USB cables (×2)

**Protection**:
- Fuses: 1A, 3A, 5A blade fuses (×3 each)
- Inline fuse holder (×2)

**Wire**:
- 22 AWG solid core (2m red, 2m black)
- 26 AWG stranded (2m red, 2m black)
- Silicone wire 18 AWG (1m, for power)

**Boards**:
- Spare ESP32 dev board
- Spare TP4056 charging module
- Spare buck converter module (LM2596)
- Small perfboard / stripboard

## Systematic Debugging

When something doesn't work, follow this order:

### 1. Power First

Most failures are power-related.

```
Check in order:
□ Is the power source working? (Measure voltage)
□ Is the fuse intact? (Continuity test)
□ Is voltage reaching the board? (Measure at board power pins)
□ Is the regulator outputting correct voltage? (3.3V or 5V at output)
□ Are all ground connections solid?
□ Is current draw reasonable? (Compare to expected)
```

**Quick power test**: Measure voltage at the IC's VCC/GND pins directly. If it's wrong there, work backwards toward the power source.

### 2. Then Signals

```
□ Is the clock/oscillator running? (Scope or frequency counter)
□ Are serial TX/RX connected correctly? (TX→RX crossover)
□ Are I2C pull-ups present? (Measure SCL/SDA — should be high at idle)
□ Are SPI chip selects wired correctly? (Active low)
□ Is the baud rate / protocol correct?
```

### 3. Then Software

```
□ Does the board respond to serial at all? (Try 115200 baud)
□ Is the correct firmware flashed?
□ Are pin assignments in code matching actual wiring?
□ Is WiFi/BLE interfering? (ADC2 unusable when WiFi active on ESP32)
□ Can you get a minimal blink sketch working?
```

## Common Failure Modes

### Cold Solder Joints

**Symptoms**: Intermittent connections, works when pressed, fails when moved
**Cause**: Insufficient heat during soldering
**Fix**: Reheat joint with flux, add small amount of fresh solder, let cool without moving

### Corroded Connectors

**Symptoms**: High resistance connections, intermittent contact
**Cause**: Moisture, salt air, dissimilar metals
**Fix**: Clean with isopropyl alcohol and brush. Apply DeoxIT contact cleaner. Protect with dielectric grease.

### Blown Voltage Regulators

**Symptoms**: No output voltage, regulator hot or visibly damaged
**Cause**: Input overvoltage, reverse polarity, output short circuit
**Fix**: Replace regulator. Add reverse polarity protection (series Schottky diode). Check load for shorts first.

### ESD Damage

**Symptoms**: IC partially works, random crashes, one peripheral dead
**Cause**: Static discharge during handling
**Prevention**: Touch grounded metal before handling boards. Use ESD-safe tools. Ground yourself in dry environments.
**Fix**: Usually requires replacing the damaged IC. For ESP32/Arduino, replace the whole board.

### Broken Traces

**Symptoms**: Signal doesn't reach destination, continuity test fails along trace
**Cause**: Physical stress, vibration, thermal cycling
**Fix**: Scrape solder mask off trace on both sides of break, bridge with thin wire and solder.

### Moisture / Water Damage

**Symptoms**: Short circuits, corrosion, erratic behavior
**Fix**:
1. Disconnect power immediately
2. Disassemble and remove batteries
3. Rinse with isopropyl alcohol (displaces water)
4. Dry thoroughly (warm air, desiccant, sun — not hot air gun on components)
5. Inspect for corrosion, clean with IPA and brush
6. Test before re-powering

## Improvised Repairs

### No Soldering Iron Available

- **Twist and tape**: Strip wires, twist tightly, wrap with electrical tape. Not permanent but works.
- **Wire wrap**: If you have thin wire (30 AWG), wrap tightly around pins. Surprisingly reliable.
- **Conductive adhesive**: Silver-filled epoxy can bond connections (cures in hours).
- **Candle + paperclip**: Heat a paperclip in a candle flame as a crude soldering tip. Apply solder with the hot tip. Last resort.

### No Specific Component

- **No pull-up resistor?** Almost any resistor from 1kΩ to 47kΩ will work for I2C pull-ups. Two in parallel if individual values are too high.
- **No specific voltage?** Use a resistor voltage divider from a higher voltage. Or chain regulators (12V → 5V 7805 → 3.3V AMS1117).
- **No fuse?** A thin wire strand can act as a fuse. It's not rated, but it's better than nothing.
- **No heat shrink?** Electrical tape, hot glue, or even a piece of straw slit lengthwise.

### Waterproofing in the Field

- Hot glue over connections and exposed PCB areas
- Wrap in plastic bag with desiccant
- Coat with clear nail polish (poor man's conformal coating)
- Seal with silicone caulk from hardware store

## Emergency Contact Protocol

If electronics repair isn't possible and you need communication:

1. **Radio**: Baofeng on FRS/GMRS/2m simplex — no electronics repair needed
2. **Visual signals**: Mirror for daytime, LED flashlight for morse at night
3. **Meshtastic**: If one node works, relay messages through the mesh
4. **Improvised antenna**: A piece of wire cut to 1/4 wavelength can replace a broken antenna
   - 2m (146 MHz): ~50cm (19.5 inches)
   - 70cm (440 MHz): ~17cm (6.5 inches)
   - LoRa 915 MHz: ~8.2cm (3.2 inches)
