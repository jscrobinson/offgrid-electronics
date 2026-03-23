# PCB Design Basics

## PCB Design Workflow

```
1. Schematic Capture  →  Define circuit, components, and connections
2. Component Selection →  Choose footprints, verify availability
3. PCB Layout          →  Place components, route traces
4. Design Rule Check   →  Verify clearances, connectivity
5. Generate Gerbers    →  Manufacturing output files
6. Order & Fabricate   →  Send to fab house
7. Assembly            →  Solder components to board
```

---

## KiCad Overview

KiCad is a free, open-source PCB design suite. It's professional-grade and widely used in hobby and commercial projects.

### KiCad Applications

| Application         | Purpose                                   |
|--------------------|-------------------------------------------|
| KiCad (project mgr)| Project file management                   |
| Schematic Editor   | Draw circuit schematics                    |
| Symbol Editor      | Create/edit schematic symbols              |
| PCB Editor         | Layout PCB, route traces                   |
| Footprint Editor   | Create/edit component footprints           |
| 3D Viewer          | Preview assembled board in 3D              |
| Gerber Viewer      | Inspect manufacturing output files         |

### KiCad Workflow

**Schematic:**
1. Create a new project
2. Open Schematic Editor
3. Place symbols from the library (press `A` to add)
4. Wire connections (`W` to start a wire)
5. Add power symbols (VCC, GND, +3V3, +5V)
6. Assign values to components (double-click to edit)
7. Annotate schematic (assigns reference designators: R1, C1, U1, etc.)
8. Run Electrical Rules Check (ERC) — fix all errors
9. Assign footprints to all symbols (Footprint Assignment tool)

**PCB Layout:**
1. From schematic, use "Update PCB from Schematic" to import netlist
2. All components appear in a pile — arrange them on the board
3. Define board outline (Edge.Cuts layer)
4. Place components logically (connectors at edges, ICs centered, decoupling caps near IC pins)
5. Route traces (press `X` to start routing)
6. Add ground plane (copper fill/zone on GND net)
7. Run Design Rule Check (DRC) — fix all errors
8. Generate fabrication output files

### Essential KiCad Shortcuts

| Key | Action                    |
|-----|---------------------------|
| A   | Add symbol/footprint      |
| W   | Start wire/trace          |
| X   | Start routing trace       |
| D   | Drag (move with connections)|
| M   | Move                      |
| R   | Rotate                    |
| E   | Edit properties           |
| F   | Flip to other side        |
| V   | Change via/layer during routing |
| B   | Rebuild copper fills      |
| I   | Inspect clearance/net     |

---

## Schematic Symbols

### Standard Reference Designators

| Prefix | Component Type       |
|--------|---------------------|
| R      | Resistor            |
| C      | Capacitor           |
| L      | Inductor            |
| D      | Diode / LED         |
| Q      | Transistor          |
| U      | Integrated Circuit  |
| J      | Connector           |
| SW     | Switch              |
| F      | Fuse                |
| FB     | Ferrite bead        |
| TP     | Test point          |
| Y      | Crystal/oscillator  |

### Schematic Best Practices

- Signal flow left-to-right, power top (V+) to bottom (GND)
- Label nets clearly (SDA, SCL, MOSI, etc.)
- Use hierarchical sheets for complex designs
- Add decoupling capacitors near every IC in the schematic (even if placement is a layout concern)
- Include mounting holes, test points, and fiducials
- Add notes and comments for unusual circuit choices

---

## Footprints

### Common Footprint Sizes

**SMD Passives (resistors, capacitors):**

| Size Code | Metric (mm)  | Pad Area    | Hand Solderable? |
|-----------|-------------|-------------|------------------|
| 0201      | 0.6 × 0.3  | Tiny        | Expert only      |
| 0402      | 1.0 × 0.5  | Very small  | Difficult        |
| 0603      | 1.6 × 0.8  | Small       | With practice    |
| 0805      | 2.0 × 1.25 | Medium      | Yes, comfortable |
| 1206      | 3.2 × 1.6  | Large       | Easy             |

**For hand assembly, use 0805 or larger.** 0603 is manageable with flux, tweezers, and magnification.

**IC Packages:**

| Package | Pin Pitch | Hand Solderable? | Notes                    |
|---------|-----------|------------------|--------------------------|
| DIP     | 2.54mm    | Easy             | Through-hole, breadboard |
| SOIC    | 1.27mm    | Yes              | Most common SMD IC       |
| SSOP    | 0.65mm    | With practice    | Drag soldering           |
| TQFP    | 0.5-0.8mm | Difficult        | Drag soldering + flux    |
| QFN     | 0.4-0.65mm| Hot air needed   | Ground pad underneath    |
| BGA     | 0.4-1.0mm | Reflow only      | Cannot hand solder       |

---

## PCB Layout Tips

### Component Placement

