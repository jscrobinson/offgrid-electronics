# LoRa Range Optimization Guide

## Overview

Maximizing LoRa range is a combination of antenna engineering, radio parameter tuning, and site selection. This guide covers the practical aspects of getting the most out of your LoRa link.

## Antenna Selection

The antenna is the single most impactful component for range. A good antenna does far more than increasing transmit power.

### Antenna Types

| Type | Gain | Pattern | Size (915 MHz) | Best For |
|------|------|---------|-----------------|----------|
| 1/4 wave whip | ~1.5 dBi | Omnidirectional, donut-shaped | ~8.2 cm | Portable, basic |
| 1/2 wave dipole | ~2.15 dBi | Omnidirectional, tighter donut | ~16.4 cm | General purpose |
| 5/8 wave ground plane | ~3-4 dBi | Omnidirectional, low angle | ~20 cm + radials | Fixed base station |
| Collinear (2-element) | ~5-6 dBi | Omnidirectional, very flat | ~35 cm | Fixed elevated site |
| Collinear (4-element) | ~7-8 dBi | Omnidirectional, very flat | ~70 cm | Tower/mast mount |
| Yagi (3-element) | ~7-8 dBi | Directional, ~60deg beam | ~50 cm | Point-to-point link |
| Yagi (5+ element) | ~10-12 dBi | Directional, ~35deg beam | ~80 cm+ | Long-distance P2P |
| Helical (on PCB) | ~-1 to 1 dBi | Near-omnidirectional | Small | Space-constrained |
| PCB trace antenna | ~-2 to 0 dBi | Variable | On PCB | Integrated devices |

**Recommendations**:
- **Portable/handheld**: 1/4 wave whip or stubby flex antenna. Easy to carry, decent performance.
- **Fixed node (omnidirectional)**: 1/2 wave or collinear. Provides good coverage in all horizontal directions.
- **Point-to-point link**: Yagi or other directional antenna. Concentrates energy toward the other station.
- **Avoid**: The tiny stock antennas that come with cheap modules. They are often poorly tuned and cut range dramatically.

### Frequency Matching

An antenna must be tuned for your operating frequency. A 915 MHz antenna will perform poorly at 868 MHz and vice versa. Always check:
- The antenna's specified frequency range
- VSWR or return loss specification (VSWR < 2:1 is acceptable, < 1.5:1 is good)

A 1/4 wave antenna length:
```
Length (cm) = 7500 / frequency (MHz)

868 MHz: 7500 / 868 = 8.64 cm
915 MHz: 7500 / 915 = 8.20 cm
433 MHz: 7500 / 433 = 17.32 cm
```

## Antenna Height and Fresnel Zone

### Height Matters More Than Power

Doubling transmit power adds only 3 dB (maybe 30% more range). Doubling antenna height can add 6 dB or more in practice because it gets the signal above obstacles and clears the Fresnel zone.

### What Is the Fresnel Zone?

Radio waves do not travel in a laser-thin line. The signal occupies an ellipsoidal volume between transmitter and receiver called the Fresnel zone. For a reliable link, at least 60% of the first Fresnel zone must be clear of obstructions.

**First Fresnel zone radius at the midpoint**:
```
r (meters) = 17.32 * sqrt(d / (4 * f))
```
Where d = distance in km, f = frequency in GHz.

| Distance | Fresnel Zone Radius (915 MHz) | Minimum Clearance (60%) |
|----------|------------------------------|------------------------|
| 1 km | 8.6 m | 5.2 m |
| 5 km | 19.2 m | 11.5 m |
| 10 km | 27.2 m | 16.3 m |
| 20 km | 38.4 m | 23.1 m |

**Practical implication**: For a 10 km link at 915 MHz, you need at least 16 meters of clearance above any terrain or obstacle at the midpoint. This is why antenna height is so critical for long-range links.

### Earth Curvature

For links beyond ~5 km, the curvature of the Earth becomes a factor. At 10 km, the Earth's surface drops about 2 meters below a straight line between two points. At 20 km, it drops about 8 meters. This adds to the required antenna height.

**Rule of thumb for required combined antenna height over flat terrain**:
```
h_total (m) ≈ d^2 / 25  (for d in km, very rough)
```
A 20 km link over flat ground needs roughly 16 meters of combined antenna height just for Earth curvature, plus Fresnel zone clearance on top of that.

## Radio Parameter Tuning

### Spreading Factor (SF)

This is your primary range control. See [lora-parameters.md](lora-parameters.md) for detailed tables.

- Start with SF9 or SF10 for a balanced link
- If you have margin (RSSI well above sensitivity), drop to SF7 or SF8 for faster data rate
- If the link is marginal, increase to SF11 or SF12
- Each SF step adds ~2.5 dB link budget (but doubles airtime)

### Bandwidth (BW)

- 125 kHz is standard and recommended for most use
- 62.5 kHz adds ~3 dB sensitivity but requires TCXO and halves data rate
- 250 or 500 kHz reduces range but increases throughput

### Coding Rate

