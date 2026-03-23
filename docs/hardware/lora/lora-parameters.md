# LoRa Radio Parameters Explained

## Overview

LoRa's physical layer has three main configurable parameters that trade off range, data rate, and airtime: **Spreading Factor (SF)**, **Bandwidth (BW)**, and **Coding Rate (CR)**. Understanding these is essential for optimizing LoRa links for your specific application.

## Spreading Factor (SF)

The spreading factor determines how many chirps are used to represent each symbol. Higher SF means more chirps per symbol, which means:
- **More processing gain** — the receiver can decode weaker signals
- **Longer range** — each SF step adds ~2.5 dB of link budget
- **Lower data rate** — fewer symbols per second
- **More airtime** — longer time on air per packet
- **Higher battery usage** — more TX/RX time

| SF | Chips/Symbol | Receiver Sensitivity (125kHz BW) | Relative Range | Notes |
|----|-------------|----------------------------------|----------------|-------|
| SF7 | 128 | -123 dBm | 1x (baseline) | Fastest, shortest range |
| SF8 | 256 | -126 dBm | ~1.3x | |
| SF9 | 512 | -129 dBm | ~1.7x | Good general-purpose default |
| SF10 | 1024 | -132 dBm | ~2.2x | |
| SF11 | 2048 | -134.5 dBm | ~2.8x | |
| SF12 | 4096 | -137 dBm | ~3.5x | Slowest, longest range |

**Key insight**: Each SF step up roughly doubles the airtime. SF12 takes 32x longer than SF7 for the same payload. This matters enormously for battery life and duty cycle compliance.

**Orthogonality**: Different SFs are quasi-orthogonal — an SF7 transmission and an SF12 transmission can occur on the same frequency simultaneously without interfering with each other (mostly). LoRaWAN exploits this to serve many devices.

## Bandwidth (BW)

Bandwidth determines the frequency range of the chirp. LoRa supports several bandwidths:

| Bandwidth | Symbol Rate | Sensitivity Impact | Use Case |
|-----------|-------------|-------------------|----------|
| 7.8 kHz | Very slow | Best sensitivity | Not commonly used |
| 10.4 kHz | Very slow | Excellent | Extreme range experiments |
| 15.6 kHz | Slow | Very good | |
| 20.8 kHz | Slow | Good | |
| 31.25 kHz | Moderate | Good | |
| 41.7 kHz | Moderate | Fair | |
| 62.5 kHz | Moderate | Fair | |
| **125 kHz** | **Standard** | **Standard** | **Default for most use** |
| **250 kHz** | Fast | Reduced | LoRaWAN DR4 |
| **500 kHz** | Fastest | Lowest | LoRaWAN US uplink DR4, downlink |

**Wider bandwidth = faster data but worse sensitivity.** Doubling the bandwidth roughly halves the sensitivity benefit (loses ~3 dB of link budget).

**125 kHz** is the standard choice for most applications. Use 250 or 500 kHz when you need higher throughput and range is not a concern.

**Narrower bandwidths** (< 62.5 kHz) require a TCXO (Temperature Compensated Crystal Oscillator) on the radio module because standard crystals have too much frequency drift. The SX1262 supports TCXO natively. The SX1276 typically does not have TCXO on most modules.

## Coding Rate (CR)

The coding rate adds Forward Error Correction (FEC) redundancy to the transmitted data:

| Coding Rate | Ratio | Overhead | Error Correction Capability |
|-------------|-------|----------|----------------------------|
| 4/5 | 1.25x | 25% extra symbols | Low — corrects minor bit errors |
| 4/6 | 1.5x | 50% extra symbols | Moderate |
| 4/7 | 1.75x | 75% extra symbols | Good |
| 4/8 | 2.0x | 100% extra symbols | Best — doubles airtime vs 4/5 |

**Higher coding rate = more error resilience but more airtime.** In practice:
- **4/5** is fine for clean, high-SNR links
- **4/7** or **4/8** helps in noisy environments or near the sensitivity limit
- The difference in range between CR 4/5 and 4/8 is minimal (it does not add link budget, just error resilience)

For most applications, **4/5** is the default and recommended starting point.

## Data Rate and Airtime Table

