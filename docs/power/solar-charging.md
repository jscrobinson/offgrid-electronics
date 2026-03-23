# Solar Charging for Off-Grid Electronics

Everything you need to know to power your projects from the sun.

---

## Solar Panel Types

### Monocrystalline
- **Efficiency:** ~20-22% (highest of common panel types)
- **Appearance:** dark black/blue, uniform color, rounded cell corners (or half-cut cells)
- **Cost:** most expensive per watt
- **Best for:** limited space where you need maximum output per square meter
- **Lifespan:** 25-30 years

### Polycrystalline
- **Efficiency:** ~15-18%
- **Appearance:** blue, speckled/marbled look
- **Cost:** cheaper than mono
- **Best for:** budget installations where space is not constrained
- **Lifespan:** 25-30 years

### Thin-Film (Amorphous)
- **Efficiency:** ~10-12%
- **Appearance:** uniform dark appearance, can be flexible
- **Cost:** cheapest per panel (but more panels needed for same output)
- **Best for:** curved surfaces, flexible/portable panels, partial shade tolerance
- **Lifespan:** 10-20 years
- **Advantage:** performs better in partial shade and high temperatures than crystalline types

### For DIY Projects
Small panels commonly available for electronics projects:

| Panel | Voltage | Current | Use Case |
|-------|---------|---------|----------|
| 5V/1W | 5V Vmp | 200mA | ESP32 trickle charge |
| 6V/2W | 6V Vmp | 330mA | TP4056 + single cell |
| 6V/6W | 6V Vmp | 1A | TP4056 at full charge rate |
| 12V/10W | 18V Voc | 560mA | Small 12V battery top-off |
| 18V/50W | 18V Vmp | 2.78A | Serious off-grid node power |
| 18V/100W | 18V Vmp | 5.55A | Full off-grid system |

---

## Understanding Panel Ratings

Every solar panel has these four key electrical ratings (found on the back label or datasheet):

### Vmp — Voltage at Maximum Power
- The voltage the panel produces when delivering maximum power
- This is the operating voltage you should design around
- Example: 18V Vmp means the panel outputs 18V under optimal load

### Imp — Current at Maximum Power
- The current the panel delivers at maximum power
- Example: 5.55A Imp

### Voc — Open Circuit Voltage
- The voltage when no load is connected (panel disconnected from everything)
- Always higher than Vmp (typically 15-25% higher)
- **Important for charge controller input rating** — the controller must handle Voc
- Example: a "12V" panel might have Voc of 22V

### Isc — Short Circuit Current
- The maximum current the panel can produce (output shorted)
- Slightly higher than Imp
- Solar panels are inherently current-limited, so shorting won't damage them
- Example: 5.8A Isc

### Power Rating
- **Wattage = Vmp x Imp**
- Example: 18V x 5.55A = ~100W
- Rated under STC (Standard Test Conditions): 1000 W/m2 irradiance, 25C cell temperature, AM1.5 spectrum
- **Real-world output is typically 70-85% of rated power** due to temperature, angle, clouds, dust, and wire losses

---

## Charge Controllers

A charge controller sits between the solar panel and the battery. It regulates voltage and current to safely charge the battery and prevent overcharging.

**Never connect a solar panel directly to a lithium battery.** Even small panels can produce voltages that exceed safe charging limits.

### PWM (Pulse Width Modulation)

- **How it works:** essentially a switch that connects/disconnects the panel from the battery rapidly. The panel voltage is pulled down to the battery voltage.
- **Efficiency:** panel operates at battery voltage, not its optimal Vmp. Significant energy is wasted.
- **Requirement:** panel Vmp must be close to battery voltage (use a "12V" panel for a 12V battery)
- **Cost:** $5-20 for small controllers
- **Best for:** very small systems, tight budgets, when panel is already voltage-matched

**PWM Example:**
A 12V/100W panel (Vmp 18V) charging a 12V battery through a PWM controller. The panel is forced to operate at ~13V (battery voltage) instead of its optimal 18V. You lose ~28% of potential power.

### MPPT (Maximum Power Point Tracking)

