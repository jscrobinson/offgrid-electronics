# Weather Satellite Reception

## Overview

Several orbiting weather satellites broadcast image data on frequencies around 137 MHz that can be received with an RTL-SDR and a simple homemade antenna. This is one of the most rewarding SDR projects — you receive actual satellite images of the Earth directly, as the satellite passes overhead.

Two main satellite systems are accessible:
- **NOAA POES** (US, APT format — analog)
- **Meteor M2** (Russian, LRPT format — digital)

---

## NOAA APT Satellites

### Active Satellites and Frequencies

| Satellite | Frequency | Status |
|-----------|-----------|--------|
| **NOAA-15** | 137.620 MHz | Active (oldest, occasionally unreliable) |
| **NOAA-18** | 137.9125 MHz | Active |
| **NOAA-19** | 137.100 MHz | Active |

Each satellite orbits at approximately 850 km altitude in a polar orbit, passing over any given location roughly 2-4 times per day (both northbound and southbound passes). A pass lasts approximately 12-15 minutes.

### APT Signal Characteristics

- **Modulation**: FM (analog, 2400 Hz subcarrier AM-modulated with image data)
- **Bandwidth**: ~40 kHz
- **Signal strength**: Strong enough to receive with simple antennas
- **Image resolution**: ~4 km per pixel
- **Image content**: Visible light and infrared channels, side by side

---

## Meteor M2 Satellite

### Frequencies

| Satellite | Frequency | Format |
|-----------|-----------|--------|
| **Meteor M2-3** | 137.900 MHz | LRPT (digital) |
| **Meteor M2-4** | 137.100 MHz | LRPT (digital) |

Check current status — Meteor satellites have changed frequencies and had operational interruptions.

### LRPT Signal Characteristics

- **Modulation**: QPSK digital
- **Bandwidth**: ~120 kHz
- **Image resolution**: ~1 km per pixel (higher than NOAA APT)
- **Image content**: Three channels (visible, near-IR, thermal IR)

Meteor LRPT produces higher-resolution images than NOAA APT but requires digital demodulation and decoding.

---

## Pass Prediction

You need to know when a satellite will be overhead. Satellites in polar orbits pass at predictable times.

### Software

| Tool | Platform | Description |
|------|----------|-------------|
| **Gpredict** | Linux, Windows, macOS | Excellent free satellite tracking. Shows real-time position, upcoming passes, azimuth/elevation. |
| **N2YO** | Web | https://www.n2yo.com — Online pass predictor. No install needed. |
| **Orbitron** | Windows | Classic satellite tracking software. |
| **ISS Detector** | Android, iOS | Mobile app, supports weather satellites. |
| **Look4Sat** | Android | Free satellite pass predictor. |
| **SatDump** | All platforms | Includes pass prediction along with decoding. |

### Using Gpredict

```bash
sudo apt install gpredict
```

1. Open Gpredict.
2. Go to **Edit > Update TLE** (Two-Line Elements) to download current orbital data.
3. Add NOAA-15, NOAA-18, NOAA-19, Meteor M2 satellites to your tracking list.
4. Set your ground station location (latitude, longitude, altitude).
5. View the **Upcoming Passes** list for your location.
6. A good pass is one with maximum elevation above 30 degrees. Higher = better signal.

### What Makes a Good Pass?

| Max Elevation | Quality | Expected Result |
|--------------|---------|-----------------|
| 80-90 degrees | Excellent (overhead) | Complete, high-quality image |
| 50-70 degrees | Good | Good image, some edge noise |
| 30-50 degrees | Moderate | Partial image, more noise |
| Below 20 degrees | Poor | Likely too noisy for a good image |

---

## Antenna

### V-Dipole (Simplest and Effective)

Two telescopic whips or rigid wires arranged in a V-shape:

```
        Antenna elements (~53.4 cm each)
          /         \
         / ~120°     \
        /             \
       /_______________\
            |     |
         Center conductor / Shield
            to coax
```