1. **Place connectors first** — they define the physical interface to the outside world
2. **Place critical components** — MCU, regulators, crystals
3. **Place decoupling capacitors** as close as physically possible to IC power pins. Route directly from cap to IC pin, not through a via if possible
4. **Group related components** — keep analog and digital sections separate
5. **Consider mechanical constraints** — enclosure fit, mounting holes, connector access

### Trace Width and Current

Trace width depends on current, copper weight, and acceptable temperature rise.

**For 1oz copper (35μm), 10°C rise, outer layer:**

| Current | Min Trace Width | Recommended Width |
|---------|----------------|-------------------|
| 100mA   | 0.1mm (4mil)   | 0.25mm (10mil)    |
| 500mA   | 0.25mm (10mil) | 0.5mm (20mil)     |
| 1A      | 0.5mm (20mil)  | 1.0mm (40mil)     |
| 2A      | 1.0mm (40mil)  | 1.5mm (60mil)     |
| 3A      | 1.5mm (60mil)  | 2.0mm (80mil)     |
| 5A      | 2.5mm (100mil) | 3.0mm (120mil)    |

**For signal traces (SPI, I2C, UART, GPIO):** 0.2mm (8mil) to 0.3mm (12mil) is fine.
**For power traces:** calculate based on current, use the table above.

Use an online trace width calculator (e.g., Saturn PCB Toolkit) for precise calculations.

### Ground Plane

**Always use a ground plane** — fill unused copper area with GND on at least one layer.

Benefits:
- Low-impedance return path for all signals
- Better EMI performance
- Thermal dissipation
- Reduces crosstalk between traces

For 2-layer boards: use bottom layer as ground plane, route signals on top. Use vias to connect to ground plane frequently.

For 4-layer boards: typical stackup is Signal / GND / Power / Signal.

### General Layout Rules

- **Decoupling caps** — closest possible to IC power pins, with short traces and vias
- **Crystal oscillator** — place close to MCU, short traces, guard ring of GND vias around it
- **Avoid routing under crystals** or sensitive analog components
- **Keep analog and digital grounds separate** until they meet at one point (star ground) — or use a solid ground plane
- **Avoid 90° trace corners** — use 45° angles or curves (mostly cosmetic, but good practice)
- **Minimize via count** on high-frequency signals
- **Keep high-current switching loops small** (buck converter: IC → inductor → output cap → GND → IC)

---

## Design Rules

### Typical Fabrication Capabilities

| Parameter              | Budget Fab    | Standard Fab | Advanced    |
|-----------------------|---------------|-------------|-------------|
| Min trace width       | 6mil (0.15mm) | 4mil (0.1mm)| 3mil        |
| Min trace spacing     | 6mil (0.15mm) | 4mil (0.1mm)| 3mil        |
| Min drill size        | 0.3mm         | 0.2mm       | 0.1mm       |
| Min via diameter      | 0.6mm         | 0.4mm       | 0.2mm       |
| Min annular ring      | 0.15mm        | 0.1mm       | 0.075mm     |
| Copper weight         | 1oz (35μm)    | 1-2oz       | 0.5-4oz     |
| Board thickness       | 1.6mm         | 0.4-2.4mm   | 0.2-6mm     |
| Min SMD pad           | 0.25mm        | 0.2mm       | 0.15mm      |

**Safe defaults for hobby designs:** 8mil trace/space, 0.8mm via with 0.4mm drill, 1.6mm board thickness, 1oz copper.

### KiCad Design Rule Settings

In KiCad PCB Editor → Board Setup → Design Rules:

```
Clearance:          0.2mm (8mil) minimum
Track Width:        0.25mm (10mil) default, wider for power
Via Size:           0.8mm outer, 0.4mm drill
Differential Pair:  (for USB, set per fab spec)
Copper to Edge:     0.3mm minimum
Min Through Hole:   0.3mm
Min Annular Ring:   0.15mm
```

---

## Generating Gerber Files

Gerber files are the standard manufacturing output format.

### Required Files

| File         | Layer               | Extension  |
|-------------|---------------------|------------|
| Front Copper| F.Cu                | .gtl       |
| Back Copper | B.Cu                | .gbl       |
| Front Mask  | F.Mask              | .gts       |
| Back Mask   | B.Mask              | .gbs       |
| Front Silk  | F.SilkS             | .gto       |
| Back Silk   | B.SilkS             | .gbo       |
| Board Outline| Edge.Cuts          | .gm1       |
| Drill file  | —                   | .drl       |

### KiCad Gerber Export

1. PCB Editor → File → Plot
2. Select layers: F.Cu, B.Cu, F.SilkS, B.SilkS, F.Mask, B.Mask, Edge.Cuts
3. Format: Gerber
4. Check "Use Protel filename extensions"
5. Click "Plot"
6. Click "Generate Drill Files" → format: Excellon, units: mm
7. Zip all output files together for upload to fab

---

## Popular Fab Houses

