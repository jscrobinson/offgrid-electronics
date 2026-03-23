# Field Solar Setup Guide

> Portable solar power for electronics in the field.

## Overview

A field solar setup keeps your devices charged and running when there's no grid power. This guide covers portable setups for charging radios, phones, laptops, Raspberry Pi, and other electronics.

## Components

### Solar Panels

| Type | Size | Output | Use Case |
|---|---|---|---|
| Small rigid | 6V 1-3W | 200-500mA | ESP32/Arduino trickle charge |
| Folding panel | 21-28V, 20-60W | 1-3A | Phone, radio, battery bank |
| Folding panel | 21-28V, 100W | 4-5A | Laptop, Pi, multiple devices |
| Rigid panel | 18V, 100-200W | 5-10A | Base camp, continuous power |

**Folding panels** (Rockpals, Jackery, BigBlue, Renogy) are the best choice for portable use — compact when folded, fast to deploy.

### Charge Controllers

For battery charging (not USB direct):

- **PWM**: Simple, cheap. Panel voltage must roughly match battery voltage. ~75% efficient.
- **MPPT**: Converts excess panel voltage to current. ~95% efficient. 20-30% more energy captured. Worth it for panels >50W.

Budget picks:
- Small: CN3791 module ($2, single cell solar charging IC)
- Medium: Victron SmartSolar 75/15 (15A MPPT, Bluetooth monitoring)
- Large: EPever Tracer 2210AN (20A MPPT, good value)

### Batteries

| Type | Pros | Cons | Best For |
|---|---|---|---|
| LiFePO4 12V | 2000+ cycles, safe, stable voltage | Heavier, more expensive | Semi-permanent field setups |
| Li-ion power bank | Convenient, USB output, portable | Limited cycles (500), lower capacity | Day trips, phone/radio charging |
| 18650 packs | Flexible, rebuildable, cheap per Wh | Requires BMS, assembly | DIY custom packs |
| Lead-acid 12V | Cheap, available everywhere | Very heavy, 50% max DoD | Vehicle/base camp only |

## Example Setups

### Minimal: Phone + Radio Charging

- **Panel**: 21W folding panel with USB output ($25-40)
- **Battery**: 10,000-20,000 mAh power bank
- **Charges**: Phone (1-2x/day), Baofeng battery (2-3x/day)
- **Weight**: ~500g total
- **Cost**: ~$50-70

### Medium: Laptop + Pi + Radios

- **Panel**: 60-100W folding panel ($80-150)
- **Charge controller**: 10A MPPT or PWM
- **Battery**: 12V 20Ah LiFePO4 ($80-120) = 256Wh
- **Inverter**: 150W pure sine wave (for laptop) or use 12V-to-USB-C PD adapter
- **Charges**: Laptop (1x), Pi (continuous 8+ hours), phones, radios
- **Weight**: ~5kg
- **Cost**: ~$250-400

### Full: Base Camp Continuous Power

- **Panel**: 200W rigid or 2x100W folding ($150-300)
- **Charge controller**: 20A MPPT
- **Battery**: 12V 100Ah LiFePO4 ($250-400) = 1280Wh
- **Inverter**: 300-500W pure sine wave
- **Powers**: Multiple laptops, Pi cluster, radios, LED lighting, fans
- **Weight**: ~20kg (battery alone is ~13kg)
- **Cost**: ~$600-1000

## Wiring

### Basic Wiring Diagram

```
Solar Panel ──→ Charge Controller ──→ Battery
                       │
                       ├──→ 12V loads (direct)
                       │
                       └──→ Inverter ──→ AC loads
                                │
                               Fuse between each component
```

### Wire Gauge

| Current | Min Gauge (short run <3m) | Min Gauge (long run >3m) |
|---|---|---|
| <5A | 18 AWG | 16 AWG |
| 5-10A | 16 AWG | 14 AWG |
| 10-20A | 14 AWG | 12 AWG |
| 20-30A | 12 AWG | 10 AWG |

### Connectors

- **Anderson Powerpole**: Standard for 12V DC, genderless, color-coded, rated 15-45A. Highly recommended for field use.
- **MC4**: Standard for solar panels. Weatherproof, locking.
- **XT60**: Common for LiPo/Li-ion packs. Rated 60A continuous.
- **Barrel jack**: Fine for low current (<3A). Common on small devices.

### Fuses

**Always fuse between battery and load.** A short circuit on an unfused lithium battery can cause fire.

| Circuit | Fuse Rating |
|---|---|
| Battery → charge controller | 1.5x panel short circuit current |
| Battery → inverter | 1.25x inverter max current |
| Battery → 12V loads | 1.25x expected max load |

Use automotive blade fuses (cheap, available everywhere) with inline fuse holders.

## Daily Power Estimation

1. List all devices and their power consumption
2. Estimate hours of use per day
3. Sum up Wh/day

| Device | Power (W) | Hours/day | Wh/day |
|---|---|---|---|
| Raspberry Pi 4 | 5 | 8 | 40 |
| T-Beam (Meshtastic) | 0.5 | 24 | 12 |
| Laptop charging | 45 | 2 | 90 |
| Phone charging | 10 | 2 | 20 |
| LED light | 5 | 4 | 20 |
| **Total** | | | **182 Wh/day** |

### Sizing the Battery

- Battery should store 2-3 days of power (for cloudy days)
- For LiFePO4: usable capacity = 90% of rated
- 182 Wh/day × 2 days / 0.9 = **405 Wh minimum** → 12V 34Ah LiFePO4

### Sizing the Panel

- Average sun hours varies by location (3-6 hours of "peak sun")
- Account for losses (~20%: angle, clouds, controller efficiency)
- 182 Wh/day / 4 hours / 0.8 = **57W minimum** → use a 100W panel for margin

## Tips

- **Angle the panel** toward the sun. Even rough alignment improves output 20-30%.
- **Avoid partial shading**. One shaded cell can cut output by 50%+ (unless bypass diodes are present).
- **Monitor voltage**. A simple voltmeter on the battery tells you state of charge.
- **LiFePO4 voltage vs SOC**: 13.4V=100%, 13.2V=80%, 13.0V=50%, 12.8V=20%, 12.0V=0% (empty)
- **Bring a USB power meter** ($5-10) to verify charging current and diagnose issues.
- **Store panels flat** to avoid cracking cells. Don't fold them wet.

## Small-Scale: ESP32 Solar Sensor Node

For a solar-powered ESP32 that runs indefinitely:

```
6V 1W solar panel → TP4056 module → 18650 cell → ESP32 (via 3.3V regulator or direct)
```

- Add a Schottky diode between panel and TP4056 to prevent reverse current at night
- ESP32 deep sleep: ~10μA → a single 18650 lasts months even without sun
- With 1W panel + deep sleep + 5-minute wake cycle: runs indefinitely in most climates
