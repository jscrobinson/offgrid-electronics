# FRS, GMRS, PMR446, and MURS Radio Services

## Overview

These are personal radio services available without (or with minimal) licensing, intended for short-range personal and family communications. They use pre-assigned frequencies and are limited in power.

---

## FRS — Family Radio Service (United States)

**Regulatory basis**: FCC Part 95 Subpart B

- **Frequency range**: 462/467 MHz (UHF)
- **Channels**: 22
- **Maximum power**: 2 watts EIRP (channels 1-7 and 15-22), 0.5 watts EIRP (channels 8-14)
- **License required**: No
- **Antenna**: Fixed (non-removable), integral to the radio
- **Modulation**: FM (narrowband, 12.5 kHz)
- **Typical range**: 0.5 to 2 miles (urban), up to 5+ miles (open terrain, hilltop)

### FRS Channel Table

| Channel | Frequency (MHz) | Max Power | Shared With |
|---------|-----------------|-----------|-------------|
| 1 | 462.5625 | 2 W | GMRS |
| 2 | 462.5875 | 2 W | GMRS |
| 3 | 462.6125 | 2 W | GMRS |
| 4 | 462.6375 | 2 W | GMRS |
| 5 | 462.6625 | 2 W | GMRS |
| 6 | 462.6875 | 2 W | GMRS |
| 7 | 462.7125 | 2 W | GMRS |
| 8 | 467.5625 | 0.5 W | FRS only |
| 9 | 467.5875 | 0.5 W | FRS only |
| 10 | 467.6125 | 0.5 W | FRS only |
| 11 | 467.6375 | 0.5 W | FRS only |
| 12 | 467.6625 | 0.5 W | FRS only |
| 13 | 467.6875 | 0.5 W | FRS only |
| 14 | 467.7125 | 0.5 W | FRS only |
| 15 | 462.5500 | 2 W | GMRS |
| 16 | 462.5750 | 2 W | GMRS |
| 17 | 462.6000 | 2 W | GMRS |
| 18 | 462.6250 | 2 W | GMRS |
| 19 | 462.6500 | 2 W | GMRS |
| 20 | 462.6750 | 2 W | GMRS |
| 21 | 462.7000 | 2 W | GMRS |
| 22 | 462.7250 | 2 W | GMRS |

### FRS Notes

- FRS radios must have fixed, non-removable antennas.
- No repeater use allowed on FRS.
- "Privacy codes" (CTCSS/DCS) do NOT provide privacy — they only filter what you hear. Others can still hear you.
- Channel 1 (462.5625 MHz) is commonly used as a de facto calling/emergency channel.
- Digital data is allowed on FRS channels 1-14 (up to 1 watt on 1-7).
- Many consumer radios sold as "FRS/GMRS" can operate on both services.

---

## GMRS — General Mobile Radio Service (United States)

**Regulatory basis**: FCC Part 95 Subpart E

- **Frequency range**: 462/467 MHz (UHF)
- **Channels**: 30 (8 main + 7 interstitial shared with FRS + 8 repeater output + 7 repeater input)
- **Maximum power**: 50 watts EIRP (main channels), 5 watts (interstitial channels 15-22), 50W on repeater channels
- **License required**: Yes — FCC license, $35 for 10 years, no exam required
- **License covers**: The licensee and their immediate family members
- **Antenna**: External antennas permitted (unlike FRS)
- **Repeaters**: Allowed on designated repeater pairs

### GMRS Channel/Frequency Table

#### Main Channels (up to 50W)

| Channel | TX Frequency (MHz) | Notes |
|---------|-------------------|-------|
| 1 | 462.5625 | Shared with FRS Ch 1 |
| 2 | 462.5875 | Shared with FRS Ch 2 |
| 3 | 462.6125 | Shared with FRS Ch 3 |
| 4 | 462.6375 | Shared with FRS Ch 4 |
| 5 | 462.6625 | Shared with FRS Ch 5 |
| 6 | 462.6875 | Shared with FRS Ch 6 |
| 7 | 462.7125 | Shared with FRS Ch 7 |
| 8 | 462.7250 | Shared with FRS Ch 22 |

#### Interstitial Channels (up to 5W, shared with FRS)

