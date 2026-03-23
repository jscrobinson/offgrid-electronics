# Battery Types and Chemistry Comparison

A practical reference for selecting the right battery chemistry for off-grid electronics projects.

---

## Li-ion (18650, 21700)

The workhorse of modern portable electronics and DIY projects.

- **Nominal voltage:** 3.7V per cell
- **Full charge:** 4.2V per cell
- **Cutoff voltage:** 2.5V per cell (never discharge below this — causes permanent damage)
- **Energy density:** ~250 Wh/kg (highest practical energy density of common rechargeable chemistries)
- **Cycle life:** 300-500 full cycles (more if you avoid full charge/discharge extremes)
- **Self-discharge:** ~2-3% per month
- **Memory effect:** None — charge to any level at any time without degradation

### Common Form Factors

| Cell | Diameter | Length | Typical Capacity |
|------|----------|--------|-----------------|
| 18650 | 18mm | 65mm | 2500-3500 mAh |
| 21700 | 21mm | 70mm | 4000-5000 mAh |
| 14500 | 14mm | 50mm | 800-1000 mAh (AA size) |

### Characteristics
- Widely available, standardized sizes
- Huge variety of cells optimized for capacity or current
- Used in: laptops, power banks, EVs, flashlights, vapes, T-Beam, power tools
- Requires protection circuitry (BMS) in multi-cell packs
- Can vent or catch fire if punctured, shorted, or overcharged

---

## LiPo (Lithium Polymer)

Same lithium chemistry as Li-ion but in a flexible pouch format.

- **Nominal voltage:** 3.7V per cell
- **Full charge:** 4.2V per cell
- **Cutoff voltage:** 3.0V per cell (more conservative than hard-can Li-ion)
- **Energy density:** ~200-250 Wh/kg
- **Cycle life:** 300-500 cycles
- **Self-discharge:** ~3-5% per month

### Key Differences from Li-ion Cylinders
- **Flexible form factor:** flat pouches that fit in tight spaces
- **Lightweight:** no metal can
- **C-rating:** discharge rate expressed as multiple of capacity (e.g., a 1000mAh 10C pack can deliver 10A)
- **Puff/swell danger:** overcharging, over-discharging, or damage causes gas buildup — the pouch inflates. A puffy LiPo is dangerous. Dispose of it immediately.
- **Connectors:** typically JST-PH 2.0 for single cell, XT30/XT60 for RC packs, JST 1.25 on many dev boards (Heltec, Adafruit)

### Common Uses
- RC vehicles, drones (high C-rating packs)
- Wearables and compact devices
- Dev boards with JST battery connectors (Heltec V3, Adafruit Feather, etc.)
- Phones, tablets

### Safety
- Never puncture — lithium fire risk
- Store in fireproof LiPo bags
- Do not charge unattended
- Dispose of puffy cells properly (discharge to 0V into salt water, then recycle)

---

## LiFePO4 (Lithium Iron Phosphate)

The safe, long-life lithium chemistry. Ideal for stationary storage.

- **Nominal voltage:** 3.2V per cell (lower than Li-ion)
- **Full charge:** 3.65V per cell
- **Cutoff voltage:** 2.5V per cell
- **Energy density:** ~90-120 Wh/kg (lower than Li-ion)
- **Cycle life:** 2000-5000+ cycles (far superior to other lithium chemistries)
- **Self-discharge:** ~1-3% per month

### Advantages
- **Much safer:** thermally stable, won't catch fire even if punctured
- **Long life:** 2000+ cycles at 80% depth of discharge
- **Flat discharge curve:** voltage stays very stable (~3.2V) through most of the discharge
- **Wide temperature range:** operates well from -20C to 60C
- **No cobalt:** more ethical and sustainable supply chain

### Disadvantages
- Heavier than Li-ion for the same capacity
- Lower voltage per cell (need 4S for 12V systems vs 3S Li-ion)
- More expensive per cell (but cheaper per cycle over lifespan)

### Common Uses
- Solar energy storage (home and off-grid)
- RV/marine house batteries
- Ham radio portable power
- Any application where cycle life and safety matter more than weight

### Common Configurations
| Config | Nominal V | Replaces |
|--------|-----------|----------|
| 4S (4 cells) | 12.8V | 12V lead-acid |
| 8S | 25.6V | 24V systems |
| 16S | 51.2V | 48V systems |

---

## NiMH (Nickel-Metal Hydride)

The practical rechargeable replacement for disposable AA/AAA batteries.

- **Nominal voltage:** 1.2V per cell
- **Energy density:** ~60-120 Wh/kg
- **Cycle life:** 500-1000 cycles (Eneloop: 2100 cycles)
- **Self-discharge:** Standard: ~20-30% per month. Low self-discharge (LSD): ~1% per month

### Common Capacities
| Size | Typical Capacity |
|------|-----------------|
| AA | 1900-2800 mAh |
| AAA | 750-1100 mAh |

### Key Points
- **No memory effect** in modern NiMH (old NiCd had this problem)
- **1.2V vs 1.5V:** most devices designed for alkaline (1.5V) work fine on NiMH (1.2V) because alkaline voltage drops quickly under load while NiMH stays flat at 1.2V
- **Low self-discharge cells** (Eneloop, Amazon Basics LSD, EBL) retain 70-80% charge after a year — buy these, not standard NiMH
- **Charging:** use a smart charger that detects -delta-V to stop (not a dumb timed charger)

