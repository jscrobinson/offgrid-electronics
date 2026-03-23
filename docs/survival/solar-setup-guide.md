# Field Solar Setup Guide

Portable solar power for electronics in the field: panels, charge controllers, batteries, wiring, and example configurations.

---

## System Overview

```
[Solar Panel] --> [Charge Controller] --> [Battery] --> [Load/Devices]
                                              |
                                    The charge controller protects
                                    the battery from overcharge,
                                    over-discharge, and manages
                                    charging profiles.
```

---

## Selecting Panels

### Panel Types for Portable Use

| Type | Efficiency | Weight | Durability | Cost | Best For |
|------|-----------|--------|------------|------|----------|
| Monocrystalline | 20-24% | Medium | Good | Higher | Best power per area |
| Polycrystalline | 15-20% | Medium | Good | Lower | Budget setups |
| CIGS/Flexible | 12-16% | Very light | Fair | High | Backpacks, curved surfaces |
| Folding panels | 20-22% | Portable | Good | Medium | Field deployment |

### Recommended Panel Sizes

| Size | Output (good sun) | Use Case |
|------|-------------------|----------|
| 5-10W | 0.3-0.6A at 5V | Phone charging only |
| 20-30W | 1-1.5A at 18V | Phone + handheld radio |
| 50W | 2.5-3A at 18V | Pi + radio + phone |
| 100W | 5-6A at 18V | Laptop + multiple devices |
| 2x100W | 10-12A at 18V | Full field station |

### Key Panel Specifications

```
Pmax: Maximum power (watts) -- under standard test conditions (STC)
       STC = 1000 W/m2 irradiance, 25 deg C cell temp, AM1.5 spectrum
       Real-world output is typically 60-80% of rated

Vmp:  Voltage at maximum power (typically 17-18V for "12V" panels)
Imp:  Current at maximum power
Voc:  Open circuit voltage (no load -- higher than Vmp)
Isc:  Short circuit current (shorted output -- higher than Imp)
```

**Important**: "12V" panels actually output around 18V at max power (Vmp). This is necessary because the charge controller needs voltage headroom above the battery voltage to push current in.

### Folding Panel Recommendations

Good brands for field use: Renogy, BougeRV, Jackery, Bluetti, ALLPOWERS.

Look for:
- Built-in kickstand
- MC4 connectors or Anderson Powerpole
- IP65+ water resistance
- Grommets for mounting/hanging
- Carrying case/handle

---

## Charge Controllers

The charge controller sits between the panel and battery, regulating voltage and current.

### PWM vs MPPT

| Feature | PWM | MPPT |
|---------|-----|------|
| Cost | $10-30 | $40-150+ |
| Efficiency | 75-80% | 93-99% |
| Panel voltage | Must match battery voltage | Can be much higher |
| Best for | Small systems (<100W) | Larger systems, max output |
| Complexity | Simple | More complex |

**MPPT** (Maximum Power Point Tracking) extracts significantly more power, especially when:
- Panel voltage is much higher than battery voltage
- It is cloudy or panels are partially shaded
- Temperature varies (cold panels have higher voltage)

**For field use**: MPPT is worth the cost for systems 50W+. PWM is fine for small 20W phone-charging setups.

### Recommended Controllers

- **Victron SmartSolar 75/15** -- excellent MPPT, Bluetooth monitoring, 15A
- **EPever Tracer series** -- good budget MPPT, RS485 interface
- **Renogy Wanderer 10A** -- good budget PWM for small systems
- **Genasun GV-5** -- tiny, efficient, great for small LiFePO4 systems

### Sizing the Controller

```
Controller current rating >= Panel Isc x 1.25

Example: 100W panel, Isc = 6A
  Minimum controller: 6 x 1.25 = 7.5A --> use 10A or 15A controller
```

---

## Battery Selection

### Battery Chemistry Comparison

