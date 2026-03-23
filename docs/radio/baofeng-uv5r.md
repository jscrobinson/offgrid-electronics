# Baofeng UV-5R / UV-5RH Complete Reference

## Overview

The Baofeng UV-5R (and its variants like the JucJet UV5RH) is an extremely popular, inexpensive dual-band VHF/UHF handheld transceiver (HT). It is widely used by amateur radio operators, preppers, and hobbyists. Despite its low cost (~$25-40), it is a surprisingly capable radio.

**Important**: Transmitting on any frequency requires proper authorization. Amateur radio frequencies require a ham license. Transmitting on FRS, GMRS, or other services with a Baofeng may not be legal (see regulations section at the bottom).

---

## Specifications

| Parameter | Value |
|-----------|-------|
| Frequency Range (VHF) | 136 - 174 MHz |
| Frequency Range (UHF) | 400 - 520 MHz |
| Channel Memory | 128 channels |
| Power Output (UV-5R) | Low: 1W / High: 4-5W |
| Power Output (UV-5RH) | Low: 1W / Medium: 4W / High: 8W |
| Modulation | FM (narrowband and wideband) |
| Channel Spacing | 2.5 / 5 / 6.25 / 10 / 12.5 / 20 / 25 kHz (selectable) |
| Battery | 1800 mAh Li-ion (BL-5), 7.4V |
| Battery Life | ~12-20 hours (5/5/90 duty cycle) |
| Antenna Connector | SMA-Female (on radio body) |
| Sensitivity | -122 dBm (12dB SINAD) typical |
| Frequency Stability | ±2.5 ppm |
| Audio Output | 700 mW |
| Dimensions | ~110 x 58 x 32 mm (body) |
| Weight | ~250g with battery and antenna |
| Other Features | FM broadcast radio (65-108 MHz receive), built-in flashlight (LED), dual watch, dual standby, VOX, emergency alarm, battery save |

### Common Variants

- **UV-5R**: The original. 4-5W max output. Most widely available.
- **UV-5R Plus / V2+**: Minor cosmetic changes, same internals.
- **UV-5R8W / BF-F8HP**: Higher power (8W claimed). Improved front-end.
- **UV-5RH / JucJet UV5RH**: Enhanced version. 8W, improved receiver, USB-C charging on some models.
- **UV-5X**: GMRS-certified version (Part 95 type-accepted).

---

## Physical Layout

### Front Panel

- **LCD Display**: Shows dual VFO (A/B), frequency or channel name, icons for battery, signal, tone mode
- **Keypad**: 0-9, *, # (plus MENU, UP, DOWN, EXIT/AB, VFO/MR, BAND/A-B, CALL)
- **PTT (Push-to-Talk)**: Side button (large)
- **MONI**: Side button (above PTT) — momentary opens squelch to listen
- **CALL**: Side button (below PTT) — programmable alarm or 1750 Hz tone
- **Flashlight button**: Top (press and hold or toggle depending on model)
- **LED indicator**: Red = transmitting, Green/Blue = receiving

### Top

- **SMA-Female antenna connector** (requires SMA-Male antenna)
- **LED flashlight**

### Side

- **Volume knob / Power switch** (rotate to turn on, adjust volume)
- **Accessory jack**: Kenwood-compatible 2-pin (2.5mm + 3.5mm) for speaker-mic, headset, programming cable

---

## Basic Operation

### Power On / Off

Turn the volume knob clockwise to power on. Counterclockwise past the click to power off.

### Switching Between VFO and Memory (Channel) Mode

Press **VFO/MR** to toggle between:
- **VFO (Frequency) mode**: Enter frequencies directly. Display shows frequency.
- **MR (Memory/Channel) mode**: Recall stored channels. Display shows channel number and name.

### Selecting a Band (VHF or UHF)

Press **BAND** (or **A/B**) to toggle the active VFO between VHF and UHF frequency ranges.

### Selecting Upper/Lower Display (A/B)

Press **EXIT/AB** (or the **A/B** key) to switch between the upper (A) and lower (B) display. The active display determines which frequency you transmit on.

### Manual Frequency Entry (VFO Mode)

1. Make sure you are in VFO mode (press VFO/MR if needed).
2. Type the frequency on the keypad. Example: for 146.520 MHz, press **1 4 6 5 2 0**.
3. For frequencies that don't fill all digits, wait — the radio will accept after a timeout.

### Monitoring (Opening Squelch)

Press and hold the **MONI** button to temporarily open the squelch and listen to all signals on the frequency.

### Dual Watch / Dual Standby

