# Software Defined Radio (SDR) Overview

## What Is SDR?

In a traditional radio, most signal processing (filtering, demodulation, amplification) is done by dedicated analog hardware circuits. In a **Software Defined Radio**, these functions are performed by software running on a general-purpose computer (or embedded processor).

An SDR device typically contains:
1. An **antenna** to receive RF signals
2. An **RF front-end** (tuner, mixer, amplifier)
3. An **analog-to-digital converter (ADC)** that digitizes the RF signal
4. A **USB or network interface** to send the digitized data to a computer

The computer then does everything else in software: filtering, demodulation, decoding, display, recording. This makes SDR incredibly flexible — the same hardware can receive FM broadcast, decode aircraft transponders, capture weather satellite images, or monitor ISM-band sensors, all by changing software.

---

## Common SDR Hardware

### RTL-SDR Blog V3 / V4 (~$30)

The most popular entry-level SDR. Based on the Realtek RTL2832U chip (originally a DVB-T TV tuner, repurposed for wideband reception).

| Parameter | V3 | V4 |
|-----------|----|----|
| Frequency range | 500 kHz - 1.766 GHz | 500 kHz - 1.766 GHz |
| Tuner | R820T2 | R828D |
| ADC | 8-bit | 8-bit |
| Max sample rate | 2.4 MSPS (stable), 3.2 MSPS (max) | 2.4 MSPS (stable), 3.2 MSPS (max) |
| Bandwidth | Up to ~2.4 MHz | Up to ~2.4 MHz |
| Connector | SMA Female | SMA Female |
| Direct sampling | HF mode via Q-branch (limited) | Improved HF mode |
| Bias-T | Yes (software activated, 4.5V) | Yes |
| TCXO | 1 PPM | 1 PPM |
| Price | ~$25-30 | ~$30-35 |

**Best for**: Beginners, general-purpose wideband reception, ADS-B, weather satellites, FM, ISM band monitoring, amateur radio monitoring. Receive-only.

### HackRF One (~$300)

An open-source SDR platform capable of both **transmit and receive**.

| Parameter | Value |
|-----------|-------|
| Frequency range | 1 MHz - 6 GHz |
| ADC/DAC | 8-bit |
| Max sample rate | 20 MSPS |
| Bandwidth | Up to 20 MHz |
| Connector | SMA Female |
| TX power | ~-10 to +10 dBm (varies with frequency) |
| Half/full duplex | Half duplex (TX or RX, not simultaneous) |

**Best for**: Security research, protocol analysis, signal replay, wideband spectrum analysis, experimenting with TX (at very low power). NOT a high-performance receiver — the 8-bit ADC limits dynamic range.

### Airspy Mini / R2 / HF+ Discovery ($100-200)

High-quality receivers with better performance than RTL-SDR.

- **Airspy Mini**: 24-1800 MHz, 12-bit, 6 MSPS. Good VHF/UHF receiver.
- **Airspy R2**: 24-1800 MHz, 12-bit, 10 MSPS. Wider bandwidth.
- **Airspy HF+ Discovery**: 0.5 kHz - 31 MHz and 60-260 MHz. Excellent HF receiver. 18-bit effective resolution.

**Best for**: Serious listeners who want better performance than RTL-SDR. HF+ Discovery is excellent for shortwave and amateur HF monitoring.

### SDRplay RSP Series ($100-250)

- **RSPdx**: 1 kHz - 2 GHz, 14-bit ADC, 10 MHz bandwidth. Multiple antenna ports. Good for HF through UHF.
- **RSP1B**: Budget model, 1 kHz - 2 GHz, 14-bit, 10 MHz bandwidth.

**Best for**: Wideband monitoring, HF through UHF, good dynamic range. Uses SDRuno software (Windows) or can work with other apps.

### KiwiSDR ($300+)

A web-based SDR receiver (0-30 MHz). Plugs into a BeagleBone single-board computer and serves a web interface. Many KiwiSDRs are publicly accessible online.

**Best for**: Remote HF monitoring, sharing your receiver with others via the web.

### Comparison Table

| Device | Freq Range | Bits | BW | TX | Price |
|--------|-----------|------|-----|-----|-------|
| RTL-SDR V3/V4 | 0.5 MHz - 1.766 GHz | 8 | 2.4 MHz | No | $30 |
| Airspy Mini | 24 - 1800 MHz | 12 | 6 MHz | No | $100 |
| Airspy HF+ Discovery | 0.5 kHz - 260 MHz | 18-bit eff | 768 kHz | No | $170 |
| SDRplay RSPdx | 1 kHz - 2 GHz | 14 | 10 MHz | No | $250 |
| HackRF One | 1 MHz - 6 GHz | 8 | 20 MHz | Yes | $300 |
| LimeSDR Mini | 10 MHz - 3.5 GHz | 12 | 30.72 MHz | Yes | $200 |
| ADALM-Pluto | 325 MHz - 3.8 GHz | 12 | 20 MHz | Yes | $200 |

