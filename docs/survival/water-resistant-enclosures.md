# Water-Resistant Enclosures

IP ratings, enclosure types, sealing, thermal management, and protecting electronics in the field.

---

## IP (Ingress Protection) Ratings

The IP code defines protection against solids and liquids. Format: **IP[solids][liquids]**

### Solids (First Digit)

| Rating | Protection Against         | Size          |
|--------|----------------------------|---------------|
| 0      | No protection              | —             |
| 1      | Large objects              | >50mm         |
| 2      | Fingers                    | >12.5mm       |
| 3      | Tools, thick wires         | >2.5mm        |
| 4      | Most wires, screws         | >1mm          |
| 5      | Dust protected (limited)   | Some dust OK  |
| 6      | Dust tight (complete)      | No dust       |

### Liquids (Second Digit)

| Rating | Protection Against              | Test                              |
|--------|---------------------------------|-----------------------------------|
| 0      | No protection                   | —                                 |
| 1      | Vertical drips                  | Dripping water                    |
| 2      | Drips at 15 degree tilt         | Light rain                        |
| 3      | Spraying water                  | Rain at 60 degree angle           |
| 4      | Splashing water                 | Splashing from any direction      |
| 5      | Water jets                      | 6.3mm nozzle, any direction       |
| 6      | Powerful water jets             | 12.5mm nozzle, any direction      |
| 7      | Temporary immersion             | 1m depth for 30 minutes           |
| 8      | Continuous immersion            | Manufacturer-specified depth/time |

### Common Ratings for Projects

| Rating | Meaning                  | Suitable For                      |
|--------|--------------------------|-----------------------------------|
| IP20   | Finger protection only   | Indoor electronics                |
| IP44   | Splash protected         | Sheltered outdoor                 |
| IP54   | Dust + splash protected  | Outdoor, under eaves              |
| IP65   | Dust tight + water jets  | Fully outdoor, exposed            |
| IP67   | Dust tight + immersion   | Field deployment, rain            |
| IP68   | Dust tight + submersion  | Underwater, severe conditions     |

---

## Enclosure Types

### Pelican / Seahorse Cases

**Best for:** Transport and semi-permanent field deployment.

- IP67 rated
- Extremely durable (crushproof, dustproof, waterproof)
- Automatic pressure equalization valve
- Available with customizable foam or padded dividers
- Expensive but worth it for critical equipment

| Model        | Internal Dimensions     | Use Case              | Price  |
|--------------|------------------------|-----------------------|--------|
| Pelican 1010 | 111 x 73 x 43 mm      | Small electronics     | ~$20   |
| Pelican 1150 | 208 x 144 x 92 mm     | Pi + accessories      | ~$30   |
| Pelican 1200 | 235 x 181 x 105 mm    | Medium station        | ~$35   |
| Pelican 1450 | 374 x 260 x 154 mm    | Full field kit        | ~$80   |
| Pelican 1550 | 473 x 360 x 196 mm    | Large deployment      | ~$120  |

**Seahorse** cases are compatible alternatives at lower prices.

### Hammond Manufacturing Enclosures

**Best for:** Permanent outdoor electronics installations.

- ABS or polycarbonate plastic, or die-cast aluminum
- IP65-IP68 depending on model
- Designed for mounting PCBs inside
- Multiple sizes, often with clear lids

| Series       | Material      | IP Rating | Notes                        |
|--------------|---------------|-----------|------------------------------|
| 1554/1555    | ABS           | IP66      | General purpose, cheap       |
| 1554 (clear) | Polycarbonate | IP66      | See-through lid              |
| 1590         | Die-cast Al   | IP54      | EMI shielding, RF projects   |
| RL6000       | ABS           | IP65      | Hinged lid, DIN rail mount   |

### Electrical Junction Boxes

**Best for:** Budget permanent installations.

- Available at hardware stores
- PVC or ABS
- IP54-IP65 typical
- Knockouts for cable entry
- Very affordable ($5-15)

Brands: Carlon, Cantex, Gewiss

### 3D Printed Enclosures

**Best for:** Custom fit, prototyping.

- PETG or ASA filament (UV resistant, better than PLA)
- Add O-ring groove for water resistance
- Seal the print lines with epoxy or silicone
- Not inherently waterproof — layer lines leak

**Improving water resistance of 3D prints:**
1. Print with 100% infill or high wall count
2. Use ironing or vapor smoothing on sealing surfaces
3. Apply conformal coating or epoxy to exterior
4. Use an O-ring in a groove at the lid seam
5. Seal cable entries with cable glands

---

## Cable Glands

Cable glands provide sealed, strain-relieved cable entry into enclosures.

### Types

| Type             | Use                                  | IP Rating |
|------------------|--------------------------------------|-----------|
| Nylon (PG/M)     | Standard cable entry                | IP68      |
| Metal (brass)    | EMI shielding, heavy-duty           | IP68      |
| Flat cable gland | Ribbon cables, flat flex            | IP65      |
| Ventilation gland| Allow airflow while blocking water  | IP67      |

### Standard Sizes

| Thread Size | Cable Diameter | Hole Diameter |
|-------------|---------------|---------------|
| PG7 / M12   | 3-6.5mm       | 12.5mm        |
| PG9 / M16   | 4-8mm         | 16mm          |
| PG11 / M20  | 5-10mm        | 20mm          |
| PG13.5 / M20| 6-12mm        | 20mm          |
| PG16 / M22  | 10-14mm       | 22mm          |

### Installation

1. Drill hole to matching diameter
2. Insert gland body from outside
3. Thread locknut on inside
4. Pass cable through
5. Tighten compression nut to seal around cable

**Tip:** For cables smaller than the gland range, wrap the cable with self-fusing silicone tape to build up diameter for a good seal.