#### Construction

1. **Each element**: 53.4 cm long (quarter wavelength at 137 MHz). Use telescopic whips, coat hanger wire, or brass rod.
2. **Angle**: Elements at approximately **120 degrees** apart (60 degrees from vertical on each side).
3. **Feedpoint**: Connect one element to the center conductor of your coax, the other to the shield.
4. **Coax**: RG-58 or RG-8X, as short as practical (under 10 meters/30 feet).
5. **Orientation**: Lay the antenna roughly horizontal, with elements pointing approximately east-west (for north-south polar orbiting satellites). Angle slightly upward.
6. **No ground plane needed.**

The V-dipole is circularly polarized (approximately), which is good because satellite signals are right-hand circularly polarized (RHCP). This simple antenna works surprisingly well.

### QFH (Quadrifilar Helix) Antenna

A more advanced antenna with better performance:
- Truly circular polarized (RHCP)
- Omnidirectional overhead coverage
- Better at low elevation angles
- More complex to build (requires precise dimensions and phasing)

Many construction guides are available online. Typically built from copper pipe or coax.

### Turnstile Antenna

Two dipoles crossed at 90 degrees, with one fed 90 degrees out of phase:
- Creates circular polarization
- Simple to build
- Performance between V-dipole and QFH

---

## Receiving NOAA APT

### Method 1: Record Audio and Decode Later

#### Step 1: Record During a Pass

```bash
# Record the satellite pass as audio using rtl_fm
# Start recording a few minutes before the pass
rtl_fm -f 137620000 -s 48000 -g 40 -p 0 -E deemp -F 9 - | \
  sox -t raw -e signed -c 1 -b 16 -r 48000 - recording_noaa15.wav rate 11025
```

Frequencies:
- NOAA-15: 137620000 (137.620 MHz)
- NOAA-18: 137912500 (137.9125 MHz)
- NOAA-19: 137100000 (137.100 MHz)

Parameters:
- `-s 48000`: Sample rate
- `-g 40`: Gain (adjust to your setup, try 40-49.6)
- `-E deemp`: De-emphasis filter
- `-F 9`: FIR filter size

#### Step 2: Decode with WXtoImg

WXtoImg is the classic NOAA APT decoder:

1. Download WXtoImg from the internet (the original site is down, but mirrors exist).
2. Install and configure with your location (latitude, longitude).
3. Open the recorded WAV file.
4. Select **File > Open Audio File**.
5. The software will process the audio and generate satellite images.
6. Various enhancement options: thermal, vegetation, multispectral analysis (MSA).

#### Alternative Decoder: noaa-apt

A modern, open-source NOAA APT decoder:

```bash
# Download from https://github.com/martinber/noaa-apt/releases
# Or build from source (requires Rust)
cargo install noaa-apt
```

```bash
# Decode a WAV recording
noaa-apt recording_noaa15.wav -o output_image.png
```

### Method 2: SatDump (Recommended Modern Approach)

SatDump is a modern, all-in-one satellite decoder that handles reception and decoding for both NOAA APT and Meteor LRPT:

```bash
# Install SatDump
# Download from https://github.com/SatDump/SatDump/releases
# Available for Windows, Linux, macOS

# On Linux, AppImage is the easiest:
chmod +x SatDump-*.AppImage
./SatDump-*.AppImage
```

SatDump features:
- Real-time demodulation and decoding
- Support for NOAA APT, Meteor LRPT, and many other satellite protocols
- Built-in SDR device support (RTL-SDR, Airspy, etc.)
- Automatic Doppler correction
- Post-processing and enhancement options
- Pass prediction

### Method 3: SDR Application + Virtual Audio