The following table shows data rates and airtime for a **20-byte payload** with **8-byte preamble**, explicit header mode, CRC enabled, at **125 kHz bandwidth** and **CR 4/5**:

| SF | Bit Rate (bps) | 20-byte Payload Airtime | Max Payload (255 bytes) Airtime | Receiver Sensitivity |
|----|----------------|------------------------|--------------------------------|---------------------|
| SF7 | 5,470 | ~46 ms | ~400 ms | -123 dBm |
| SF8 | 3,125 | ~82 ms | ~720 ms | -126 dBm |
| SF9 | 1,760 | ~165 ms | ~1.3 s | -129 dBm |
| SF10 | 977 | ~330 ms | ~2.6 s | -132 dBm |
| SF11 | 537 | ~660 ms | ~4.7 s | -134.5 dBm |
| SF12 | 293 | ~1.2 s | ~9.3 s | -137 dBm |

**Observation**: A 20-byte packet at SF12 takes ~26x longer to transmit than at SF7. For battery-powered devices sending frequent updates, this is the difference between months and days of battery life.

### With 250 kHz Bandwidth (CR 4/5)

| SF | Bit Rate (bps) | 20-byte Airtime | Sensitivity |
|----|----------------|-----------------|-------------|
| SF7 | 10,940 | ~23 ms | -120 dBm |
| SF9 | 3,520 | ~82 ms | -126 dBm |
| SF12 | 586 | ~600 ms | -134 dBm |

### With 500 kHz Bandwidth (CR 4/5)

| SF | Bit Rate (bps) | 20-byte Airtime | Sensitivity |
|----|----------------|-----------------|-------------|
| SF7 | 21,880 | ~12 ms | -117 dBm |
| SF9 | 7,030 | ~41 ms | -123 dBm |
| SF12 | 1,172 | ~300 ms | -131 dBm |

## Frequency Plans

### US915 (902-928 MHz)

Used in North America, governed by FCC Part 15.247.

- **64 uplink channels** at 125 kHz BW: 902.3 MHz to 914.9 MHz (200 kHz spacing)
- **8 uplink channels** at 500 kHz BW: 903.0 MHz to 914.2 MHz (1.6 MHz spacing)
- **8 downlink channels** at 500 kHz BW: 923.3 MHz to 927.5 MHz (600 kHz spacing)
- **Max TX power**: 30 dBm EIRP (1 Watt) — most modules support 17-22 dBm conducted
- **No duty cycle limit**, but frequency hopping is typically used
- **Meshtastic default**: Uses a subset of channels, commonly sub-band 2 (channels 8-15 + 65)

For raw LoRa (non-LoRaWAN), you can use any frequency in the 902-928 MHz range. Common choices:
- 915.0 MHz (center of band, most common)
- 906.875 MHz, 907.5 MHz (Meshtastic defaults vary by slot)

### EU868 (863-870 MHz)

Used in Europe, governed by ETSI EN 300.220.

- **3 default channels**: 868.1, 868.3, 868.5 MHz (mandatory for join in LoRaWAN)
- **5 additional common channels**: configurable
- **Max TX power**: 14 dBm ERP (25 mW) on most sub-bands
- **Duty cycle**: **1% on 868.0-868.6 MHz** (sub-band g1), **0.1% on 868.7-869.2 MHz**, **10% on 869.4-869.65 MHz** (sub-band g3, high power at 27 dBm)

**Duty cycle math**: At 1% duty cycle, you can transmit for a total of 36 seconds per hour. A SF12/125kHz packet of 20 bytes takes ~1.2 seconds, so you can send about 30 such packets per hour. At SF7, you can send about 780 packets per hour.

### AU915 (915-928 MHz)

Used in Australia and New Zealand. Very similar to US915:
- 64 + 8 uplink channels, 8 downlink channels
- Max 30 dBm EIRP
- No duty cycle requirement

### AS923 (920-923 MHz)

Used in Japan, South Korea, Singapore, and parts of Southeast Asia:
- 2 default channels: 923.2 MHz and 923.4 MHz
- Max TX power varies by country (Japan: 13 dBm, others vary)
- Listen-before-talk may be required (Japan)

### Choosing a Frequency for Raw LoRa

