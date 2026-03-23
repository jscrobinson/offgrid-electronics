# Battery Management Systems (BMS) and Charging

How to safely charge, discharge, and manage battery packs for off-grid electronics.

---

## What a BMS Does

A Battery Management System protects lithium cells from conditions that would damage them or create safety hazards. Any multi-cell lithium pack absolutely requires a BMS. Even single-cell applications benefit from protection circuitry.

### Protection Functions

| Function | What It Prevents | How It Works |
|----------|-----------------|--------------|
| **Overcharge protection** | Charging above 4.2V (Li-ion) or 3.65V (LiFePO4) | Disconnects charger when voltage limit reached |
| **Over-discharge protection** | Discharging below 2.5-3.0V | Disconnects load when voltage drops too low |
| **Overcurrent protection** | Drawing more current than cells can safely deliver | Disconnects load above current threshold |
| **Short circuit protection** | Dead short across terminals | Disconnects within microseconds |
| **Cell balancing** | Cells drifting apart in voltage over time | Equalizes cell voltages during charge |
| **Temperature protection** | Charging/discharging outside safe temp range | NTC thermistor monitoring (some BMS boards) |

### Why Balancing Matters

In a series pack (e.g., 3S = 3 cells in series), cells are never perfectly identical. Over charge/discharge cycles, their voltages drift apart. Without balancing:
- The weakest cell hits cutoff voltage first, reducing usable capacity
- The strongest cell gets overcharged, creating a safety hazard
- The pack degrades much faster than individual cells would

---

## Li-ion Charging Profile: CC-CV

All lithium cells (Li-ion, LiPo, LiFePO4) use a CC-CV (Constant Current - Constant Voltage) charging profile. This is the single most important concept in lithium battery charging.

### Phase 1: Constant Current (CC)
- Charger delivers a fixed current (typically 0.5C to 1C)
- For a 3000mAh cell at 1C: charge at 3A
- Cell voltage rises steadily from wherever it is up to 4.2V
- This phase delivers roughly 70-80% of the charge

### Phase 2: Constant Voltage (CV)
- Once cell reaches 4.2V, charger holds voltage at exactly 4.2V
- Current tapers off gradually as the cell fills up
- Charging is considered complete when current drops to ~50-100mA (C/20 to C/30)
- This phase delivers the remaining 20-30%

### Charging Profile Diagram
```
Current (A) __|____
             |    \
             |     \___________
             |                  \
             |___________________\____> Time

Voltage (V)        _______________
             ____/                |
            /                     |  4.2V
           /                      |
          /                       |
         |________________________|____> Time

         |<-- CC Phase -->|<-- CV Phase -->|
```

### Charging Parameters by Chemistry

| Chemistry | Max Charge V | Charge Rate | Termination Current |
|-----------|-------------|-------------|-------------------|
| Li-ion | 4.20V +/- 0.05V | 0.5-1C | C/20 (50-100mA) |
| LiPo | 4.20V +/- 0.05V | 0.5-1C (unless higher C-rated) | C/20 |
| LiFePO4 | 3.65V +/- 0.05V | 0.5-1C | C/20 |

**Critical: 4.2V is a hard limit.** Charging even 0.1V above this accelerates degradation and increases fire risk. Use a proper charge IC — do not try to regulate lithium charging with a simple voltage regulator.

---

## Common Charge ICs

### TP4056 (Single Cell Li-ion/LiPo)

The most popular charge IC for hobbyist projects. Costs under $0.50 on a breakout board.

- **Cells:** Single Li-ion/LiPo (4.2V)
- **Charge current:** Set by RPROG resistor (1.2k = 1A default on most boards)
- **Input voltage:** 4.5-8V (5V USB typical)
- **Features:** CC-CV charging, red/blue LED status indicators
- **Module variants:**
  - **TP4056 bare:** charge IC only, no protection
  - **TP4056 with DW01A + 8205A:** includes over-discharge, overcurrent, and short protection — **always buy this version**

**RPROG Resistor Values (TP4056):**

| RPROG | Charge Current |
|-------|---------------|
| 10k | 130mA |
| 5k | 250mA |
| 2k | 580mA |
| 1.2k | 1000mA (default) |

