# GNU Radio Basics

## What Is GNU Radio?

GNU Radio is a free, open-source **signal processing framework** for implementing software-defined radios. Unlike SDR# or GQRX (which are end-user applications), GNU Radio is a toolkit for building your own radio systems by connecting signal processing blocks together.

It includes:
- **GNU Radio Companion (GRC)**: A visual flowgraph editor where you drag-and-drop blocks and connect them.
- **Hundreds of signal processing blocks**: Filters, demodulators, decoders, signal sources, audio sinks, file sinks, etc.
- **Python and C++ APIs**: For writing custom blocks and automated scripts.

GNU Radio is used in education, research, amateur radio, and industry. It is powerful but has a steeper learning curve than applications like SDR#.

---

## Installation

### Ubuntu / Debian

```bash
sudo apt install gnuradio gnuradio-dev gr-osmosdr
```

`gr-osmosdr` provides the RTL-SDR source block (and support for many other SDR devices).

### Fedora

```bash
sudo dnf install gnuradio gnuradio-devel gr-osmosdr
```

### Arch Linux

```bash
sudo pacman -S gnuradio gnuradio-companion gr-osmosdr
```

### macOS (Homebrew)

```bash
brew install gnuradio
```

### Windows

GNU Radio on Windows is available via:
- **Conda/Mamba**: The recommended method.
  ```
  conda install -c conda-forge gnuradio
  ```
- **Radioconda**: A pre-built Conda distribution with GNU Radio and common SDR tools. Download from https://github.com/ryanvolz/radioconda
- Older binary installers exist but are often outdated.

### Verify Installation

```bash
gnuradio-companion
```

This should open the GNU Radio Companion visual editor.

---

## GNU Radio Companion (GRC) Overview

GRC is the visual editor. You build signal processing **flowgraphs** by placing blocks on a canvas and connecting their ports.

### Interface

```
┌──────────┬────────────────────────────┐
│          │                            │
│  Block   │     Canvas (Flowgraph)     │
│  Library │                            │
│  (left)  │   [Source] → [Filter] →    │
│          │   [Demod] → [Audio Sink]   │
│          │                            │
├──────────┴────────────────────────────┤
│  Console / Log Output (bottom)        │
└───────────────────────────────────────┘
```

### Basic Workflow

1. **Find blocks** in the library panel (left side). Use the search box.
2. **Drag blocks** onto the canvas.
3. **Connect blocks** by clicking an output port and dragging to an input port. Port colors indicate data types:
   - **Blue**: Complex float (I/Q data)
   - **Orange**: Float (real-valued)
   - **Green**: Integer
   - **Yellow**: Short
   - **Magenta**: Byte
4. **Configure blocks** by double-clicking to open their properties dialog.
5. **Run the flowgraph** by clicking the Play button (or pressing F6).
6. **Stop** with the Stop button (or F7).

### Important Concepts

- **Sample rate**: All blocks in a flowgraph must be consistent about the sample rate. The `samp_rate` variable (created by default) sets this globally.
- **Data types**: Blocks must have matching types at their connection points. A complex source cannot directly feed a float input without a conversion block.
- **Throttle**: If using simulated sources (not hardware), include a **Throttle** block to prevent the CPU from running at 100%.
- **Variables**: Use **Variable** blocks to define reusable parameters (sample rate, center frequency, etc.).

---

## Building a Simple FM Receiver

This example receives wideband FM broadcast radio using an RTL-SDR.

### Blocks Needed

1. **RTL-SDR Source** (`osmocom Source` or `RTL-SDR Source`)
2. **Low Pass Filter**
3. **WBFM Receive** (Wideband FM Demodulator)
4. **Rational Resampler** (to convert sample rate for audio)
5. **Audio Sink** (plays through speakers)
6. **Variable** blocks for parameters

### Step-by-Step

#### 1. Create Variables

Add these **Variable** blocks:

| Variable | Value | Notes |
|----------|-------|-------|
| `samp_rate` | 2400000 | 2.4 MSPS from RTL-SDR |
| `center_freq` | 101100000 | 101.1 MHz (change to a local FM station) |
| `audio_rate` | 48000 | Standard audio sample rate |
| `fm_demod_rate` | 480000 | Intermediate rate after decimation |

#### 2. Add RTL-SDR Source (osmocom Source)

- Search for "osmocom" or "RTL-SDR Source" in the block library.
- Properties:
  - **Device Arguments**: `rtl=0`
  - **Sample Rate**: `samp_rate`
  - **Center Freq**: `center_freq`
  - **RF Gain**: `30` (adjust as needed)
  - **IF Gain**: `0`
  - **BB Gain**: `0`

Output type: Complex

#### 3. Add Low Pass Filter

- Search for "Low Pass Filter."
- Properties:
  - **Decimation**: `int(samp_rate / fm_demod_rate)` = 5 (2400000 / 480000)
  - **Sample Rate**: `samp_rate`
  - **Cutoff Freq**: `100000` (100 kHz, FM broadcast signal bandwidth)
  - **Transition Width**: `10000` (10 kHz)
  - **Window**: Hamming
