# CHIRP Radio Programming Software — Complete Guide

## What Is CHIRP

CHIRP is a free, open-source, cross-platform tool for programming amateur and commercial radios. It supports hundreds of radio models from manufacturers including Baofeng, Yaesu, Kenwood, Icom, TYT, Retevis, and many others.

CHIRP provides a spreadsheet-style interface for editing channels, which is dramatically faster and less error-prone than programming radios manually through their keypads.

**Website**: https://chirp.danplanet.com

---

## Download and Install

### CHIRP-next (Recommended — Python 3 Version)

The current actively-maintained version is **CHIRP-next**, rewritten in Python 3 with a wxPython GUI. The older "legacy" CHIRP (Python 2) is no longer maintained.

#### Windows

1. Download the Windows installer from https://chirp.danplanet.com/projects/chirp/wiki/Download
2. Download the `.exe` installer (e.g., `chirp-next-xxxxxxxx-installer.exe`).
3. Run the installer. Follow prompts.
4. CHIRP will be available in the Start Menu.

#### Linux (Debian/Ubuntu)

```bash
# Install via pip (recommended for latest version)
pip3 install chirp

# Or install via Flatpak
flatpak install flathub com.danplanet.chirp

# Or on some distributions, from package manager
sudo apt install chirp    # May be older version
```

To run after pip install:
```bash
chirp
```

#### Linux (Fedora)

```bash
pip3 install chirp
# or
sudo dnf install chirp
```

#### macOS

1. Download the macOS `.dmg` from the CHIRP download page.
2. Open the `.dmg` and drag CHIRP to Applications.
3. On first run, you may need to right-click > Open to bypass Gatekeeper.

---

## Programming Cable

You need a USB programming cable to connect your computer to the radio. For Baofeng UV-5R and similar radios, this is a **USB to Kenwood 2-pin** cable.

### Cable Types

| Chipset | Description | Compatibility |
|---------|-------------|---------------|
| **CH340** | Most common, most reliable with modern OS | Windows 10/11, Linux, macOS (with driver) |
| **PL2303** (Prolific) | Older chipset, driver issues common | Problematic on Windows 10/11. Prolific has cracked down on counterfeit chips. |
| **FTDI** | Higher quality, less common for Baofeng cables | Best compatibility across all platforms |
| **CP2102** | Silicon Labs chipset | Good compatibility |

**Recommendation**: Buy a **CH340** cable. They are inexpensive ($5-10), widely available, and work reliably.

### Driver Installation

#### Windows (CH340)

Windows 10/11 usually installs CH340 drivers automatically via Windows Update when you plug in the cable. If not:
1. Download CH340 drivers from the manufacturer's site (search "CH340 driver download").
2. Install the driver.
3. Open Device Manager (right-click Start > Device Manager).
4. Under "Ports (COM & LPT)", you should see "USB-SERIAL CH340 (COMx)".
5. Note the COM port number.

#### Windows (PL2303 — Troubleshooting)

PL2303 cables often show "PL2303HXA PHASED OUT" or Code 10 error on Windows 10/11:
1. **Try an older driver**: Prolific driver version 3.3.2.102 or 3.3.11.152 sometimes works. Uninstall the current driver first, then install the older version.
2. **Disable automatic driver updates** for the device.
3. **Better solution**: Return the PL2303 cable and buy a CH340 cable.

#### Linux

CH340 and PL2303 drivers are built into the Linux kernel. The device will appear as `/dev/ttyUSB0` (or ttyUSB1, etc.).

**Permission issue fix** (if you get "Permission denied"):
```bash
# Add your user to the dialout group
sudo usermod -a -G dialout $USER

# Log out and back in for the change to take effect

# Or, for a quick test, run CHIRP as root (not recommended long-term)
sudo chirp
```

**Check device**:
```bash
ls -la /dev/ttyUSB*
# Should show /dev/ttyUSB0 or similar
```

#### macOS

CH340 drivers must be installed manually on some macOS versions:
1. Download the CH340 driver for macOS from the manufacturer (search "CH340 mac driver").
2. Install and restart.
3. Grant necessary security permissions in System Preferences > Security & Privacy.

---

## Connecting the Radio

1. **Turn the radio ON**. Set volume to a moderate level.
2. **Plug the 2-pin connector** into the radio's accessory port (side of the radio). The 2.5mm plug goes in the smaller hole (upper), the 3.5mm plug in the larger hole (lower). Push firmly until fully seated.
3. **Plug the USB end** into your computer.
4. Wait a few seconds for driver recognition.
5. Open CHIRP.

---

## Reading from Radio (Downloading)