| Chemistry | Voltage | Cycles | Weight | Safety | Temp Range | Cost |
|-----------|---------|--------|--------|--------|------------|------|
| LiFePO4 (LFP) | 3.2V/cell | 2000-5000 | Medium | Excellent | -20 to 60C | Higher |
| Li-ion (18650) | 3.7V/cell | 300-500 | Light | Good | 0 to 45C | Medium |
| Lead-acid (AGM) | 2V/cell | 200-400 | Heavy | Good | -20 to 50C | Low |
| Lead-acid (Gel) | 2V/cell | 500-800 | Heavy | Good | -20 to 50C | Medium |

### LiFePO4 -- Recommended for Field Use

**Why LiFePO4 is the best choice:**
- Very safe (will not catch fire or explode, even if punctured)
- Flat discharge curve (holds voltage until nearly empty)
- 2000+ cycles (years of daily use)
- Light for the capacity
- Built-in BMS (Battery Management System) handles cell balancing
- Drop-in replacement for lead-acid in many cases

**Common LiFePO4 batteries:**

| Capacity | Wh | Weight | Use Case |
|----------|----|--------|----------|
| 12V 6Ah | 72Wh | 0.8kg | Pi + radio for a day |
| 12V 12Ah | 144Wh | 1.5kg | Pi + radio + sensors for 2 days |
| 12V 20Ah | 256Wh | 2.5kg | Field station, multi-day |
| 12V 50Ah | 640Wh | 6kg | Full station, extended deployment |
| 12V 100Ah | 1280Wh | 12kg | Base camp, continuous operation |

### LiFePO4 Voltage Chart (12V / 4S)

```
100%:  14.6V (charging complete)
 90%:  13.6V
 80%:  13.4V
 50%:  13.2V (voltage is very flat in the middle)
 20%:  13.0V
 10%:  12.8V
  0%:  10.0V (BMS cutoff -- do not discharge below this)

Charge voltage: 14.2-14.6V
Float voltage:  13.6V
Low voltage cutoff: 10.0-11.0V (BMS will disconnect)
```

---

## Wiring and Connectors

### Anderson Powerpole Connectors (Recommended)

Anderson Powerpoles are the standard for portable DC power in amateur radio and field electronics:

- Genderless (every connector mates with every other)
- Color coded (red = positive, black = negative)
- Rated for 15A, 30A, or 45A depending on size
- Easy to assemble with crimping tool
- Stack together for multi-conductor connections

```
Standard orientation (ARES/RACES standard):
  Red on top (or left), Black on bottom (or right)
  When looking at the front of the connector:
  +-------+
  |  RED  | <-- positive
  +-------+
  |  BLK  | <-- negative
  +-------+
```

### Wire Sizing

Use adequately sized wire to avoid voltage drop and heat:

| Current | Minimum Wire (short run <3ft) | Recommended (>3ft) |
|---------|-------------------------------|-------------------|
| 1-3A | 22 AWG | 20 AWG |
| 3-5A | 20 AWG | 18 AWG |
| 5-10A | 16 AWG | 14 AWG |
| 10-15A | 14 AWG | 12 AWG |
| 15-20A | 12 AWG | 10 AWG |

### Voltage Drop Calculation

```
Voltage drop = (2 x Length x Current) / (Wire area x Conductivity)

Simplified for copper:
  Drop (V) = 2 x L(ft) x I(A) x R_per_ft

AWG resistance per foot:
  10 AWG: 0.001 ohm/ft
  12 AWG: 0.00159 ohm/ft
  14 AWG: 0.00253 ohm/ft
  16 AWG: 0.00402 ohm/ft
  18 AWG: 0.00639 ohm/ft

Keep voltage drop under 3% of system voltage.
For 12V system: max 0.36V drop.
```

---

## Fuses and Protection

**Every wire run needs a fuse.** A short circuit without a fuse can cause fire.

