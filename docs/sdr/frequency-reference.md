# SDR Frequency Reference

## Quick-Scan Frequency Table

Organized by frequency for easy reference when scanning with an SDR. All frequencies in MHz unless noted.

---

## AM Broadcast (MF)

| Frequency Range | Service | Mode | Notes |
|----------------|---------|------|-------|
| 0.530 - 1.700 MHz | AM Broadcast Radio | AM | Requires HF-capable SDR or direct sampling mode. Ground wave propagation. |

---

## Shortwave / HF (Requires HF-Capable SDR)

| Frequency | Service | Mode | Notes |
|-----------|---------|------|-------|
| 2.500 | WWV Time Signal | AM | NIST time standard, Fort Collins, CO |
| 3.330 | CHU Time Signal | AM | Canadian time standard |
| 3.500 - 4.000 | Amateur 80m | LSB/CW | Nighttime regional |
| 5.000 | WWV Time Signal | AM | Strongest WWV frequency |
| 7.000 - 7.300 | Amateur 40m | LSB/CW | Day and night, workhorse band |
| 7.850 | CHU Time Signal | AM | Canadian time standard |
| 10.000 | WWV Time Signal | AM | |
| 14.000 - 14.350 | Amateur 20m | USB/CW | Daytime worldwide DX |
| 14.070 | FT8 Digital | USB | Very popular digital mode |
| 14.300 | Maritime/Emergency Net | USB | HF emergency frequency |
| 15.000 | WWV Time Signal | AM | |
| 20.000 | WWV Time Signal | AM | |
| 21.000 - 21.450 | Amateur 15m | USB/CW | Solar-dependent DX |
| 27.065 | CB Channel 9 | AM | Citizens Band emergency |
| 27.185 | CB Channel 19 | AM | Citizens Band highway/trucker |
| 28.000 - 29.700 | Amateur 10m | USB/FM | Solar-dependent, sporadic-E |

---

## VHF Low Band (30-88 MHz)

| Frequency Range | Service | Mode | Notes |
|----------------|---------|------|-------|
| 30 - 50 | VHF Low Band business/government | NFM | Various agencies |
| 33.40 | US military (common) | NFM | |
| 46.61, 46.63, 46.67, 46.71 | Cordless phones (old) | NFM | Legacy analog cordless |
| 49.830 - 49.990 | Baby monitors (old) | NFM/WFM | Legacy analog |
| 50.000 - 54.000 | Amateur 6m | USB/FM | "Magic Band" sporadic-E |
| 50.125 | 6m SSB calling | USB | |
| 52.525 | 6m FM calling | NFM | |

---

## FM Broadcast (88-108 MHz)

| Frequency Range | Service | Mode | Notes |
|----------------|---------|------|-------|
| 87.500 - 108.000 | FM Broadcast Radio | WFM | ~200 kHz bandwidth. Stereo, RDS data. Great first test for SDR setup. |

---

## Aircraft Band (108-137 MHz)

| Frequency | Service | Mode | Notes |
|-----------|---------|------|-------|
| 108.000 - 117.950 | VOR Navigation | — | Navigation beacons (Morse code ID) |
| 118.000 - 121.400 | ATC (various) | AM | Tower, ground, clearance delivery, approach |
| **121.500** | **Aviation Emergency** | AM | International distress frequency. Always monitored. |
| 121.600 - 121.925 | Ground control (various) | AM | |
| 122.000 | Flight Service | AM | |
| 122.750 | Air-to-air (GA) | AM | General aviation air-to-air |
| 122.800 | UNICOM | AM | Uncontrolled airports |
| 123.025 | Helicopter air-to-air | AM | |
| 123.100 | SAR on-scene | AM | Search and rescue |
| 123.450 | Air-to-air | AM | Common air-to-air |
| 124.000 - 135.000 | ATC (various) | AM | Approach, departure, center |
| 135.000 - 137.000 | ATC (various) | AM | Newer allocations |

**Tip**: Most aircraft communications are brief and intermittent. Leave the SDR tuned to a local tower/approach frequency and watch the waterfall for activity. Check LiveATC.net to find frequencies for airports near you.

---

## NOAA Weather Satellites (137 MHz)

