# Field Solar Setup Guide

Portable solar power for electronics, communications, and off-grid computing.

---

## System Components

A field solar setup has four main components:

```
Solar Panel → Charge Controller → Battery → Load
```

1. **Solar panel** — Converts sunlight to DC electricity
2. **Charge controller** — Regulates charging, prevents overcharge/discharge
3. **Battery** — Stores energy for use when sun isn't available
4. **Load** — Your devices (radio, Pi, sensors, lights)

---

## Solar Panels

### Types for Field Use

| Type            | Efficiency | Weight      | Durability | Best For           |
|-----------------|------------|-------------|------------|--------------------|
| Monocrystalline | 20-24%     | Moderate    | Good       | Fixed/semi-portable|
| Folding (mono)  | 20-22%     | Light       | Good       | Backpack/field     |
| Flexible (thin) | 15-18%     | Very light  | Fair       | Mounting on packs  |
| Amorphous       | 8-12%      | Light       | Good       | Low light, cloudy  |

### Recommended Panel Sizes

| Panel Wattage | Typical Use                          | Weight   | Folded Size      |
|---------------|--------------------------------------|----------|------------------|
| 10W           | Phone charging, single sensor node   | ~0.5 kg  | Book-sized       |
| 21-28W        | Phone + small electronics            | ~0.7 kg  | Tablet-sized     |
| 50W           | Raspberry Pi + radio + phone         | ~2 kg    | Briefcase        |
| 100W          | Full field station                   | ~4 kg    | Large briefcase  |
| 200W          | Multiple devices, laptop charging    | ~7 kg    | Suitcase         |

### Panel Specifications

Key specs to understand:
- **Vmp** — Voltage at maximum power (operating voltage)
- **Imp** — Current at maximum power
- **Voc** — Open circuit voltage (no load, higher than Vmp)
- **Isc** — Short circuit current (maximum possible current)

**Important:** Panel output varies with sunlight intensity. Rated specs are at **STC** (Standard Test Conditions: 1000W/m2, 25C). Real-world output is typically 60-80% of rated.

### Panel Positioning

