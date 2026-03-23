# GQRX Guide (Linux / macOS)

## Overview

GQRX is a free, open-source SDR receiver application powered by GNU Radio and the Qt GUI toolkit. It is the most popular SDR application on Linux and is also available on macOS. It provides a clean interface with spectrum display, waterfall, multiple demodulation modes, and audio recording.

---

## Installation

### Debian / Ubuntu

```bash
sudo apt install gqrx-sdr
```

### Fedora

```bash
sudo dnf install gqrx
```

### Arch Linux

```bash
sudo pacman -S gqrx
```

### Flatpak (Any Linux Distribution)

```bash
flatpak install flathub dk.gqrx.gqrx
```

### AppImage

Download the AppImage from https://github.com/gqrx-sdr/gqrx/releases

```bash
chmod +x gqrx-*.AppImage
./gqrx-*.AppImage
```

### macOS

```bash
brew install --cask gqrx
```

Or download the macOS DMG from the GQRX releases page.

### From Source

```bash
sudo apt install git cmake g++ pkg-config libboost-all-dev liblog4cpp5-dev \
  libgmp-dev libsndfile1-dev libfftw3-dev libsdl1.2-dev libqt5svg5-dev \
  libqwt-qt5-dev qtbase5-dev libpulse-dev librtlsdr-dev gnuradio-dev \
  gr-osmosdr
git clone https://github.com/gqrx-sdr/gqrx.git
cd gqrx
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install
```

---

## First-Time Configuration

When you first launch GQRX, a configuration dialog appears.

### Device Selection

In the **Device** field, enter or select the device string:

| Device | String |
|--------|--------|
| RTL-SDR | `rtl=0` |
| RTL-SDR (specific serial) | `rtl=SERIALNUMBER` |
| RTL-SDR via TCP (remote) | `rtl_tcp=HOST:PORT` |
| Airspy | `airspy=0` |
| HackRF | `hackrf=0` |
| SDRplay | `soapy=0,driver=sdrplay` |
| Audio input (for IF) | `pulseaudio` or `alsa` |
| File (I/Q recording) | `file=FILENAME,freq=CENTER_FREQ,rate=SAMPLE_RATE` |

For most users with an RTL-SDR: `rtl=0`

### Audio Device

- Select your audio output device (typically `pulseaudio` or `default` on Linux).
- If no audio output, check that PulseAudio or PipeWire is running.

### Sample Rate

- RTL-SDR: Use **2400000** (2.4 MSPS) for maximum bandwidth, or **1024000** (1.024 MSPS) for lower CPU usage.
- The sample rate determines how much spectrum bandwidth you can see at once.

### Input Rate and Decimation

- **Input rate**: The sample rate from the device.
- **Decimation**: Reduces the effective bandwidth and sample rate. None = full bandwidth. 2x, 4x, etc. reduce it. Can help with CPU load.

Click **OK** to apply settings.

---

## User Interface

### Main Window Layout

```
┌─────────────────────────────────────┐
│  Frequency [  145.520.000 ]  [▶]   │  ← Frequency entry, Play/Stop
├─────────────────────────────────────┤
│                                     │
│         Spectrum (FFT)              │
│                                     │
├─────────────────────────────────────┤
│                                     │
│         Waterfall                   │
│                                     │
├──────────┬──────────────────────────┤
│ Receiver │                          │
│ settings │      (Side panels)       │
│          │                          │
└──────────┴──────────────────────────┘
```

### Spectrum and Waterfall

- **Spectrum (top)**: Real-time signal strength vs frequency. Click to tune.
- **Waterfall (bottom)**: Time history of signals. Color intensity = signal strength.
- Adjust the split between spectrum and waterfall by dragging the divider.

---

## Tuning

### Setting Frequency

- **Click on the frequency display** at the top and type a new frequency.
- **Mouse wheel** over a digit in the frequency display to increment/decrement.
- **Click on the spectrum or waterfall** to tune.
- **Keyboard**: Type the frequency in the input box.

### LNB LO (Local Oscillator Offset)

If using a downconverter (e.g., Ham-It-Up for HF), set the LO frequency:
- **Input > LNB LO**: Enter the converter's local oscillator frequency.
- The displayed frequency will be corrected accordingly.

---

## Demodulation Modes

Select the mode in the **Receiver Options** panel (bottom-left).

| Mode | Description | Filter Width |
|------|-------------|-------------|
| **WFM (Mono)** | Wideband FM mono | 200 kHz |
| **WFM (Stereo)** | Wideband FM stereo | 200 kHz |
| **NFM** | Narrowband FM | ~10-15 kHz |
| **AM** | Amplitude Modulation | ~10 kHz |
| **USB** | Upper Sideband | ~2.4 kHz |
| **LSB** | Lower Sideband | ~2.4 kHz |
| **CW-L** | CW (lower tone) | ~500 Hz |
| **CW-U** | CW (upper tone) | ~500 Hz |
| **Raw I/Q** | Passthrough | Full BW |

### Filter Width