- Minimal impact on range (does not change link budget)
- CR 4/8 helps in high-interference environments by correcting more bit errors
- For clean environments, stick with CR 4/5

### Power

- SX1276: up to +17 dBm (PA_BOOST) or +20 dBm (with RFO_HF)
- SX1262: up to +22 dBm
- Higher power helps, but going from +14 to +22 dBm is only 8 dB — less than switching from SF7 to SF10
- Higher TX power means higher current draw — matters for battery life
- Check your local regulations for maximum TX power

## Line of Sight vs Non-Line-of-Sight

### Line of Sight (LOS)

With a clear, unobstructed path between transmitter and receiver:
- Range follows the free-space path loss model closely
- 20-50+ km is achievable with good antennas and elevated positions
- Reflections off flat surfaces (water, flat ground) can cause multipath fading — elevating antennas helps

### Non-Line-of-Sight (NLOS)

In real-world environments with obstructions:

| Environment | Typical Range | Signal Behavior |
|-------------|---------------|-----------------|
| Open rural (rolling hills) | 5-15 km | Some diffraction over hills, generally good |
| Suburban (houses, trees) | 2-5 km | Significant attenuation, multipath reflections |
| Urban (buildings) | 0.5-3 km | Heavy absorption, diffraction around buildings |
| Dense urban (downtown) | 0.2-1 km | Severe attenuation, mostly reflections |
| Indoor to outdoor | 0.1-1 km | Walls absorb 5-15 dB each depending on material |
| Forest / heavy vegetation | 1-5 km | Leaves absorb and scatter signal, especially when wet |

**Material attenuation (approximate, per wall/layer)**:
| Material | Attenuation |
|----------|-------------|
| Drywall / wood frame | 3-5 dB |
| Brick | 5-10 dB |
| Concrete (reinforced) | 10-20 dB |
| Metal (sheet/foil) | 20-40 dB |
| Glass (plain) | 2-4 dB |
| Glass (low-E coated) | 10-15 dB |
| Vegetation (per 10m) | 2-5 dB |
| Earth/ground | Opaque |

## Ground Plane

Many antenna types (especially 1/4 wave monopoles) require a ground plane to function correctly. Without a proper ground plane, the antenna pattern deforms and efficiency drops.

### What Counts as a Ground Plane
- Metal plate or disc beneath the antenna, ideally 1/4 wavelength in radius (~8 cm at 915 MHz)
- 3-4 radial wires extending from the antenna base, each 1/4 wavelength
- A metal enclosure or vehicle roof
- A PCB ground pour (for PCB-mount antennas)

### Signs of Missing Ground Plane
- Much shorter range than expected
- Poor VSWR / high reflected power
- Radiation pattern has a strong upward lobe (wasting energy toward the sky)

**Tip**: If mounting a 1/4 wave whip on a non-metallic enclosure, add at least 4 radial wires (each ~8 cm for 915 MHz) extending horizontally or at 45 degrees downward from the antenna base.

1/2 wave dipoles and collinear antennas are less dependent on a ground plane because they are balanced antennas.

## Cable Loss and Connectors

### Connector Types

| Connector | Impedance | Size | Use Case |
|-----------|-----------|------|----------|
| SMA (male/female) | 50 ohm | Medium | Most common on dev boards and antennas |
| RP-SMA | 50 ohm | Medium | WiFi convention (reversed pin). Do NOT mix with SMA. |
| IPEX / U.FL | 50 ohm | Tiny | Board-to-antenna pigtails, fragile |
| N-type | 50 ohm | Large | Low loss, outdoor/professional installs |
| BNC | 50 ohm | Medium | Lab use, quick-connect |

**Warning**: SMA and RP-SMA look identical but are NOT compatible. SMA has a center pin on the male plug. RP-SMA has a center pin on the female (socket). Using the wrong type results in no connection.

### Cable Loss

Every meter of coaxial cable attenuates your signal. Use the shortest cable possible and choose low-loss cable for runs over 1-2 meters.

| Cable Type | Loss at 900 MHz (per meter) | Use Case |
|------------|----------------------------|----------|
| RG-174 | ~1.0 dB/m | Short pigtails only (<30 cm) |
| RG-58 | ~0.6 dB/m | Short runs only (<1 m) |
| RG-213 | ~0.3 dB/m | Medium runs (1-5 m) |
| LMR-195 | ~0.5 dB/m | Short to medium runs |
| LMR-240 | ~0.35 dB/m | Medium runs |
| LMR-400 | ~0.22 dB/m | Long runs (5-20 m), recommended |
| LMR-600 | ~0.14 dB/m | Professional installs, long runs |
| Aircom Plus | ~0.12 dB/m | Professional, expensive |

**Example**: 10 meters of RG-58 at 900 MHz loses 6 dB — that is equivalent to reducing your transmit power by 75%. The same 10 meters of LMR-400 loses only 2.2 dB. Cable choice matters.

### IPEX / U.FL Pigtails

The tiny IPEX connectors used on most dev boards are designed for short pigtails (typically to SMA). They have limited insertion cycles (~30) and are fragile. For a permanent installation:
- Solder an SMA edge-mount connector directly to the board if possible
- Keep IPEX pigtails under 15 cm
- Secure the cable so the IPEX connector does not experience mechanical stress