**Wiring:**
```
USB/Solar (5V) → IN+ / IN- on TP4056 board
Battery → BAT+ / BAT- (or B+ / B-)
Load → OUT+ / OUT- (on protected version)
```

**Limitations:**
- Single cell only (not for multi-cell packs)
- Linear regulator — wastes power as heat when input voltage is much higher than battery voltage
- Not great for solar (no MPPT, no load sharing)

### MCP73831 (Single Cell, Tiny)

- **Package:** SOT-23-5 (very small, for PCB designs)
- **Charge current:** Up to 500mA (set by resistor)
- **Input:** 3.75-6V
- **Used on:** many Adafruit and SparkFun boards
- **Advantage:** simpler to integrate into custom PCBs than TP4056

### BQ24074 (Solar + USB, Load Sharing)

- **Input:** USB or solar panel (up to 28V input on some variants)
- **Charge current:** Up to 1.5A
- **Key feature:** true power path management (load sharing)
  - Device runs from input power while simultaneously charging the battery
  - Battery only supplies current when input power is removed
  - This is important — without load sharing, you're cycling the battery unnecessarily
- **DPPM (Dynamic Power Path Management):** automatically reduces charge current to prioritize the load
- **Used on:** Adafruit Solar Charger boards
- **Ideal for:** solar-powered Meshtastic nodes, weather stations, remote sensors

### Other Notable ICs

| IC | Use Case | Notes |
|----|----------|-------|
| CN3791 | Solar MPPT charger | Cheap MPPT for small solar panels, adjustable MPPT voltage via resistor divider |
| IP5306 | Power bank IC | Integrated boost to 5V, charge management, LED indicators, push-button control |
| BQ25895 | USB-C PD charging | Supports USB-C Power Delivery negotiation |
| LTC4162 | Advanced multi-chemistry | I2C programmable, supports Li-ion/LiFePO4/lead-acid |

---

## Multi-Cell Series Packs and BMS Modules

### Series vs Parallel

**Series (S):** cells connected positive-to-negative. Voltage adds, capacity stays the same.
- 2S = 7.4V nominal (2 x 3.7V)
- 3S = 11.1V nominal
- 4S = 14.8V nominal

**Parallel (P):** cells connected positive-to-positive and negative-to-negative. Capacity adds, voltage stays the same.
- 2P = double the mAh at 3.7V

**Combined notation:** 3S2P = 3 series groups of 2 parallel cells each
- Voltage: 3 x 3.7V = 11.1V
- Capacity: 2 x cell_mAh (e.g., 2 x 3000mAh = 6000mAh)
- Total cells: 6

### Common Pack Configurations

| Config | Cells | Nominal V | Example (3000mAh cells) |
|--------|-------|-----------|------------------------|
| 1S1P | 1 | 3.7V | 3.7V, 3000mAh, 11.1Wh |
| 2S1P | 2 | 7.4V | 7.4V, 3000mAh, 22.2Wh |
| 3S1P | 3 | 11.1V | 11.1V, 3000mAh, 33.3Wh |
| 4S1P | 4 | 14.8V | 14.8V, 3000mAh, 44.4Wh |
| 3S2P | 6 | 11.1V | 11.1V, 6000mAh, 66.6Wh |
| 4S2P | 8 | 14.8V | 14.8V, 6000mAh, 88.8Wh |

### BMS Module Types

#### Passive Balancing BMS (Most Common for DIY)
- Bleeds excess energy from higher-voltage cells as heat through resistors
- Simple, cheap, effective enough for most projects
- Balancing current typically 30-60mA (slow but works over many cycles)
- Almost all hobby BMS boards use passive balancing

#### Active Balancing BMS
- Transfers energy from higher cells to lower cells (no energy wasted as heat)
- More complex, more expensive
- Used in EVs, high-end solar storage
- Overkill for most DIY projects

### Common BMS Modules (Available on Amazon, AliExpress, etc.)

