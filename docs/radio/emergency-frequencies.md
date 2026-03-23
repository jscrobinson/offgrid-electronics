# Emergency and Calling Frequencies

## Quick Reference Card

Print this page and keep it with your radio.

### Most Important Frequencies

| Frequency | Service | Use |
|-----------|---------|-----|
| **146.520 MHz** | Amateur (2m FM) | National simplex calling frequency |
| **446.000 MHz** | Amateur (70cm FM) | National simplex calling frequency |
| **462.5625 MHz** | FRS Channel 1 | De facto FRS calling/emergency channel |
| **462.6750 MHz** | GMRS Channel 20 | GMRS emergency/traveler assistance |
| **156.800 MHz** | Marine VHF Ch 16 | International marine distress and calling |
| **121.500 MHz** | Aviation | International aeronautical emergency |
| **243.000 MHz** | Military aviation | Military aeronautical emergency (UHF) |
| **27.065 MHz** | CB Channel 9 | Citizens Band emergency channel |

---

## Amateur Radio Emergency Frequencies

### VHF

| Frequency | Mode | Description |
|-----------|------|-------------|
| **146.520 MHz** | FM | **2-meter national simplex calling frequency.** The single most important ham frequency to program into any VHF radio. If you need to find another ham operator on simplex, call here first. |
| 146.550 MHz | FM | Common simplex, often used as alternate |
| 146.580 MHz | FM | Common simplex |
| 146.460 MHz | FM | Common simplex |
| 147.420 MHz | FM | Common simplex |
| 147.450 MHz | FM | Common simplex |
| 147.510 MHz | FM | Common simplex (used for wilderness SAR in some areas) |
| 147.570 MHz | FM | Common simplex |
| 144.200 MHz | SSB | 2-meter SSB calling frequency |
| 144.390 MHz | Data | APRS (Automatic Packet Reporting System) — position reporting and messaging |

### UHF

| Frequency | Mode | Description |
|-----------|------|-------------|
| **446.000 MHz** | FM | **70cm national simplex calling frequency** |
| 446.500 MHz | FM | Common simplex |
| 432.100 MHz | SSB | 70cm SSB calling frequency |

### HF (Long Distance)

| Frequency | Mode | Description |
|-----------|------|-------------|
| 7.030 MHz | CW | 40m QRP calling |
| 7.185 MHz | SSB | IARU Region 2 emergency center of activity |
| 7.240 MHz | SSB | ARES/RACES traffic nets, regional emergency |
| 7.290 MHz | SSB | Common traffic net frequency |
| 14.060 MHz | CW | 20m QRP calling |
| **14.300 MHz** | SSB | **International maritime/emergency net.** Intercontinental Maritime Net. Major emergency traffic. |
| 14.313 MHz | SSB | Intercontinental traffic and emergency assistance |
| 21.360 MHz | SSB | IARU emergency center of activity |
| 28.400 MHz | SSB | 10m calling frequency |

### ARES/RACES

Amateur Radio Emergency Service (ARES) and Radio Amateur Civil Emergency Service (RACES) use designated repeaters and simplex frequencies in each area. Contact your local ARES group or Emergency Coordinator to learn the local emergency frequencies and nets.

---

## FRS/GMRS Emergency Frequencies

| Channel | Frequency | Service | Description |
|---------|-----------|---------|-------------|
| **FRS/GMRS Ch 1** | 462.5625 MHz | FRS/GMRS | De facto calling and emergency channel |
| **GMRS Ch 20** | 462.6750 MHz | GMRS | Commonly designated for emergency and traveler assistance |
| FRS/GMRS Ch 3 | 462.6125 MHz | FRS/GMRS | Some groups designate this as alternate emergency |

### GMRS Emergency Repeaters

Some areas have GMRS repeaters specifically designated for emergency communications. Check local GMRS groups. The repeater pair for GMRS Channel 20:
- Output: 462.6750 MHz
- Input: 467.6750 MHz (with +5 MHz offset)

