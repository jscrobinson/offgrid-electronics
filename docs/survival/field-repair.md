# Field Repair Guide

Essential tools, spare parts, and techniques for fixing electronics without a workshop.

---

## Field Repair Kit

### Essential Tools

| Tool                          | Purpose                                    | Priority |
|-------------------------------|--------------------------------------------|----------|
| Multimeter (pocket-sized)     | Voltage, continuity, resistance            | Critical |
| Soldering iron (USB/battery)  | Solder joints, wire connections            | Critical |
| Solder + flux                 | Soldering consumables                      | Critical |
| Wire strippers / flush cutters| Cutting and stripping wire                 | Critical |
| Precision screwdriver set     | Opening enclosures, adjusting pots         | Critical |
| Needle-nose pliers            | Gripping, bending wire                     | Critical |
| Electrical tape               | Insulation, temporary repair               | Critical |
| Heat shrink assortment        | Permanent wire insulation                  | High     |
| USB-C/micro-USB cables        | Power, programming, data                   | High     |
| Butane lighter / heat gun     | Heat shrink, melting solder in field       | High     |
| Tweezers (ESD)                | Handling small components                  | High     |
| Magnifying glass / loupe      | Inspecting solder joints, traces           | Medium   |
| Helping hands / PCB vise      | Hold work while soldering                  | Medium   |
| Hot glue gun (battery)        | Strain relief, weatherproofing             | Medium   |
| Isopropyl alcohol + swabs     | Cleaning flux, contacts                    | Medium   |
| Desoldering wick or pump      | Removing solder for rework                 | Medium   |

### Spare Components

| Component                     | Quantity | Notes                              |
|-------------------------------|----------|-------------------------------------|
| ESP32 dev board               | 1-2      | Most versatile replacement           |
| Arduino Nano                  | 1        | Simple, 5V tolerant                  |
| USB-UART adapter (CP2102)     | 1        | Programming, serial debug            |
| Dupont jumper wires (M/F, M/M)| 20+      | Quick prototyping                    |
| Breadboard (mini)             | 1        | Temporary circuits                   |
| Wire (22 AWG solid, stranded) | 5m each  | Hookup wire                          |
| Resistors (assortment)        | Kit      | 100R, 1K, 4.7K, 10K, 47K, 100K    |
| Capacitors (assortment)       | Kit      | 100nF ceramic, 10uF, 100uF, 1000uF |
| LEDs (various colors)         | 10       | Status indicators, debug             |
| Diodes (1N4007, 1N5819)       | 10       | Flyback, reverse polarity protection |
| MOSFETs (IRLZ44N)            | 2        | Load switching replacement           |
| Voltage regulators (LM7805, AMS1117-3.3) | 3 | Power regulation              |
| Buck converter modules (12V to 5V) | 2   | USB output for Pi/devices            |
| Fuses (blade, assorted amps)  | 10       | Overcurrent protection               |
| Micro SD cards (spare)        | 2        | Pre-loaded with OS image             |
| USB flash drives              | 2        | Data transfer, bootable              |
| Screw terminals (2/3 pin)     | 5        | Quick wire connections                |
| Cable glands (PG7, PG9)       | 5        | Enclosure cable entry                |
| Zip ties (assorted)           | 50+      | Cable management, mounting           |
| Silicone sealant              | 1 tube   | Waterproofing                        |
| Conformal coating spray       | 1 can    | PCB protection                       |
| Desiccant packs               | 10       | Moisture absorption                  |

### Diagnostic Equipment

| Item                          | Use                                        |
|-------------------------------|--------------------------------------------|
| USB power meter               | Measure voltage/current on USB devices     |
| Logic analyzer (8ch)          | Debug I2C, SPI, UART signals              |
| Oscilloscope (handheld/USB)   | If budget allows — invaluable for power issues |
| Spare laptop/tablet           | Programming, diagnostics, serial monitor   |
| Serial console cable (USB-UART)| Direct console access to Pi, ESP32         |

---

## Systematic Debugging

### The POWER Method

When something stops working, follow this order:

**P — Power**
1. Is power reaching the device? Check with multimeter
2. Correct voltage? (5V, 3.3V, 12V — within spec)
3. Check fuses — blown fuses are silent failures
4. Check connectors — pull and reseat all power connections
5. Check battery voltage under load (not just open-circuit)