- **How it works:** a DC-DC converter that finds the panel's optimal operating point (Vmp/Imp) and converts it to the correct battery charging voltage/current
- **Efficiency:** extracts maximum power from the panel regardless of battery voltage
- **Advantage:** typically 20-30% more energy harvested compared to PWM
- **Voltage flexibility:** panel voltage can be much higher than battery voltage
- **Cost:** $30-200+ depending on capacity
- **Best for:** any system where efficiency matters, mismatched panel/battery voltages, larger systems

**MPPT Example:**
Same 12V/100W panel (Vmp 18V, Imp 5.55A). MPPT controller operates the panel at 18V/5.55A = 100W, then converts down to 14.4V at ~6.7A for battery charging (minus ~5% conversion losses). You get about 25% more charging current than PWM.

### Common Controllers

#### Large Systems (12V/24V/48V)
| Controller | Type | Input V | Battery | Amps | Notes |
|-----------|------|---------|---------|------|-------|
| Victron SmartSolar 75/15 | MPPT | 75V max | 12/24V | 15A | Bluetooth, excellent software, gold standard |
| Victron SmartSolar 100/30 | MPPT | 100V max | 12/24V | 30A | For larger arrays |
| EPever Tracer 2210AN | MPPT | 100V max | 12/24V | 20A | Good budget option, RS485 |
| EPever Tracer 1210AN | MPPT | 100V max | 12/24V | 10A | Smaller budget MPPT |
| Renogy Wanderer 10A | PWM | 25V max | 12V | 10A | Cheap and simple |

#### Small Systems (IC-level for PCB projects)
| IC | Type | Input V | Output | Notes |
|----|------|---------|--------|-------|
| CN3791 | MPPT | 4.5-6V | 4.2V (1 cell) | Set MPPT voltage via resistor divider, up to 4A charge |
| BQ25895 | Buck-boost | 3.9-14V | 4.2V (1 cell) | I2C configurable, USB + solar input |
| LT3652 | MPPT | 4.95-32V | Multi-chemistry | High voltage input, good for 18V panels |
| SPV1040 | MPPT boost | 0.3-5.5V | Up to 5V | For very small panels, boost topology |

---

## System Sizing

### Step 1: Calculate Daily Energy Consumption

Add up everything your system powers:

```
Device                  Power    Hours/day    Energy/day
ESP32 (active WiFi)     0.5W     24h          12 Wh
GPS                     0.1W     24h          2.4 Wh
LoRa TX (duty cycle)    0.05W    24h          1.2 Wh
                                    Total:     15.6 Wh/day
```

### Step 2: Account for Inefficiencies

- Charge controller losses: ~10-15%
- Battery charge/discharge losses: ~10-15%
- Wire losses: ~2-5%
- **Rule of thumb: multiply your load by 1.3 to account for all losses**

Adjusted consumption: 15.6 x 1.3 = **20.3 Wh/day**

### Step 3: Size the Solar Panel

- Determine your **peak sun hours** (PSH) — the equivalent hours of full 1000 W/m2 sunlight per day
  - Southern US summer: 5-6 PSH
  - Northern US summer: 4-5 PSH
  - Winter anywhere in US: 2-4 PSH
  - Cloudy/rainy regions: 2-3 PSH
  - **Design for the worst month you need to operate in**

```
Panel watts = Daily Wh / Peak Sun Hours
Panel watts = 20.3 / 4 (conservative) = 5.1W minimum
```

Add margin: **use a 10W panel** (2x is a good safety factor for weather variability)

### Step 4: Size the Battery

- How many days of autonomy do you need without sun?
- For a Meshtastic node: 2-3 days is reasonable

```
Battery Wh = Daily consumption x Days of autonomy
Battery Wh = 15.6 x 3 = 46.8 Wh

For Li-ion: 46.8 Wh / 3.7V = 12,648 mAh = ~4x 3000mAh 18650s
For lead-acid (50% DoD): 46.8 / 0.5 = 93.6 Wh usable → need ~93.6 Wh battery
```

---

## Wiring