- Face the sun directly (perpendicular to rays) for maximum output
- In Northern Hemisphere: face south, tilt angle roughly equal to latitude
- Adjust every 2-3 hours if possible
- Shade on even one cell can reduce entire panel output drastically (bypass diodes help but don't eliminate the problem)

---

## Charge Controllers

### PWM (Pulse Width Modulation)

- Simpler, cheaper
- Panel voltage must roughly match battery voltage
- Less efficient — wastes excess panel voltage as heat
- Fine for small systems (under 50W)

### MPPT (Maximum Power Point Tracking)

- More expensive but 15-30% more efficient
- Converts excess voltage to current (like a DC-DC converter)
- Can use higher voltage panels with lower voltage batteries
- Worth it for systems over 50W

### Common Controllers

| Controller          | Type | Max Panel | Battery     | Price  |
|---------------------|------|-----------|-------------|--------|
| Generic 10A PWM     | PWM  | ~120W@12V | 12V/24V     | ~$8    |
| EPever Tracer 1210AN| MPPT | 130W@12V  | 12V/24V     | ~$50   |
| Victron SmartSolar  | MPPT | 100-450W  | 12V/24V/48V | ~$100+ |
| Genasun GV-5        | MPPT | 65W       | LiFePO4     | ~$80   |

### Controller Sizing

Controller current rating must exceed the panel's maximum current:

```
Panel Wattage / Battery Voltage = Minimum Controller Amps

Example: 100W panel, 12V battery
100W / 12V = 8.33A → Use at least a 10A controller
```

For MPPT, also check the maximum input voltage (Voc of panel must be below controller's max input).

---

## Batteries

### LiFePO4 (Lithium Iron Phosphate) — Recommended

**Why LiFePO4 for field use:**
- 2000-5000+ cycle life (vs 300-500 for lead-acid)
- Lightweight (1/3 the weight of lead-acid for same capacity)
- Flat discharge curve — steady voltage throughout discharge
- Safe chemistry — no thermal runaway, no toxic gases
- 80-100% usable capacity (vs 50% for lead-acid)
- Tolerates partial charge/discharge well

| Capacity | Voltage | Usable Energy | Weight  | Use Case                    |
|----------|---------|---------------|---------|------------------------------|
| 6Ah      | 12.8V   | 76.8 Wh       | ~0.8 kg | Single device, overnight     |
| 12Ah     | 12.8V   | 153.6 Wh      | ~1.5 kg | Pi + radio, 1-2 days         |
| 20Ah     | 12.8V   | 256 Wh        | ~2.5 kg | Full station, 2-3 days       |
| 50Ah     | 12.8V   | 640 Wh        | ~6 kg   | Extended deployment          |
| 100Ah    | 12.8V   | 1280 Wh       | ~12 kg  | Base camp                    |

### LiFePO4 Voltage Chart

| State of Charge | Cell Voltage | 4S (12V) Pack |
|-----------------|-------------|---------------|
| 100%            | 3.65V       | 14.6V         |
| 90%             | 3.35V       | 13.4V         |
| 80%             | 3.32V       | 13.3V         |
| 50%             | 3.30V       | 13.2V         |
| 20%             | 3.27V       | 13.1V         |
| 10%             | 3.20V       | 12.8V         |
| 0% (cutoff)     | 2.50V       | 10.0V         |

**Charge voltage:** 14.4-14.6V (3.6-3.65V per cell)
**Discharge cutoff:** 10.0V (2.5V per cell)

### Lead-Acid (Budget Alternative)

- Cheaper upfront
- Heavier (3x weight of LiFePO4)
- Only use 50% of capacity (deep discharge damages them)
- Shorter lifespan
- AGM (Absorbed Glass Mat) is best for portable use — no liquid acid

### Power Banks and USB Batteries

For very small setups:
- USB power banks (10,000-30,000 mAh at 3.7V)
- Charge via solar panel's USB output
- Good for phones, ESP32, small Pi projects
- Limited output current — may not support Pi 4 reliably

---

## Connectors and Wiring

### Anderson Powerpole Connectors

The standard for 12V DC field power distribution:

- Color-coded: Red (positive), Black (negative)
- Genderless — any connector mates with any other
- Rated 15A, 30A, or 45A depending on contact size
- Crimp connections (use proper ratcheting crimper)
- Standard in ham radio, ARES/RACES emergency communications

**Wiring convention (ARES standard):**
- Red housing on top (tongue up), black on bottom
- Pin on red (positive), socket on black (negative)

### Wire Gauges

| Wire Gauge (AWG) | Max Current (chassis) | Typical Use                  |
|-------------------|-----------------------|------------------------------|
| 18                | 16A                   | Small loads, sensors          |
| 16                | 22A                   | LED strips, fans              |
| 14                | 32A                   | Medium loads                  |
| 12                | 41A                   | Main power runs               |
| 10                | 55A                   | High current, battery cables  |

**Voltage drop matters on long runs.** Use a wire gauge calculator for runs over 3 meters.

### Fuses

**Always fuse the positive wire** close to the battery:

| Fuse Type        | Use Case                          |
|------------------|-----------------------------------|
| ATC blade fuse   | Automotive-style, easy to replace |
| Inline fuse      | Simple in-line protection         |
| Polyfuse (PTC)   | Self-resetting, for electronics   |
| Circuit breaker  | Reusable, for main battery line   |

**Fuse sizing:** 125% of maximum expected current.

---

## Daily Power Estimation

### Step 1: Calculate Daily Consumption

```
Device Power (W) x Hours/day = Watt-hours/day (Wh)

Example field station:
  Raspberry Pi 4:     5W  x 24h =  120 Wh
  LoRa radio:         0.1W x 24h =  2.4 Wh
  LED light:          3W  x 4h  =   12 Wh
  Phone charging:     10W x 2h  =   20 Wh
                                   --------
  Total:                           154.4 Wh/day
```

### Step 2: Size the Battery

Account for days without sun (autonomy) and depth of discharge:

```
Battery capacity = (Daily Wh x Days of autonomy) / (Battery voltage x DoD)

For LiFePO4 (90% DoD), 2 days autonomy:
= (154.4 x 2) / (12.8 x 0.9)
= 308.8 / 11.52
= 26.8 Ah → Use a 30Ah battery
```

### Step 3: Size the Solar Panel

Account for sun hours and system losses (~20%):

```
Panel watts = Daily Wh / (Sun hours x 0.8)

For 4 peak sun hours:
= 154.4 / (4 x 0.8)
= 48.25W → Use a 50-60W panel

For 6 peak sun hours (summer, clear):
= 154.4 / (6 x 0.8)
= 32.2W → Use a 40-50W panel
```

**Peak sun hours** vary by location and season. Conservative estimate: 3-4 hours for temperate regions, 5-6 for sunny/desert regions.

---

## Example Setups

### Minimal: Phone + Meshtastic Node

```
Components:
- 21W folding solar panel (~$30)
- USB power bank 20,000mAh (~$20)
- Meshtastic node (T-Beam) — powered from power bank USB

Daily usage: ~15 Wh
Panel produces: ~60 Wh on a sunny day
Runtime without sun: ~3-4 days
Total weight: ~0.8 kg
Total cost: ~$80
```

### Medium: Raspberry Pi Field Server

```
Components:
- 50W folding solar panel (~$60)
- 20Ah LiFePO4 12V battery (~$80)
- 10A PWM charge controller (~$10)
- 12V to 5V 3A USB-C buck converter (~$5)
- Anderson Powerpole connectors (~$15)
- 10A inline fuse (~$3)

Devices:
- Raspberry Pi 4 (5W continuous)
- Meshtastic node (0.1W)
- USB SSD (2W when active)

Daily usage: ~160 Wh
Battery capacity: 256 Wh (usable)
Runtime without sun: ~1.5 days
Panel produces: ~140 Wh on a sunny day
Total weight: ~5 kg
Total cost: ~$250
```

### Full: Off-Grid Communications Station

```
Components:
- 100W rigid or folding solar panel (~$100)
- 50Ah LiFePO4 12V battery (~$200)
- 20A MPPT charge controller (~$60)
- 12V distribution box with fuses
- Multiple DC-DC converters (12V→5V, 12V→3.3V)
- Anderson Powerpole distribution strip

Devices:
- Raspberry Pi 4 as server
- Meshtastic gateway node
- WiFi access point
- LED lighting
- Phone/laptop charging
- Environmental sensors

Daily usage: ~300 Wh
Battery capacity: 640 Wh (usable)
Runtime without sun: ~2 days
Panel produces: ~280 Wh on a sunny day
Total weight: ~18 kg
Total cost: ~$500
```

---

## Tips and Gotchas

1. **Always connect battery to controller first**, then panel. Disconnect in reverse order (panel first, then battery)
2. **Never connect panel directly to battery** without a charge controller
3. **Don't mix battery types** or batteries of different ages/capacities in parallel
4. **LiFePO4 needs LiFePO4-specific charge profile** — set your controller correctly (14.4V charge, not 14.7V for lead-acid)
5. **Shade kills solar output** — even partial shade on one cell affects the whole panel
6. **Temperature affects batteries** — LiFePO4 won't charge below 0C (most BMS will prevent it). Keep batteries insulated in cold weather
7. **Fuse everything** — especially the battery positive terminal
8. **Use silicone wire** for field use — more flexible, heat resistant, doesn't crack in cold
9. **Carry a multimeter** — essential for debugging power issues
10. **Label everything** — voltage, polarity, fuse rating, wire gauge
