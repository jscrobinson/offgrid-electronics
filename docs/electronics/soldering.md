# Soldering Guide

## Equipment

### Soldering Iron

| Type                    | Cost       | Best For                              |
|------------------------|-----------|---------------------------------------|
| Basic fixed-temp iron   | $10-25    | Occasional hobby use                  |
| Adjustable temp station | $40-80    | Regular hobbyist (Hakko FX888D, KSGER T12) |
| T12/T100 handle station | $30-60    | Best value (Quecoo, FNIRSI, KSGER)   |
| Professional station    | $150-400  | Daily use (JBC, Hakko, Weller)        |
| USB-C portable iron     | $60-100   | Field work (Pinecil, TS101, SQ-001)  |

**Recommended starter:** A T12-based station (Quecoo T12-956, KSGER T12) or the Pinecil for portability. These use rapid-heating T12 tips that are cheap and widely available.

### Soldering Tips

| Tip Shape    | Use                                        |
|-------------|-------------------------------------------|
| Chisel (D/K)| General purpose, best heat transfer. **Use this 90% of the time** |
| Conical (B) | Fine pitch work, limited heat transfer     |
| Bevel (C)   | SMD drag soldering                         |
| Knife (K)   | SMD work, drag soldering                   |
| Hoof (J)    | SMD pads, dragging                         |

**A 2-3mm chisel tip is the best all-around choice.** Beginners often mistakenly use a fine conical tip for everything — the chisel transfers heat much better and is actually easier to use.

### Solder

| Type              | Composition      | Melting Point | Notes                            |
|------------------|-----------------|---------------|----------------------------------|
| 63/37 leaded     | 63% Sn, 37% Pb  | 183°C         | Eutectic — best flow, no pasty range, easiest to work with |
| 60/40 leaded     | 60% Sn, 40% Pb  | 183-190°C     | Very common, nearly as good as 63/37 |
| Lead-free SAC305 | 96.5Sn/3Ag/0.5Cu| 217-220°C     | Required for commercial products, harder to work with |
| Lead-free SN100C | 99.3Sn/0.7Cu    | 227°C         | Budget lead-free option           |

**Use 63/37 leaded solder for hobby work.** It flows better, wets easier, and is more forgiving. 0.8mm diameter with rosin flux core is the best general-purpose size. Use 0.5mm for fine SMD work.

**Lead-free** is required for commercial products (RoHS compliance). It needs higher temperatures and is less forgiving but produces adequate joints with practice.

### Flux

Flux cleans oxides from metal surfaces, allowing solder to wet and flow properly.

| Type          | Activity | Cleaning Required | Notes                           |
|--------------|----------|-------------------|---------------------------------|
| Rosin (R)    | Mild     | Optional          | In flux-core solder             |
| RMA          | Moderate | Recommended       | Better wetting                  |
| No-clean     | Mild     | No                | Leaves benign residue           |
| Water-soluble| Active   | **Yes, mandatory**| Corrosive if not cleaned        |

**For rework and SMD:** Use a flux pen or syringe of rosin or no-clean flux. Apply liberally — more flux almost always helps.

### Other Tools

- **Solder wick (desoldering braid):** Copper braid that absorbs molten solder. Apply flux to wick for better absorption. Available in 1-3mm widths
- **Solder sucker (desoldering pump):** Spring-loaded vacuum for removing solder from through-hole joints
- **Helping hands / PCB holder:** Third hand with alligator clips, or a PCB vise (Omnifixo, Stickvise)
- **Brass wool tip cleaner:** Better than wet sponge — cleans tips without thermal shock
- **Wet sponge:** Traditional tip cleaner. Keep it damp, not soaking
- **Tweezers:** Sharp, anti-magnetic tweezers for placing SMD components
- **Magnification:** Head-mounted magnifier, desk magnifier with light, or USB microscope for SMD inspection

---

## Temperature Settings

| Solder Type     | Iron Temperature  | Notes                        |
|----------------|-------------------|------------------------------|
| 63/37 leaded   | 320-350°C         | Start at 320°C, increase if solder doesn't flow quickly |
| 60/40 leaded   | 320-370°C         | Similar to 63/37              |
| Lead-free SAC  | 370-400°C         | Higher melting point          |
| Lead-free fine  | 350-380°C         | Fine pitch SMD, less time     |

**Rules:**
- Use the **lowest temperature that works quickly** — you want each joint to take 2-4 seconds
- If the solder doesn't flow quickly, **increase temperature rather than holding the iron longer** (prolonged heating damages components and pads)
- Large ground planes and thick copper act as heat sinks — you may need to increase temperature or use a larger tip

---

## Through-Hole Soldering Technique

### Step-by-Step

1. **Insert component** through the PCB holes. Bend leads slightly on the back to hold it in place
2. **Apply iron to the joint** — touch the iron tip to BOTH the pad and the component lead simultaneously. The chisel tip flat should contact both surfaces
3. **Wait 1-2 seconds** for the pad and lead to heat up
4. **Apply solder to the joint** (NOT to the iron tip) — feed solder wire into the junction of pad, lead, and iron. The solder should flow smoothly onto the heated surfaces
5. **Feed enough solder** to form a proper fillet — a smooth, concave, shiny (leaded) or slightly matte (lead-free) cone shape
6. **Remove solder wire first**, then remove iron
7. **Total time per joint: 2-4 seconds.** If it takes longer, something is wrong (tip not clean, temperature too low, not enough flux)

### What a Good Joint Looks Like

