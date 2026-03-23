# Trunked Radio Systems

## What Is Trunking?

In a conventional radio system, each user group (department, squad, etc.) is assigned a specific frequency. That frequency is dedicated to them whether they are using it or not.

In a **trunked radio system**, a pool of frequencies is shared among many user groups. A **control channel** manages frequency assignments dynamically — when a user needs to talk, the control channel assigns an available frequency from the pool for the duration of the conversation. When the conversation ends, the frequency returns to the pool.

This is similar to how a cell phone network works: many users share a limited number of channels, with the system managing assignments transparently.

### Why It Matters to SDR Users

Trunked radio systems are used by:
- Police, fire, EMS (public safety)
- Government agencies
- Utilities and public works
- Large businesses and organizations
- Transportation systems

Monitoring these systems requires understanding how trunking works and using specialized software that can follow conversations across frequency changes.

---

## How Trunked Systems Work

### Control Channel

One frequency in the pool serves as the **control channel**. It continuously broadcasts data that includes:
- Which talk groups are active
- Which frequency is assigned to each active talk group
- System configuration information

Your monitoring software locks onto the control channel and reads this data to know where to tune for each conversation.

### Talk Groups

Users are organized into **talk groups** (TGIDs). A talk group is a logical grouping — for example:
- TGID 1001: Police Dispatch
- TGID 1002: Police Tactical
- TGID 2001: Fire Dispatch
- TGID 3001: EMS

When someone in TGID 1001 keys up, the control channel assigns a voice frequency, and all radios monitoring TGID 1001 switch to that frequency.

### Voice Frequencies

The remaining frequencies in the pool carry the actual voice conversations. A large system might have 10-30+ voice channels.

---

## Trunked System Types

### P25 (Project 25 / APCO-25)

The most common public safety trunking standard in the US.

| Feature | Phase 1 | Phase 2 |
|---------|---------|---------|
| Modulation | C4FM (FDMA) | H-DQPSK (TDMA, 2 slots per channel) |
| Voice codec | IMBE | AMBE+2 |
| Bandwidth | 12.5 kHz | 12.5 kHz (2 voice channels per freq) |
| Encryption | Optional (AES-256, DES) | Optional |
| Frequency bands | VHF, UHF, 700 MHz, 800 MHz | Same |

P25 systems may use:
- **Conventional P25**: Digital voice on fixed frequencies (not trunked)
- **P25 Phase 1 trunked**: Single channel per frequency
- **P25 Phase 2 trunked**: Two timeslots per frequency (TDMA), doubling capacity

### DMR (Digital Mobile Radio)

Originally a commercial/business standard, now also used by amateur radio operators and some public agencies.

| Feature | Value |
|---------|-------|
| Modulation | 4FSK (TDMA, 2 slots per 12.5 kHz channel) |
| Voice codec | AMBE+2 |
| Tiers | Tier I (unlicensed), Tier II (conventional/trunked), Tier III (trunked) |
| Bandwidth | 12.5 kHz (2 timeslots) |
| Color code | 0-15 (similar to CTCSS, identifies the system) |

### NXDN

A narrowband digital radio standard by Kenwood and Icom.

| Feature | Value |
|---------|-------|
| Modulation | 4FSK |
| Bandwidth | 6.25 kHz (or 12.5 kHz) |
| Voice codec | AMBE+2 |

Less common than P25 and DMR. Used by some smaller agencies and businesses.

### Motorola SmartZone / SmartNet

Proprietary Motorola trunking systems. Older but still in use:
- **SmartNet**: Single-site trunking
- **SmartZone**: Multi-site trunking with roaming
- Being replaced by P25 in many areas

### EDACS (Enhanced Digital Access Communications System)

An older Ericsson/Harris trunking system. Still in use in some areas. Being phased out in favor of P25.

---

## Monitoring Software

### SDRTrunk

**Platform**: Windows, Linux, macOS (Java-based)

SDRTrunk is the most popular software for monitoring trunked radio systems with an SDR.

#### Installation

1. Download from https://github.com/DSheirer/sdrtrunk/releases
2. Requires Java 17 or later.
3. Extract and run:
   ```bash
   # Linux
   java -jar sdrtrunk-app.jar

   # Or use the provided launcher script
   ./sdrtrunk.sh
   ```

#### Features

- Decodes P25 Phase 1 and Phase 2 (with JMBE codec library)
- Decodes DMR
- Decodes NXDN
- Decodes Motorola SmartNet/SmartZone
- Multiple simultaneous channels
- Recording per talk group
- Alias management (map talk group IDs to names)
- Visual channel display

#### Setup Steps

1. **Add your SDR device**: Tuners > Add RTL-SDR.
2. **Create a playlist**: File > New Playlist.
3. **Add a system**: Right-click in the playlist > Add System.
   - Select system type (P25, DMR, etc.)
   - Enter the control channel frequency.