### For Antenna Cables

Use a bulkhead SMA or N-type connector instead of a cable gland:
- Drill hole for the connector
- Mount with supplied nut and washer
- Apply silicone sealant around the flange
- Connect antenna on outside, pigtail on inside

---

## Conformal Coating

Protects bare PCBs from moisture, dust, and corrosion.

### Types

| Coating              | Protection | Ease of Use | Rework   | Notes                     |
|----------------------|------------|-------------|----------|---------------------------|
| Acrylic (1B)         | Good       | Easy        | Easy     | Most common hobby choice  |
| Silicone (1C3)       | Excellent  | Easy        | Moderate | Flexible, wide temp range |
| Urethane (1A)        | Excellent  | Moderate    | Hard     | Very tough, chemical res. |
| Epoxy                | Excellent  | Moderate    | Very hard| Permanent, rigid          |

### Application

```
Products:
- MG Chemicals 422B (acrylic, brush or spray)
- Electrolube HPA (acrylic spray)
- Dow Corning 1-2577 (silicone)
- Clear nail polish (budget emergency option)
```

**Steps:**
1. Clean the PCB (isopropyl alcohol)
2. Mask connectors, buttons, sensors, and anything that needs contact
3. Apply thin, even coat (brush or spray)
4. Let cure (30 min for acrylic, longer for others)
5. Apply second coat
6. Remove masking tape

**Don't coat:** USB connectors, SD card slots, programming headers, sensor elements, buttons, antenna traces, heat sinks.

---

## Desiccant

Absorbs moisture inside sealed enclosures.

### Types

| Type              | Capacity  | Reusable | Notes                           |
|-------------------|-----------|----------|---------------------------------|
| Silica gel         | Good      | Yes      | Most common, change when pink   |
| Indicating silica  | Good      | Yes      | Blue to pink or orange to green |
| Molecular sieve    | Excellent | Yes      | Better at low humidity           |
| Calcium chloride   | Very good | No       | Turns to liquid — messy          |

### Sizing

Rule of thumb: **5-10 grams of silica gel per liter** of enclosure volume.

### Regeneration

Reuse indicating silica gel by drying it out:
- Oven: 120C (250F) for 1-2 hours
- Microwave: 2-3 minutes at medium power (watch carefully)
- Color returns to original (blue or orange) when dry

---

## Gore-Tex Vents (Pressure Equalization)

### Why They're Needed

Sealed enclosures experience pressure changes from temperature swings. Without equalization:
- Rising temperature creates positive pressure that can blow out gaskets
- Falling temperature creates negative pressure that sucks moisture in through seals

### How They Work

PTFE (Gore-Tex) membrane allows air to pass but blocks water, dust, and insects. Typically IP67-IP68 rated.

### Products

| Product                  | Thread  | IP Rating | Price  |
|--------------------------|---------|-----------|--------|
| Gore PolyVent (PMF)      | M12     | IP68/IP69 | ~$5    |
| Amphenol vent plug       | M12/M16 | IP67      | ~$3    |
| Generic PTFE vent screw  | M12     | IP67      | ~$1-2  |

Install in a threaded hole on the enclosure, preferably on the bottom (drip direction) or under an overhang.

---

## Thermal Management

### The Problem

Sealed enclosures trap heat from:
- Electronics (processors, voltage regulators, radios)
- Solar radiation on the enclosure itself
- High ambient temperature

### Solutions

**Passive:**
- **White or reflective enclosure** — Reduces solar absorption by 50%+
- **Shade/overhang** — Keep enclosure out of direct sun
- **Thermal pad to enclosure wall** — Use the case as a heatsink
- **Larger enclosure** — More air volume = more thermal mass
- **Aluminum enclosure** — Conducts heat better than plastic

**Active (use sparingly — costs power):**
- **Fan with filtered inlet** — IP-rated fan assemblies exist
- **Peltier cooler** — Thermoelectric cooling (power hungry, 30-60W)
- **Heat pipes** — Route heat to external heatsink

### Temperature Limits

| Component          | Max Temp | Notes                             |
|--------------------|----------|-----------------------------------|
| LiFePO4 battery    | 45C charging | Reduce charge rate above 35C  |
| RPi 4              | 85C (throttles) | Add heatsink + fan above 60C |
| ESP32              | 85C      | Usually fine without cooling       |
| OLED display       | 70C      | Reduce brightness in heat          |
| SD card            | 85C      | Unreliable above 70C              |

### Enclosure Temperature in Sun

A black enclosure in direct sun can reach **60-80C** internally. A white enclosure under the same conditions: **40-55C**. Always use white or light colored enclosures for outdoor deployment.

---

## Mounting

### Internal Mounting

- **DIN rail** — Standard for industrial components
- **Standoffs and screws** — For PCBs (M2.5 or M3 common)
- **Velcro / 3M Dual Lock** — Easy removal, vibration dampening
- **Zip ties** to internal features
- **Self-adhesive PCB feet** — Stick to enclosure floor

### External Mounting

- **Pole/mast clamp** — U-bolts, hose clamps, or pipe clamps
- **Wall mount** — Screws through enclosure flanges
- **Cable ties to structure** — Quick temporary mounting
- **Magnet mount** — Strong neodymium magnets on enclosure back

---

## Field Sealing Checklist

1. All cable glands installed and tightened
2. All unused knockouts/holes sealed
3. Lid gasket/O-ring clean and seated properly
4. Screws/latches fully tightened
5. Desiccant pack inside (fresh/dry)
6. Vent plug installed (if using one)
7. Antenna connectors sealed with silicone or self-vulcanizing tape
8. PCBs conformal coated
9. No sharp edges that could cut wires and cause short circuits
10. Strain relief on all cables