1. Open SDR# or GQRX.
2. Tune to the satellite frequency.
3. Set mode to WFM (wideband FM), bandwidth ~40 kHz.
4. Pipe audio to a virtual audio cable (VB-Audio on Windows, PulseAudio on Linux).
5. Run WXtoImg or another decoder reading from the virtual audio source.
6. Start receiving when the satellite rises above the horizon.

---

## Receiving Meteor M2 LRPT

Meteor LRPT produces higher-resolution images but requires digital demodulation.

### Using SatDump (Recommended)

1. Open SatDump.
2. Select your RTL-SDR device.
3. Select the Meteor M2 pipeline.
4. Set the correct frequency.
5. Start recording/processing when the satellite pass begins.
6. SatDump handles demodulation (QPSK), frame synchronization, error correction, and image assembly.

### Manual Process

1. **Record I/Q data** during the pass:
   ```bash
   rtl_sdr -f 137900000 -s 1024000 -g 40 meteor_iq.raw
   ```

2. **Demodulate** with MeteorDemod or SatDump:
   ```bash
   # Using MeteorDemod
   meteor_demod -B -s 1024000 -o meteor_output.s meteor_iq.raw
   ```

3. **Decode** the demodulated data:
   ```bash
   meteor_decode -a meteor_output.s -o meteor_image
   ```

4. View the resulting PNG images.

---

## Image Enhancement and Processing

### NOAA APT Enhancements

WXtoImg and noaa-apt can apply various false-color enhancements:

| Enhancement | Description |
|------------|-------------|
| **Raw** | Unprocessed visible + IR channels side by side |
| **Thermal** | False-color thermal mapping (cold = blue, warm = red) |
| **MSA** | Multispectral analysis — vegetation appears green |
| **HVCT** | High-contrast visible and thermal |
| **Sea surface temp** | Highlights ocean temperature gradients |
| **Precipitation** | Highlights likely precipitation areas |

### Meteor M2 Image Channels

| Channel | Content |
|---------|---------|
| Channel 1 | Visible light (0.5-0.7 um) |
| Channel 2 | Near infrared (0.7-1.1 um) |
| Channel 3 | Thermal infrared (10.5-11.5 um) or mid-IR |

Composite images can be created from multiple channels for color and enhanced views.

---

## Tips for Success

1. **Antenna placement is critical.** The antenna needs a clear view of the sky, especially toward the horizon. Even a V-dipole on the ground floor works, but a rooftop or elevated location dramatically improves results.

2. **Gain setting**: Start around 40 dB. Too much gain can overload from strong signals. If you see the signal but the image is noisy, try reducing gain.

3. **Doppler shift**: The satellite signal shifts in frequency as it approaches and recedes (about +/- 3 kHz at 137 MHz). For NOAA APT, the FM demodulator handles this naturally. For Meteor LRPT, Doppler correction improves results — SatDump handles this automatically.

4. **Start recording early**: Begin recording 1-2 minutes before the predicted pass start to ensure you capture the full pass.

5. **Try multiple passes**: Not every pass will produce a great image. Cloud cover, satellite orientation, and your local RF environment all affect results. Nighttime passes produce IR-only images (no visible light).

6. **Use the highest pass of the day** for best results. Overhead passes (80-90 degrees elevation) give the longest, cleanest images.

7. **Filter interference**: If you have strong pager or commercial signals near 137 MHz, a bandpass filter (137 +/- 5 MHz) can help.

---

## What to Expect

A successful NOAA APT reception produces a grayscale image approximately 2080 pixels wide, showing two channels (visible and infrared) of the Earth as seen from the satellite's perspective. The image is built line-by-line as the satellite passes overhead, so you will see a strip of Earth centered on the satellite's ground track.

Features visible in good images:
- Cloud patterns and weather systems
- Coastlines and major geographic features
- Temperature variations (IR channel)
- Hurricane and storm structures
- Snow and ice coverage

This is one of the most satisfying SDR projects because you are directly receiving signals from space and converting them into visible images of the Earth.
