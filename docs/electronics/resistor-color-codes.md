# Resistor Color Codes

## 4-Band Resistor Color Code

Most common for through-hole resistors (1/4W, 1/2W axial).

```
┌──────────────────────────────┐
│  Band1  Band2  Multiplier  Tolerance │
│  ████   ████     ████       ████     │
│  1st    2nd      ×10^n     ±%        │
│  digit  digit                        │
└──────────────────────────────┘
```

Read from the band closest to one end (tolerance band is usually spaced slightly farther from the last band or is metallic gold/silver).

## 5-Band Resistor Color Code

Used for precision resistors (1% tolerance and better).

```
┌────────────────────────────────────┐
│  Band1  Band2  Band3  Multiplier  Tolerance │
│  ████   ████   ████     ████       ████     │
│  1st    2nd    3rd      ×10^n     ±%        │
│  digit  digit  digit                        │
└────────────────────────────────────┘
```

---

## Color Code Table

| Color  | Digit | Multiplier     | Tolerance |
|--------|-------|----------------|-----------|
| Black  | 0     | ×1 (10⁰)      | —         |
| Brown  | 1     | ×10 (10¹)     | ±1%       |
| Red    | 2     | ×100 (10²)    | ±2%       |
| Orange | 3     | ×1k (10³)     | ±0.05%*   |
| Yellow | 4     | ×10k (10⁴)    | ±0.02%*   |
| Green  | 5     | ×100k (10⁵)   | ±0.5%     |
| Blue   | 6     | ×1M (10⁶)     | ±0.25%    |
| Violet | 7     | ×10M (10⁷)    | ±0.1%     |
| Grey   | 8     | ×100M (10⁸)   | ±0.01%*   |
| White  | 9     | ×1G (10⁹)     | —         |
| Gold   | —     | ×0.1           | ±5%       |
| Silver | —     | ×0.01          | ±10%      |
| None   | —     | —              | ±20%      |

*Rarely encountered tolerances.

### Mnemonic

**B**ig **B**rown **R**abbits **O**ften **Y**ield **G**reat **B**ig **V**ocal **G**roans **W**hen **G**rasped **S**lowly

(Black Brown Red Orange Yellow Green Blue Violet Grey White Gold Silver)

---

## 4-Band Reading Examples

### Example 1: Brown Black Red Gold
```
Brown = 1
Black = 0
Red   = ×100
Gold  = ±5%

Value: 10 × 100 = 1,000Ω = 1kΩ ±5%
```

### Example 2: Yellow Violet Orange Gold
```
Yellow = 4
Violet = 7
Orange = ×1,000
Gold   = ±5%

Value: 47 × 1,000 = 47,000Ω = 47kΩ ±5%
```

### Example 3: Red Red Brown Gold
```
Red   = 2
Red   = 2
Brown = ×10
Gold  = ±5%

Value: 22 × 10 = 220Ω ±5%
```

### Example 4: Brown Black Gold Gold
```
Brown = 1
Black = 0
Gold  = ×0.1
Gold  = ±5%

Value: 10 × 0.1 = 1.0Ω ±5%
```

---

## 5-Band Reading Examples

### Example 1: Brown Black Black Brown Brown
```
Brown = 1
Black = 0
Black = 0
Brown = ×10
Brown = ±1%

Value: 100 × 10 = 1,000Ω = 1kΩ ±1%
```

### Example 2: Red Violet Green Black Brown
```
Red   = 2
Violet = 7
Green  = 5
Black  = ×1
Brown  = ±1%

Value: 275 × 1 = 275Ω ±1%
```

### Example 3: Yellow Violet Black Red Brown
```
Yellow = 4
Violet = 7
Black  = 0
Red    = ×100
Brown  = ±1%

Value: 470 × 100 = 47,000Ω = 47kΩ ±1%
```

---

## SMD Resistor Codes

### 3-Digit Code

The first two digits are the significant figures, the third is the multiplier (number of zeros to add).

```
Format: XYZ  →  XY × 10^Z

472 = 47 × 10² = 4,700Ω = 4.7kΩ
103 = 10 × 10³ = 10,000Ω = 10kΩ
220 = 22 × 10⁰ = 22Ω
101 = 10 × 10¹ = 100Ω
4R7 = 4.7Ω       (R indicates decimal point)
R47 = 0.47Ω
```

### 4-Digit Code

Used for higher precision (1% tolerance). First three digits are significant, fourth is multiplier.

```
Format: WXYZ  →  WXY × 10^Z

4702 = 470 × 10² = 47,000Ω = 47kΩ
1001 = 100 × 10¹ = 1,000Ω = 1kΩ
1000 = 100 × 10⁰ = 100Ω
10R0 = 10.0Ω
```

### EIA-96 Code (1% SMD Resistors)

Two digits + one letter. The two digits are a lookup code, the letter is the multiplier.

**Multiplier Letters:**

| Letter | Multiplier |
|--------|-----------|
| Z      | 0.001     |
| Y or R | 0.01      |
| X or S | 0.1       |
| A      | 1         |
| B or H | 10        |
| C      | 100       |
| D      | 1,000     |
| E      | 10,000    |
| F      | 100,000   |

