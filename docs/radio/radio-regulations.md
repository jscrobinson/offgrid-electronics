# Radio Regulations Overview

## Fundamental Principle

**You must be authorized before you transmit.** In the United States, radio transmissions are regulated by the Federal Communications Commission (FCC). Different radio services have different rules about who may transmit, on what frequencies, at what power, and with what type of equipment.

The single exception: **In a genuine life-threatening emergency, you may use any radio, on any frequency, to call for help.** This is codified in FCC rules and international law. Outside of a true emergency, the rules apply.

---

## FCC Part 97 — Amateur Radio Service

### Overview

Amateur radio ("ham radio") provides the most flexibility of any radio service: wide frequency allocations, high power limits, ability to build your own equipment, and authorization to experiment. In exchange, operators must pass an examination and identify with a callsign.

### License Requirements

| License Class | Exam | Privileges |
|--------------|------|------------|
| **Technician** | 35-question multiple choice | All VHF/UHF amateur bands. Limited HF (CW on portions of 80/40/15m, all modes on 10m portion). |
| **General** | Technician + 35-question General exam | Technician privileges + most HF bands |
| **Extra** | Technician + General + 50-question Extra exam | All amateur frequencies and modes |

- License term: **10 years**, renewable (free renewal).
- FCC application fee: **$35** (as of 2024).
- Volunteer Examiner (VE) session fees vary ($0-$15 typically).
- No Morse code requirement for any class (eliminated 2007).
- Minimum age: None (children can be licensed).

### Callsigns

- Issued by the FCC upon license grant.
- Format: 1-2 letter prefix + number (0-9) + 1-3 letter suffix (e.g., W1ABC, KD2XYZ, N0CALL).
- Region number in the callsign originally indicated geographic area but is no longer enforced for location.
- Vanity callsigns available (apply through FCC, $35 fee).

### Operating Rules

**Identification**:
- You must identify with your callsign at the **beginning** and **end** of each communication, and at least every **10 minutes** during a contact.
- Use phone (voice), CW, or a digital mode for identification.
- Tactical call signs (e.g., "Net Control," "Base Camp") may be used, but you must still give your FCC callsign per the rules above.

**Power**:
- Maximum output power: **1,500 watts PEP** (peak envelope power) for General and Extra on most bands.
- Technician: 1,500 watts on VHF/UHF, limited on HF.
- **Use the minimum power necessary** to maintain the desired communication. This is not just good practice — it is an FCC rule (97.313).
- Some bands and modes have lower power limits (e.g., 200W on 30m, 100W ERP on 60m, etc.).

**Prohibited Transmissions**:
- **No broadcasting** (one-way transmissions intended for general reception). Amateur radio is for two-way communication.
- **No music** (except incidental as part of rebroadcasting from space stations).
- **No obscene or indecent language**.
- **No business communications** or communications for profit (with narrow exceptions for emergencies).
- **No false or deceptive signals** or identification.
- **No unidentified transmissions** (with exceptions for control signals and brief tests).
- **No encryption** for the purpose of obscuring the meaning of communications (except for satellite command, certain control links).
- **No third-party traffic** to countries that do not have a third-party traffic agreement with the US.

**Band Plans**:
- The FCC defines which frequencies each license class may use and which modes are permitted in each sub-band.
- Band plans also include voluntary (but strongly followed) conventions agreed upon by the amateur community (e.g., calling frequencies, digital segments, satellite segments).

**Interference**:
- Intentional interference is a serious violation (97.101(d)).
- If you cause harmful interference, you must correct it.
- Amateur operators should cooperate to minimize interference.

### Enforcement

- FCC can issue warnings, fines (up to $100,000+), and license revocation.
- FCC direction-finding teams can locate interfering stations.
- Volunteer monitors (ARRL Official Observers) monitor the bands and report violations.
- In practice, enforcement focuses on the most egregious cases (intentional interference, unlicensed operation on amateur frequencies, obscenity).

---

## FCC Part 95 — Personal Radio Services

Part 95 covers several personal radio services, each with its own subpart.

### Subpart A — General Provisions

Applies to all Part 95 services.

### Subpart B — Family Radio Service (FRS)

| Rule | Detail |
|------|--------|
| License | Not required |
| Frequencies | 462/467 MHz (22 channels) |
| Power | 2W EIRP (Ch 1-7, 15-22), 0.5W (Ch 8-14) |
| Equipment | Must be FRS-certified (Part 95 type-accepted) |
| Antenna | Fixed, integral (non-removable) |
| Repeaters | Not permitted |
| Prohibited | Business use (limited exceptions), obscenity, false signals |

### Subpart E — General Mobile Radio Service (GMRS)

| Rule | Detail |
|------|--------|
| License | Required. $35 for 10 years. No exam. |
| Licensee | Covers licensee and immediate family members |
| Frequencies | 462/467 MHz (same as FRS, plus repeater pairs) |
| Power | Up to 50W EIRP on main and repeater channels, 5W on interstitial |
| Equipment | Must be Part 95 type-accepted for GMRS |
| Antenna | External antennas permitted |
| Repeaters | Permitted on designated repeater pairs |
| Identification | Must identify with callsign |

### Subpart C — Citizens Band Radio Service (CB)

| Rule | Detail |
|------|--------|
| License | Not required (since 1983) |
| Frequencies | 26.965 - 27.405 MHz (40 channels) |
| Power | 4W AM, 12W PEP SSB |
| Equipment | Must be Part 95 type-accepted |
| Antenna | Max height: 20 feet above existing structure or 60 feet total |
| Prohibited | Linear amplifiers (illegal on CB), modifications to increase power, skip communications (intentional long-distance via sky wave) |