Adjust the filter bandwidth using the slider or by typing a value. The filter is visible as the highlighted region on the spectrum display.

### Squelch

Adjust the squelch threshold with the **Squelch** slider. Signals below this level will be muted. Set just above the noise floor for NFM/AM voice monitoring.

---

## Gain Control

### Setting Gain

Go to **Input Controls** (wrench/gear icon, or the Input tab):

- **LNA Gain**: The main RF gain (for RTL-SDR, this is the tuner gain).
- **Hardware AGC**: Enable/disable automatic gain.
- For RTL-SDR: a single gain slider appears. Manual gain is generally better than AGC.

### Gain Tips

- Start with gain around 30-35 dB.
- Increase if signals are too weak.
- Decrease if you see spurious signals or the noise floor is uneven (overloading).
- For ADS-B and similar applications, maximum gain is often appropriate.
- For strong local signals (FM broadcast), use lower gain to avoid overload.

---

## FFT Settings

Adjust the FFT display under the **FFT Settings** section:

| Setting | Description |
|---------|-------------|
| **FFT Size** | Number of FFT bins (1024, 2048, 4096, 8192). Higher = more frequency resolution, more CPU. |
| **Rate** | FFT update rate (frames per second). Lower = less CPU. |
| **Window** | FFT windowing function (Hamming, Hann, Blackman-Harris, etc.). Blackman-Harris is a good default. |
| **Averaging** | Smooths the spectrum display. Higher = smoother but slower response to changing signals. |
| **Waterfall mode** | Color scheme and scale for the waterfall display. |

---

## Recording

### Audio Recording

1. Click the **Record** button (red circle) in the toolbar, or go to **Tools > Audio Recording**.
2. Audio is saved as a WAV file.
3. Configure the output directory in **Tools > Audio Recording > Settings**.

### I/Q Recording

1. Go to **Tools > I/Q Recording**.
2. Click **Rec** to start recording raw I/Q data.
3. Files are large. At 2.4 MSPS, expect about 9.6 MB per second.
4. I/Q recordings can be replayed later by selecting a file source in the device settings.

---

## Remote Control via TCP

GQRX has a remote control interface that allows other programs to control tuning and settings via TCP.

### Enable Remote Control

1. Go to **Tools > Remote Control** (or **Tools > Remote control settings**).
2. Default port: **7356**.
3. Click **Enable**.

### Connecting

Programs that support GQRX remote control (e.g., Gpredict for satellite tracking) connect to `localhost:7356`.

### Protocol

The remote control uses a simple text protocol compatible with Hamlib's `rigctld`:

```
# Set frequency to 145.520 MHz
F 145520000

# Get current frequency
f

# Set mode
M NFM 12500

# Get signal strength
l STRENGTH
```

Useful for automated scanning, satellite Doppler correction, and integration with other tools.

---

## Bookmarks

GQRX supports frequency bookmarks:

1. **Tools > Bookmarks** to open the bookmark manager.
2. Click **Add** to bookmark the current frequency and mode.
3. Enter a name, tags, and notes.
4. Double-click a bookmark to tune to it.
5. Bookmarks are stored in `~/.config/gqrx/bookmarks.csv`.

You can edit the bookmarks file directly with a text editor:
```
# Tag name; Frequency; Name; Modulation; Bandwidth
HAM;146520000;2m Calling;NFM;12500
NOAA;162550000;NOAA WX1;NFM;15000
```

---

## Common Tasks

### Monitor 2-Meter Ham Band

1. Set frequency to 146.520 MHz (national calling).
2. Mode: NFM.
3. Filter: 12500 Hz.
4. Squelch: Adjust just above noise.
5. Gain: 30-35 dB.

### Listen to FM Broadcast

1. Set frequency to a local FM station (e.g., 101.1 MHz).
2. Mode: WFM (Stereo).
3. Gain: 20-25 dB (strong signals, avoid overload).

### Monitor Aircraft

1. Set frequency to 118-137 MHz range.
2. Mode: AM.
3. Filter: 8000 Hz.
4. Squelch: Light squelch.
5. Gain: 35 dB.

---

## Troubleshooting

### No Audio Output

- Check audio device selection in the configure dialog (Edit > I/O Devices).
- Make sure PulseAudio/PipeWire is running.
- Check system volume and output device.
- Try `pulseaudio --start` if PulseAudio is not running.

### "No input device found"

- Ensure RTL-SDR drivers are installed and DVB-T modules are blacklisted.
- Verify with `rtl_test -t`.
- Check device string (should be `rtl=0`).
- Check permissions (udev rules or run with sudo to test).

### High CPU Usage

- Reduce FFT size (try 2048 or 1024).
- Reduce FFT rate.
- Reduce sample rate.
- Enable decimation.
- Close the waterfall if not needed (does not apply to GQRX easily, but reducing FFT rate helps).

### DC Spike in Center

Normal for RTL-SDR. Tune slightly off-center so the spike doesn't overlap your signal. Some DSP settings can reduce it, but a small offset is the simplest solution.