If you are not using LoRaWAN and just doing point-to-point or mesh:
1. Stay within your region's ISM band
2. Pick a frequency that avoids known interference
3. For US915, 915.0 MHz is the simplest default
4. For EU868, 868.1 MHz is common, but mind the 1% duty cycle
5. Document your frequency so all nodes match

## Link Budget Calculation

The link budget determines whether a LoRa signal can be received at a given distance. It is the fundamental equation for range estimation.

```
Link Budget (dB) = TX Power (dBm) + TX Antenna Gain (dBi) + RX Antenna Gain (dBi)
                   - TX Cable Loss (dB) - RX Cable Loss (dB)
                   - Path Loss (dB) - Fade Margin (dB)
```

**Received signal must be above the receiver sensitivity for successful demodulation.**

### Free-Space Path Loss (FSPL)

```
FSPL (dB) = 20*log10(d) + 20*log10(f) - 27.55
```
Where d = distance in meters, f = frequency in MHz.

| Distance | FSPL at 868 MHz | FSPL at 915 MHz |
|----------|----------------|-----------------|
| 1 km | 91.3 dB | 91.7 dB |
| 5 km | 105.3 dB | 105.7 dB |
| 10 km | 111.3 dB | 111.7 dB |
| 20 km | 117.3 dB | 117.7 dB |
| 50 km | 125.3 dB | 125.7 dB |

### Example Calculation

Setup: SX1262 at +22 dBm, 3 dBi antenna on both sides, 1 dB cable loss each side, SF9/125kHz (sensitivity -129 dBm), 10 dB fade margin.

```
Available link budget = 22 + 3 + 3 - 1 - 1 = 26 dBm transmitted EIRP equivalent
                        (actually: link budget = 26 - (-129) = 155 dB)
Maximum path loss     = 155 - 10 (fade margin) = 145 dB
```

Using FSPL formula at 915 MHz:
```
145 = 20*log10(d) + 20*log10(915) - 27.55
145 = 20*log10(d) + 59.23 - 27.55
20*log10(d) = 113.32
d = 10^(113.32/20) = ~46,400 meters = ~46 km
```

This is the **theoretical free-space** range. Real-world will be significantly less due to terrain, vegetation, buildings, and ground effects. Typically expect 30-60% of theoretical in rural and 10-25% in urban environments.

## Practical Recommendations

### Short Range, High Throughput (< 2 km, urban)
- SF7, 250 kHz BW, CR 4/5
- Good for: frequent sensor readings, near-real-time data
- Airtime: minimal, great for battery life

### General Purpose (2-10 km)
- SF9, 125 kHz BW, CR 4/5
- Good balance of range and throughput
- This is what most Meshtastic configurations default to

### Long Range (10+ km, rural/LOS)
- SF10-SF12, 125 kHz BW, CR 4/5 or 4/8
- Maximum range at the expense of data rate
- Long airtime — mind duty cycle in EU

### Extreme Range (20+ km, LOS, experimental)
- SF12, 62.5 kHz or 31.25 kHz BW, CR 4/8
- Requires TCXO on both radios
- Very slow (~100-200 bps effective)
- Possible with elevated antennas and clear line of sight

### Dense Network (many nodes, limited spectrum)
- SF7, 125 kHz BW, CR 4/5
- Minimizes airtime, reduces collision probability
- Different node groups on different frequencies if possible

## Sync Word

The sync word is a 1 or 2 byte value that differentiates LoRa networks. Receivers only demodulate packets with a matching sync word.

| Sync Word | Use |
|-----------|-----|
| 0x12 | Default for private/raw LoRa networks |
| 0x34 | LoRaWAN |
| 0x1424 | LoRaWAN (SX1262 2-byte format) |

Meshtastic uses its own sync word. If building a custom network, pick a sync word that does not conflict with other known LoRa traffic in your area.

## Implicit vs Explicit Header Mode

- **Explicit header** (default): Packet includes SF, CR, payload length, and CRC presence in a header. The receiver auto-detects these parameters.
- **Implicit header**: No header; receiver must know SF, CR, and payload length in advance. Saves a few bytes of airtime. Used when all parameters are fixed and known.

For most projects, use explicit header mode unless you have a specific reason to save those few bytes.