---

## Marine VHF Frequencies

| Channel | Frequency | Description |
|---------|-----------|-------------|
| **Ch 16** | **156.800 MHz** | **International distress, safety, and calling.** All vessels must monitor this channel. Coast Guard monitors continuously. |
| Ch 6 | 156.300 MHz | Intership safety |
| Ch 9 | 156.450 MHz | Supplementary calling channel (contact port operations) |
| Ch 13 | 156.650 MHz | Bridge-to-bridge navigation safety |
| Ch 22A | 157.100 MHz | Coast Guard liaison and maritime safety information |
| Ch 70 | 156.525 MHz | Digital selective calling (DSC) — automated distress alerting |

### Marine Emergency Procedure

1. Press the **DSC distress button** (if equipped) for automated digital distress alert on Ch 70.
2. Switch to **Channel 16** and broadcast:
   - "MAYDAY MAYDAY MAYDAY"
   - "This is [vessel name] [vessel name] [vessel name]"
   - "MAYDAY [vessel name]"
   - "My position is [latitude/longitude or description]"
   - "I [nature of distress]"
   - "I require [type of assistance]"
   - "[Number of persons aboard]"
   - "OVER"
3. Wait for acknowledgment. Repeat at intervals if no response.

---

## Aviation Frequencies

| Frequency | Description |
|-----------|-------------|
| **121.500 MHz** | **International aeronautical emergency (VHF).** Also the ELT (Emergency Locator Transmitter) frequency. Monitored by all ATC facilities and many aircraft. AM mode. |
| 243.000 MHz | Military aeronautical emergency (UHF). Military equivalent of 121.5. |
| 122.750 MHz | General aviation air-to-air |
| 123.025 MHz | Helicopter air-to-air |
| 123.100 MHz | Search and rescue (SAR) on-scene |

**Note**: Do not transmit on aviation frequencies unless you are involved in an actual aviation emergency. These frequencies are AM mode, not FM.

---

## Citizens Band (CB) Frequencies

| Channel | Frequency | Description |
|---------|-----------|-------------|
| **Ch 9** | **27.065 MHz** | **Emergency channel.** Designated by FCC for emergency communications and traveler assistance. REACT International monitors this channel in some areas. |
| Ch 19 | 27.185 MHz | Highway/trucker channel. Good for road information and emergencies on highways. |

---

## NOAA Weather Radio Frequencies

NOAA Weather Radio (NWR) broadcasts continuous weather information, forecasts, warnings, and emergency alerts (including Amber alerts, civil emergencies, and other hazards) 24/7. Receive-only — do not transmit on these frequencies.

| Frequency (MHz) | WX Channel |
|-----------------|------------|
| 162.400 | WX-2 |
| 162.425 | WX-4 |
| 162.450 | WX-5 |
| 162.475 | WX-3 |
| 162.500 | WX-6 |
| 162.525 | WX-7 |
| 162.550 | WX-1 |

Most of the US population is within range of at least one NWR transmitter. The Baofeng UV-5R and most scanners/SDRs can receive these frequencies.

To find which frequency serves your area, check: www.weather.gov/nwr/

### Programming NOAA into Your Radio

Program all 7 frequencies into your radio. Scan through them to find the strongest signal for your area. Typically only 1-3 will be receivable at any given location.

For Baofeng: Program as receive-only channels (set power to LOW, but note you should not transmit on these frequencies). In CHIRP, you can set "Skip" to "S" so they don't interfere with scanning your regular channels.

---

## MURS Emergency

While there is no official MURS emergency channel, some groups use:
| Channel | Frequency | Notes |
|---------|-----------|-------|
| MURS 1 | 151.820 MHz | Some groups designate as calling/emergency |

---

## Time and Frequency Standard Stations