**EIA-96 Code Table:**

| Code | Value | Code | Value | Code | Value | Code | Value |
|------|-------|------|-------|------|-------|------|-------|
| 01   | 100   | 25   | 178   | 49   | 316   | 73   | 562   |
| 02   | 102   | 26   | 182   | 50   | 324   | 74   | 576   |
| 03   | 105   | 27   | 187   | 51   | 332   | 75   | 590   |
| 04   | 107   | 28   | 191   | 52   | 340   | 76   | 604   |
| 05   | 110   | 29   | 196   | 53   | 348   | 77   | 619   |
| 06   | 113   | 30   | 200   | 54   | 357   | 78   | 634   |
| 07   | 115   | 31   | 205   | 55   | 365   | 79   | 649   |
| 08   | 118   | 32   | 210   | 56   | 374   | 80   | 665   |
| 09   | 121   | 33   | 215   | 57   | 383   | 81   | 681   |
| 10   | 124   | 34   | 221   | 58   | 392   | 82   | 698   |
| 11   | 127   | 35   | 226   | 59   | 402   | 83   | 715   |
| 12   | 130   | 36   | 232   | 60   | 412   | 84   | 732   |
| 13   | 133   | 37   | 237   | 61   | 422   | 85   | 750   |
| 14   | 137   | 38   | 243   | 62   | 432   | 86   | 768   |
| 15   | 140   | 39   | 249   | 63   | 442   | 87   | 787   |
| 16   | 143   | 40   | 255   | 64   | 453   | 88   | 806   |
| 17   | 147   | 41   | 261   | 65   | 464   | 89   | 825   |
| 18   | 150   | 42   | 267   | 66   | 475   | 90   | 845   |
| 19   | 154   | 43   | 274   | 67   | 487   | 91   | 866   |
| 20   | 158   | 44   | 280   | 68   | 499   | 92   | 887   |
| 21   | 162   | 45   | 287   | 69   | 511   | 93   | 909   |
| 22   | 165   | 46   | 294   | 70   | 523   | 94   | 931   |
| 23   | 169   | 47   | 301   | 71   | 536   | 95   | 953   |
| 24   | 174   | 48   | 309   | 72   | 549   | 96   | 976   |

**Example:** `68C` → code 68 = 499, multiplier C = ×100 → 49,900Ω = 49.9kΩ

---

## Standard Resistor Value Series

### E12 Series (10% tolerance) — 12 values per decade

```
1.0  1.2  1.5  1.8  2.2  2.7  3.3  3.9  4.7  5.6  6.8  8.2
```

Multiply by 1, 10, 100, 1k, 10k, 100k, 1M for full range.

Common E12 values you'll use constantly:
```
100Ω  220Ω  330Ω  470Ω  1kΩ  2.2kΩ  3.3kΩ  4.7kΩ  10kΩ  47kΩ  100kΩ
```

### E24 Series (5% tolerance) — 24 values per decade

```
1.0  1.1  1.2  1.3  1.5  1.6  1.8  2.0  2.2  2.4  2.7  3.0
3.3  3.6  3.9  4.3  4.7  5.1  5.6  6.2  6.8  7.5  8.2  9.1
```

### E96 Series (1% tolerance) — 96 values per decade

Too many to list, but these are spaced approximately 2% apart. Standard precision resistors come in E96 values.

---

## Reading Tips

### Identifying Band 1

- **Band 1 is closest to one end** of the resistor body
- **Tolerance band** (gold/silver/brown) is usually the last band, slightly farther from Band 3/4
- **Gold and silver are never first** — if you see gold or silver, that's the tolerance end; read from the other side
- 5-band resistors (1% with brown tolerance) can be tricky — the brown tolerance band is usually spaced slightly apart

### Common Pitfalls

- Confusing the direction — always look for gold/silver to identify the tolerance end
- Brown body resistors can hide the brown bands
- Very old or burned resistors may have discolored bands
- When in doubt, **measure with a multimeter** — color codes are just printed identification

### Quick Verification

Keep a multimeter handy. If your color code reading says 4.7kΩ but you measure 47kΩ, you read the multiplier wrong. This is the single most common mistake.

### Common Resistor Values to Recognize on Sight

| Colors (4-band)              | Value    | Common Use                    |
|------------------------------|----------|-------------------------------|
| Brown Black Brown Gold       | 100Ω     | LED current limiter (5V, 20mA)|
| Brown Black Red Gold         | 1kΩ      | General purpose, LED limiter  |
| Brown Black Orange Gold      | 10kΩ     | Pull-up/pull-down resistors   |
| Yellow Violet Red Gold       | 4.7kΩ    | I2C pull-up resistors         |
| Red Red Brown Gold           | 220Ω     | LED current limiter (5V)      |
| Brown Black Yellow Gold      | 100kΩ    | High impedance applications   |
| Brown Black Green Gold       | 1MΩ      | Very high impedance           |
