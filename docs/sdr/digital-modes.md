# Digital Radio Modes Overview

## Introduction

Digital radio modes replace traditional analog FM voice with digitally encoded and compressed voice. The audio is processed by a voice codec, converted to a digital bitstream, and transmitted using digital modulation. This provides clearer audio (up to a point), more efficient spectrum use, and additional features like text messaging, GPS position reporting, and encryption.

This guide covers the most common digital modes you will encounter when monitoring with an SDR.

---

## DMR (Digital Mobile Radio)

### Overview

DMR is an open standard defined by ETSI. It is the most popular digital radio standard worldwide for commercial, amateur, and increasingly some public safety use.

### Technical Details

| Parameter | Value |
|-----------|-------|
| Modulation | 4FSK |
| Access | TDMA (2 timeslots per 12.5 kHz channel) |
| Voice codec | AMBE+2 |
| Data rate | 9.6 kbps per timeslot |
| Bandwidth | 12.5 kHz |

### Key Concepts

- **Timeslots**: Each 12.5 kHz channel carries TWO independent voice conversations using Time Division Multiple Access (TDMA). Timeslot 1 (TS1) and Timeslot 2 (TS2).
- **Color Code**: A number (0-15) that identifies the system, similar to CTCSS tones. Radios must match the color code to access the system.
- **Talk Groups (TG)**: Logical groupings of users. Example: TG 1 = Worldwide, TG 310 = US nationwide, TG 3106 = Pennsylvania.
- **Private calls**: Direct calls to a specific radio ID.
- **Tiers**:
  - **Tier I**: License-free (low power, like digital PMR446 in Europe)
  - **Tier II**: Conventional (licensed, direct/repeater) and simple trunked
  - **Tier III**: Full trunked system (equivalent to P25 trunking)

### Amateur Radio DMR

DMR is popular among ham operators via networks like:
- **Brandmeister**: The largest amateur DMR network worldwide. Thousands of interconnected repeaters.
- **TGIF**: An alternative network.
- **DMR-MARC**: One of the original amateur DMR networks.

Amateur DMR requires:
- A DMR-capable radio (e.g., TYT MD-380/UV380, Anytone AT-D878UV, Retevis RT3S)
- A DMR ID (registered at radioid.net with your callsign)
- Programming with correct frequencies, color codes, talk groups, and timeslots

### Monitoring DMR with SDR

**DSD+ (Windows)**:
1. Tune SDR# to the DMR frequency (NFM mode, 12.5 kHz).
2. Route audio to DSD+ via virtual audio cable.
3. DSD+ auto-detects DMR and decodes both timeslots.
4. Voice output plays through speakers.

**SDRTrunk**: Can decode DMR directly with the RTL-SDR, including trunked DMR Tier III systems.

---

## D-STAR (Digital Smart Technologies for Amateur Radio)

### Overview

D-STAR is an open standard developed by the Japan Amateur Radio League (JARL) and primarily implemented by Icom. It was the first digital voice mode widely adopted by amateur radio operators.

### Technical Details

| Parameter | Digital Voice (DV) | Digital Data (DD) |
|-----------|-------------------|-------------------|
| Modulation | GMSK | GMSK |
| Voice codec | AMBE (3600 bps) | N/A |
| Data rate | 4800 bps (1200 voice + 3600 data) | 128 kbps |
| Bandwidth | 6.25 kHz | 150 kHz |
| Bands | VHF, UHF | UHF (1.2 GHz) |

### Key Concepts

- **Reflectors**: D-STAR repeaters can connect to reflectors (conference servers) over the internet. Users on different repeaters connected to the same reflector can communicate.
- **Callsign routing**: D-STAR uses callsigns for routing — you can call a specific station by callsign, and the system routes the call to whatever repeater that station is connected to.
- **Gateway**: Internet-connected D-STAR repeaters have a gateway that enables inter-repeater linking.
- **REF, DCS, XLX**: Different reflector systems.

### Equipment

D-STAR was long exclusive to Icom radios:
- Icom IC-9700, IC-7100 (base/mobile)
- Icom ID-51A, ID-52A (handheld)
- OpenSpot and MMDVM hotspots enable D-STAR access from other radios.

### Monitoring D-STAR with SDR

- DSD+ can decode D-STAR DV audio.
- GQRX + DSD can also decode.
- D-STAR signals on NFM sound like a distinctive "quacking" noise.

---

## P25 (Project 25 / APCO-25)

### Overview

P25 is the primary digital radio standard for public safety (police, fire, EMS) in North America. It is designed to be interoperable across agencies and manufacturers.

See the [trunking.md](trunking.md) document for detailed P25 trunking information.

### Technical Details

| Parameter | Phase 1 | Phase 2 |
|-----------|---------|---------|
| Modulation | C4FM (FDMA) | H-DQPSK (TDMA) |
| Voice codec | IMBE (7200 bps) | AMBE+2 (4800 bps) |
| Bandwidth | 12.5 kHz | 12.5 kHz (2 voices) |
| Data rate | 9600 bps | 12000 bps |

### Key Concepts

- **NAC (Network Access Code)**: Similar to color code in DMR or CTCSS in analog. A 12-bit code (0x000 to 0xFFF).
- **Talk Groups**: Groups of users organized by function (dispatch, tactical, mutual aid).
- **ISSI**: Inter-RF Subsystem Interface — connects P25 systems from different manufacturers.
- **Encryption**: P25 supports AES-256 and DES encryption. Encrypted traffic cannot be decoded.

### Monitoring P25

