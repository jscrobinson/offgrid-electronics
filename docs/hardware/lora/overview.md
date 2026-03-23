# LoRa Technology Overview

## What Is LoRa?

LoRa (Long Range) is a proprietary chirp spread spectrum (CSS) modulation technique developed by Semtech. It operates in unlicensed ISM bands and is designed for low-power, long-range communication at low data rates. The physical layer modulation encodes data into chirp signals — frequency sweeps that increase (upchirp) or decrease (downchirp) linearly over time. This makes LoRa highly resistant to multipath fading, Doppler shift, and interference.

Key characteristics:
- **Range**: 2-15 km typical, 20+ km line-of-sight
- **Data rate**: 0.3 kbps to 27 kbps (depending on parameters)
- **Power**: Devices can run for years on coin cells or small batteries
- **Topology**: Point-to-point, star, or mesh (with appropriate firmware)

## LoRa vs LoRaWAN

These terms are frequently confused. They refer to different layers of the stack.

| Aspect | LoRa | LoRaWAN |
|--------|------|---------|
| Layer | Physical (PHY) modulation | MAC protocol + network architecture |
| Defined by | Semtech (proprietary) | LoRa Alliance (open specification) |
| Topology | Point-to-point, any | Star-of-stars (end devices -> gateways -> network server) |
| Addressing | None (raw radio) | DevEUI, AppEUI, device classes (A/B/C) |
| Encryption | None built-in | AES-128 (NwkSKey + AppSKey) |
| Use without the other | Yes — raw LoRa with RadioLib, Arduino-LoRa, etc. | No — LoRaWAN requires LoRa PHY |

**For off-grid and mesh networking use cases, you typically use raw LoRa (not LoRaWAN).** LoRaWAN requires infrastructure (gateways, network servers like TTN/Chirpstack) that may not be available. Projects like Meshtastic use raw LoRa with their own mesh protocol on top.

## Frequency Bands

LoRa operates in ISM (Industrial, Scientific, Medical) bands that vary by region. Using the wrong band is illegal in most jurisdictions.

| Region | Band | Channels | Notes |
|--------|------|----------|-------|
| Europe (EU868) | 863-870 MHz | 8 default + additional | 1% duty cycle on most sub-bands |
| North America (US915) | 902-928 MHz | 64 uplink (125kHz) + 8 uplink (500kHz) + 8 downlink | FCC Part 15: max 1W conducted, frequency hopping or digital modulation required |
| Australia (AU915) | 915-928 MHz | Same channel plan as US915 | ACMA regulated |
| Asia (AS923) | 920-923 MHz | Varies by country | Japan, South Korea, Southeast Asia |
| Asia (433) | 433.05-434.79 MHz | Varies | Lower frequency = better penetration but larger antennas |
| India (IN865) | 865-867 MHz | 3 default channels | |
| China (CN470) | 470-510 MHz | 96 channels | |

**Important**: Many LoRa modules are hardware-locked to a specific band. An SX1276 868 MHz module cannot transmit at 915 MHz (its RF frontend is tuned and filtered for that band). Always buy modules matching your region.

## Range vs Data Rate Tradeoffs

LoRa's key innovation is the configurable tradeoff between range and data rate, controlled primarily by the **Spreading Factor (SF)**:

- **SF7**: Fastest data rate (~5.5 kbps at 125kHz BW), shortest range, least airtime
- **SF12**: Slowest data rate (~0.29 kbps at 125kHz BW), longest range, most airtime

Each step up in SF roughly doubles the airtime and adds ~2.5 dB of link budget (about 30% more range in ideal conditions). See [lora-parameters.md](lora-parameters.md) for detailed tables.

Practical data rate limits mean LoRa is suited for:
- Small sensor readings (temperature, humidity, GPS coordinates)
- Status messages and alerts
- Short text messages (Meshtastic-style)
- NOT suited for: images, audio, video, firmware updates (though small OTA is possible with patience)

## Typical Use Cases

### IoT Sensor Networks
Deploy battery-powered sensors across a farm, forest, or building complex. Each sensor transmits a few bytes periodically. A central gateway collects data. Battery life can exceed 2-5 years.