The radio can monitor both the A and B VFOs simultaneously. When a signal is received on either, that VFO becomes active. Enable via Menu 7 (TDR).

---

## Menu System

Access: Press **MENU**, use **UP/DOWN** to scroll to item number (or type the number), press **MENU** to select, use **UP/DOWN** to change value, press **MENU** to confirm, press **EXIT** to leave.

### Complete Menu Reference

| Menu # | Abbreviation | Setting | Options/Description |
|--------|-------------|---------|---------------------|
| 0 | SQL | Squelch Level | 0-9. 0=open (hear everything). 3-5 typical. Higher=less sensitive. |
| 1 | STEP | Frequency Step | 2.5 / 5 / 6.25 / 10 / 12.5 / 20 / 25 kHz. Use 5 kHz for ham, 12.5 for FRS/GMRS. |
| 2 | TXP | Transmit Power | HIGH / LOW (or HIGH/MED/LOW on 3-power models) |
| 3 | SAVE | Battery Save | OFF / 1 / 2 / 3 / 4. Higher number = more aggressive power saving. |
| 4 | VOX | Voice-Operated Transmit | OFF / 1-10. Sensitivity level. 1=most sensitive. |
| 5 | WN | Wideband/Narrowband | WIDE (25 kHz) / NARROW (12.5 kHz). Use NARROW for most two-way radio. |
| 6 | ABR | Display Backlight Time | OFF / 1-5 seconds |
| 7 | TDR | Dual Watch (Dual Standby) | OFF / ON |
| 8 | BEEP | Keypad Beep | OFF / ON |
| 9 | TOT | Transmit Timeout Timer | OFF / 15-600 seconds. Limits continuous transmit time. |
| 10 | R-DCS | Receive DCS Code | OFF / D023N-D754N/I. Set to match the DCS code of the station you want to hear. |
| 11 | R-CTCS | Receive CTCSS Tone | OFF / 67.0-254.1 Hz. Set to match the CTCSS tone of the station you want to hear. |
| 12 | T-DCS | Transmit DCS Code | OFF / D023N-D754N/I. Set to match what the receiving station expects. |
| 13 | T-CTCS | Transmit CTCSS Tone | OFF / 67.0-254.1 Hz. Set to match what the repeater or receiving station expects. |
| 14 | VOICE | Voice Prompts | OFF / ON (Chinese) / ON (English) |
| 15 | ANI-ID | ANI Code | Automatic Number Identification. For trunking/commercial use. |
| 16 | DTMFST | DTMF Side Tone | OFF / DT-ST / ANI-ST / DT+ANI. DTMF feedback in speaker. |
| 17 | S-CODE | Signal Code | 1-15. Selects which ANI code to use. |
| 18 | SC-REV | Scan Resume Method | TO (time, resumes after pause) / CO (carrier, resumes when signal drops) / SE (stop, stays on active frequency) |
| 19 | PTT-ID | PTT ID | OFF / BOT (beginning of TX) / EOT (end of TX) / BOTH |
| 20 | PTT-LT | PTT ID Delay | 0-50 ms |
| 21 | MDF-A | Display Mode (A) | FREQ (frequency) / CH (channel number) / NAME (channel name) |
| 22 | MDF-B | Display Mode (B) | FREQ / CH / NAME |
| 23 | BCL | Busy Channel Lockout | OFF / ON. Prevents transmitting if channel is in use. |
| 24 | AUTOLK | Auto Key Lock | OFF / ON. Locks keypad automatically after timeout. |
| 25 | SFT-D | Frequency Shift Direction | OFF / + / -. For repeater offset direction. |
| 26 | OFFSET | Frequency Offset | 00.000-69.990 MHz. For repeater offset amount. |
| 27 | MEM-CH | Memory Channel Store | Store current VFO settings to a channel. |
| 28 | DEL-CH | Delete Channel | Remove a stored channel from memory. |
| 29 | WT-LED | Standby LED Color | OFF / BLUE / ORANGE / PURPLE |
| 30 | RX-LED | Receive LED Color | OFF / BLUE / ORANGE / PURPLE |
| 31 | TX-LED | Transmit LED Color | OFF / BLUE / ORANGE / PURPLE |
| 32 | AL-MOD | Alarm Mode | SITE / TONE / CODE |
| 33 | BAND | Band Selection | VHF / UHF |
| 34 | TDR-AB | Dual Watch TX Priority | OFF / A / B |
| 35 | STE | Squelch Tail Eliminate | OFF / ON. Reduces the burst of noise at end of received transmission. |
| 36 | RP-STE | Repeater STE | OFF / 1-10 |
| 37 | RPT-RL | Repeater Tail Revert | OFF / 1-10 |
| 38 | PONMSG | Power-On Message | FULL (full screen) / MSG (custom message) / VOL (battery voltage) |
| 39 | ROGER | Roger Beep | OFF / ON. Sends a tone when you release PTT. |
| 40 | RESET | Factory Reset | VFO (reset VFO only) / ALL (full factory reset) |