## Real-World Range Expectations

These are practical ranges based on community experience with common LoRa hardware (SX1276/SX1262 at 14-22 dBm, basic whip or small collinear antennas):

| Scenario | SF9/125kHz | SF12/125kHz |
|----------|-----------|-------------|
| Dense urban (ground level) | 0.3-1 km | 0.5-2 km |
| Suburban (ground level) | 1-3 km | 2-5 km |
| Suburban (one elevated node) | 3-8 km | 5-12 km |
| Rural (flat terrain, ground level) | 3-8 km | 5-15 km |
| Rural (one elevated node, 10m+) | 5-15 km | 10-25 km |
| Hilltop to hilltop (LOS) | 10-25 km | 20-50 km |
| Mountain to valley | 15-40 km | 30-80+ km |

**Record ranges**: Community members have achieved 200+ km with high-altitude balloon payloads and 100+ km with mountain-top to mountain-top links using high-gain antennas. These are extreme cases.

## Testing Methodology

### Tools You Need

- **RSSI (Received Signal Strength Indicator)**: How strong the received signal is. Measured in dBm. Typical useful range: -40 dBm (very strong) to -130 dBm (at sensitivity limit).
- **SNR (Signal-to-Noise Ratio)**: How far above the noise floor the signal is. Measured in dB. LoRa can decode at negative SNR (down to about -20 dB at SF12). Positive SNR means you have margin.

### Reading RSSI and SNR (RadioLib)

```cpp
// After receiving a packet:
float rssi = radio.getRSSI();
float snr = radio.getSNR();
Serial.printf("RSSI: %.1f dBm, SNR: %.1f dB\n", rssi, snr);
```

### Interpreting Results

| RSSI | Signal Quality |
|------|---------------|
| > -70 dBm | Excellent — you are close or have very good antennas |
| -70 to -90 dBm | Good — reliable link with plenty of margin |
| -90 to -110 dBm | Moderate — working but be aware of fade margin |
| -110 to -120 dBm | Weak — approaching limits, may have packet loss |
| -120 to -130 dBm | Very weak — near sensitivity limit, unreliable |
| < -130 dBm | Below sensitivity — no reception |

| SNR | Meaning |
|-----|---------|
| > 10 dB | Excellent margin |
| 5-10 dB | Good, reliable |
| 0-5 dB | Adequate |
| -5 to 0 dB | Marginal (LoRa still works here) |
| -10 to -5 dB | Weak, only works at higher SF |
| < -15 dB | At the edge, SF12 only |

### Walk Test Procedure

1. Set up a **fixed base station** with the antenna at its final height and position.
2. Carry a **mobile node** with a display showing last-received RSSI and SNR, or log to SD card/serial.
3. Configure both nodes to send periodic packets (every 5-10 seconds).
4. Walk or drive away from the base station along your intended coverage area.
5. Record RSSI, SNR, and GPS coordinates at each point (or use Meshtastic's built-in map/trace).
6. Mark locations where packets start failing.
7. Repeat with different SF, antenna height, and antenna types to compare.

### What to Measure

- **Packet delivery ratio**: How many packets arrived vs how many were sent? Below 90% means the link is marginal.
- **RSSI vs distance**: Plot this. Expect roughly linear (in dB) decrease with log(distance). Sudden drops indicate obstructions.
- **SNR vs distance**: When SNR goes negative, you are relying on LoRa's spread spectrum processing gain. Higher SF gives more margin.
- **Maximum reliable range**: The farthest point where you still get >90% packet delivery.

### Fade Margin

Always design your link with 10-20 dB of fade margin. Real-world signal strength varies due to:
- Weather (rain attenuation is minimal at 900 MHz but humidity affects propagation)
- Vegetation changes (trees in leaf vs bare)
- Moving obstacles (vehicles, people)
- Multipath fading (constructive and destructive interference)

If your link works at exactly the sensitivity limit with no margin, it will fail intermittently.

## Quick Optimization Checklist

1. **Antenna height**: Get the antenna as high as possible. This is usually the cheapest and most effective improvement.
2. **Antenna quality**: Replace stock rubber duck with a properly tuned 1/4 wave, 1/2 wave, or collinear.
3. **Cable**: Use the shortest, lowest-loss cable possible. LMR-400 for runs over 2 meters.
4. **Clear Fresnel zone**: Ensure 60%+ of the first Fresnel zone is unobstructed.
5. **Spreading factor**: Increase SF if link is marginal; decrease if you have margin to spare.
6. **TX power**: Increase to maximum allowed by regulations. This is a last resort, not the first.
7. **Ground plane**: Ensure your antenna has an adequate ground plane.
8. **Connector quality**: Check all connectors. A corroded or loose SMA connector can add several dB of loss.
9. **Orientation**: Vertical polarization is standard. Ensure both antennas are oriented the same way (both vertical).
10. **Environment**: Clear vegetation around the antenna if possible. Even nearby bushes can attenuate signal.