```
[Panel] --fuse-- [Controller] --fuse-- [Battery] --fuse-- [Load]
```

### Fuse Sizing

```
Fuse rating = max expected current x 1.25

Panel to controller: Panel Isc x 1.25
Battery to controller: Controller max charge current x 1.25
Battery to load: Max load current x 1.25
```

### Fuse Types

- **ATC blade fuses** -- automotive, cheap, easy to find, up to 40A
- **ANL fuses** -- higher current (40-300A), for battery main connections
- **Resettable PTC fuses** -- auto-reset, good for prototype circuits
- **Inline fuse holders** -- waterproof versions available for outdoor use

---

## Estimating Daily Power Needs

### Common Device Power Consumption

| Device | Voltage | Current | Power | Daily (24h) |
|--------|---------|---------|-------|-------------|
| Raspberry Pi 4 (idle) | 5V | 0.6A | 3W | 72Wh |
| Raspberry Pi 4 (load) | 5V | 1.0A | 5W | 120Wh |
| Raspberry Pi Zero 2W | 5V | 0.3A | 1.5W | 36Wh |
| ESP32 (active) | 3.3V | 0.15A | 0.5W | 12Wh |
| ESP32 (deep sleep) | 3.3V | 10uA | 0.03mW | ~0 |
| Baofeng radio (RX) | 7.4V | 0.15A | 1.1W | 26Wh |
| Baofeng radio (TX 5W) | 7.4V | 1.6A | 12W | varies |
| Meshtastic node | 3.3V | 0.08A | 0.3W | 7Wh |
| USB fan | 5V | 0.5A | 2.5W | 60Wh |
| LED light strip (1m) | 12V | 0.5A | 6W | 144Wh |
| Laptop (average) | 19V | 2.5A | 45W | 360Wh* |
| Phone charging | 5V | 2A | 10W | 10-20Wh |
| RTL-SDR + Pi | 5V | 0.8A | 4W | 96Wh |
| LoRa gateway | 5V | 0.5A | 2.5W | 60Wh |

\* Laptops are not on 24h -- figure 6-8 hours active use.

### Calculation Method

```
Step 1: List all devices with their power (watts) and daily hours of use
Step 2: Calculate Wh for each: Power x Hours = Wh
Step 3: Sum all Wh = Total daily energy need
Step 4: Account for inefficiency: Total x 1.3 (30% loss in controller/wiring/conversion)
Step 5: Battery size: Total x Days_of_autonomy / 0.8 (don't drain below 20%)
Step 6: Panel size: Total / Peak_sun_hours / 0.7 (panel efficiency factor)
```

**Peak sun hours**: varies by location and season
- Summer, clear: 5-7 hours
- Winter, clear: 3-4 hours
- Cloudy: 1-3 hours
- For field planning, use conservative estimates

---

## Example Setups

### Minimal: Phone + Radio Charging

```
Budget: ~$80-120
Panel: 20W folding
Controller: PWM 10A (or just a USB solar panel with built-in regulation)
Battery: 12V 6Ah LiFePO4 (72Wh)
Outputs: USB-A ports (from controller), 12V cigarette lighter adapter

Daily capacity: 72Wh
Daily need: phone (15Wh) + Baofeng (10Wh) = 25Wh
Autonomy without sun: ~2 days
Recharge time: ~4-5 hours (good sun)
Weight: ~2kg total
```

### Medium: Pi + Radio + Sensors

```
Budget: ~$200-300
Panel: 50W rigid or folding
Controller: MPPT 10A (Victron 75/10 or similar)
Battery: 12V 20Ah LiFePO4 (256Wh)
DC-DC: 12V to 5V 3A buck converter (for Pi)
Outputs: 12V for radio, 5V for Pi and USB devices

Devices:
  Pi 4 (24h): 5W x 24h = 120Wh
  Meshtastic node: 0.3W x 24h = 7Wh
  Phone charging: 15Wh
  Handheld radio: 10Wh
  Total: ~152Wh
  With losses: ~200Wh/day

Battery: 256Wh --> ~1 day without sun
Panel: 50W x 5h sun = 250Wh --> good match
Weight: ~5kg total
```