| Config | Typical Board | Charge V | Cutoff V | Max Current |
|--------|--------------|----------|----------|-------------|
| 1S | TP4056+DW01A | 4.2V | 2.5V | 2-3A |
| 2S | HX-2S-02 | 8.4V | 5.0V | 3-20A |
| 3S | HX-3S-02 | 12.6V | 7.5V | 10-40A |
| 4S | Various | 16.8V | 10.0V | 10-40A |
| 4S LiFePO4 | Various | 14.6V | 10.0V | 10-100A |

### Wiring a BMS Module

Most BMS boards have these connections:
```
B- : Battery pack negative (and common ground)
B1 : Connection between cell 1 and cell 2
B2 : Connection between cell 2 and cell 3 (3S/4S)
B3 : Connection between cell 3 and cell 4 (4S)
B+ : Battery pack positive
P- : Pack output negative (load and charger negative)
P+ : Pack output positive (usually connected directly to B+)
C- : Charger negative (some boards separate charge and discharge paths)
```

**Important wiring order:**
1. Connect balance wires FIRST (B-, B1, B2, B3, B+) — start from B-
2. Then connect main power wires
3. Connecting in wrong order can blow the BMS

---

## Safety Rules for Lithium Batteries

These are not suggestions. Ignoring any of these can cause fire, explosion, or toxic fumes.

1. **Never short-circuit** a lithium cell — even momentarily. This means no loose 18650s in a pocket with keys or coins.
2. **Never puncture** a lithium cell — they contain flammable electrolyte.
3. **Never overcharge** — always use a proper charge IC with 4.2V cutoff (or 3.65V for LiFePO4).
4. **Never over-discharge** — use a BMS or set a low-voltage cutoff. Cells discharged below ~2.0V may develop internal shorts and become dangerous to recharge.
5. **Never charge below 0C (32F)** — lithium plating occurs, permanently damaging the cell and creating internal short-circuit risk. Discharging in cold is fine.
6. **Never charge unattended** unless you have a proper BMS and trust your charging setup.
7. **Never use a damaged cell** — dents, torn wraps, or any sign of swelling means dispose of it.
8. **Use correct wire gauge** for the current you're drawing.
9. **Store lithium cells in fireproof bags** (LiPo bags) when not in use.
10. **Use fuses** on battery packs — an inline fuse between the battery and load is cheap insurance.

---

## Storage Voltage

For long-term storage (more than a week without use), lithium cells last longest at a partial state of charge.

| Chemistry | Storage Voltage (per cell) | Approximate SoC |
|-----------|---------------------------|-----------------|
| Li-ion | 3.7-3.8V | ~40-50% |
| LiPo | 3.7-3.8V | ~40-50% |
| LiFePO4 | 3.3V | ~50% |

- Storing at full charge (4.2V) accelerates calendar aging
- Storing fully depleted risks dropping below safe voltage due to self-discharge
- Most quality chargers have a "storage" mode that charges/discharges to 3.8V
- If you're not going to use a pack for months, charge it to ~50% and check it every few months

---

## Practical Tips

### Matching Cells for Packs
- When building multi-cell packs, use cells from the same manufacturer, model, and ideally the same batch
- Charge all cells individually to 4.2V, then measure capacity by discharging at a known rate
- Match cells within 50mAh of each other for best results
- Mismatched cells cause the BMS to work harder and reduce pack capacity to the weakest cell

### Charger Recommendations for 18650
- **XTAR VC4SL:** 4-bay, measures internal resistance and capacity, highly accurate
- **Nitecore SC4:** 4-bay, fast charging up to 3A per slot
- **LiitoKala Lii-500:** budget 4-bay with capacity testing
- Always verify a new charger terminates at 4.2V with a multimeter before trusting it with good cells

### Quick Diagnostics
- **Cell won't charge:** If voltage is below 2.0V, the BMS protection may have tripped. Some chargers can recover these; many cannot. If the cell has been below 2.0V for an extended period, it may be unsafe to charge.
- **Pack capacity dropping:** Check individual cell voltages. If one cell is significantly lower, it's weak and dragging down the pack.
- **Charging stops early:** Balance wires may be disconnected, or one cell is triggering the overvoltage protection.
