# Power Calculations for Electronics Projects

The math you need to size batteries, estimate runtime, and design power systems.

---

## Fundamental Formulas

### Ohm's Law and Power
```
V = I x R        Voltage (V) = Current (A) x Resistance (ohms)
P = V x I        Power (W) = Voltage (V) x Current (A)
P = I^2 x R      Power (W) = Current^2 x Resistance
P = V^2 / R      Power (W) = Voltage^2 / Resistance
```

### Energy
```
Energy (Wh) = Power (W) x Time (h)
Energy (Wh) = Voltage (V) x Current (A) x Time (h)
Energy (J)  = Power (W) x Time (s)        [1 Wh = 3600 J]
```

---

## Battery Capacity Conversions

Battery capacity is often listed in mAh, but energy content depends on voltage.

### mAh to Wh
```
Wh = mAh x V / 1000
```

**Examples:**

| Battery | Capacity | Voltage | Energy |
|---------|----------|---------|--------|
| 18650 cell | 3000 mAh | 3.7V | 11.1 Wh |
| 21700 cell | 5000 mAh | 3.7V | 18.5 Wh |
| LiPo pack | 10000 mAh | 3.7V | 37.0 Wh |
| 3S Li-ion pack | 3000 mAh | 11.1V | 33.3 Wh |
| USB power bank (listed as "10000mAh") | 10000 mAh @ 3.7V | 3.7V (internal) | 37 Wh (actual ~30-33 Wh after conversion losses) |
| Lead-acid | 7000 mAh (7Ah) | 12V | 84 Wh (42 Wh usable at 50% DoD) |
| AA NiMH | 2000 mAh | 1.2V | 2.4 Wh |
| AA Alkaline | 2500 mAh | 1.5V | 3.75 Wh |

**Power bank marketing note:** A "10000mAh" power bank has 37Wh of energy at its internal 3.7V cell voltage. When boosted to 5V USB output, the available capacity is about 37Wh / 5V = 7400mAh at 5V — minus 10-15% conversion losses. So you actually get roughly 6500-6800 mAh at 5V. This is not a scam; it's physics.

---

## Runtime Calculations

### Basic Runtime
```
Runtime (hours) = Battery energy (Wh) / Load power (W)
```

### Example: ESP32 Meshtastic Node on 18650

**Active WiFi mode:**
- Current draw: ~160mA at 3.3V
- Power: 0.16A x 3.3V = 0.53W
- But the ESP32 is powered through a voltage regulator from the 3.7V cell
- Actual draw from battery: ~0.53W / 0.85 (regulator efficiency) = 0.62W
- Battery: 3000mAh 18650 = 11.1 Wh
- Runtime: 11.1 / 0.62 = **17.9 hours**

**Deep sleep mode:**
- Current draw: ~10 uA at 3.3V
- Power: 0.00001A x 3.3V = 0.000033W = 33 uW
- Battery: 11.1 Wh = 11,100,000 uWh
- Runtime: 11,100,000 / 33 = 336,364 hours = **38.4 years**
- In practice, battery self-discharge limits this to a few years

**Meshtastic T-Beam (typical usage with GPS + LoRa):**
- Active receive: ~120mA at 3.7V = 0.44W
- GPS active: adds ~30-50mA
- LoRa transmit (short bursts): ~120mA additional during TX
- Average with default settings: ~0.5W
- Battery: 3000mAh 18650 = 11.1 Wh
- Runtime: 11.1 / 0.5 = **~22 hours**
- With power-saving settings (reduced GPS, longer sleep): **36-72+ hours**

### Example: Raspberry Pi 4

| State | Current @ 5V | Power |
|-------|-------------|-------|
| Idle (no peripherals) | ~600mA | ~3W |
| Light load | ~800mA | ~4W |
| Full CPU load (4 cores) | ~1200mA | ~6W |
| With USB peripherals | Add per device | +0.5-2.5W each |

- Running a Pi 4 at ~4W average from a 100Wh battery: 100 / 4 = **25 hours**
- Running from a 50W solar panel with 4 peak sun hours: 50W x 4h = 200Wh generated. 4W x 24h = 96Wh consumed. Feasible with adequate battery buffer.

### Example: T-Beam with GPS + LoRa (Meshtastic)

| Mode | Current @ 3.7V | Power |
|------|----------------|-------|
| Full active (GPS + LoRa RX) | ~120mA | ~0.44W |
| LoRa TX burst | ~240mA | ~0.89W |
| GPS power save mode | ~80mA | ~0.30W |
| Light sleep | ~15mA | ~0.06W |
| Deep sleep | ~10uA | ~0.037mW |

Average for a router node: ~80-120mA depending on traffic and settings.

---

## Duty Cycling to Extend Battery Life

Duty cycling is the most effective way to extend battery life for wireless devices.

### Concept
Instead of running continuously, the device wakes up periodically, does its task, then goes back to sleep.

```
Average current = (active_current x active_time + sleep_current x sleep_time) / total_period
```

### Example: ESP32 Sensor Node
- Active: 160mA for 5 seconds (measure sensor, transmit)
- Deep sleep: 10uA for 295 seconds (5-minute interval)
- Cycle period: 300 seconds

```
Average = (160mA x 5s + 0.01mA x 295s) / 300s
Average = (800 + 2.95) / 300
Average = 2.68 mA
```

Runtime with 3000mAh cell: 3000 / 2.68 = **1119 hours = 46.6 days**

Compare to always-on: 3000 / 160 = 18.75 hours. Duty cycling gave us **60x improvement**.

