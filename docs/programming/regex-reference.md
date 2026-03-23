# Regex Quick Reference

Regular expressions for pattern matching in text. This covers the syntax common across most engines (PCRE, Python, JavaScript, grep, sed) with tool-specific notes.

---

## Character Classes

```
.          Any character (except newline, unless /s flag)
\d         Digit [0-9]
\D         Non-digit [^0-9]
\w         Word character [a-zA-Z0-9_]
\W         Non-word character [^a-zA-Z0-9_]
\s         Whitespace [ \t\n\r\f\v]
\S         Non-whitespace
\t         Tab
\n         Newline
\r         Carriage return
\\         Literal backslash
\.         Literal dot (escape any special char with \)
```

### Custom Character Classes

```
[abc]      a, b, or c
[a-z]      lowercase letter
[A-Z]      uppercase letter
[0-9]      digit (same as \d)
[a-zA-Z]   any letter
[a-zA-Z0-9]  alphanumeric
[^abc]     NOT a, b, or c (negation)
[^0-9]     non-digit
[-]        literal hyphen (at start/end of class)
[\[\]]     literal square brackets (escaped)
```

---

## Quantifiers

```
*          Zero or more        a*     → "", "a", "aa", "aaa", ...
+          One or more         a+     → "a", "aa", "aaa", ...
?          Zero or one         a?     → "", "a"
{n}        Exactly n           a{3}   → "aaa"
{n,}       n or more           a{2,}  → "aa", "aaa", "aaaa", ...
{n,m}      Between n and m     a{2,4} → "aa", "aaa", "aaaa"
```

### Greedy vs Lazy

By default, quantifiers are **greedy** (match as much as possible). Add `?` to make them **lazy** (match as little as possible):

```
.*         Greedy: match as much as possible
.*?        Lazy: match as little as possible
.+?        Lazy one-or-more
.??        Lazy zero-or-one

Example with "Hello World":
  ".*o"   matches "Hello Wo"  (greedy, goes to last 'o')
  ".*?o"  matches "Hello"     (lazy, stops at first 'o')

Practical example — matching HTML tags:
  <.*>     matches "<b>bold</b>"  (greedy, everything between first < and last >)
  <.*?>    matches "<b>"          (lazy, first complete tag)
```

---

## Anchors

```
^          Start of string (or start of line with /m flag)
$          End of string (or end of line with /m flag)
\b         Word boundary (between \w and \W)
\B         Non-word boundary
\A         Start of string (always, even with /m)
\Z         End of string (always, even with /m)
```

Examples:
```
^Hello       String must start with "Hello"
world$       String must end with "world"
^exact$      String must be exactly "exact"
\bword\b     Whole word "word" (not "sword" or "wordy")
\bpre        Word starting with "pre"
ing\b        Word ending with "ing"
```

---

## Groups and Captures

```
(abc)        Capturing group — matches "abc" and captures it
(?:abc)      Non-capturing group — matches "abc" but doesn't capture
(?P<name>abc)  Named group (Python) — captured as "name"
(?<name>abc)   Named group (JavaScript, .NET, Java)
\1           Backreference to group 1
\2           Backreference to group 2
$1           Replacement reference to group 1 (in replacement strings)
```

### Backreferences

```
(abc)\1        Matches "abcabc" (repeated capture)
(\w+)\s+\1    Matches repeated words: "the the", "is is"
(['"])(.*?)\1  Matches quoted strings with matching quotes
```

### Alternation

```
cat|dog        Matches "cat" or "dog"
(cat|dog)      Same, but captures which one matched
(?:cat|dog)    Same, without capturing
^(http|https|ftp)://   URL protocols
```

---

## Lookahead and Lookbehind

Zero-width assertions: they check a condition but don't consume characters.

```
(?=...)      Positive lookahead  — followed by ...
(?!...)      Negative lookahead  — NOT followed by ...
(?<=...)     Positive lookbehind — preceded by ...
(?<!...)     Negative lookbehind — NOT preceded by ...
```

Examples:
```
\d+(?= dollars)     Match digits followed by " dollars" (doesn't include " dollars")
                     "100 dollars" → matches "100"

\d+(?! dollars)      Match digits NOT followed by " dollars"

(?<=\$)\d+           Match digits preceded by "$"
                     "$50" → matches "50"

(?<!\$)\d+           Match digits NOT preceded by "$"

# Password validation (must contain uppercase, lowercase, digit, 8+ chars):
^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$

# Match word not preceded by another word:
(?<!\w)word          Same as \bword
```