### JLCPCB (China)

- **Price:** Starting at $2 for 5 boards (100×100mm, 2-layer)
- **Shipping:** 3-5 days (DHL) or 2-3 weeks (economy)
- **Capabilities:** 2-16 layers, 6/6mil min, various colors
- **SMT Assembly:** Available — upload BOM and Pick & Place files, parts from their stocked inventory (LCSC)
- **Colors:** Green (cheapest/fastest), black, white, blue, red, yellow, purple
- **Order:** jlcpcb.com — upload Gerber zip, instant quote
- **Special:** Purple boards and 1-2 layer are often $2, 4-layer starts around $7 for 5 boards

### PCBWay (China)

- **Price:** Starting at $5 for 10 boards (100×100mm, 2-layer)
- **Shipping:** Similar to JLCPCB
- **Capabilities:** 1-14 layers, advanced processes (flex PCB, aluminum, HDI)
- **Assembly:** Available, wider component sourcing options
- **Order:** pcbway.com — upload Gerber, instant quote
- **Notes:** Good customer service, flexible on custom requirements

### OSH Park (USA)

- **Price:** $5/sq inch for 2-layer (minimum order 3 boards), $10/sq inch for 4-layer
- **Shipping:** Free shipping (US), 12 business days typical
- **Capabilities:** 2 and 4 layer, high quality, ENIG finish standard
- **Colors:** Signature purple solder mask
- **Order:** oshpark.com — drag and drop KiCad .kicad_pcb file directly (no Gerber export needed)
- **Notes:** Higher cost but excellent quality, no minimum quantity, great for small boards, based in USA

### Comparison

| Feature          | JLCPCB         | PCBWay         | OSH Park      |
|-----------------|----------------|----------------|---------------|
| Min price       | $2 / 5 boards  | $5 / 10 boards | ~$1-5 / 3 boards |
| Speed           | 1-3 days fab   | 1-3 days fab   | ~12 days      |
| Quality         | Good           | Good           | Excellent     |
| Assembly service| Yes (LCSC parts)| Yes            | No            |
| Best for        | Cheap protos   | Custom/flex PCB | Small US orders|
| Instant quote   | Yes            | Yes            | Yes           |

---

## Assembly Options

### Hand Soldering

- Through-hole: Easy with basic iron
- SMD 0805+: Manageable with fine tip, flux, and tweezers
- SMD 0603: Needs magnification and practice
- Fine-pitch IC (0.5mm): Drag soldering technique with flux
- QFN/BGA: Requires hot air station or reflow

### Reflow Soldering (DIY)

1. Apply solder paste to pads using stencil (order stencil from fab house for $5-10)
2. Place components on paste with tweezers
3. Reflow using:
   - **Hot plate** (cheapest: $30-50 cooking hot plate, better: Miniware or similar)
   - **Reflow oven** (converted toaster oven with controller, or commercial like T-962)
   - **Hot air station** (for small boards or rework)
4. Profile: Preheat to 150°C, soak for 60-90s, ramp to 230°C (leaded) or 250°C (lead-free), hold for 10-30s, cool

### JLCPCB SMT Assembly Service

For boards where you don't want to hand-solder hundreds of SMD parts:

1. Design your PCB in KiCad as normal
2. Generate Gerber files
3. Generate BOM (Bill of Materials) — KiCad: File → Fabrication Outputs → BOM. Format: Reference, Value, Footprint, LCSC Part Number
4. Generate Pick & Place file (Component Placement List) — KiCad: File → Fabrication Outputs → Component Placement
5. Upload to JLCPCB with "SMT Assembly" option
6. Match components to their LCSC database
7. Review placement preview
8. Order — boards arrive assembled

**Cost:** Base assembly fee ~$8 + per-component cost (pennies for common parts from their stocked inventory, more for extended parts requiring setup fees).

**Tip:** Design with JLCPCB's "basic parts" in mind — these are stocked in their feeders and have no setup fee. Check their parts library before finalizing your BOM.

---

## Design Checklist

Before ordering:

- [ ] ERC passes with no errors in schematic
- [ ] DRC passes with no errors in PCB layout
- [ ] All components have correct footprints
- [ ] Decoupling capacitors placed near all IC power pins
- [ ] Power traces sized for current
- [ ] Ground plane is continuous (no unnecessary splits)
- [ ] Board outline is correct size
- [ ] Mounting holes in correct positions
- [ ] Connectors accessible from board edges
- [ ] Silkscreen labels readable and correct
- [ ] Test points for important signals
- [ ] Fiducials placed (if using pick-and-place assembly)
- [ ] Polarity markings for diodes, electrolytic caps, connectors
- [ ] Crystal placed close to MCU with short traces
- [ ] Reviewed 3D view for mechanical fit
- [ ] Gerber files verified in Gerber viewer
- [ ] BOM and Pick & Place files generated (if using assembly service)