**O — Observe**
1. Any LEDs lit? Which pattern?
2. Any unusual heat? (feel components carefully)
3. Any burnt smell?
4. Any physical damage visible?
5. What changed since it last worked?

**W — Wiring**
1. Continuity test on all critical paths
2. Check for loose connections (wiggle test)
3. Check for shorts (resistance between power and ground)
4. Check solder joints — cold joints crack under vibration
5. Check for corroded connectors

**E — Environment**
1. Temperature — too hot or too cold?
2. Moisture — condensation inside enclosure?
3. Vibration damage — components shaken loose?
4. EMI — new interference source nearby?
5. Power source changed — solar vs battery vs generator?

**R — Replace and Test**
1. Swap with known-good component
2. Test one thing at a time
3. Start with the simplest possible configuration
4. Add complexity back incrementally

### Quick Diagnostic Flowchart

```
Device not working
|
+-- No power LED?
|   +-- Check power source voltage
|   +-- Check fuse
|   +-- Check power cable/connector
|   +-- Check voltage regulator output
|
+-- Power LED on but no function?
|   +-- Check serial output (connect USB-UART)
|   +-- Check for boot loops (rapid LED blinking)
|   +-- Try reflashing firmware
|   +-- Check SD card (remove, clean, reinsert)
|   +-- Check for overheating (throttling)
|
+-- Intermittent failures?
|   +-- Power supply ripple/brownout
|   +-- Loose connection (wiggle test)
|   +-- Thermal issue (fails when hot)
|   +-- Memory issue (check with memtest)
|   +-- SD card corruption
|
+-- Sensor/peripheral not responding?
    +-- Run I2C scanner
    +-- Check wiring (SDA, SCL, power)
    +-- Check pull-up resistors
    +-- Try different GPIO pins
    +-- Test sensor with known-good code
```

---

## Common Failure Modes

### Power-Related

| Failure                    | Symptoms                      | Fix                                  |
|----------------------------|-------------------------------|--------------------------------------|
| Blown fuse                 | Complete dead, no power       | Replace fuse, find root cause        |
| Reverse polarity           | Instant damage, magic smoke   | Add Schottky diode protection        |
| Voltage regulator burnout  | Overheating, low/no output    | Replace, check for shorts downstream |
| Brown-out                  | Random resets, boot loops     | Bigger capacitor, better supply      |
| Battery over-discharge     | Won't charge, BMS lockout     | Disconnect load, try slow charge     |
| Connector corrosion        | Intermittent connection       | Clean with IPA, apply dielectric grease |

### Communication-Related

| Failure                    | Symptoms                      | Fix                                  |
|----------------------------|-------------------------------|--------------------------------------|
| I2C hang                   | All I2C devices stop          | Power cycle, add bus recovery code   |
| SPI clock issue            | Garbled data, no response     | Check speed, check wiring            |
| UART baud mismatch         | Garbage characters            | Verify both ends at same baud rate   |
| WiFi won't connect         | Timeout, wrong SSID           | Check credentials, channel, distance |
| LoRa no reception          | No packets received           | Check frequency, SF, antenna, RSSI   |
| Antenna disconnect         | Very short range              | Check U.FL connector, SMA tight      |

### Environmental

| Failure                    | Symptoms                      | Fix                                  |
|----------------------------|-------------------------------|--------------------------------------|
| Moisture ingress           | Corrosion, shorts, erratic    | Dry out, apply conformal coating     |
| UV degradation             | Brittle plastic, faded labels | Use UV-resistant enclosure/paint     |
| Cold battery               | Low capacity, won't charge    | Insulate battery, warm before charge |
| Heat throttling            | Slow performance, shutdowns   | Add heatsink, improve ventilation    |
| Vibration                  | Intermittent connections      | Secure with hot glue, add strain relief |
| Lightning/ESD              | Random damage, fried ICs      | Add TVS diodes, ground properly      |

### Software/Firmware

| Failure                    | Symptoms                      | Fix                                  |
|----------------------------|-------------------------------|--------------------------------------|
| SD card corruption         | Boot failure, read errors     | Reflash SD card from backup image    |
| Firmware crash             | Boot loop, watchdog reset     | Reflash firmware via serial          |
| Memory leak                | Slows over time, then crashes | Restart, fix code, add watchdog      |
| Filesystem full            | Can't write logs, crashes     | Delete old logs, add log rotation    |
| I2C address conflict       | Multiple sensors fail         | Check with scanner, change addresses |