Note: Some firmware versions may have slightly different menu numbers or additional items.

---

## Key Configuration Tasks

### Setting Squelch (Menu 0 - SQL)

1. MENU > 0 > MENU
2. UP/DOWN to select level (0-9)
3. MENU to confirm, EXIT

Recommendation: Start at 3-4. Increase if you hear too much noise. Decrease if you are missing weak signals.

### Setting CTCSS Tone for a Repeater (Menu 13 - T-CTCS)

Most repeaters require a CTCSS (PL) tone to access:

1. Tune to the repeater input frequency (with offset programmed)
2. MENU > 13 > MENU
3. UP/DOWN to select the correct tone frequency (e.g., 100.0 Hz)
4. MENU to confirm, EXIT

### Setting Repeater Offset (Menu 25/26)

1. First tune to the repeater **output** (receive) frequency
2. MENU > 25 > MENU > select + or - > MENU > EXIT
3. MENU > 26 > MENU > enter offset (e.g., 00.600 for 600 kHz on 2m, or 05.000 for 5 MHz on 70cm) > MENU > EXIT

### Setting Transmit Power (Menu 2 - TXP)

1. MENU > 2 > MENU
2. Select HIGH or LOW
3. MENU to confirm, EXIT

### Saving a Channel to Memory (Menu 27 - MEM-CH)

1. In VFO mode, set the desired frequency, tone, offset, power, etc.
2. MENU > 27 > MENU
3. UP/DOWN to select channel number (001-127)
4. MENU to save, EXIT
5. To store the TX frequency separately (for repeaters): switch to the TX frequency, then repeat the process with the same channel number.

### Deleting a Channel (Menu 28 - DEL-CH)

1. MENU > 28 > MENU
2. Select channel number
3. MENU to confirm, EXIT

### Enabling Wideband or Narrowband (Menu 5 - WN)

- **WIDE (25 kHz)**: For FM broadcast, some older ham repeaters
- **NARROW (12.5 kHz)**: For FRS, GMRS, most modern ham repeaters, all commercial
- MENU > 5 > MENU > select > MENU > EXIT

---

## Programming with CHIRP

For detailed CHIRP instructions, see: [chirp-programming.md](chirp-programming.md)

### Quick Summary

1. **Get a programming cable**: USB to Kenwood 2-pin. Common chipsets: **CH340** or **Prolific PL2303**. The CH340 is more reliable with modern Windows. Cost: $5-10.
2. **Install CHIRP-next**: Download from chirp.danplanet.com. Use the Python 3 version (chirp-next).
3. **Install cable drivers** if needed (Windows usually auto-installs CH340 drivers).
4. **Connect**: Plug cable into radio's accessory port (2-pin, side of radio). Plug USB into computer.
5. **Read from radio**: In CHIRP, Radio > Download from Radio. Select:
   - Vendor: Baofeng
   - Model: UV-5R
   - Port: COM port (Windows) or /dev/ttyUSB0 (Linux)
6. **Edit channels**: Fill in frequency, name, tone mode, tone, duplex, offset, power, mode.
7. **Upload to radio**: Radio > Upload to Radio.

### Programming Cable Notes

- **CH340 chipset**: Usually works out of the box on Windows 10/11. Green or clear cable.
- **PL2303 chipset**: Older chipset. May need specific driver version on Windows 10/11. Prolific has blacklisted counterfeit chips, which many cheap cables use. If you get "Code 10" error in Device Manager, try a CH340 cable instead.
- **Cable pinout**: 2.5mm plug = audio/data, 3.5mm plug = PTT/ground. Make sure both plugs are fully inserted.
- **Turn radio ON before connecting** to CHIRP. Set volume to mid-level.

---

## FRS/GMRS/MURS Channel Programming Reference

### FRS/GMRS Channels for Baofeng