### Meshtastic Power Saving Options
- **Power Save mode:** radio goes to sleep between listen intervals
- **Reduce GPS frequency:** set position broadcast interval longer, enable GPS power save
- **Router role with sleep:** ROUTER_CLIENT sleeps between receive windows
- **Screen timeout:** OLED displays draw 20-30mA — set short screen timeout or disable

---

## Voltage Regulator Efficiency

Every voltage regulator between the battery and load wastes some power. This significantly impacts runtime calculations.

### Linear Regulators (LDO)
- **Efficiency = Vout / Vin** (always)
- Example: AMS1117-3.3 converting 5V to 3.3V: efficiency = 3.3/5 = 66%. One-third of the energy is wasted as heat.
- Example: 3.7V Li-ion to 3.3V via LDO: efficiency = 3.3/3.7 = 89%. Much better when voltage difference is small.
- **Use LDOs when:** input voltage is close to output voltage (dropout < 0.5V)

### Switching Regulators (Buck/Boost)
- **Efficiency:** typically 85-95%, relatively constant across voltage ranges
- **Buck (step-down):** input voltage higher than output
- **Boost (step-up):** input voltage lower than output
- **Buck-boost:** handles input above or below output
- **Use switchers when:** voltage difference is large, or efficiency matters for battery life

### Impact on Runtime

A 3.7V 18650 powering an ESP32 at 3.3V:

| Regulator Type | Efficiency | Effective Battery Capacity | Runtime Difference |
|---------------|------------|---------------------------|-------------------|
| LDO (AMS1117) | 89% | 11.1 Wh x 0.89 = 9.88 Wh | Baseline |
| Buck (TPS63001) | 93% | 11.1 Wh x 0.93 = 10.32 Wh | +4.5% |
| Direct (no reg) | ~100% | 11.1 Wh | +12% (but voltage varies) |

When the source is 12V and load needs 3.3V, the difference is dramatic:

| Regulator Type | Efficiency | Power Wasted (at 500mA load) |
|---------------|------------|------------------------------|
| LDO | 28% (3.3/12) | 4.35W wasted as heat! |
| Buck converter | ~90% | 0.18W wasted |

**Rule of thumb:** never use an LDO when Vin is more than ~1.5x Vout.

---

## Wire Gauge and Voltage Drop

Using wire that is too thin causes voltage drop, power loss (as heat), and potentially fire.

### AWG Wire Current Capacity (Copper, Chassis Wiring)

| AWG | Diameter (mm) | Max Current (chassis) | Resistance (ohms/m) | Common Use |
|-----|--------------|----------------------|---------------------|------------|
| 30 | 0.25 | 0.5A | 0.339 | Signal wires, LEDs |
| 28 | 0.32 | 0.7A | 0.213 | Low-current connections |
| 26 | 0.40 | 1.0A | 0.134 | Breadboard jumpers |
| 24 | 0.51 | 1.5A | 0.084 | USB cables, small loads |
| 22 | 0.64 | 3A | 0.053 | General hookup wire |
| 20 | 0.81 | 5A | 0.033 | Power connections |
| 18 | 1.02 | 7A | 0.021 | Battery packs, motors |
| 16 | 1.29 | 10A | 0.013 | High-current DC |
| 14 | 1.63 | 15A | 0.0083 | Solar panel runs |
| 12 | 2.05 | 20A | 0.0052 | Main battery cables |
| 10 | 2.59 | 30A | 0.0033 | Inverter connections |

*Current ratings are approximate for single conductors in free air at room temperature. Bundled wires in conduit need to be derated.*

### Voltage Drop Calculation
```
Voltage drop = Current (A) x Resistance (ohms/m) x Length (m) x 2
                                                            ^^^ round trip (positive + negative wire)
```

**Example:** 5A through 3 meters of 18 AWG wire
```
V_drop = 5A x 0.021 ohms/m x 3m x 2 = 0.63V
Power lost = 5A x 0.63V = 3.15W
```

On a 12V system, that's 5.25% loss — acceptable.
On a 5V system, that's 12.6% loss — problematic. Use thicker wire or shorter runs.

### Rules of Thumb
- Keep voltage drop under 3% for power runs
- Use the shortest wire runs possible
- When in doubt, go one gauge thicker
- For solar panel to charge controller runs, use 10-14 AWG depending on current
- For 12V battery to inverter, use the thickest practical wire (8-10 AWG for 500W inverter)
- Anderson PowerPole connectors are standard for 12V DC distribution in ham radio and off-grid setups (15A, 30A, 45A ratings)

---

## Quick Reference Calculations

### How long will my battery last?
```
Hours = (Battery_mAh x Battery_V) / (Load_W x 1000)
```

### How big a battery do I need?
```
Battery_Wh = Load_W x Hours_needed x 1.2 (margin)
Battery_mAh = Battery_Wh / Battery_V x 1000
```

### How big a solar panel do I need?
```
Panel_W = (Load_W x 24) / (Sun_hours x 0.7)
          [0.7 accounts for system losses]
```

### How long to charge a battery from solar?
```
Charge_hours = Battery_Wh / (Panel_W x Charge_controller_efficiency)
```
This is in "sun hours" — actual clock time depends on time of day and weather.

### Converting between 5V USB mAh and actual Wh
```
Wh = USB_mAh x 5 / 1000
True_internal_mAh = Wh / 3.7 x 1000
```

A device rated "3A @ 5V" draws 15W. From a 37Wh power bank: 37/15 = 2.5 hours runtime.