4. **Add channels**: Add the control channel and voice frequencies.
5. **Configure aliases**: Map talk group IDs to readable names (e.g., TGID 1001 = "PD Dispatch").
6. **Start decoding**: Enable the system.

#### JMBE Voice Codec

P25 IMBE/AMBE voice decoding requires the JMBE library (Java implementation of the codec). SDRTrunk will prompt you to build it:

```bash
git clone https://github.com/DSheirer/jmbe.git
cd jmbe
./gradlew build
```

Copy the resulting `.jar` file to SDRTrunk's library directory as instructed.

### OP25

**Platform**: Linux

An open-source P25 decoder that runs on Linux. More technical to set up but very capable.

#### Installation

```bash
sudo apt install git gnuradio gnuradio-dev gr-osmosdr librtlsdr-dev cmake \
  build-essential libboost-all-dev libcppunit-dev swig

git clone https://github.com/boatbod/op25.git
cd op25/op25/gr-op25_repeater
mkdir build && cd build
cmake ..
make
sudo make install
sudo ldconfig
```

#### Usage

```bash
cd op25/op25/gr-op25_repeater/apps
./rx.py --args 'rtl=0' -N 'LNA:40' -S 2400000 -f CONTROL_FREQ -T trunk.tsv -V -o 25000 -w
```

OP25 provides a web-based interface showing system activity, talk group assignments, and audio playback.

### Trunk-Recorder

**Platform**: Linux

A multi-channel recorder that captures every active conversation on a trunked system simultaneously (with enough SDR bandwidth).

```bash
git clone https://github.com/robotastic/trunk-recorder.git
cd trunk-recorder
mkdir build && cd build
cmake ..
make
```

Configure via `config.json` with system parameters, frequencies, and talk groups of interest. Can upload recordings to online platforms (OpenMHz, Broadcastify).

### DSD+ (Digital Speech Decoder Plus)

**Platform**: Windows

A standalone decoder for digital voice modes:
- P25 Phase 1 and Phase 2
- DMR
- NXDN
- D-STAR
- ProVoice

DSD+ takes audio input (from SDR software via virtual audio cable) and decodes the digital voice.

```
SDR# (tuned to voice channel) → Virtual Audio Cable → DSD+ → Speakers
```

---

## Finding System Information

### RadioReference.com

The primary resource for finding trunked system details in your area:
- System type (P25, DMR, etc.)
- Control channel frequencies
- Voice channel frequencies
- Talk group IDs and descriptions (police, fire, EMS, etc.)
- System status and notes

**https://www.radioreference.com/apps/db/**

Navigate to your state > county > select the trunked system. The database provides everything you need to configure your monitoring software.

### Example System Entry

```
System: Example County P25
Type: P25 Phase II
Control channels: 851.2125, 851.7125, 852.2125
Voice channels: 851.0375, 851.0625, ... (many frequencies)

Talk Groups:
  TGID 1001: Police Dispatch
  TGID 1002: Police Tactical 1
  TGID 1003: Police Tactical 2
  TGID 2001: Fire Dispatch
  TGID 2002: Fire Tactical
  TGID 3001: EMS Dispatch
  ...
```

---

## Encryption

Many modern public safety systems use encryption (AES-256) on some or all talk groups. Encrypted traffic cannot be decoded by any consumer monitoring equipment — you will hear only digital noise or silence.

Common encryption patterns:
- **Full encryption**: All traffic encrypted. Nothing can be monitored.
- **Partial encryption**: Only certain talk groups encrypted (e.g., tactical/undercover), while dispatch and routine traffic remain unencrypted.
- **No encryption**: All traffic in the clear.

Check RadioReference.com for the encryption status of systems in your area. The trend is toward increasing encryption, especially for law enforcement channels.

---

## Hardware Considerations

### Single RTL-SDR

- Can monitor one control channel and one voice channel at a time.
- Sufficient for following one talk group.
- The ~2.4 MHz bandwidth may cover the control channel and some voice channels if they are close together.

### Multiple RTL-SDRs

- Dedicate one dongle to the control channel and others to voice channels.
- Enables simultaneous monitoring of multiple talk groups.
- SDRTrunk and trunk-recorder support multiple SDR devices.

### Wideband SDRs

- Airspy (6-10 MHz bandwidth) or SDRplay (10 MHz bandwidth) can cover an entire trunked system's frequency pool with a single device.
- SDRTrunk supports these wider-bandwidth devices.

---

## Legal Considerations

- In the US, monitoring radio communications is generally legal under the Electronic Communications Privacy Act (with some exceptions).
- **Exceptions**: It is illegal to use information gained from monitoring to commit a crime, tip off subjects of investigation, or for commercial purposes without consent.
- Some states have laws restricting mobile scanners (in vehicles) or scanner use during commission of a crime.
- Encrypted communications should not be decrypted without authorization.
- Always check your local and state laws regarding radio monitoring.