---

## Improvised Repairs

### No Soldering Iron

- **Crimp connections:** Use crimp connectors + pliers (not ideal but functional)
- **Wire wrapping:** Tightly wrap wire around a pin, secure with tape
- **Screw terminals:** Use screw terminal blocks for all connections
- **Conductive epoxy:** For small connections (slow cure, higher resistance)

### No Proper Wire

- **USB cable:** Cut open, extract the 4 wires inside (28 AWG typical)
- **Ethernet cable:** 8 wires of 24 AWG solid core
- **Headphone cable:** Thin stranded wire, good for signals
- **Twist multiple thin wires** for higher current capacity

### No Replacement Component

- **Resistor from wire:** Nichrome wire (from old heating element) has significant resistance
- **Capacitor smoothing:** Paralleling multiple small caps equals one big cap
- **Voltage divider:** Two resistors to step down voltage (inefficient but works)
- **Diode from LED:** An LED is a diode and can be used for polarity protection in a pinch

### Waterproofing in the Field

- **Plastic bag + rubber bands:** Temporary splash protection
- **Hot glue:** Seal cable entries, coat exposed connections
- **Silicone sealant:** Seal enclosure gaps
- **Self-fusing silicone tape:** Wrap connectors, cable entries
- **Nail polish:** Emergency conformal coating for small boards
- **Candle wax:** Coat PCB surfaces (peel off later for rework)

### Power in Emergency

- **Car cigarette lighter:** 12V, can power most field equipment
- **USB battery bank:** 5V for microcontrollers and Pi
- **Laptop as power source:** USB ports provide 5V 500mA-2A
- **AA batteries in series:** 4x AA = 6V, 8x AA = 12V (use holders or tape)
- **Solar panel direct:** Small 5V USB solar panel can power ESP32 directly in bright sun (add large capacitor for stability)

---

## Preventive Measures

### Before Deployment

1. **Burn-in test** all electronics for 48 hours before field deployment
2. **Photograph your wiring** while it works — reference for field repair
3. **Document pin assignments** and configuration — label everything
4. **Create backup SD card images** — test that they boot
5. **Apply conformal coating** to all exposed PCBs
6. **Add watchdog timers** to all firmware — auto-recover from crashes
7. **Enable remote access** (SSH, serial) for software troubleshooting
8. **Pack spares** of anything critical to the mission

### During Deployment

1. **Monitor voltage** and temperature (INA219, BME280)
2. **Log errors** to persistent storage
3. **Implement automatic restart** on failure conditions
4. **Check connections weekly** if accessible
5. **Replace desiccant** every few months in humid environments

### Recovery Procedures

**Bricked ESP32:**
```bash
# Erase flash and reflash
esptool.py --chip esp32 erase_flash
esptool.py --chip esp32 write_flash 0x0 firmware.bin
```

**Corrupted Raspberry Pi SD card:**
```bash
# From another computer:
# Write fresh image
sudo dd if=backup.img of=/dev/sdX bs=4M status=progress

# Or mount and fix
sudo fsck /dev/sdX2
```

**BMS lockout (LiFePO4):**
1. Disconnect all loads
2. Apply charger at low current
3. If BMS won't reset, check for cell imbalance
4. Some BMS require brief short of the charge port to reset

---

## Emergency Reference Card

Print and laminate this for your field kit:

```
VOLTAGE REFERENCE
-----------------
LiFePO4 12V: Full=14.4V, Nominal=13.2V, Low=12.0V, Cutoff=10.0V
Li-Ion cell:  Full=4.2V,  Nominal=3.7V,  Low=3.4V,  Cutoff=3.0V
LiFePO4 cell: Full=3.65V, Nominal=3.3V,  Low=3.2V,  Cutoff=2.5V
USB:          5.0V +/-0.25V

LED COLOR CODES (generic)
-------------------------
Solid green = OK/powered
Blinking green = activity
Solid red = error/charging
Blinking red = low battery/fault
Blue blink = Bluetooth active

COMMON BAUD RATES
------------------
GPS default: 9600
ESP32 debug: 115200
Arduino: 9600 or 115200
Pi serial: 115200

I2C ADDRESSES
--------------
0x3C = SSD1306 OLED
0x68 = MPU6050
0x76 = BME280/BMP280
0x40 = INA219
0x23 = BH1750
0x29 = VL53L0X
```