This reads the current channel programming from the radio into CHIRP.

1. **Radio > Download from Radio** (or click the "download" icon).
2. In the dialog:
   - **Port**: Select the COM port (Windows: COM3, COM4, etc.) or device (Linux: /dev/ttyUSB0, macOS: /dev/cu.usbserial-xxxxx).
   - **Vendor**: Select "Baofeng" (or your radio's manufacturer).
   - **Model**: Select "UV-5R" (or your specific model).
3. Click **OK**.
4. The radio's display will go blank and the progress bar will advance. **Do not touch the radio or cable** during this process.
5. Download takes about 30-60 seconds.
6. When complete, you will see a spreadsheet of all programmed channels.

### If Download Fails

- **"An error occurred"**: Check cable connection. Ensure both plugs are fully inserted.
- **"No response from radio"**: Make sure radio is ON. Try a different COM port. Try turning radio off and on again.
- **"Timeout"**: May be a driver issue. Try a different cable or driver version.
- **"Permission denied" (Linux)**: Add yourself to the `dialout` group (see above).
- **Port not listed**: Driver not installed. Check Device Manager (Windows) or `ls /dev/ttyUSB*` (Linux).

---

## Editing Channels

After downloading, you will see a spreadsheet with these columns:

| Column | Description | Example |
|--------|-------------|---------|
| **Loc** | Channel/memory location number | 0-127 |
| **Name** | Channel name (up to 6-7 characters) | CALL, RPT1 |
| **Frequency** | Receive frequency in MHz | 146.520000 |
| **Duplex** | Duplex mode: (blank)=simplex, +=positive offset, -=negative offset, split=different TX freq | + |
| **Offset** | Repeater offset in MHz | 0.600000 |
| **Tone** | Tone mode: (none), Tone, TSQL, DTCS, Cross | Tone |
| **rToneFreq** | Transmit CTCSS tone frequency | 100.0 |
| **cToneFreq** | Receive CTCSS tone frequency (for TSQL) | 100.0 |
| **DtcsCode** | DCS code number | 023 |
| **DtcsPolarity** | DCS polarity | NN |
| **Mode** | FM or NFM | NFM |
| **TStep** | Tuning step in kHz | 5.00 |
| **Skip** | Scan skip: (blank)=scan, S=skip, P=priority | |
| **Power** | Transmit power | High |
| **Comment** | Notes (not stored on radio) | |

### Adding a Simplex Channel

Example: 2-meter national calling frequency

| Field | Value |
|-------|-------|
| Loc | (next available, e.g., 0) |
| Name | CALL |
| Frequency | 146.520000 |
| Duplex | (blank/off) |
| Offset | 0.000000 |
| Tone | (none) |
| Mode | NFM |
| Power | High |

### Adding a Repeater Channel

Example: A repeater on 147.060 MHz output, +600 kHz offset, 100.0 Hz CTCSS tone

| Field | Value |
|-------|-------|
| Loc | (next available) |
| Name | RPT060 |
| Frequency | 147.060000 |
| Duplex | + |
| Offset | 0.600000 |
| Tone | Tone |
| rToneFreq | 100.0 |
| Mode | NFM |
| Power | High |

### Tone Mode Options

| Mode | Description |
|------|-------------|
| **(none)** | No tone. Carrier squelch only. |
| **Tone** | Transmit a CTCSS tone. Receive is open (carrier squelch). Most common for repeater access. |
| **TSQL** | Transmit AND receive CTCSS. Only hear stations with matching tone. |
| **DTCS** | DCS (Digital Coded Squelch). Similar concept to CTCSS but digital. |
| **Cross** | Different encode/decode methods (e.g., CTCSS transmit, DCS receive). |

### Common CTCSS Tone Frequencies

67.0, 69.3, 71.9, 74.4, 77.0, 79.7, 82.5, 85.4, 88.5, 91.5, 94.8, 97.4, **100.0**, 103.5, 107.2, 110.9, 114.8, 118.8, 123.0, 127.3, 131.8, 136.5, 141.3, **146.2**, 151.4, 156.7, 159.8, 162.2, 165.5, 167.9, 171.3, 173.8, 177.3, 179.9, 183.5, 186.2, 189.9, 192.8, 196.6, 199.5, 203.5, 206.5, 210.7, 218.1, 225.7, 229.1, 233.6, 241.8, 250.3, 254.1

---

## Importing from Repeater Databases

CHIRP can import repeater data from online databases, saving you from manually entering repeater information.

### RepeaterBook Import

1. **Radio > Import from Data Source > RepeaterBook**
2. Select your country, state/province.
3. Optionally filter by band, county, etc.
4. Click **OK**.
5. A list of repeaters will appear.
6. Select the repeaters you want to add (Ctrl+Click for multiple, Ctrl+A for all).
7. Click **OK**.
8. Assign them to channel locations.

### RFinder Import

1. **Radio > Import from Data Source > RFinder**
2. Requires an RFinder account (some features are paid).
3. Enter location coordinates or search criteria.
4. Import selected repeaters.

### Manual CSV Import

You can also import channels from a CSV file:
1. **File > Import** (or Radio > Import)
2. Select a `.csv` file.
3. Map columns if necessary.
4. Select channels to import.

---

## Uploading to Radio

After editing channels:

1. **Radio > Upload to Radio** (or click the "upload" icon).
2. In the dialog, verify: Port, Vendor, Model.
3. Click **OK**.
4. **Do not touch the radio or cable** during upload.
5. Upload takes about 30-60 seconds.
6. When complete, the radio will return to normal operation with the new channels.

**Warning**: Uploading **overwrites all channels** on the radio with what is in CHIRP. Make sure your CHIRP file is complete before uploading.

---

## Saving and Loading Files

### Save CHIRP File

- **File > Save As** to save as a CHIRP image file (`.img`).
- This is a binary image of the radio's memory. It preserves all settings.
- Keep backups of your `.img` files.

### Export to CSV

- **File > Export** to save as a `.csv` (comma-separated values) file.
- Useful for sharing, editing in a spreadsheet, or as a human-readable backup.

### Import from CSV

- **File > Import** and select a `.csv` file.
- You will be prompted to select which entries to import and where to place them.

### Opening an Existing File

- **File > Open** to load a previously saved `.img` file.
- You can edit this file and then upload it to a radio.

---

## Common Issues and Solutions

### "No response from radio" / Timeout Error

1. Check that both plugs of the programming cable are fully seated in the radio.
2. Check that the radio is turned ON.
3. Make sure you selected the correct COM port.
4. Try a different USB port on your computer.
5. Try turning the radio off and back on.
6. Some radios need to be on a specific frequency or in VFO mode before programming.

### Wrong COM Port / Port Not Listed

- **Windows**: Open Device Manager > Ports (COM & LPT). Look for "USB-SERIAL CH340" or "Prolific USB-to-Serial Comm Port". Note the COM number.
- **Linux**: Run `ls /dev/ttyUSB*` in a terminal.
- **macOS**: The port will be something like `/dev/cu.usbserial-1420` or `/dev/cu.wchusbserial1410`.

### "PL2303HXA PHASED OUT" / Code 10 Error (Windows)

Your PL2303 cable has a chip that Prolific has flagged as counterfeit. Options:
1. Install an older PL2303 driver (version 3.3.2.102).
2. Buy a CH340 cable instead (recommended, ~$5-8).

### Upload Fails Partway Through

- Make sure radio battery is adequately charged.
- Do not bump or move the cable during transfer.
- Try again. Occasional glitches happen.
- Make sure no other software is using the COM port.

### Channels Don't Appear After Upload

- Check that you are in **MR (Memory) mode** on the radio (press VFO/MR until you see channel numbers).
- Check that the display mode is set to show channel names (Menu 21/22 on UV-5R).

### CHIRP Shows Different Model Warnings

If CHIRP warns about model mismatch:
- Many UV-5R variants (UV-5R+, UV-5RE, BF-F8HP) can be programmed as "UV-5R" in CHIRP.
- If unsure, check the CHIRP wiki for your specific model.

---

## Tips and Best Practices

1. **Always download from the radio first** before making changes. This gives you a baseline and prevents losing existing programming.

2. **Save your CHIRP file frequently** and keep backups. Name files descriptively (e.g., `uv5r-2024-repeaters-east-coast.img`).

3. **Organize channels logically**: Group repeaters by area, put simplex calling frequencies in predictable locations, put emergency frequencies first.

4. **Use the Name field**: Short but descriptive names help when scrolling channels on the radio. Examples: `CALL52`, `RPT060`, `FRS1`, `NOAA1`.

5. **Set scan skip (S)** on channels you don't want to include when scanning (like NOAA weather that you only check manually).

6. **Export to CSV** periodically as a human-readable backup that can survive software changes.

7. **Share CSV files** with your group so everyone has matching channel programming.

8. **For multiple radios of the same model**: Program one radio, save the file, then upload the same file to all other radios. Instant consistent programming across your group.

9. **Check your work**: After uploading, manually verify a few channels on the radio (correct frequency, tone, offset) to make sure everything transferred correctly.

10. **Keep a printed channel list** in your radio bag for quick reference when the radio is in use.
