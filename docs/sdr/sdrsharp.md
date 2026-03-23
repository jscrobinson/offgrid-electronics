# SDR# (SDRSharp) Guide

## Overview

SDR# (SDRSharp) is the most popular SDR software for Windows, particularly with RTL-SDR devices. It is developed by Airspy (makers of the Airspy SDR hardware) and is free to use. It provides a spectrum display, waterfall, multiple demodulation modes, and an extensible plugin system.

---

## Download and Install

1. Go to https://airspy.com/download/
2. Download the SDR# installer package (ZIP file).
3. Extract to a permanent location (e.g., `C:\SDR\SDRSharp`). Do NOT run from within the ZIP.
4. Run `install-rtlsdr.bat` to download RTL-SDR support files.
5. Install the RTL-SDR driver using Zadig (see rtl-sdr-setup.md).
6. Run `SDRSharp.exe`.

### First-Time Configuration

1. In the **Source** dropdown (top-left), select **RTL-SDR (USB)** or **RTL-SDR TCP** (for remote).
2. Click the **gear icon** (⚙) next to the source dropdown to open device settings.
3. Verify your RTL-SDR device is listed.
4. Click the **Play button** (▶) to start receiving.

---

## User Interface

### Main Display Areas

```
┌──────────────────────────────────────────┐
│  [Source ▼] [▶ Play] [Freq: 100.000.000]│  ← Top bar
├──────────────────────────────────────────┤
│                                          │
│           Spectrum (FFT)                 │  ← Signal strength vs frequency
│                                          │
├──────────────────────────────────────────┤
│                                          │
│           Waterfall                      │  ← Time vs frequency (scrolling)
│                                          │
│                                          │
├──────────────────────────────────────────┤
│  Radio │ AGC │ Audio │ FFT │ ...        │  ← Side panels (left)
└──────────────────────────────────────────┘
```

### Side Panels (Left)

- **Radio**: Mode selection, bandwidth, squelch, volume
- **AGC**: Automatic gain control settings
- **Audio**: Audio output settings, recording
- **FFT Display**: Spectrum/waterfall display settings
- **Frequency Manager**: Save and recall frequencies (plugin)
- **Recording**: IQ recording controls

### Spectrum Display

- **Horizontal axis**: Frequency
- **Vertical axis**: Signal strength (dB)
- The **red/yellow line** at the top shows the current RF spectrum.
- Click anywhere on the spectrum to tune to that frequency.

### Waterfall Display

- **Horizontal axis**: Frequency
- **Vertical axis**: Time (newest at top, scrolling down)
- **Color**: Signal strength (blue/black = weak, yellow/red/white = strong)
- The waterfall makes it easy to spot intermittent signals and see band activity at a glance.

---

## Tuning and Frequency Control

### Setting Frequency

**Direct entry**: Click on the frequency display at the top. Type the frequency in Hz. Examples:
- 100000000 = 100 MHz (FM broadcast)
- 146520000 = 146.520 MHz (2m calling)
- 1090000000 = 1090 MHz (ADS-B)

**Mouse wheel**: Hover over a digit in the frequency display and scroll to change it.

**Click on spectrum/waterfall**: Click directly on a signal to tune to it.

### Frequency Correction (PPM)

RTL-SDR devices may have a slight frequency offset. To correct:
1. Click the **gear icon** next to the source dropdown.
2. Adjust the **Frequency Correction (PPM)** value.
3. Tune to a known signal (e.g., FM broadcast station) and adjust until it is centered.
4. The RTL-SDR Blog V3/V4 with TCXO should be within ±1 PPM.

---

## Demodulation Modes

Select the demodulation mode in the **Radio** panel on the left.

| Mode | Use | Bandwidth |
|------|-----|-----------|
| **WFM** | Wideband FM (broadcast FM radio) | ~200 kHz |
| **NFM** | Narrowband FM (two-way radio, FRS, GMRS, ham VHF/UHF) | 6-15 kHz |
| **AM** | Amplitude Modulation (aircraft, AM broadcast via HF SDR) | ~6-10 kHz |
| **USB** | Upper Sideband (HF amateur above 10 MHz) | ~2.4 kHz |
| **LSB** | Lower Sideband (HF amateur below 10 MHz) | ~2.4 kHz |
| **CW** | Continuous Wave (Morse code) | ~500 Hz |
| **DSB** | Double Sideband | ~6 kHz |
| **RAW** | Raw I/Q passthrough (for piping to other software) | Variable |

### Bandwidth Adjustment

The filter bandwidth (the highlighted area on the spectrum) can be adjusted:
- Drag the edges of the filter overlay on the spectrum display.
- Or type a value in the bandwidth field in the Radio panel.

---

## Gain Settings

Proper gain setting is critical for good reception. Too low = weak signals lost in noise. Too high = overloading, spurious signals, distortion.

### RTL-SDR Gain Control

Click the **gear icon** to access gain settings:

- **RF Gain**: The main gain control. Slider from 0 to ~49.6 dB (for R820T2 tuner). This adjusts the tuner's LNA and mixer gain.
- **AGC**: Automatic gain control.
  - **RTL AGC**: Hardware AGC in the RTL2832U chip. Usually leave OFF.
  - **Tuner AGC**: Hardware AGC in the R820T2 tuner. Can be useful but often results in suboptimal gain.

### Manual Gain Recommendations

| Situation | Recommended Gain |
|-----------|-----------------|
| Strong signals (FM broadcast, local repeaters) | Low to moderate (20-30 dB) |
| Moderate signals (aircraft, weather satellites) | Moderate to high (30-40 dB) |
| Weak signals (distant ADS-B, ISM devices) | High (40-49.6 dB) |
| Overloaded (strong signals causing spurious) | Reduce gain until spurious signals disappear |

**How to tell if gain is too high**: You will see "phantom" signals (images, intermod products) that appear at frequencies where no real signal exists. The noise floor rises unevenly. Reduce gain until these disappear.

**How to tell if gain is too low**: Weak signals are not visible above the noise floor. Increase gain until the signal-to-noise ratio of your target signal is maximized.

---

## Receiving Common Signals

### FM Broadcast Radio

1. Set mode to **WFM**.
2. Tune to 87.5-108 MHz range.
3. Set gain to moderate (~25-30 dB).
4. Click on a signal peak to tune.
5. You should hear FM audio. Stereo will decode automatically if signal is strong.

### Aircraft Communications

1. Set mode to **AM**.
2. Tune to 118-137 MHz range.
3. Set bandwidth to ~8 kHz.
4. Set gain to moderate-high (~35 dB).
5. Aircraft transmissions are intermittent — wait and watch the waterfall for activity.
6. Common frequencies: 121.500 (emergency), local tower/approach frequencies.

### Narrowband FM (Two-Way Radio)

1. Set mode to **NFM**.
2. Set bandwidth to 12.5 kHz.
3. Tune to the desired frequency (e.g., 146.520 MHz for 2m calling, 462.5625 MHz for FRS Ch 1).
4. Set gain appropriately.
5. Set squelch so the audio is quiet between transmissions.

### NOAA Weather Radio

1. Set mode to **NFM**.
2. Set bandwidth to ~15 kHz.
3. Tune to one of the NOAA frequencies: 162.400, 162.425, 162.450, 162.475, 162.500, 162.525, 162.550 MHz.
4. Weather broadcasts are continuous — you should hear voice immediately on an active channel.

---

## Plugins

SDR# has a plugin system that extends functionality. Some useful plugins:

### Frequency Manager (Built-in)

- Save and organize frequencies with names, mode, and notes.
- Double-click an entry to tune.
- Import/export frequency lists.

### Scanner (Built-in)

- Scans through a range of frequencies or a list of saved frequencies.
- Stops on active signals.
- Configure scan speed, squelch level, and resume delay.

### DSD+ Plugin

- Decode digital voice modes (P25, DMR, NXDN, D-STAR).
- Requires DSD+ software installed separately.
- Audio is piped from SDR# to DSD+ via virtual audio cable.

### Frequency Scanner Plugin

- More advanced scanning than built-in scanner.
- Configurable scan ranges, step sizes, and dwell times.

### Installing Plugins

1. Download the plugin files (usually a `.dll` file).
2. Place the `.dll` in the SDR# installation directory.
3. Add the plugin entry to `Plugins.xml` (or `MagicLine` in newer versions) as instructed by the plugin author.
4. Restart SDR#.

---

## Recording

### Audio Recording

1. In the **Audio** panel, click the record button.
2. Audio is saved as a WAV file in the SDR# directory (or configured output folder).
3. Useful for recording voice communications, weather broadcasts, etc.

### I/Q Recording (Baseband)

1. In the **Recording** panel, enable baseband recording.
2. This records the raw I/Q data at the full sample rate.
3. File sizes are large (about 5 MB/sec at 2.4 MSPS).
4. I/Q recordings can be replayed later in SDR# (File > Play) for post-analysis. This is like a time machine — you can retune and demodulate any signal within the recorded bandwidth after the fact.

---

## Tips and Settings

### Reducing CPU Usage

- Reduce FFT resolution (FFT Display panel).
- Reduce spectrum update rate ("Speed" slider in FFT Display).
- Use a lower sample rate if full bandwidth is not needed.
- Disable waterfall if not needed (saves rendering).

### Improving Weak Signal Reception

- **Increase gain** (but not to the point of overloading).
- **Enable the bias-T** if using an LNA or active antenna (gear icon > Bias-T checkbox).
- Use a better antenna (see antenna-basics.md).
- Use a bandpass filter to reject strong out-of-band signals that cause overloading.
- Increase FFT averaging to smooth the spectrum display and make weak signals more visible.

### Correcting DC Spike

A spike at the center frequency is normal for RTL-SDR (DC offset). To avoid it:
- Enable **"Correct IQ"** in the SDR# settings (usually on by default).
- Or tune slightly off-center so the DC spike does not overlap your signal of interest.

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Space | Toggle play/stop |
| Ctrl+S | Open settings |
| Mouse wheel on frequency | Change frequency digit |
| Click+drag on waterfall | Tune to clicked frequency |