| Channel | Frequency (MHz) | CTCSS | Bandwidth | Power (FRS) |
|---------|-----------------|-------|-----------|-------------|
| FRS 1 / GMRS 1 | 462.5625 | None | Narrow | 2W |
| FRS 2 / GMRS 2 | 462.5875 | None | Narrow | 2W |
| FRS 3 / GMRS 3 | 462.6125 | None | Narrow | 2W |
| FRS 4 / GMRS 4 | 462.6375 | None | Narrow | 2W |
| FRS 5 / GMRS 5 | 462.6625 | None | Narrow | 2W |
| FRS 6 / GMRS 6 | 462.6875 | None | Narrow | 2W |
| FRS 7 / GMRS 7 | 462.7125 | None | Narrow | 2W |
| FRS 8 | 467.5625 | None | Narrow | 0.5W |
| FRS 9 | 467.5875 | None | Narrow | 0.5W |
| FRS 10 | 467.6125 | None | Narrow | 0.5W |
| FRS 11 | 467.6375 | None | Narrow | 0.5W |
| FRS 12 | 467.6625 | None | Narrow | 0.5W |
| FRS 13 | 467.6875 | None | Narrow | 0.5W |
| FRS 14 | 467.7125 | None | Narrow | 0.5W |
| FRS 15 | 462.5500 | None | Narrow | 2W |
| FRS 16 | 462.5750 | None | Narrow | 2W |
| FRS 17 | 462.6000 | None | Narrow | 2W |
| FRS 18 | 462.6250 | None | Narrow | 2W |
| FRS 19 | 462.6500 | None | Narrow | 2W |
| FRS 20 | 462.6750 | None | Narrow | 2W |
| FRS 21 | 462.7000 | None | Narrow | 2W |
| FRS 22 | 462.7250 | None | Narrow | 2W |

### MURS Channels

| Channel | Frequency (MHz) | Bandwidth |
|---------|-----------------|-----------|
| MURS 1 | 151.820 | Narrow (11.25 kHz) |
| MURS 2 | 151.880 | Narrow (11.25 kHz) |
| MURS 3 | 151.940 | Narrow (11.25 kHz) |
| MURS 4 | 154.570 | Wide (20 kHz) |
| MURS 5 | 154.600 | Wide (20 kHz) |

**Legal note**: Transmitting on FRS or GMRS frequencies with a Baofeng UV-5R is technically illegal in the United States because the UV-5R is not Part 95 type-accepted. The UV-5X is a GMRS-certified Baofeng variant. For fully legal FRS use, use a dedicated FRS radio. For legal GMRS use, use a Part 95-certified radio with a valid GMRS license.

---

## Antenna Upgrades

The stock "rubber duck" antenna is notoriously poor. Upgrading the antenna is the single most impactful improvement you can make.

### Recommended Upgrades

| Antenna | Type | Gain | Length | Notes |
|---------|------|------|--------|-------|
| **Nagoya NA-771** | Dual-band whip | ~2.15 dBi | 15.6 in (39.5 cm) | Most popular upgrade. Significant improvement over stock. ~$10-15. Get genuine (many counterfeits). |
| **Nagoya NA-701** | Dual-band whip | ~1.5 dBi | 7.6 in (19.5 cm) | Shorter, still better than stock. Good compromise for portability. |
| **Signal Stick** | Dual-band whip | ~2 dBi | 19 in (48 cm) | Flexible, high quality. Made by SignalStuff/BTECH. |
| **Nagoya NA-320A** | VHF/UHF whip | ~3 dBi | 15.5 in (39 cm) | Good performer. |
| **Diamond SRH77CA** | Dual-band whip | ~2.15 dBi | 15.4 in | Well-known brand, reliable. |
| **Tactical/foldable** | Various | Varies | Varies | Some are gimmicks, some are decent. Test SWR before relying on them. |
| **External mobile/base** | Various | 3-9+ dBi | Large | For base or vehicle use with SMA-to-SO239 adapter and coax. Dramatically improves range. |

### Connector

The UV-5R has an **SMA-Female** connector on the radio body. You need antennas with an **SMA-Male** connector. Some antennas are sold with BNC or other connectors — you will need an adapter.

### Warning About Counterfeit Antennas

The Nagoya NA-771 is heavily counterfeited. Counterfeit antennas can have very high SWR and may damage your radio's final amplifier. Buy from reputable sources and check reviews.

---

## Battery Tips

### Stock Battery (BL-5, 1800 mAh)

- Charge time: approximately 4-5 hours from empty using the included drop-in charger.
- The LED on the charger turns green when fully charged.
- **Do not leave the battery charging for days** — the cheap charger does not have great overcharge protection.
- Expected life: 12-20 hours typical use (5% TX, 5% RX, 90% standby).

### Extended Batteries