### Subpart J — Multi-Use Radio Service (MURS)

| Rule | Detail |
|------|--------|
| License | Not required |
| Frequencies | 151.820, 151.880, 151.940, 154.570, 154.600 MHz |
| Power | 2W |
| Equipment | Must be Part 95 type-accepted |
| Antenna | External antennas permitted. No height limit specified. |
| Repeaters | Not permitted |

---

## Equipment Authorization (Type Acceptance)

### What It Means

The FCC requires that radios used in certain services be specifically tested and approved ("type-accepted" or "certified") for that service. This ensures the radio meets technical standards for spurious emissions, frequency stability, etc.

### Why This Matters for Baofeng Radios

- **Amateur radio (Part 97)**: No type acceptance required. You can build and use any equipment on amateur frequencies.
- **FRS (Part 95B)**: Equipment MUST be Part 95 certified for FRS. The Baofeng UV-5R is NOT FRS-certified. Using it on FRS frequencies is technically illegal.
- **GMRS (Part 95E)**: Equipment MUST be Part 95 certified for GMRS. The Baofeng UV-5R is NOT GMRS-certified. The Baofeng UV-5X IS GMRS-certified.
- **MURS (Part 95J)**: Equipment MUST be Part 95 certified for MURS. The UV-5R is not.

### Practical Reality

Many people use non-type-accepted radios (like the UV-5R) on FRS and GMRS frequencies. Enforcement is rare for individual users. However:
- If you cause interference, you will have no legal standing.
- In a legal dispute, using non-certified equipment compounds the violation.
- For full legal compliance, use certified radios for Part 95 services and save the Baofeng for amateur frequencies (with a ham license).

---

## Power Limits Summary

| Service | Maximum Power |
|---------|--------------|
| Amateur (HF, most bands) | 1,500W PEP |
| Amateur (VHF/UHF) | 1,500W PEP |
| Amateur (60m) | 100W ERP |
| Amateur (30m) | 200W PEP |
| GMRS (main channels) | 50W EIRP |
| GMRS (interstitial channels) | 5W EIRP |
| FRS (Ch 1-7, 15-22) | 2W EIRP |
| FRS (Ch 8-14) | 0.5W EIRP |
| MURS | 2W |
| CB (AM) | 4W |
| CB (SSB) | 12W PEP |

---

## International Considerations

### ITU Regions

The International Telecommunication Union (ITU) divides the world into three regions with different frequency allocations:
- **Region 1**: Europe, Africa, the Middle East, northern Asia
- **Region 2**: The Americas
- **Region 3**: South and East Asia, Oceania

### Key International Rules

1. **FRS is a US-only service.** FRS radios should not be used outside the US (frequencies may be allocated to other services in other countries).
2. **PMR446 is a European service.** Do not use PMR446 radios in the US.
3. **GMRS is a US-only service.**
4. **Amateur radio**: Many countries have reciprocal operating agreements. A US ham may be able to operate in another country with their US license (or with a CEPT license document in Europe). Check the specific country's rules.
5. **Marine VHF**: International standards apply. Channel 16 (156.800 MHz) is the international distress and calling frequency worldwide.
6. **Aviation**: 121.500 MHz is the international aviation emergency frequency worldwide.
7. **When traveling internationally**: Research the radio regulations of your destination country. What is legal in the US may be illegal elsewhere, and vice versa.

### CEPT Amateur Radio License

The European Conference of Postal and Telecommunications Administrations (CEPT) has a harmonized amateur radio license recognized across member countries. US operators with a General or Extra class license can obtain CEPT documentation to operate in participating European countries without a separate exam.

---

## Enforcement and Penalties

### FCC Enforcement Actions

| Violation Level | Typical Penalty |
|----------------|-----------------|
| Minor, first offense | Warning letter (Notice of Unlicensed Operation or Notice of Violation) |
| Continued violations | Fine (Forfeiture Order), $1,000 - $10,000+ |
| Serious interference | Equipment seizure, injunction, fines up to $100,000+ |
| Willful, repeated violations | Criminal prosecution possible (rare) |
| Operating on frequencies allocated to safety services | Severe penalties — potential criminal charges |

### What Gets Enforced

In practice, the FCC focuses enforcement on:
1. **Intentional interference** to licensed services (especially public safety)
2. **Unlicensed operation on amateur frequencies** that causes interference or complaints
3. **Illegal amplifiers** on CB
4. **Pirate broadcasting** (unlicensed FM broadcast stations)
5. **Equipment causing harmful interference** (Part 15 violations, defective equipment)

Individual use of a non-type-accepted radio on FRS/GMRS channels without causing interference rarely results in enforcement action, but it remains technically illegal.

---

## Summary: Know Before You Transmit

1. **Get licensed** if you want to use amateur radio frequencies. The Technician exam is not difficult and opens up VHF/UHF.
2. **Get a GMRS license** ($35, no exam) if you want legal access to GMRS repeaters and higher power.
3. **Use type-accepted equipment** for the service you are operating on.
4. **Identify yourself** as required (callsign on amateur and GMRS).
5. **Use minimum necessary power.**
6. **Do not transmit on frequencies you are not authorized to use.**
7. **Do not cause interference.**
8. **Do not use radio for illegal purposes.**
9. **In a genuine emergency, use whatever you have to save lives.** Then return to legal operation afterward.
10. **Ignorance of the rules is not a defense.** The rules are available at ecfr.gov (Title 47, Parts 95 and 97).