### Recommended Cells
- Panasonic Eneloop (white): 1900 mAh AA, 2100 cycle life, gold standard
- Eneloop Pro (black): 2500 mAh AA, 500 cycle life, higher capacity
- IKEA LADDA 2450: rebranded Eneloop Pro, excellent value
- EBL: decent budget option

### Uses
- Flashlights, radios, remote controls
- Devices that take standard AA/AAA form factor
- Good for items with moderate drain

---

## Lead-Acid

The oldest rechargeable battery technology. Heavy, cheap, reliable.

- **Nominal voltage:** 2V per cell (6 cells = 12V battery)
- **Full charge:** 2.4V/cell (14.4V for 12V battery)
- **Float voltage:** 2.25V/cell (13.5V for 12V battery)
- **Energy density:** ~30-50 Wh/kg (very low)
- **Cycle life:** 200-500 cycles (deep cycle), depending on depth of discharge
- **Self-discharge:** ~3-5% per month

### Types
| Type | Description | Best For |
|------|------------|----------|
| Flooded (wet cell) | Liquid electrolyte, needs venting, can spill | Automotive starting, cheap solar |
| AGM (Absorbed Glass Mat) | Sealed, maintenance-free, vibration resistant | Solar, UPS, portable |
| Gel | Sealed, gel electrolyte, slow charge | Deep cycle solar, marine |

### Critical Rule: Depth of Discharge (DoD)
- **Never discharge below 50%** — this is the single most important rule for lead-acid longevity
- A 100Ah lead-acid battery gives you only ~50Ah of usable capacity
- Discharging below 50% dramatically shortens cycle life
- At 50% DoD: ~500 cycles. At 80% DoD: ~200 cycles

### Advantages
- Very cheap upfront
- Widely available everywhere in the world
- Easy to recycle (99% recycling rate)
- Tolerant of abuse (overcharging is less catastrophic than lithium)

### Disadvantages
- Extremely heavy
- Low usable capacity (50% DoD limit)
- Slow to charge
- Shorter lifespan than LiFePO4
- Flooded types need ventilation (hydrogen gas)

### Common Uses
- Automotive starting batteries
- Off-grid solar storage (on a budget)
- UPS systems
- Ham radio field operations (when weight is not critical)

---

## Alkaline (Non-Rechargeable)

The ubiquitous disposable battery.

- **Voltage:** 1.5V (AA, AAA, C, D), 9V (6LR61)
- **Energy density:** ~100-150 Wh/kg
- **Shelf life:** 5-10 years (Energizer claims 10 years)
- **Self-discharge:** Very low (<2% per year)
- **Cycle life:** Not rechargeable (some "rechargeable alkaline" exist but are poor)

### Key Points
- Voltage drops steadily during discharge (starts 1.5V, ends ~0.9V)
- Capacity drops dramatically at high drain — not suitable for high-current devices
- Can leak if left in devices for extended periods (especially cheap brands)
- Good for: emergency kits, low-drain devices, long-term storage
- Bad for: high-drain devices (flashlights, motors, cameras)

### Shelf Life Winners
- Energizer Ultimate Lithium (L91/L92): 20-year shelf life, works in extreme cold, lightest AA, expensive — ideal for emergency kits
- Energizer MAX: 10-year shelf life
- Duracell Optimum: 10-year shelf life

---

## Comparison Table

| Chemistry | Nominal V/cell | Energy Density (Wh/kg) | Cycle Life | Self-Discharge (/month) | Relative Cost | Safety | Best Use Case |
|-----------|---------------|----------------------|------------|------------------------|---------------|--------|---------------|
| Li-ion (18650) | 3.7V | 250 | 300-500 | 2-3% | Medium | Moderate (needs BMS) | Portable electronics, power banks |
| LiPo | 3.7V | 200-250 | 300-500 | 3-5% | Medium | Moderate (puff risk) | RC, drones, compact devices |
| LiFePO4 | 3.2V | 90-120 | 2000-5000 | 1-3% | High (per cell) | High | Solar storage, long-life systems |
| NiMH | 1.2V | 60-120 | 500-2100 | 1-30%* | Low | High | AA/AAA replacement |
| Lead-Acid | 2.0V | 30-50 | 200-500 | 3-5% | Very Low | Moderate (acid) | Budget solar, automotive |
| Alkaline | 1.5V | 100-150 | 1 (disposable) | <2%/year | Very Low | High | Emergency kits, low drain |

*NiMH self-discharge varies widely: standard ~20-30%, low self-discharge (Eneloop) ~1%.

---

## Quick Decision Guide

**Need maximum runtime in minimum weight?** Li-ion 18650/21700

**Building a small device with tight spaces?** LiPo pouch cell

**Solar storage that needs to last years?** LiFePO4

**Device takes AA/AAA batteries?** NiMH Eneloop

**Budget solar system, weight doesn't matter?** Lead-acid AGM

**Emergency kit, needs 10+ year shelf life?** Alkaline or Energizer Ultimate Lithium

**Meshtastic T-Beam?** 18650 Li-ion (Samsung 30Q or LG HG2)

**Meshtastic Heltec V3?** LiPo with JST 1.25 connector