### Mesh Networking (Meshtastic)
Off-grid text messaging and position sharing. Each node relays messages for other nodes. No internet or cell infrastructure required. Useful for hiking, emergencies, events, rural areas.

### Asset Tracking
Combine LoRa with GPS. Devices report position periodically. Low power means trackers can run for weeks to months. Range covers large areas (warehouses, ports, ranches).

### Agricultural Monitoring
Soil moisture, weather stations, water level monitoring across large properties where WiFi and cellular do not reach.

### Emergency / Disaster Communications
When cell towers go down, LoRa mesh networks can provide basic text and position communication. Runs on battery power, no infrastructure needed.

### Infrastructure Monitoring
Bridge strain gauges, pipeline leak detection, power line monitoring — anywhere you need data from a remote location without running cables or paying for cellular.

## Comparison with Other LPWAN Technologies

| Feature | LoRa | Sigfox | NB-IoT | LTE-M |
|---------|------|--------|--------|-------|
| Spectrum | Unlicensed ISM | Unlicensed ISM | Licensed cellular | Licensed cellular |
| Range (urban) | 2-5 km | 3-10 km | 1-10 km | 1-10 km |
| Range (rural) | 5-15 km | 30-50 km | 10+ km | 10+ km |
| Max data rate | 27 kbps | 100 bps | 250 kbps | 1 Mbps |
| Max payload | 243 bytes | 12 bytes (UL) / 8 bytes (DL) | 1600 bytes | 1600 bytes |
| Messages/day | Unlimited (duty cycle limited in EU) | 140 UL / 4 DL | Unlimited | Unlimited |
| Battery life | 2-10+ years | 2-10+ years | 2-10 years | 2-10 years |
| Private network | Yes (buy your own hardware) | No (Sigfox operates network) | No (carrier network) | No (carrier network) |
| Cost per device | $5-20 for a module | $2-5 module + subscription | $5-15 module + SIM/plan | $10-20 module + SIM/plan |
| Bidirectional | Yes, full | Very limited downlink | Yes, full | Yes, full |
| Infrastructure needed | None (P2P) or self-hosted gateway | Sigfox base stations | Cell towers (carrier) | Cell towers (carrier) |

### Why LoRa Wins for Off-Grid

- **No subscription fees**: You own the hardware and the network.
- **Private networks**: No dependency on any company or carrier.
- **Mesh capable**: Firmware like Meshtastic enables multi-hop relaying.
- **Fully offline**: Works with zero internet connectivity.
- **Open ecosystem**: Multiple chip vendors (Semtech SX1276/SX1262/LR1110), many module makers (Heltec, LILYGO, RAK, Hope RF), extensive open-source software.

## Common LoRa Chips

| Chip | Frequency | Features | Status |
|------|-----------|----------|--------|
| SX1276 | 137-1020 MHz | Original LoRa transceiver, FSK+LoRa, widespread | Mature, widely available |
| SX1278 | 137-525 MHz | Same as SX1276, lower frequency variant | Mature |
| SX1262 | 150-960 MHz | Next-gen: lower power TX/RX, longer range, TCXO support | Recommended for new designs |
| SX1268 | 410-810 MHz | SX1262 variant for lower frequencies | Newer |
| LR1110 | 150-960 MHz + GNSS + WiFi scanning | LoRa + onboard GNSS scanner + WiFi passive scanning | Advanced, for tracking |
| LR1121 | 150-960 MHz + 2.4 GHz | Dual-band LoRa, sub-GHz + 2.4 GHz | Latest generation |

## Getting Started

For practical LoRa projects, see:
- [LILYGO T-Beam v1.2](lilygo-tbeam-v1.2.md) — ESP32 + LoRa + GPS, ideal for Meshtastic
- [Heltec WiFi LoRa 32 V3](heltec-esp32-v3.md) — ESP32-S3 + LoRa + OLED, great general-purpose board
- [LoRa Parameters Explained](lora-parameters.md) — Deep dive on SF, BW, CR, and frequency plans
- [Range Optimization](range-optimization.md) — Practical guide to maximizing range