Useful for verifying your radio's frequency accuracy and for time synchronization.

| Frequency | Station | Location | Notes |
|-----------|---------|----------|-------|
| 2.500 MHz | WWV | Fort Collins, CO, USA | AM, continuous time signals |
| 5.000 MHz | WWV | Fort Collins, CO, USA | AM, strongest signal typically |
| 10.000 MHz | WWV | Fort Collins, CO, USA | AM |
| 15.000 MHz | WWV | Fort Collins, CO, USA | AM |
| 20.000 MHz | WWV | Fort Collins, CO, USA | AM |
| 3.330 MHz | CHU | Ottawa, Canada | AM, voice announcements |
| 7.850 MHz | CHU | Ottawa, Canada | AM |
| 14.670 MHz | CHU | Ottawa, Canada | AM |

WWV broadcasts voice time announcements each minute, along with tones and BCD time code. Useful for calibrating receivers and as a propagation indicator — if you can hear WWV on a given frequency, propagation is open on that band.

---

## Emergency Communication Best Practices

### Before an Emergency

1. **Program emergency frequencies into your radios NOW**, not when the emergency happens.
2. **Know your local repeaters**, especially ARES/RACES repeaters.
3. **Test your equipment regularly.** Check into a local net weekly.
4. **Keep batteries charged** and spares available.
5. **Have a communication plan** with your family/group: which frequencies, what times, backup plans.
6. **Get licensed.** A ham license gives you access to the widest range of frequencies and modes. GMRS license is $35 with no exam.

### During an Emergency

1. **Listen first.** Get situational awareness before transmitting.
2. **Be concise.** Emergencies require clear, brief communications. State: WHO you are, WHERE you are, WHAT happened, WHAT you need.
3. **Use the correct frequency.** Do not transmit emergency traffic on a casual conversation frequency if an emergency net is active.
4. **Follow net control.** If an emergency net is running, follow the net control station's instructions. Do not freelance.
5. **Monitor multiple frequencies** if your radio supports dual watch.

### Legal Note on Emergency Transmissions

FCC rules (47 CFR 97.403 for amateur, 97.405 for RACES) permit the use of any means of radiocommunication available to provide essential communication needs in connection with the immediate safety of human life and immediate protection of property when normal communication systems are not available.

In a life-threatening emergency, you may transmit on any frequency using any equipment to call for help. This applies even to unlicensed individuals. Outside of genuine emergencies, follow normal licensing and operating rules.

---

## Channel Programming Suggestion

Here is a suggested channel layout for a Baofeng UV-5R or similar dual-band radio, combining the most important emergency, calling, and monitoring frequencies:

| Ch # | Name | Frequency | Mode | Notes |
|------|------|-----------|------|-------|
| 001 | CALL2M | 146.520 | NFM | 2m national simplex calling |
| 002 | CALL70 | 446.000 | NFM | 70cm national simplex calling |
| 003 | FRS1 | 462.5625 | NFM | FRS/GMRS Channel 1 |
| 004 | GMRS20 | 462.6750 | NFM | GMRS emergency channel |
| 005 | MARINE | 156.800 | NFM | Marine Ch 16 (RX only) |
| 006 | WX1 | 162.550 | NFM | NOAA Weather (RX only) |
| 007 | WX2 | 162.400 | NFM | NOAA Weather (RX only) |
| 008 | WX3 | 162.475 | NFM | NOAA Weather (RX only) |
| 009 | WX4 | 162.425 | NFM | NOAA Weather (RX only) |
| 010 | WX5 | 162.450 | NFM | NOAA Weather (RX only) |
| 011 | WX6 | 162.500 | NFM | NOAA Weather (RX only) |
| 012 | WX7 | 162.525 | NFM | NOAA Weather (RX only) |
| 013+ | (local repeaters) | (varies) | NFM | Program your area repeaters |

Channels marked "RX only" should only be monitored — do not transmit on them.
