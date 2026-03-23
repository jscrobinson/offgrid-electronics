# Water-Resistant Enclosures

> Protecting electronics from weather and environmental damage.

## IP Ratings

IP (Ingress Protection) ratings define how well an enclosure protects against solids and liquids.

Format: **IP[Solids][Liquids]** (e.g., IP67)

### Solids (First Digit)

| Rating | Protection |
|---|---|
| 0 | No protection |
| 1 | Objects >50mm |
| 2 | Objects >12.5mm (fingers) |
| 3 | Objects >2.5mm (tools, wires) |
| 4 | Objects >1mm (fine wires) |
| 5 | Dust-protected (limited ingress) |
| 6 | Dust-tight (no ingress) |

### Liquids (Second Digit)

| Rating | Protection |
|---|---|
| 0 | No protection |
| 1 | Vertical dripping water |
| 2 | Dripping water (15° tilt) |
| 3 | Spraying water (60° angle) |
| 4 | Splashing water (any direction) |
| 5 | Water jets (6.3mm nozzle) |
| 6 | Powerful water jets (12.5mm nozzle) |
| 7 | Temporary immersion (1m for 30 min) |
| 8 | Continuous immersion (depth specified) |

### Common Ratings for Electronics

- **IP54**: Dust-protected, splash-proof — indoor use, mild outdoor
- **IP65**: Dust-tight, water jets — outdoor mounting, weather stations
- **IP67**: Dust-tight, submersible to 1m — field deployment, rain/flooding
- **IP68**: Dust-tight, continuous submersion — underwater sensors

## Enclosure Types

### Pelican / Nanuk Cases

- Rugged, watertight (IP67+), crushproof, pressure relief valve
- Sizes from small (1010: phone-sized) to large (1600+: equipment cases)
- Customizable foam inserts
- Expensive ($20-200+) but nearly indestructible
- Best for: transport cases, mission-critical equipment

### Hammond / Bud Plastic Enclosures

- ABS or polycarbonate project boxes
- Flat or flanged lids, with or without gaskets
- Many sizes, mounting ears, DIN rail options
- $5-30 depending on size
- Best for: permanent installations, project enclosures

### Electrical Junction Boxes

- Widely available at hardware stores
- IP65-IP68 rated
- ABS or polycarbonate with gasket seal
- Knockouts for cable entry
- $3-15
- Best for: outdoor sensor nodes, relay boxes

### Ammo Cans

- Surplus metal ammo cans with rubber gasket
- Very rugged, waterproof, cheap ($5-15)
- Requires drilling for cables (seal with cable glands)
- Good for: base station enclosures, battery boxes

## Cable Entry

### Cable Glands (PG / Metric)

Cable glands provide waterproof cable entry points.

| Size | Cable Diameter | Thread |
|---|---|---|
| PG7 | 3-6.5mm | M12 |
| PG9 | 4-8mm | M15 |
| PG11 | 5-10mm | M18 |
| PG13.5 | 6-12mm | M20 |
| PG16 | 10-14mm | M22 |

Installation:
1. Drill hole matching the thread size
2. Insert gland from outside
3. Thread locknut on inside
4. Pass cable through, tighten compression nut
5. Test with water spray

### Waterproof Connectors

- **SP13/SP16 (e.g., Cnlinko)**: Circular waterproof connectors, 2-9 pins, IP67, screw-lock. Good for power and signal.
- **M12 connectors**: Industrial standard, IP67, various pin configurations. Common on sensors.
- **SMA bulkhead**: For antenna feedthrough. Panel-mount SMA with O-ring.

### Antenna Feedthrough

For LoRa, WiFi, or radio antennas:
1. Use a bulkhead SMA connector (panel mount)
2. Drill hole, mount with O-ring gasket
3. External antenna connects to outside SMA
4. Short pigtail (IPEX to SMA) connects to board inside

## Sealing Techniques

### Silicone Sealant

- Apply around cable glands, joints, and any drilled holes
- Use neutral cure silicone (won't corrode electronics)
- Let cure 24 hours before deployment
- Removable with a razor blade later

### Conformal Coating

Protects the PCB itself from moisture, salt spray, and contamination.

- **Types**: Acrylic (easy to apply/remove), silicone (flexible), polyurethane (tough), epoxy (permanent)
- **Application**: Spray or brush on the assembled PCB
- **Coverage**: Coat everything except connectors, buttons, and heat sinks
- **Brands**: MG Chemicals 422B (acrylic), Techspray Fine-L-Kote

### Hot Glue

Quick and dirty sealing for temporary deployments:
- Seal cable entry points
- Reinforce connector joints
- Fill gaps in enclosure
- Easy to remove later

## Moisture Management

### Desiccant Packs

- Include silica gel packets inside sealed enclosures
- Absorb moisture trapped during assembly
- Replace or recharge (bake at 120°C for 2 hours) periodically
- Indicating desiccant (blue → pink when saturated)

### Gore-Tex Vent Plugs

- Allow pressure equalization without letting water in
- Prevent condensation from temperature cycling
- Essential for enclosures that heat up in the sun (pressure builds)
- M12 thread, screw into drilled hole
- ~$2-5 each

## Thermal Management

### The Problem

Sealed enclosures trap heat. Electronics inside generate heat. Sun adds more heat.

### Solutions

1. **White or light-colored enclosure**: Reflects sunlight (saves 10-15°C vs black)
2. **Shade**: Mount on north side of structure, or add a sun shield
3. **Ventilation** (if IP65+ not required): Louvered vents, fan with dust filter
4. **Gore-Tex vents**: Allow some air exchange while keeping water out
5. **Thermal pads/standoffs**: Conduct heat from hot components to enclosure wall
6. **Reduce duty cycle**: Run processor intermittently, sleep between readings

### Temperature Monitoring

Include a BME280 or DS18B20 inside the enclosure to monitor internal temperature. Log it alongside your sensor data to catch thermal issues early.

## Mounting

- **Pole mount**: U-bolts or hose clamps around enclosure flanges
- **Wall mount**: Enclosure mounting ears + screws/anchors
- **DIN rail**: Many Hammond enclosures support DIN rail clips (common in control panels)
- **Zip ties**: Temporary mounting, surprisingly effective
- **Magnetic mount**: Epoxy magnets to flat enclosure bottom for steel surfaces

## Example: Outdoor LoRa Sensor Node

Bill of materials:
- IP67 junction box (~100×68×50mm)
- PG7 cable gland (for sensor cable)
- SMA bulkhead connector (for LoRa antenna)
- ESP32 + LoRa module (Heltec V3 or T-Beam)
- BME280 sensor (can mount externally via gland)
- 18650 battery + TP4056 charger
- Small solar panel (6V 1W)
- Silica gel packet
- Conformal coating on PCB

Assembly:
1. Coat PCB with conformal coating, let dry
2. Install cable glands and SMA bulkhead
3. Mount board inside with standoffs or hot glue
4. Route sensor cable through PG7 gland, tighten
5. Connect antenna pigtail to SMA bulkhead
6. Add desiccant packet
7. Seal lid, test with garden hose spray