### Standard System Wiring
```
Solar Panel(s)
      |
      | (size wire for Isc of panel)
      |
[Charge Controller]
      |
      | (size wire for charge current)
      |
[Battery / Battery Pack with BMS]
      |
      | (fuse here, size for max load current)
      |
[Load] or [DC-DC converter] → [Load]
      |
(optional) [Inverter] → AC loads
```

### Important Wiring Notes
- **Fuse every positive wire** as close to the battery as possible
- **Use appropriately sized wire** — see power-calculations.md for AWG table
- **Connect charge controller to battery FIRST, then connect the panel.** Disconnect in reverse order (panel first, then battery).
- **Never disconnect the battery while the panel is connected** — the charge controller needs the battery as a load to regulate voltage. Without it, the panel voltage can spike and damage the controller.

---

## Small-Scale Solar for Microcontroller Projects

### ESP32 + TP4056 + Small Solar Panel

The simplest possible solar charging setup for a Meshtastic node or sensor:

```
6V/2W Solar Panel
      |
[1N5817 Schottky Diode] (prevents reverse current at night)
      |
[TP4056 module with protection] (IN+ / IN-)
      |                    |
[3.7V 18650 cell]    [OUT+ / OUT-]
      (BAT+/BAT-)         |
                     [Load: ESP32 board]
```

**Notes:**
- The TP4056 needs at least 4.5V input, so a 5V panel may not provide enough voltage under load. Use a 6V panel.
- The TP4056 is a linear charger — excess voltage is dissipated as heat. A 6V panel is fine; a 12V panel will overheat the TP4056 or destroy it. Stay under 8V input.
- The 1N5817 Schottky diode drops ~0.3V and prevents the battery from discharging back through the panel at night. Some TP4056 boards have this built in — check your specific board.
- This setup has no MPPT — the panel often won't operate at its optimal voltage. For a small system this is an acceptable tradeoff for simplicity.

### Better: CN3791 Solar MPPT Charger

For more efficient small-scale solar charging:

```
6V Solar Panel
      |
[CN3791 MPPT charger module]
      |
[3.7V Li-ion cell]
      |
[Load]
```

- The CN3791 tracks the panel's maximum power point using a voltage divider (set the MPPT voltage to ~80% of Voc)
- Significantly more efficient than TP4056 for solar input
- Modules available on AliExpress for $1-3
- Set MPPT voltage via resistor divider on the MPPT pin

---

## Partial Shading

Partial shading is one of the biggest real-world performance killers for solar panels.

- A single shaded cell in a series string can reduce the entire panel's output dramatically (the shaded cell becomes a resistor)
- Most panels have bypass diodes that allow current to flow around shaded cell groups, but you still lose that section's output
- **For small DIY installations:** keep the entire panel in full sun. Even a shadow from a wire or branch matters.
- **Panel placement:** avoid locations where trees, buildings, or other objects will shade the panel at any point during the day
- Thin-film panels handle partial shade somewhat better than crystalline panels

---

## Panel Angle and Orientation

### Fixed Installations
- **Orientation:** face panels toward the equator (south in Northern Hemisphere, north in Southern Hemisphere)
- **Tilt angle for maximum annual output:** roughly equal to your latitude
  - 30 degrees latitude → 30 degree tilt
  - 45 degrees latitude → 45 degree tilt
- **Winter optimization:** add 15 degrees to latitude angle
- **Summer optimization:** subtract 15 degrees from latitude angle

### Adjustable Mounting
- If you can adjust seasonally, tilt steeper in winter and flatter in summer
- Even a simple two-position mount (summer/winter) captures significantly more energy than a fixed mount

### Flat Mounting
- A panel laid flat (0 degrees) loses about 10-25% annual output compared to optimal tilt (varies by latitude)
- For rooftop mounting on a flat roof where aesthetics or wind loading matter, flat is an acceptable compromise
- For a portable/temporary Meshtastic solar node, flat on the ground works — just aim for full sun

### Temperature Effects
- Solar panels lose efficiency as they get hotter (~0.3-0.5% per degree C above 25C for crystalline)
- Allow airflow behind the panel — don't mount flush against a surface
- This is why panels often produce more power on a cool sunny spring day than a hot summer day