| Channel | Frequency (MHz) | Shared with FRS |
|---------|-----------------|-----------------|
| 15 | 462.5500 | FRS Ch 15 |
| 16 | 462.5750 | FRS Ch 16 |
| 17 | 462.6000 | FRS Ch 17 |
| 18 | 462.6250 | FRS Ch 18 |
| 19 | 462.6500 | FRS Ch 19 |
| 20 | 462.6750 | FRS Ch 20 |
| 21 | 462.7000 | FRS Ch 21 |

#### Repeater Pairs (up to 50W)

| Repeater Pair | Output (MHz) | Input (MHz) | Offset |
|--------------|--------------|-------------|--------|
| RP1 | 462.5500 | 467.5500 | +5 MHz |
| RP2 | 462.5750 | 467.5750 | +5 MHz |
| RP3 | 462.6000 | 467.6000 | +5 MHz |
| RP4 | 462.6250 | 467.6250 | +5 MHz |
| RP5 | 462.6500 | 467.6500 | +5 MHz |
| RP6 | 462.6750 | 467.6750 | +5 MHz |
| RP7 | 462.7000 | 467.7000 | +5 MHz |
| RP8 | 462.7250 | 467.7250 | +5 MHz |

### GMRS Advantages Over FRS

- Higher power (up to 50 watts vs 2 watts)
- External antennas allowed (base station antennas, mobile antennas, improved handhelds)
- Repeater use allowed — dramatically extends range (20-50+ miles with a well-placed repeater)
- Range: 5-25+ miles simplex with mobile/base antennas, 50+ miles through repeaters

### GMRS Emergency Use

- **GMRS Channel 20 (462.675 MHz)** is commonly designated for emergency and traveler assistance.
- Some areas have GMRS repeaters specifically for emergency communications.

---

## PMR446 — Private Mobile Radio 446 (Europe)

**Regulatory basis**: ERC Decision (98)25, ETSI standards

- **Frequency range**: 446.000 - 446.200 MHz (UHF)
- **Channels**: 16 analog + 16 digital
- **Maximum power**: 0.500 watts ERP
- **License required**: No (license-exempt in most of Europe, UK, and some other countries)
- **Antenna**: Integral (non-removable)
- **Modulation**: FM (12.5 kHz narrowband) for analog; various digital modes (dPMR446)

### PMR446 Analog Channel Table

| Channel | Frequency (MHz) |
|---------|-----------------|
| 1 | 446.00625 |
| 2 | 446.01875 |
| 3 | 446.03125 |
| 4 | 446.04375 |
| 5 | 446.05625 |
| 6 | 446.06875 |
| 7 | 446.08125 |
| 8 | 446.09375 |
| 9 | 446.10625 |
| 10 | 446.11875 |
| 11 | 446.13125 |
| 12 | 446.14375 |
| 13 | 446.15625 |
| 14 | 446.16875 |
| 15 | 446.18125 |
| 16 | 446.19375 |

### PMR446 Digital Channel Table (dPMR446)

| Channel | Frequency (MHz) |
|---------|-----------------|
| 1 | 446.103125 |
| 2 | 446.109375 |
| 3 | 446.115625 |
| 4 | 446.121875 |
| 5 | 446.128125 |
| 6 | 446.134375 |
| 7 | 446.140625 |
| 8 | 446.146875 |
| 9 | 446.153125 |
| 10 | 446.159375 |
| 11 | 446.165625 |
| 12 | 446.171875 |
| 13 | 446.178125 |
| 14 | 446.184375 |
| 15 | 446.190625 |
| 16 | 446.196875 |

### PMR446 Notes

- **PMR446 is NOT legal in the United States.** These frequencies overlap with UHF amateur radio and other allocations.
- **FRS radios are NOT legal in Europe.** Do not use FRS radios in countries where PMR446 is the standard.
- Similar range to FRS (0.5-2 miles urban, up to 5 miles open terrain).
- Channel 1 (446.00625 MHz) is the de facto calling channel.

---

## MURS — Multi-Use Radio Service (United States)

**Regulatory basis**: FCC Part 95 Subpart J

