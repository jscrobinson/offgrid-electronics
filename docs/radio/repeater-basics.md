# Repeater Basics

## What Is a Repeater?

A repeater is an automated radio station, usually located at a high point (hilltop, tall building, tower), that receives signals on one frequency and simultaneously retransmits them on another frequency. This extends the communication range of low-power portable and mobile radios from a few miles to potentially 50-100+ miles.

### How It Works

1. Your radio transmits on the repeater's **input** (receive) frequency.
2. The repeater receives your signal.
3. The repeater instantly retransmits your signal on its **output** (transmit) frequency at higher power and from a better location.
4. Other stations hear the repeater's output.

```
Your HT (5W)  ──→  Repeater (hilltop, 50-100W)  ──→  Other stations
 462.600 TX         RX: 462.600 / TX: 467.600          RX: 467.600
                    (Receives, then retransmits)
```

The repeater uses two different frequencies so it can receive and transmit at the same time. This is called **duplex** operation.

---

## Offset (Frequency Shift)

The **offset** is the difference between the repeater's output (receive) frequency and its input (transmit) frequency. When you program a repeater into your radio:
- You set the **receive frequency** to the repeater's output.
- The radio automatically calculates your **transmit frequency** by adding or subtracting the offset.

### Standard Offsets by Band

| Band | Offset | Direction |
|------|--------|-----------|
| **6 meters** (50-54 MHz) | 1 MHz | Minus (-) typical |
| **2 meters** (144-148 MHz) | 600 kHz (0.6 MHz) | Plus (+) or Minus (-) varies |
| **1.25 meters** (222-225 MHz) | 1.6 MHz | Minus (-) typical |
| **70 centimeters** (420-450 MHz) | 5 MHz | Plus (+) or Minus (-) varies |
| **GMRS** (462/467 MHz) | 5 MHz | Plus (+) |

### 2-Meter Offset Convention (US)

The direction of the offset typically follows these rules:
- **Repeater output below 147 MHz**: Offset is **negative (-)** — your radio transmits 600 kHz below the repeater output.
  - Example: Repeater output 146.940, your TX = 146.340
- **Repeater output at/above 147 MHz**: Offset is **positive (+)** — your radio transmits 600 kHz above the repeater output.
  - Example: Repeater output 147.060, your TX = 147.660

**Exceptions exist.** Always verify the offset for a specific repeater in a repeater directory (RepeaterBook, etc.).

### 70-Centimeter Offset Convention (US)

Standard offset is 5 MHz. Direction varies by region and specific repeater. Check a repeater directory.
- Example: Repeater output 443.200, offset +5 MHz, your TX = 448.200.
- Example: Repeater output 447.000, offset -5 MHz, your TX = 442.000.

---

## CTCSS / PL Tones

Most repeaters require you to transmit a sub-audible tone along with your voice to activate (key up) the repeater. Without the correct tone, the repeater ignores your signal.

### CTCSS (Continuous Tone-Coded Squelch System)

Also known as **PL tone** (Private Line, a Motorola trademark).

- A continuous low-frequency tone (67.0 - 254.1 Hz) transmitted below the audible voice range.
- You cannot hear it, but the repeater's receiver detects it.
- The repeater only opens when it hears both a signal on its input frequency AND the correct CTCSS tone.

### Common CTCSS Tone Frequencies

67.0, 69.3, 71.9, 74.4, 77.0, 79.7, 82.5, 85.4, 88.5, 91.5, 94.8, 97.4, 100.0, 103.5, 107.2, 110.9, 114.8, 118.8, 123.0, 127.3, 131.8, 136.5, 141.3, 146.2, 151.4, 156.7, 162.2, 167.9, 173.8, 179.9, 186.2, 192.8, 203.5, 210.7, 218.1, 225.7, 229.1, 233.6, 241.8, 250.3, 254.1

### DCS (Digital Coded Squelch)

Similar purpose to CTCSS but uses a continuous digital code instead of an analog tone.
- Also called **DPL** (Digital Private Line, Motorola trademark).
- Codes are three-digit numbers (e.g., D023N, D754I). The N or I indicates normal or inverted polarity.
- Less common than CTCSS but used on some repeaters.

### Programming Tones

When programming a repeater into your radio:

1. **Tone Mode: "Tone"** = You transmit the CTCSS tone; receive squelch is carrier-only. This is the most common setting.
2. **Tone Mode: "TSQL"** = You transmit AND receive with CTCSS. You will only hear signals that have the matching tone. Useful for filtering, but you might miss transmissions.
3. **Tone Mode: "DTCS"** = Using DCS code instead of CTCSS.

Most repeater directories list the required tone. If not listed, the repeater may not require one (carrier access).

---

## Repeater Courtesy

### Basic Etiquette

1. **Listen before you transmit.** Make sure the frequency is clear and no one else is in mid-conversation.
2. **Identify with your callsign.** Required by law at the beginning and end of a contact, and every 10 minutes.
3. **Pause between transmissions.** Leave a 1-2 second gap after each transmission before someone else keys up. This allows:
   - The repeater's timer to reset
   - Other stations to break in
   - The repeater to drop and re-key its transmitter
4. **Keep transmissions short** during busy times.
5. **Use simplex when possible.** If you can reach the other station directly, move to a simplex frequency and free up the repeater.
6. **Don't "kerchunk" the repeater** (keying up without identifying). This is illegal — all transmissions must be identified.
7. **Yield to emergency traffic.** If someone calls an emergency, stop your conversation immediately.
8. **Say "break" or "break break"** if you need to interrupt a conversation for an emergency or urgent matter.

### Making a Call on a Repeater

**To call a specific station:**
```
"W1ABC, this is K2XYZ."
```