- **3800 mAh battery** (BL-5L or similar): Larger capacity, makes the radio taller. Roughly doubles battery life.
- **USB-C battery packs**: Some UV-5RH models and aftermarket batteries support USB-C charging.

### Battery Eliminator

A battery eliminator replaces the battery pack and powers the radio from a 12V source (car cigarette lighter, power supply). Useful for base station or vehicle use.

### Tips

- Reduce transmit power to LOW when possible — dramatically extends battery life.
- Use battery saver mode (Menu 3 - SAVE).
- Turn off the display backlight (Menu 6 - ABR = OFF) or set to short timeout.
- Turn off keypad beep (Menu 8 - BEEP = OFF).
- Disable dual watch if not needed (Menu 7 - TDR = OFF).
- Carry a spare battery for extended outings.

---

## Common Issues and Fixes

### Radio Won't Program / CHIRP Timeout

- **Check cable connections**: Both 2.5mm and 3.5mm plugs must be fully seated.
- **Check COM port**: In CHIRP, verify the correct COM port is selected (check Device Manager on Windows).
- **Driver issues**: PL2303 drivers are problematic on Windows 10/11. Try CH340 cable.
- **Radio must be ON** when programming. Set volume to mid-level.
- **Try slower baud rate**: Some CHIRP versions allow selecting baud rate. UV-5R uses 9600 baud.
- **Close other programs** that might be using the COM port.

### Poor Range / Weak Signal

- **Upgrade the antenna** (see antenna section above).
- **Check SWR** if using a non-stock antenna.
- **Check power setting**: Make sure TXP is set to HIGH (Menu 2).
- **Check bandwidth**: Should match the other station (Menu 5 - WN).
- **Antenna connector tight**: Make sure the antenna is screwed on firmly.

### Can Hear Repeater But Can't Access It

- **Check CTCSS/PL tone**: Most repeaters require a specific tone (Menu 13 - T-CTCS).
- **Check offset**: Verify the correct offset direction (Menu 25) and amount (Menu 26).
- **Check that you're transmitting on the INPUT frequency**: The repeater input is offset from the output.
- **Power too low**: Try HIGH power.
- **Too far from repeater**: Repeaters have better receive capability than your HT, so you may hear them but not reach them.

### Squelch Breaks Open Constantly (Noise)

- Increase squelch level (Menu 0 - SQL). Try 4-5.
- If near strong signal sources (pagers, commercial transmitters), the front-end may be overloaded. Not much you can do with this radio; try a different location or add an external bandpass filter.

### Audio Sounds Distorted or "Narrow"

- Check bandwidth setting (Menu 5 - WN). If the other station is using wideband and you are on narrow, audio will sound distorted/clipped. Match bandwidth to the other station.

### Radio Receives But Won't Transmit

- Check if **key lock** is on (padlock icon on display). Press and hold **#** to toggle key lock.
- Check if **Busy Channel Lockout** is enabled (Menu 23 - BCL). Disable if needed.
- Check if you are in **FM broadcast receive mode** (65-108 MHz). The radio will not transmit in this range.
- **Battery too low**: The radio may reduce or disable TX when battery is critically low.

### Display Shows "BAT" and Radio Beeps

- Battery is critically low. Recharge or replace.

---

## Factory Reset

If your radio is in an unknown state, you can factory reset:

1. MENU > 40 > MENU
2. Select **ALL** for full reset
3. MENU to confirm
4. This erases ALL programmed channels and settings

---

## Legal Considerations

**Transmitting on any frequency requires authorization:**

- **Amateur (ham) radio frequencies (144-148 MHz, 420-450 MHz, etc.)**: Requires an FCC amateur radio license (Technician class minimum for VHF/UHF). You must have a callsign and identify during transmissions.

- **FRS frequencies**: The UV-5R is NOT Part 95 type-accepted for FRS. Technically illegal to transmit on FRS with it, even at low power.

- **GMRS frequencies**: Requires a GMRS license ($35/10 years, no exam). The UV-5R is NOT Part 95 type-accepted for GMRS. Use a certified radio like the Baofeng UV-5X for legal GMRS use.

- **MURS frequencies**: The UV-5R is NOT Part 95 type-accepted for MURS.

- **Commercial/public safety/government frequencies**: Absolutely prohibited without specific authorization.

- **Marine, aviation, and other services**: Prohibited.

**In an actual life-threatening emergency**, you may transmit on any frequency using any equipment to summon help. Outside of genuine emergencies, stick to frequencies and services you are licensed for, using type-accepted equipment.