- **Frequency range**: VHF (151-154 MHz)
- **Channels**: 5
- **Maximum power**: 2 watts
- **License required**: No
- **Antenna**: External antennas permitted (unlike FRS)
- **Modulation**: FM (channels 1-3: 11.25 kHz narrowband; channels 4-5: 20 kHz wideband)

### MURS Channel Table

| Channel | Frequency (MHz) | Bandwidth | Former Allocation |
|---------|-----------------|-----------|-------------------|
| 1 | 151.820 | 11.25 kHz (narrow) | Business "dot" frequency |
| 2 | 151.880 | 11.25 kHz (narrow) | Business "dot" frequency |
| 3 | 151.940 | 11.25 kHz (narrow) | Business "dot" frequency |
| 4 | 154.570 | 20 kHz (wide) | "Blue dot" |
| 5 | 154.600 | 20 kHz (wide) | "Green dot" |

### MURS Advantages

- **VHF propagation**: Better penetration through foliage and hilly terrain compared to UHF (FRS/GMRS).
- **External antennas**: Allowed, unlike FRS. A good base antenna can significantly improve range.
- **No license required**: Unlike GMRS.
- **Less crowded**: Far fewer users than FRS/GMRS.
- **Typical range**: 1-5 miles with handheld, up to 10+ miles with base antenna at height.
- Popular for rural property, farms, ranches, and businesses (driveway sensors, etc.).

### MURS Limitations

- No repeater use allowed.
- 2 watts maximum power.
- Fewer equipment options than FRS/GMRS (though Baofeng and similar radios can be programmed to MURS frequencies).
- Not widely used for recreational/family communication.

---

## CB Radio — Citizens Band (Reference)

While not in the same category as the above services, CB radio is another license-free option:

- **Frequency range**: 26.965 - 27.405 MHz (HF, 11-meter band)
- **Channels**: 40
- **Maximum power**: 4 watts AM, 12 watts PEP SSB
- **License required**: No (in the US since 1983)
- **Modulation**: AM (most common), SSB (for longer range)
- **Propagation**: Ground wave (local, 5-15 miles), sky wave during high solar activity (worldwide skip)
- **Key channels**:
  - Channel 9 (27.065 MHz): Emergency
  - Channel 19 (27.185 MHz): Highway / trucker channel
- **Antenna**: Critical for performance. A full-length whip (102 inches / 8.5 feet) is ideal.

---

## Comparison Table

| Feature | FRS | GMRS | PMR446 | MURS | CB |
|---------|-----|------|--------|------|-----|
| Country | US | US | Europe | US | US/International |
| Band | UHF | UHF | UHF | VHF | HF (11m) |
| Channels | 22 | 30 | 16 | 5 | 40 |
| Max Power | 2 W | 50 W | 0.5 W | 2 W | 4 W AM |
| License | No | Yes ($35/10yr) | No | No | No |
| Exam | No | No | No | No | No |
| External Antenna | No | Yes | No | Yes | Yes |
| Repeaters | No | Yes | No | No | No |
| Typical Range | 1-2 mi | 2-25 mi | 1-2 mi | 1-5 mi | 5-15 mi |

---

## Practical Tips

1. **Range claims on radio packaging are wildly exaggerated.** "35-mile range" on FRS radios is essentially impossible. Expect 1-2 miles in typical conditions.

2. **CTCSS/DCS "privacy codes" provide zero privacy.** They only filter what your radio plays through the speaker. Anyone on the same frequency without a tone set will hear everything you say.

3. **If you need reliable family/group comms**, get GMRS licenses for the group. The $35 license fee (no exam) covers your immediate family and gives you access to higher power, better antennas, and repeaters.

4. **For rural/off-grid use**, consider MURS. VHF propagation through trees and hills is generally better than UHF, and you can use external antennas.

5. **For international travel**, check local regulations. FRS is US-only. PMR446 is Europe-only. Using the wrong service in the wrong country is illegal.

6. **A Baofeng UV-5R can be programmed for FRS, GMRS, and MURS frequencies**, but transmitting on FRS with a Baofeng is technically illegal because FRS requires a fixed antenna and Part 95 type-accepted radio. GMRS use with a Baofeng is also technically non-compliant (not Part 95 type-accepted), though enforcement is rare. For fully legal use, buy radios specifically certified for the service you plan to use.