**To make a general call (looking for anyone to talk to):**
```
"This is K2XYZ, listening."
```
or
```
"K2XYZ, monitoring."
```

### Using the Repeater's Timer

Most repeaters have a **timeout timer** (typically 3-5 minutes). If you transmit continuously for longer than this, the repeater will stop retransmitting and may send a warning tone. This prevents:
- Accidental long transmissions (stuck PTT button)
- Single stations from monopolizing the repeater

The repeater timer resets each time the repeater drops and re-keys. This is why you should pause between transmissions.

---

## Autopatch

Some repeaters have an **autopatch** feature that allows you to make telephone calls through the repeater. This was much more common before cell phones but some repeaters still have it.

- Typically activated by a DTMF code sequence (pressing keys on your radio's keypad).
- The repeater connects to a phone line and dials the number.
- **Remember**: Your half of the conversation is broadcast on the repeater frequency. No privacy.
- Phone patches should be brief and only for non-sensitive calls.
- Not all repeaters have autopatch, and many that do restrict access to club members.

---

## Linked Repeater Systems

### What Is Linking?

Multiple repeaters can be connected together so that a transmission on one repeater is heard on all linked repeaters. This extends coverage over very large areas.

### Linking Methods

1. **Internet linking (IRLP, EchoLink, AllStar)**:
   - Repeaters connected via the internet.
   - **IRLP**: Internet Radio Linking Project. Uses dedicated nodes.
   - **EchoLink**: Allows direct connection from a computer or smartphone app to a repeater/node.
   - **AllStar**: Open-source linking system based on Asterisk (PBX software). Growing in popularity.

2. **RF linking**: Repeaters linked via dedicated radio links (usually on different frequencies than the user-facing frequencies).

3. **Permanent vs. on-demand linking**: Some systems are permanently linked; others can be connected on demand using DTMF commands.

---

## Cross-Band Repeat

A feature in some mobile radios (not repeaters per se, but related) that allows the radio to receive on one band and retransmit on another. This effectively creates a personal low-power repeater.

### Example Use Case

Your mobile radio is in the car on a hilltop. You're hiking with an HT (handheld) on UHF:
- HT transmits on UHF → mobile radio receives on UHF
- Mobile radio retransmits on VHF → distant station hears you on VHF
- Reverse path for receiving

### Radios with Cross-Band Repeat

- Yaesu FT-8900R, FT-8800R
- Kenwood TM-V71A
- Some Baofeng mobile radios (limited capability)
- Icom IC-2730A

### Considerations

- **Legal**: You must identify on both frequencies. Some radios can be programmed to send your callsign periodically (required every 10 minutes).
- **Power consumption**: The radio is transmitting frequently. It will drain a car battery if the engine is off.
- **Heat**: Continuous or frequent retransmission generates heat. Ensure good ventilation.
- **Duty cycle**: The radio was not designed to operate at 100% duty cycle. Use lower power settings.

---

## Programming a Repeater into Your Radio

### Information You Need

For each repeater, you need:
1. **Output frequency** (what you program as your receive frequency)
2. **Offset direction** (+ or -)
3. **Offset amount** (0.6 MHz for 2m, 5 MHz for 70cm)
4. **CTCSS/PL tone** (or DCS code)

### Example: Programming a 2-Meter Repeater

Repeater info: Output 147.060, Input 147.660, PL tone 100.0 Hz

**On a Baofeng UV-5R (Manual Method)**:
1. Enter VFO mode. Enter frequency: 147.060
2. Menu 25 (SFT-D) → set to "+"
3. Menu 26 (OFFSET) → set to 00.600
4. Menu 13 (T-CTCS) → set to 100.0
5. Menu 27 (MEM-CH) → save to a channel number

**In CHIRP**:
| Field | Value |
|-------|-------|
| Frequency | 147.060000 |
| Duplex | + |
| Offset | 0.600000 |
| Tone | Tone |
| rToneFreq | 100.0 |
| Mode | NFM |

### Finding Repeaters

- **RepeaterBook** (www.repeaterbook.com): Free, comprehensive database of repeaters. Searchable by location, band, features.
- **ARRL Repeater Directory**: Published annually, available in print and digital.
- **RFinder**: Online/app repeater database (some features paid).
- **Local ham club websites**: Often list local repeaters with current status and tone information.
- **QRZ.com**: Some repeater information in user profiles.

### Testing a Repeater

1. Program the repeater into your radio.
2. Listen to verify you can hear the repeater (wait for activity, or listen for the repeater's periodic ID).
3. Key up and announce: "[Your callsign], testing."
4. If the repeater keys up (you hear the squelch tail drop or a courtesy tone), you are accessing it successfully.
5. If no response: check your tone, offset, and make sure you're in range.

---

## Repeater Troubleshooting

| Problem | Possible Cause | Solution |
|---------|---------------|----------|
| Can hear repeater but can't access it | Wrong CTCSS tone | Verify tone in repeater directory |
| Can hear repeater but can't access it | Wrong offset direction | Verify + or - offset |
| Can hear repeater but can't access it | Offset amount wrong | Verify 0.6 MHz (2m) or 5 MHz (70cm) |
| Can hear repeater but can't access it | Too far away / terrain blocking | Increase power, improve antenna, try different location |
| Repeater times out | Transmitting too long | Keep transmissions under 2-3 minutes. Pause to let timer reset. |
| Hear other stations but not through repeater | You may be hearing simplex signals, not the repeater | Check that you're on the repeater output frequency |
| Repeater keys up but no audio heard | Your audio is not making it through | Check microphone, volume, modulation level |
| Intermittent access | Marginal signal strength | Try higher power, better antenna, or better location |