- Input: Complex from RTL-SDR Source
- Output: Complex at 480000 S/s

#### 4. Add WBFM Receive

- Search for "WBFM Receive" or "WBFM Demod."
- Properties:
  - **Quadrature Rate**: `fm_demod_rate` = 480000
  - **Audio Decimation**: `int(fm_demod_rate / audio_rate)` = 10
- Input: Complex from Low Pass Filter
- Output: Float audio at 48000 S/s

#### 5. Add Audio Sink

- Search for "Audio Sink."
- Properties:
  - **Sample Rate**: `audio_rate` = 48000
- Input: Float from WBFM Receive

#### 6. (Optional) Add GUI Elements

- **QT GUI Frequency Sink**: Shows spectrum display. Connect to RTL-SDR Source output (or after filter).
- **QT GUI Waterfall Sink**: Shows waterfall. Similar connection.
- **QT GUI Range** (slider): Create a slider to adjust `center_freq` in real-time. Set the variable's "Generate Options" to "QT GUI."

### Flowgraph Diagram

```
[RTL-SDR Source] → [Low Pass Filter] → [WBFM Receive] → [Audio Sink]
    (complex)        (decimate by 5)     (demod FM)       (speakers)
    2.4 MSPS          480 kSPS           48 kSPS
```

### Run It

1. Click the **Generate** button (or F5) to generate the Python code.
2. Click **Play** (or F6) to run the flowgraph.
3. You should hear FM audio and see the spectrum display (if GUI sinks are included).
4. Press **Stop** (or F7) to stop.

---

## Key Blocks Reference

### Sources

| Block | Description |
|-------|-------------|
| **osmocom Source** | Generic SDR source (RTL-SDR, Airspy, HackRF, etc.) |
| **RTL-SDR Source** | Specific to RTL-SDR (if gr-rtlsdr is installed) |
| **Audio Source** | Microphone / sound card input |
| **File Source** | Read I/Q data from a file |
| **Signal Source** | Generate test signals (sine, square, noise) |

### Filters

| Block | Description |
|-------|-------------|
| **Low Pass Filter** | Remove frequencies above cutoff |
| **Band Pass Filter** | Pass only a range of frequencies |
| **High Pass Filter** | Remove frequencies below cutoff |
| **Rational Resampler** | Change sample rate by a rational ratio (interpolation/decimation) |

### Demodulators

| Block | Description |
|-------|-------------|
| **WBFM Receive** | Wideband FM demodulation (broadcast FM) |
| **NBFM Receive** | Narrowband FM demodulation (two-way radio) |
| **AM Demod** | AM demodulation |
| **Quadrature Demod** | Generic FM demodulator (outputs frequency deviation as float) |

### Sinks (Outputs)

| Block | Description |
|-------|-------------|
| **Audio Sink** | Play audio through speakers |
| **File Sink** | Write data to a file |
| **QT GUI Frequency Sink** | Spectrum display |
| **QT GUI Waterfall Sink** | Waterfall display |
| **QT GUI Time Sink** | Oscilloscope-style time domain display |
| **QT GUI Constellation Sink** | I/Q constellation display |

### Utility

| Block | Description |
|-------|-------------|
| **Throttle** | Rate-limits data flow (needed when no hardware source/sink) |
| **Variable** | Define a named constant |
| **QT GUI Range** | Interactive slider to control a variable |
| **Multiply Const** | Scale a signal (volume control) |
| **Complex to Real** | Extract real part of complex signal |
| **Complex to Mag** | Compute magnitude of complex signal |

---

## Python Generated Code

Every GRC flowgraph generates a Python script. This script can be:
- Run standalone: `python3 my_flowgraph.py`
- Modified by hand for more advanced functionality
- Used as a starting point for automated systems

The generated code uses GNU Radio's Python bindings and can be integrated into larger programs.

### Example: Finding the Generated Script

When you click "Generate" (F5) in GRC, a `.py` file is created in the same directory as the `.grc` file. You can run it directly:

```bash
python3 fm_receiver.py
```

---

## Saving and Loading Flowgraphs

- **File > Save**: Saves as a `.grc` file (XML format).
- **File > Open**: Load an existing `.grc` file.
- Share `.grc` files with others — they can open and run them if they have the same GNU Radio version and out-of-tree modules.
- Many example flowgraphs are available online and in the GNU Radio documentation.

---

## Tips

1. **Start simple.** The FM receiver example above is a great first project. Get it working before adding complexity.
2. **Use Variables for everything configurable.** Frequency, sample rate, gain, filter parameters — all should be variables.
3. **Watch the console output.** Error messages and warnings appear in the bottom panel.
4. **Type mismatches** are the most common error. Make sure connected ports have matching data types and sample rates.
5. **GNU Radio has excellent documentation** at https://wiki.gnuradio.org and a large community.
6. **Out-of-tree (OOT) modules** extend GNU Radio. `gr-osmosdr` for SDR hardware, `gr-satellites` for satellite decoders, `gr-adsb` for ADS-B, etc.
7. **Performance**: GNU Radio can be CPU-intensive. Use appropriate decimation early in the signal chain to reduce the sample rate to only what you need.