```
Good joint (leaded):          Good joint (lead-free):
- Shiny, smooth               - Slightly matte/satin
- Concave fillet               - Concave fillet
- Wets to both pad and lead    - Wets to both pad and lead
- No gaps or balls             - No gaps or balls
```

---

## SMD Soldering Technique

### Two-Pad Components (Resistors, Capacitors: 0805, 0603, etc.)

1. **Apply flux** to both pads
2. **Pre-tin one pad:** Apply a small blob of solder to one pad
3. **Place component:** Using tweezers, hold the component and reflow the pre-tinned pad with the iron. Slide the component into position against the molten solder
4. **Check alignment.** Reheat and adjust if needed
5. **Solder the other pad:** Apply iron and solder to the second pad
6. **Reflow the first pad** with a touch more solder if needed for a good fillet

### Multi-Pin ICs (SOIC, TQFP, QFN)

1. **Apply flux** generously to all pads
2. **Tack one corner pin** — pre-tin one pad, position the IC, reflow to tack it
3. **Check alignment** of ALL pins to ALL pads under magnification
4. **Tack the opposite corner** to lock alignment
5. **Solder remaining pins** — for fine pitch, use drag soldering:
   - Apply flux along the row of pins
   - Load a small amount of solder on a chisel or bevel tip
   - Drag the iron slowly along the pins — surface tension pulls solder onto each pin
6. **Remove bridges** with flux and solder wick

### Hot Air Rework

For QFN (no-lead) packages and BGA:
- Apply solder paste to pads (stencil or syringe)
- Place component
- Heat with hot air station at 250-300°C (leaded) or 300-350°C (lead-free)
- Use circular motion, keep nozzle 1-2cm above board
- Watch for solder reflow (component will "settle" into position)

---

## Common Problems and Fixes

### Cold Joint

**Looks:** Dull, grainy, rough, crystalline surface
**Cause:** Not enough heat, component moved during cooling
**Fix:** Reheat with flux, allow solder to reflow completely, hold still while cooling

### Solder Bridge

**Looks:** Solder connecting two adjacent pins/pads
**Cause:** Too much solder, moving iron between pins
**Fix:** Add flux, drag clean iron tip through the bridge. Or use solder wick with flux

### Insufficient Solder / Dry Joint

**Looks:** Thin, incomplete fillet, can see the gap between lead and pad
**Cause:** Not enough solder, surfaces not properly wetted
**Fix:** Add flux, reheat, and add more solder

### Overheated Joint / Burnt Flux

**Looks:** Dark, burnt residue around joint, pad may be lifting
**Cause:** Iron held too long, temperature too high
**Fix:** Clean area with IPA, add fresh flux, carefully resolder. If pad is lifted, repair with jumper wire

### Tombstoning (SMD)

**Looks:** One end of a component stands up vertically
**Cause:** Uneven heating of the two pads during reflow, one side reflows before the other
**Fix:** Add flux, heat both pads simultaneously with a wider tip, or reposition and resolder

### Solder Balls

**Looks:** Small spheres of solder scattered around the joint
**Cause:** Moisture in flux (splatters when heated), contaminated surfaces
**Fix:** Clean board with IPA, use fresh solder, ensure board is dry

---

## Desoldering

### Solder Wick (Braid)

1. Apply flux to the braid
2. Place braid on the solder joint
3. Press hot iron on top of the braid
4. Solder wicks up into the braid via capillary action
5. Remove braid and iron together
6. Use fresh section of braid for next joint

### Solder Sucker (Spring Pump)

1. Heat the joint with iron until solder is molten
2. Place sucker tip next to the joint
3. Trigger the sucker while solder is still liquid
4. Repeat if necessary
5. Clean remaining solder with wick

### Hot Air (for SMD)

1. Apply flux to all joints
2. Heat the component evenly with hot air
3. When solder melts, lift component with tweezers
4. Clean pads with wick and flux

---

## Tip Maintenance

1. **Tin the tip** when not in use — apply a coat of solder to prevent oxidation
2. **Clean before and during use** — wipe on brass wool or damp sponge
3. **Never file or sand the tip** — destroys the iron plating
4. **Re-tin frequently** during soldering sessions
5. **Use tip tinner/activator** if the tip stops accepting solder (tin+flux compound)
6. **Turn off the iron when not soldering** — prolonged high temperature without use damages tips. Or use the sleep mode on temperature-controlled stations

**A well-maintained tip should last months to years.** Tips that stop accepting solder ("going dead") are usually caused by oxidation from leaving the iron on without solder coating.

---

## Safety

### Fumes

- Solder flux fumes are respiratory irritants (not lead fumes — lead doesn't vaporize at soldering temperatures)
- **Use fume extraction:** desktop fume extractor with activated carbon filter, or work near an open window with a fan
- Don't breathe directly above the soldering area

### Lead Safety (for leaded solder)

- **Wash hands** after soldering, especially before eating
- Lead is a cumulative toxin — no amount of exposure is "safe"
- Don't eat, drink, or touch your face while soldering
- Keep soldering area away from food preparation areas
- Lead-free solder eliminates this concern (but has worse flux fumes)

### Burns

- The iron tip is 300-400°C — it will cause instant burns
- Use a proper iron stand/holder, never lay a hot iron on the bench
- Be aware of the hot tip location at all times
- If you accidentally touch the tip: run cool water over the burn immediately

### Electrical Safety

- Unplug circuits before soldering on them
- Never solder on energized mains-voltage equipment
- Be aware that capacitors can retain charge even when power is disconnected — discharge large capacitors before working on them