| Frequency | Satellite | Mode | Notes |
|-----------|-----------|------|-------|
| 137.100 | NOAA-19 | WFM (~40 kHz) | APT weather images |
| 137.620 | NOAA-15 | WFM (~40 kHz) | APT weather images |
| 137.900 | Meteor M2-3 | QPSK (~120 kHz) | LRPT digital images |
| 137.9125 | NOAA-18 | WFM (~40 kHz) | APT weather images |

---

## Amateur 2 Meters (144-148 MHz)

| Frequency | Service | Mode | Notes |
|-----------|---------|------|-------|
| 144.200 | SSB Calling | USB | Weak signal work |
| 144.390 | APRS | Data (AFSK) | Position reporting, messaging (North America) |
| 145.000 - 148.000 | Repeaters / Simplex | NFM | Dense activity in populated areas |
| **146.520** | **National Simplex Calling** | NFM | The most important 2m frequency |
| 146.550, 146.580 | Common simplex | NFM | |
| 147.000 - 147.400 | Repeaters | NFM | |

---

## MURS (151-155 MHz)

| Frequency | Channel | Mode | Notes |
|-----------|---------|------|-------|
| 151.820 | MURS 1 | NFM | License-free VHF |
| 151.880 | MURS 2 | NFM | |
| 151.940 | MURS 3 | NFM | |
| 154.570 | MURS 4 | NFM (wide) | |
| 154.600 | MURS 5 | NFM (wide) | |

---

## Marine VHF (156-163 MHz)

| Frequency | Channel | Mode | Notes |
|-----------|---------|------|-------|
| 156.050 | Ch 1 | NFM | Port operations |
| 156.300 | Ch 6 | NFM | Intership safety |
| 156.450 | Ch 9 | NFM | Supplementary calling |
| 156.550 | Ch 11 | NFM | VTS |
| 156.600 | Ch 12 | NFM | Port operations |
| 156.650 | Ch 13 | NFM | Bridge-to-bridge |
| **156.800** | **Ch 16** | NFM | **International distress and calling** |
| 157.000 | Ch 20 | NFM | Port operations |
| 157.100 | Ch 22A | NFM | Coast Guard liaison |
| 161.975 | AIS 1 | Data | AIS vessel tracking |
| 162.025 | AIS 2 | Data | AIS vessel tracking |

---

## Railroad (160-162 MHz)

| Frequency | Service | Mode | Notes |
|-----------|---------|------|-------|
| 160.215 | Road (common) | NFM | Dispatcher to trains |
| 160.245 | Road (common) | NFM | |
| 160.320 | Road (common) | NFM | |
| 160.500 | Road (common) | NFM | |
| 160.800 | End-of-train devices | Data | Telemetry |
| 161.100 | Road (common) | NFM | |
| 161.370 | AAR 1 (common) | NFM | |
| 161.550 | Ch 1 railroad | NFM | |
| 161.565 | Yard operations | NFM | |

---

## NOAA Weather Radio (162 MHz)

| Frequency | Channel | Notes |
|-----------|---------|-------|
| 162.400 | WX-2 | Continuous weather broadcasts |
| 162.425 | WX-4 | |
| 162.450 | WX-5 | |
| 162.475 | WX-3 | |
| 162.500 | WX-6 | |
| 162.525 | WX-7 | |
| 162.550 | WX-1 | |

---

## Amateur 1.25 Meters (222-225 MHz)

| Frequency | Service | Mode | Notes |
|-----------|---------|------|-------|
| 223.500 | Simplex calling | NFM | Less active than 2m/70cm |

---

## ISM Band — 315 MHz (US)

| Frequency | Service | Mode | Notes |
|-----------|---------|------|-------|
| 315.000 | Automotive TPMS | OOK/FSK | Tire pressure sensors (US vehicles) |

---

## Amateur 70 Centimeters (420-450 MHz)

| Frequency | Service | Mode | Notes |
|-----------|---------|------|-------|
| 432.100 | SSB calling | USB | |
| 440.000 - 450.000 | Repeaters / Simplex | NFM | |
| **446.000** | **National Simplex Calling** | NFM | |
| 446.500 | Common simplex | NFM | |

---

## ISM Band — 433 MHz (Europe/Worldwide)