**Lookbehind limitations:** In many engines (JavaScript, Python), lookbehind must be fixed-length. You cannot use `*` or `+` inside lookbehind (but `{n}` is OK). Python 3.6+ allows variable-length lookbehind in some cases.

---

## Flags / Modifiers

```
i    Case-insensitive    /hello/i matches "Hello", "HELLO", etc.
g    Global              Match all occurrences, not just first
m    Multiline           ^ and $ match start/end of each line
s    Dotall/Single-line  . matches newline too
x    Extended/Verbose    Ignore whitespace, allow comments
u    Unicode             Full Unicode support
```

Usage varies by tool:
```python
# Python
re.search(r"pattern", text, re.IGNORECASE | re.MULTILINE)
re.search(r"pattern", text, re.I | re.M)  # short form

# JavaScript
/pattern/gi
new RegExp("pattern", "gi")

# grep
grep -i "pattern"     # case-insensitive
grep -E "pattern"     # extended regex (ERE)
grep -P "pattern"     # Perl-compatible regex (PCRE)
```

---

## Common Patterns

### Email Address (simplified)

```
[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}
```

### IPv4 Address

```
\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b

# Stricter (valid range 0-255):
\b(?:(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\b
```

### IPv6 Address (simplified)

```
(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}
```

### URL

```
https?://[^\s/$.?#].[^\s]*

# More complete:
https?://(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&/=]*)
```

### Hex Color

```
#(?:[0-9a-fA-F]{3}){1,2}\b

# Matches: #FFF, #ffffff, #a1b2c3
```

### Phone Number (US)

```
(?:\+?1[-.\s]?)?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}

# Matches: 555-123-4567, (555) 123-4567, +1 555.123.4567
```

### Date (YYYY-MM-DD)

```
\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])
```

### Time (HH:MM:SS, 24-hour)

```
(?:[01]\d|2[0-3]):[0-5]\d(?::[0-5]\d)?
```

### MAC Address

```
(?:[0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}
```

### Whitespace Cleanup

```
^\s+         Leading whitespace
\s+$         Trailing whitespace
\s+          Multiple whitespace (replace with single space)
^\s*\n       Blank lines
```

### Log Parsing

```
# Apache/Nginx access log
^(\S+) \S+ \S+ \[([^\]]+)\] "(\S+) (\S+) \S+" (\d{3}) (\d+)

# Syslog
^(\w{3}\s+\d+\s[\d:]+)\s(\S+)\s(\S+?)(?:\[\d+\])?:\s(.*)$

# Key=Value pairs
(\w+)=("[^"]*"|\S+)
```

---

## Tool-Specific Notes

### grep

```bash
# Basic regex (BRE) — default
grep "pattern" file.txt
# Need to escape: ( ) { } + ? |
grep "ab\(c\|d\)" file.txt

# Extended regex (ERE) — recommended
grep -E "pattern" file.txt
# or: egrep "pattern" file.txt
grep -E "ab(c|d)+" file.txt

# Perl-compatible regex (PCRE) — most powerful
grep -P "pattern" file.txt
grep -P "\d+\.\d+" file.txt      # \d works with -P
grep -P "(?<=price: )\d+" file.txt  # lookbehind

# Useful flags
grep -i "pattern"      # case-insensitive
grep -r "pattern" dir/ # recursive
grep -n "pattern"      # show line numbers
grep -c "pattern"      # count matches
grep -l "pattern"      # show filenames only
grep -v "pattern"      # invert (non-matching lines)
grep -w "word"         # whole word match
grep -o "pattern"      # show only matching part
grep -A 3 "pattern"   # show 3 lines after match
grep -B 3 "pattern"   # show 3 lines before match
grep -C 3 "pattern"   # show 3 lines around match
```

### sed