---

## What Can You Do with an SDR?

### Receive and Listen

- **FM broadcast radio** (87.5-108 MHz) — stereo, RDS data
- **AM broadcast** (with HF-capable SDR or direct sampling mode)
- **Shortwave broadcast and amateur radio** (HF bands)
- **VHF/UHF amateur radio** — monitor 2m, 70cm bands
- **Aircraft communications** (118-137 MHz AM)
- **Marine VHF** (156-162 MHz)
- **Railroad communications** (160-161 MHz)
- **FRS/GMRS** (462/467 MHz)
- **Public safety, fire, EMS** (various VHF/UHF frequencies — check local laws regarding monitoring)

### Decode Digital Signals

- **ADS-B aircraft tracking** (1090 MHz) — see aircraft positions on a map in real-time
- **AIS marine vessel tracking** (161.975/162.025 MHz)
- **NOAA weather satellite images** (137 MHz APT)
- **Meteor M2 satellite images** (137 MHz LRPT)
- **ISM band device decoding** (433.92 MHz / 915 MHz) — weather stations, thermometers, tire pressure sensors, door sensors
- **POCSAG/FLEX pagers** (929-932 MHz)
- **Trunked radio systems** (P25, DMR, NXDN)
- **APRS** (144.390 MHz)
- **Digital amateur modes** (FT8, PSK31, WSPR, etc.)
- **NOAA weather fax** (HF)
- **Time signals** (WWV on 5/10/15 MHz)

### Spectrum Analysis

- See the RF spectrum around you in real-time
- Identify interference sources
- Find active frequencies
- Measure signal characteristics

### Advanced / Experimental

- **GPS signal reception and processing**
- **GSM/cellular analysis** (educational/research)
- **Bluetooth/Wi-Fi analysis** (limited, with appropriate hardware)
- **Radar signal analysis**
- **Radio astronomy** (hydrogen line at 1420 MHz)

---

## Software Overview

| Software | Platform | Description |
|----------|----------|-------------|
| **SDR#** (SDRSharp) | Windows | Most popular for RTL-SDR. Easy to use. Many plugins. |
| **GQRX** | Linux, macOS | Popular on Linux. Simple, effective. |
| **CubicSDR** | Windows, Linux, macOS | Cross-platform. Multiple VFOs. |
| **SDR++** | Windows, Linux, macOS | Modern, cross-platform. Growing in popularity. |
| **SDRuno** | Windows | For SDRplay hardware. Feature-rich. |
| **GNU Radio** | Windows, Linux, macOS | Signal processing framework. Visual flowgraph editor. Powerful but complex. |
| **HDSDR** | Windows | General-purpose SDR software. |
| **dump1090** | Linux, Windows | ADS-B decoder. Web interface with map. |
| **rtl_433** | Linux, Windows, macOS | ISM band decoder. Hundreds of device protocols. |
| **WXtoImg** | Windows, Linux | NOAA APT weather satellite image decoder. |
| **SDRTrunk** | Windows, Linux, macOS | Trunked radio system decoder (P25, DMR). |

---

## Getting Started (Recommended Path)

1. **Buy an RTL-SDR Blog V3 or V4** ($30). It comes with a basic antenna kit.
2. **Install SDR#** (Windows) or **GQRX** (Linux).
3. **Install RTL-SDR drivers** (Zadig on Windows, rtl-sdr package on Linux).
4. **Tune to an FM broadcast station** to verify everything works.
5. **Listen to aircraft** on 118-137 MHz (AM mode).
6. **Try ADS-B** with dump1090 to track aircraft on a map.
7. **Decode weather stations** with rtl_433.
8. **Receive a NOAA satellite pass** — this is the "wow" moment for most people.

Each of these topics has its own detailed guide in this documentation set.

---

## Legal Considerations

- **Receiving is generally legal** in most countries. In the US, the All Writs Act and ECPA have some provisions, but passive reception of unencrypted radio signals is broadly legal.
- **Exceptions**: Some jurisdictions restrict receiving specific types of signals (e.g., cell phone interception is illegal under the Electronic Communications Privacy Act in the US). Encrypted signals should not be decrypted.
- **Transmitting** with an SDR requires appropriate licensing. An RTL-SDR is receive-only, so this is not a concern. A HackRF or LimeSDR can transmit — ensure you are licensed and operating on authorized frequencies.
- **Do not retransmit or rebroadcast** received signals without authorization.