### Full: Multi-Device Field Station

```
Budget: ~$500-800
Panel: 2x 100W (parallel or MPPT handles series)
Controller: MPPT 30A
Battery: 12V 100Ah LiFePO4 (1280Wh)
Inverter: 300W pure sine (for laptop)
DC-DC converters: 12V to 5V (multiple), 12V to 19V (laptop direct)
Distribution: fused bus bar with Anderson Powerpole outputs

Devices:
  Pi 4 (24h): 120Wh
  Laptop (8h): 360Wh
  LoRa gateway (24h): 60Wh
  RTL-SDR (8h): 32Wh
  Phone charging (2x): 30Wh
  LED lighting (6h): 36Wh
  Radios: 30Wh
  Total: ~668Wh
  With losses: ~870Wh/day

Battery: 1280Wh --> 1 day+ without sun
Panels: 200W x 5h = 1000Wh --> covers daily need
Weight: ~25kg total (battery is ~12kg)
```

---

## Practical Tips

### Panel Positioning

- Face panels toward the equator (south in northern hemisphere)
- Tilt angle roughly equals your latitude for year-round average
- In summer, use a flatter angle; in winter, steeper
- Even partial shade on one cell can dramatically reduce the whole panel's output
- Clean panels regularly (dust, bird droppings, pollen)

### Temperature Effects

- Panels produce MORE power in cold weather (higher voltage)
- Panels produce LESS in extreme heat (lower voltage, ~0.4% per degree C)
- LiFePO4 batteries should not be charged below 0 deg C (some BMS have this protection built in)
- Keep electronics shaded; batteries in insulated compartment

### Monitoring

```
What to monitor:
- Battery voltage (most important)
- Panel voltage and current
- Load current
- Battery state of charge (SoC)

Tools:
- Victron SmartSolar app (Bluetooth)
- Watt meter (inline, ~$10, shows V/A/W/Wh)
- Multimeter (always have one)
- INA219/INA226 with Pi (programmatic monitoring)
```

### Safety

- Always connect battery to controller FIRST, then panel
- Always disconnect panel FIRST, then battery
- Never short-circuit a battery (even briefly -- enormous current)
- Use fuses on every positive wire
- Solar panels are always live in light (even cloudy) -- cover with opaque material when wiring
- LiFePO4 is safe, but still do not puncture, crush, or expose to extreme heat

---

## Wiring Diagram: Medium Setup

```
                    +----------+
                    |  50W     |
                    |  Panel   |
                    |  18V/2.8A|
                    +----+-----+
                         | MC4 connectors
                    +----+-----+
                    |  10A     | fuse
                    +----+-----+
                         |
              +----------+----------+
              |   MPPT Charge       |
              |   Controller        |
              |                     |
              | PV+  PV-  BAT+ BAT-|
              +--+----+----+----+--+
                           |    |
                    +------+----+---+
                    |  15A fuse     |
                    +------+--------+
                           |
              +------------+------------+
              |  12V 20Ah LiFePO4       |
              |  with built-in BMS      |
              +------------+------------+
                           |
         +-----------------+------------------+
         |                 |                  |
    +----+----+      +----+----+       +----+----+
    | 5A fuse |      | 3A fuse |       | 5A fuse |
    +----+----+      +----+----+       +----+----+
         |                |                  |
    +----+----+      +----+----+       +----+----+
    | 12V->5V |      | 12V out |       | USB hub |
    | Buck    |      | (radio) |       | w/power |
    | 3A      |      |         |       |         |
    +----+----+      +---------+       +---------+
         |
    +----+----+
    | RPi 4   |
    | + HAT   |
    +---------+
```