```bash
# sed uses BRE by default, -E for ERE
# Substitution: s/pattern/replacement/flags

sed 's/old/new/' file           # replace first per line
sed 's/old/new/g' file          # replace all
sed 's/old/new/gi' file         # case-insensitive (GNU sed)
sed -E 's/([0-9]+)/[\1]/g'     # ERE with capture group
sed 's/^#.*//' file             # remove comments
sed '/^$/d' file                # delete blank lines
sed -n '10,20p' file            # print lines 10-20
sed -i 's/old/new/g' file      # edit in-place (GNU)
sed -i '' 's/old/new/g' file   # edit in-place (macOS)

# Capture groups in replacement
sed -E 's/(\w+), (\w+)/\2 \1/' # "Smith, John" → "John Smith"

# & means the full match in replacement
sed 's/[0-9]*/(&)/' file       # "123" → "(123)"
```

### Python re Module

```python
import re

# Functions
re.search(r"pattern", text)      # first match anywhere
re.match(r"pattern", text)       # match at start only
re.fullmatch(r"pattern", text)   # match entire string
re.findall(r"pattern", text)     # all matches as list
re.finditer(r"pattern", text)    # all matches as iterator
re.sub(r"pattern", "repl", text) # replace
re.split(r"pattern", text)       # split

# Always use raw strings r"..." for patterns

# Named groups
m = re.search(r"(?P<year>\d{4})-(?P<month>\d{2})", text)
if m:
    m.group("year")    # "2024"
    m.group("month")   # "03"

# Compile for reuse
pattern = re.compile(r"\d+\.\d+", re.IGNORECASE)
matches = pattern.findall(text)

# Verbose mode (readable complex patterns)
pattern = re.compile(r"""
    (\d{1,3})\.    # first octet
    (\d{1,3})\.    # second octet
    (\d{1,3})\.    # third octet
    (\d{1,3})      # fourth octet
""", re.VERBOSE)
```

### JavaScript Regex

```javascript
// Literal syntax
const pattern = /\d+/g;

// Constructor syntax (double-escape backslashes)
const pattern = new RegExp("\\d+", "g");

// Methods
pattern.test(text)               // returns true/false
text.match(pattern)              // returns matches array
text.matchAll(pattern)           // returns iterator (requires /g)
text.search(pattern)             // returns index or -1
text.replace(pattern, "new")     // replace
text.replaceAll(pattern, "new")  // replace all (requires /g)
text.split(pattern)              // split

// Named groups (ES2018+)
const m = text.match(/(?<year>\d{4})-(?<month>\d{2})/);
m.groups.year   // "2024"
m.groups.month  // "03"

// Replace with function
text.replace(/(\d+)/g, (match, p1) => {
    return parseInt(p1) * 2;
});
```

---

## Regex Cheat Sheet (Visual)

```
Pattern:    ^(\d{3})-(\d{3})-(\d{4})$
Input:      555-123-4567

^           Start of string
(\d{3})     Group 1: three digits → "555"
-           Literal hyphen
(\d{3})     Group 2: three digits → "123"
-           Literal hyphen
(\d{4})     Group 3: four digits  → "4567"
$           End of string
```

```
Pattern:    (?<=\$)[\d,]+(?:\.\d{2})?
Input:      "Price: $1,234.56 USD"

(?<=\$)     Lookbehind: preceded by "$" (not captured)
[\d,]+      One or more digits or commas → "1,234"
(?:         Non-capturing group:
  \.\d{2}     dot followed by 2 digits → ".56"
)?          Optional
Result:     "1,234.56"
```

---

## Tips and Gotchas

1. **Greedy by default**: `.*` will match as much as possible. Use `.*?` for lazy matching.

2. **Escape special characters**: `\ . * + ? { } [ ] ( ) ^ $ |` must be escaped with `\` when you want the literal character.

3. **Anchors matter**: Without `^` and `$`, patterns match anywhere in the string. `\d+` matches the "123" in "abc123def".

4. **Catastrophic backtracking**: Nested quantifiers like `(a+)+` can cause exponential time on certain inputs. Avoid patterns like `(.*a){n}`.

5. **Character class shortcuts**: Inside `[...]`, most special chars lose their meaning. Only `]`, `\`, `^` (at start), and `-` (in middle) are special.

6. **Newlines**: `.` does NOT match `\n` by default. Use the `s`/dotall flag to change this.

7. **Word boundary `\b`**: Matches the position between a word character and a non-word character. It matches at start/end of string if adjacent to a word character.

8. **Testing**: Use regex101.com (when online) to test and debug patterns interactively. Offline, test in a Python REPL:
   ```python
   import re
   re.findall(r"your_pattern", "your test string")
   ```