| Frequency | Service | Mode | Notes |
|-----------|---------|------|-------|
| **433.920** | ISM devices | OOK/FSK | Weather stations, thermometers, door sensors, car fobs. Decode with rtl_433. |

---

## FRS / GMRS (462-467 MHz)

| Frequency | Channel | Mode | Notes |
|-----------|---------|------|-------|
| 462.5625 | FRS 1 / GMRS 1 | NFM | Primary calling/emergency |
| 462.5875 | FRS 2 / GMRS 2 | NFM | |
| 462.6125 | FRS 3 / GMRS 3 | NFM | |
| 462.6375 | FRS 4 / GMRS 4 | NFM | |
| 462.6625 | FRS 5 / GMRS 5 | NFM | |
| 462.6875 | FRS 6 / GMRS 6 | NFM | |
| 462.7125 | FRS 7 / GMRS 7 | NFM | |
| 462.5500 | FRS 15 | NFM | |
| 462.5750 | FRS 16 | NFM | |
| 462.6000 | FRS 17 | NFM | |
| 462.6250 | FRS 18 | NFM | |
| 462.6500 | FRS 19 | NFM | |
| 462.6750 | FRS 20 / GMRS Emergency | NFM | Emergency/traveler assistance |
| 462.7000 | FRS 21 | NFM | |
| 462.7250 | FRS 22 | NFM | |

---

## Public Safety / Trunked Systems (700-900 MHz)

| Frequency Range | Service | Mode | Notes |
|----------------|---------|------|-------|
| 764 - 776 | Public safety (700 MHz) | P25/DMR | Post-2009 allocations |
| 794 - 806 | Public safety (700 MHz) | P25/DMR | |
| 806 - 824 | Trunked systems (800 MHz) | P25/DMR/Analog | Many public safety systems |
| 851 - 869 | Trunked systems (800 MHz) | P25/DMR/Analog | Base/repeater outputs |
| 896 - 902 | Trunked systems (900 MHz) | Various | SMR (Specialized Mobile Radio) |
| 935 - 940 | Trunked systems (900 MHz) | Various | |

---

## ISM Band — 915 MHz (US)

| Frequency | Service | Mode | Notes |
|-----------|---------|------|-------|
| 902 - 928 | ISM devices (US) | Various | LoRa, sensors, smart home devices. Decode some with rtl_433. |

---

## Pagers (929-932 MHz)

| Frequency Range | Service | Mode | Notes |
|----------------|---------|------|-------|
| 929.000 - 932.000 | POCSAG/FLEX Pagers | FSK | Still active. Hospitals, emergency services. Decode with multimon-ng. |

---

## ADS-B / Aircraft Transponder (1090 MHz)

| Frequency | Service | Mode | Notes |
|-----------|---------|------|-------|
| 978.000 | UAT (US only) | Data | Some US general aviation |
| **1090.000** | **ADS-B / Mode S** | Data | Aircraft tracking. Use dump1090/readsb. |

---

## GPS (1575 MHz)

| Frequency | Service | Notes |
|-----------|---------|-------|
| 1575.42 | GPS L1 | Civil GPS signal. Requires specialized SDR processing. |

---

## Hydrogen Line (1420 MHz)

| Frequency | Service | Notes |
|-----------|---------|-------|
| 1420.405 | Radio Astronomy | Hydrogen emission line. Observe the Milky Way's structure with RTL-SDR and horn antenna. |

---

## Tips for Scanning

1. **Start with known signals** (FM broadcast, NOAA weather) to verify your setup works.
2. **Use the waterfall** to find active frequencies. Signals appear as bright lines or bursts.
3. **Set appropriate mode**: WFM for broadcast FM, NFM for two-way radio, AM for aircraft, USB/LSB for ham HF.
4. **Adjust gain** for the frequency range. Strong signals (FM broadcast, pagers) need less gain. Weak signals (satellites, distant aircraft) need more.
5. **Local frequency lists**: Check RadioReference.com for detailed frequency assignments in your area.
6. **Time of day matters**: Some frequencies are active 24/7 (ADS-B, pagers, NOAA weather), others have peak times (aircraft during the day, ham bands evenings/weekends).
7. **Antenna matters**: The stock RTL-SDR antenna is a compromise. For best results on a specific frequency, use an antenna cut for that frequency.
