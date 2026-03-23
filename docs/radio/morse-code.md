# Morse Code Complete Reference

## Character Table

### Letters

| Letter | Morse | Memory Aid |
|--------|-------|------------|
| A | .- | |
| B | -... | |
| C | -.-. | |
| D | -.. | |
| E | . | |
| F | ..-. | |
| G | --. | |
| H | .... | |
| I | .. | |
| J | .--- | |
| K | -.- | |
| L | .-.. | |
| M | -- | |
| N | -. | |
| O | --- | |
| P | .--. | |
| Q | --.- | |
| R | .-. | |
| S | ... | |
| T | - | |
| U | ..- | |
| V | ...- | |
| W | .-- | |
| X | -..- | |
| Y | -.-- | |
| Z | --.. | |

### Numbers

| Number | Morse |
|--------|-------|
| 0 | ----- |
| 1 | .---- |
| 2 | ..--- |
| 3 | ...-- |
| 4 | ....- |
| 5 | ..... |
| 6 | -.... |
| 7 | --... |
| 8 | ---.. |
| 9 | ----. |

### Punctuation

| Character | Morse |
|-----------|-------|
| Period (.) | .-.-.- |
| Comma (,) | --..-- |
| Question mark (?) | ..--.. |
| Apostrophe (') | .----. |
| Exclamation (!) | -.-.-- |
| Slash (/) | -..-. |
| Parenthesis open ( | -.--. |
| Parenthesis close ) | -.--.- |
| Ampersand (&) | .-... |
| Colon (:) | ---... |
| Semicolon (;) | -.-.-. |
| Equals (=) | -...- |
| Plus (+) | .-.-. |
| Hyphen (-) | -....- |
| Underscore (_) | ..--.- |
| Quotation mark (") | .-..-. |
| Dollar sign ($) | ...-..- |
| At sign (@) | .--.-. |

---

## Timing

Morse code timing is based on the length of a **dit** (dot), which is the fundamental unit.

| Element | Duration |
|---------|----------|
| **Dit** (dot, ".") | 1 unit |
| **Dah** (dash, "-") | 3 units |
| Gap between elements (within a character) | 1 unit |
| Gap between characters (within a word) | 3 units |
| Gap between words | 7 units |

### Example: "MORSE"

```
M      O      R      S      E
--     ---    .-.    ...    .
 ^3u^  ^3u^   ^3u^  ^3u^

Within M:  dah (3) + gap (1) + dah (3) = 7 units
Between M and O: 3 units
Within O:  dah (3) + gap (1) + dah (3) + gap (1) + dah (3) = 13 units
Between O and R: 3 units
...and so on
```

### Speed in Words Per Minute (WPM)

The standard reference word is **PARIS** (dit-dah-dah-dit / dah-dit / dah-dit-dah / dit-dit / dit-dit-dit), which with all inter-element and inter-character spacing equals exactly **50 units**.

```
1 WPM = one "PARIS" per minute = 50 units per minute
Dit duration at speed W = 1200 / W milliseconds
```

| Speed (WPM) | Dit Duration (ms) | Dah Duration (ms) |
|-------------|-------------------|--------------------|
| 5 | 240 | 720 |
| 10 | 120 | 360 |
| 13 | 92 | 277 |
| 15 | 80 | 240 |
| 20 | 60 | 180 |
| 25 | 48 | 144 |
| 30 | 40 | 120 |

---

## Prosigns (Procedural Signals)

Prosigns are special multi-character combinations sent without inter-character spacing (run together as one character). They are written with an overline or between angle brackets.

| Prosign | Morse | Meaning |
|---------|-------|---------|
| **AR** | .-.-. | End of message. "I'm done transmitting this message." |
| **AS** | .-... | Wait / Stand by |
| **BK** | -...-.- | Break (used to interrupt or for break-in keying) |
| **BT** | -...- | Break / separator between sections of text (same as equals sign) |
| **CL** | -.-..-..- | Closing station (going off the air) |
| **CT** | -.-.- | Commencing transmission / Attention |
| **HH** | ........ | Error (8 dits). Disregard last word/group, resend. |
| **KN** | -.- -. | Go ahead, specific station only (others stand by) |
| **K** | -.- | Go ahead / Invitation to transmit (any station) |
| **NR** | -. .-. | Number (precedes a message number) |
| **SK** | ...-.- | End of contact / Silent Key. "I'm done, signing off." |
| **SN** | ...-. | Understood / Verified |
| **SOS** | ...---... | International distress signal. Sent as one prosign (no spaces). |

---

## Common Abbreviations

| Abbreviation | Meaning |
|-------------|---------|
| **CQ** | Calling any station ("seek you"). General call to anyone listening. |
| **DE** | From (used between callsigns: "W1ABC DE K2XYZ" = "W1ABC, this is K2XYZ") |
| **RST** | Readability (1-5), Signal Strength (1-9), Tone (1-9). Signal report system. |
| **R** | Received / Roger |
| **73** | Best regards (standard sign-off greeting) |
| **88** | Love and kisses (affectionate sign-off) |
| **OM** | Old Man (friendly term for a male operator) |
| **YL** | Young Lady (any female operator) |
| **XYL** | Ex-Young Lady (wife) |
| **QTH** | Location (see Q-codes) |
| **WX** | Weather |
| **DX** | Long distance |
| **FB** | Fine business (good, great) |
| **HI** | Laughter |
| **ES** | And (&) |
| **UR** | Your / You're |
| **FER** | For |
| **TNX** / **TKS** | Thanks |
| **PSE** | Please |
| **RPT** | Repeat |
| **PWR** | Power |
| **ANT** | Antenna |
| **RIG** | Radio equipment |
| **SIG** | Signal |
| **HR** | Here |
| **HW** | How |
| **CPY** / **CPI** | Copy |
| **AGN** | Again |
| **MSG** | Message |
| **NR** | Number |
| **ABT** | About |
| **GE** | Good evening |
| **GM** | Good morning |
| **GA** | Good afternoon / Go ahead |
| **GN** | Good night |
| **CUL** | See you later |

### RST Signal Reporting System

**R — Readability** (1-5):
1. Unreadable
2. Barely readable, occasional words distinguishable
3. Readable with considerable difficulty
4. Readable with practically no difficulty
5. Perfectly readable

**S — Signal Strength** (1-9):
1. Faint, barely perceptible
2. Very weak
3. Weak
4. Fair
5. Fairly good
6. Good
7. Moderately strong
8. Strong
9. Extremely strong

**T — Tone** (1-9, CW only):
1. Sixty-cycle AC hum, very rough
5. Filtered rectified AC, strongly ripple-modulated
9. Perfect tone, no trace of ripple or modulation

A typical report: "RST 599" = perfectly readable, extremely strong, perfect tone. This is the best possible report.

---

## Standard CQ Call Format

```
CQ CQ CQ DE [your callsign] [your callsign] [your callsign] K
```

Example:
```
CQ CQ CQ DE W1ABC W1ABC W1ABC K
```

### Responding to a CQ

```
[calling station's callsign] DE [your callsign] [your callsign] K
```

Example:
```
W1ABC DE K2XYZ K2XYZ K
```

### Typical Exchange

```
K2XYZ DE W1ABC GE OM TNX FER CALL UR RST 579 579 QTH BOSTON MA NAME JOHN JOHN HW CPY K2XYZ DE W1ABC K

W1ABC DE K2XYZ R GE JOHN TNX FER RPT UR RST 589 589 QTH NEW YORK NY NAME BOB BOB W1ABC DE K2XYZ K

K2XYZ DE W1ABC R TNX BOB FER QSO 73 ES CUL K2XYZ DE W1ABC SK

W1ABC DE K2XYZ R 73 OM W1ABC DE K2XYZ SK
```

---

## Learning Methods

### Koch Method

Developed by psychologist Ludwig Koch. Considered one of the most effective methods.

1. Start by learning just TWO characters at full target speed (e.g., 20 WPM character speed).
2. Practice copying until you achieve 90% accuracy.
3. Add ONE new character.
4. Practice until 90% accuracy with all characters learned so far.
5. Repeat until all characters are learned.

The key insight: learn characters at full speed from the start. Slow Morse builds wrong habits because the "rhythm" of characters changes at different speeds.

Recommended character introduction order (Koch): K, M, R, S, U, A, P, T, L, O, W, I, ., N, J, E, F, 0, Y, V, ,, G, 5, /, Q, 9, Z, H, 3, 8, B, ?, 4, 2, 7, C, 1, D, 6, X, =, +

### Farnsworth Spacing

A modification that helps beginners:
- Send individual characters at a fast speed (e.g., 18-20 WPM).
- But increase the spacing between characters and words to bring the effective speed down (e.g., 10 WPM overall).
- As proficiency improves, gradually decrease the extra spacing until character and word spacing match the character speed.

This helps you learn the "sound" of each character as a complete unit rather than counting individual dits and dahs.

### Practice Resources

- **LCWO.net**: Free online Koch method trainer. Highly recommended.
- **Just Learn Morse Code**: Windows software. Koch and Farnsworth methods.
- **Morse Trainer apps**: Available for iOS and Android.
- **On-air practice**: Listen to real CW QSOs on the amateur bands (lower portions of each band).
- **CW practice nets**: Many local ham clubs run slow-speed CW practice nets.
- **W1AW practice transmissions**: ARRL broadcasts practice sessions at various speeds.

### Tips

1. **Practice daily**, even if only 10-15 minutes. Consistency matters more than duration.
2. **Learn by sound, not by sight.** Do not stare at a chart while copying. Learn the rhythm of each character.
3. **Do not count dits and dahs.** This is the number one mistake. Each character should be recognized as a complete sound pattern, like recognizing a spoken word.
4. **Copy behind**: Try to write down characters one or two behind what you're hearing. This builds the ability to hold characters in short-term memory while writing.
5. **Start with head copy**: Eventually, try to copy in your head without writing. This is the end goal for conversational CW.
6. **Use a straight key first**, then move to a paddle/keyer once you're comfortable with the code.
7. **Set a realistic speed goal**: 13 WPM is enough for comfortable on-air CW conversations. 20 WPM is a good intermediate goal. Contest operators work at 30-40+ WPM.

---

## Emergency Signal: SOS

```
...---...
```

- Three dits, three dahs, three dits — sent as a single prosign with no spacing between S-O-S.
- Internationally recognized distress signal.
- Can be transmitted by any means: radio, flashlight, sound, tapping.
- On radio, send on the calling frequency or emergency frequency and include your position if possible.
- The visual equivalent is flashing a light: three short, three long, three short.