- **SDRTrunk**: Best option for P25 trunked systems.
- **OP25**: Linux-based, very capable.
- **DSD+**: Decodes P25 Phase 1 (and Phase 2 with the paid version).
- **Trunk-Recorder**: Records all traffic on a P25 system.

P25 Phase 1 on NFM sounds like a distinctive "waterfall" or "digital garble" noise. Phase 2 TDMA sounds different — more choppy.

---

## NXDN (Next Generation Digital Narrowband)

### Overview

Developed by Kenwood and Icom. Designed for narrow-bandwidth operation (6.25 kHz channels).

### Technical Details

| Parameter | Value |
|-----------|-------|
| Modulation | 4FSK |
| Voice codec | AMBE+2 |
| Bandwidth | 6.25 kHz (or 12.5 kHz) |
| Data rate | 4800 bps (or 9600 bps in 12.5 kHz) |

### Key Concepts

- **RAN (Radio Access Number)**: Similar to color code (1-63).
- Can operate in conventional or trunked mode.
- Less common than P25 or DMR but used by some agencies and businesses.

### Monitoring NXDN

- DSD+ decodes NXDN.
- SDRTrunk supports NXDN decoding.

---

## Yaesu System Fusion (C4FM)

### Overview

Yaesu's digital voice system for amateur radio. Uses C4FM (Continuous 4-level FM) modulation — the same modulation as P25 Phase 1 but with a different protocol.

### Technical Details

| Parameter | Value |
|-----------|-------|
| Modulation | C4FM |
| Voice codec | AMBE+2 |
| Modes | VW (Voice Wide), DN (Digital Narrow), VW+VW (Voice + Image) |
| Bandwidth | 12.5 kHz |
| Bands | VHF, UHF |

### Key Concepts

- **WiRES-X**: Yaesu's internet linking system (similar to D-STAR reflectors or DMR networks).
- **Rooms and Nodes**: WiRES-X uses rooms (group) and nodes (individual stations) for internet linking.
- **AMS (Automatic Mode Select)**: Fusion repeaters can automatically switch between analog FM and digital C4FM.
- **DG-ID**: Digital Group ID, used for selective calling (0-99).

### Equipment

- Yaesu FT-70D, FT-5D (handheld)
- Yaesu FTM-300DR, FTM-500DR (mobile)
- Yaesu FT-991A (all-mode, all-band)

### Monitoring with SDR

- DSD+ can decode System Fusion (C4FM).
- System Fusion on an SDR waterfall looks similar to P25 Phase 1 but with a different frame structure.

---

## Decoding Digital Modes with DSD+ (Windows)

### Setup

1. **Install SDR#** and configure your RTL-SDR.
2. **Install a virtual audio cable**: VB-Audio Virtual Cable (free) or VoiceMeeter. This routes audio from SDR# to DSD+.
3. **Download DSD+** from https://www.dsdplus.com (free version and paid "fast lane" version).
4. **Configure SDR#**: Set audio output to the virtual audio cable.
5. **Configure DSD+**: Set audio input to the virtual audio cable.

### Usage

1. In SDR#, tune to a digital voice frequency. Set mode to NFM, bandwidth ~12.5 kHz.
2. Start DSD+. It will auto-detect the digital mode (P25, DMR, NXDN, D-STAR, System Fusion).
3. Audio is decoded and played through your default speakers.
4. DSD+ displays:
   - Detected mode
   - Signal quality indicators
   - Source/destination IDs
   - Talk group information

### DSD+ vs DSD

| Feature | DSD+ (Windows) | DSD (Linux) |
|---------|----------------|-------------|
| Auto-detect modes | Yes | Yes |
| P25 Phase 2 | Paid version | Limited |
| DMR both timeslots | Yes | Limited |
| GUI | Yes | Command line |
| Platform | Windows | Linux |

For Linux, the original **dsd** (or **dsd-fme** fork) provides similar functionality:
```bash
sudo apt install dsd
# or build from source
git clone https://github.com/szechyjs/dsd.git
cd dsd
mkdir build && cd build
cmake ..
make
```

---

## Comparison of Digital Voice Modes

| Feature | DMR | D-STAR | P25 Ph1 | P25 Ph2 | NXDN | Fusion |
|---------|-----|--------|---------|---------|------|--------|
| Primary use | Commercial/amateur | Amateur | Public safety | Public safety | Commercial | Amateur |
| TDMA | 2-slot | No | No | 2-slot | No | No |
| Codec | AMBE+2 | AMBE | IMBE | AMBE+2 | AMBE+2 | AMBE+2 |
| BW | 12.5 kHz | 6.25 kHz | 12.5 kHz | 12.5 kHz | 6.25 kHz | 12.5 kHz |
| Open standard | Yes (ETSI) | Yes (JARL) | Yes (TIA) | Yes (TIA) | Yes | No (Yaesu) |
| Internet linking | Brandmeister, etc. | Reflectors | ISSI | ISSI | NXCore | WiRES-X |
| Encryption | Optional | No (amateur) | Optional (AES) | Optional (AES) | Optional | No (amateur) |

---

## Getting Started with Monitoring

1. **Identify what systems are in your area**: Check RadioReference.com for your county/city. Note whether systems are P25, DMR, or another mode.
2. **Start with SDRTrunk** (easiest all-in-one solution for trunked systems).
3. **For conventional (non-trunked) digital channels**, use SDR# + DSD+ (Windows) or GQRX + dsd (Linux).
4. **Find the control channel** (for trunked systems) or direct frequency (for conventional) from RadioReference.
5. **Configure aliases** to map numeric talk group IDs to meaningful names.
6. **Be aware of encryption**: If you hear nothing on a channel that should be active, it may be encrypted.
