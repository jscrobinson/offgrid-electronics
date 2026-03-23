# Bash Scripting Reference

A practical offline reference for writing Bash scripts on Linux, macOS, and Raspberry Pi.

---

## Basics

### Shebang and Execution

```bash
#!/bin/bash
# or #!/usr/bin/env bash  (more portable — finds bash in PATH)

# Make executable
chmod +x script.sh

# Run
./script.sh
bash script.sh
source script.sh    # runs in current shell (variables persist)
. script.sh         # same as source
```

### Strict Mode (always use this)

```bash
#!/bin/bash
set -euo pipefail

# set -e          Exit immediately on any command failure
# set -u          Treat unset variables as error
# set -o pipefail  Pipeline fails if ANY command in pipe fails
#                  (normally only last command's exit code matters)

# Optional but useful:
# set -x          Print each command before executing (debugging)
```

---

## Variables

```bash
# Assignment (NO spaces around =)
name="world"
count=42
readonly PI=3.14159     # constant, cannot be reassigned

# Usage (always quote to prevent word splitting/globbing)
echo "Hello, $name"
echo "Hello, ${name}"    # braces for clarity/disambiguation
echo "Count: ${count}!"  # needed when followed by text

# Unset
unset name

# Environment variables (exported to child processes)
export PATH="/usr/local/bin:$PATH"
export MY_VAR="value"

# Command substitution
today=$(date +%Y-%m-%d)
file_count=$(ls -1 | wc -l)
kernel=$(uname -r)

# Arithmetic
count=$((count + 1))
result=$(( 10 * 5 + 3 ))
(( count++ ))
(( count += 5 ))

# Default values
name=${name:-"default"}      # use default if unset or empty
name=${name:="default"}      # same, but also assigns the default
name=${name:?"Error: name required"}  # error if unset or empty
name=${name:+replacement}    # use replacement if name IS set
```

---

## Quoting Rules

```bash
# Double quotes — variable and command substitution HAPPEN
echo "Hello, $name"          # Hello, world
echo "Today is $(date)"     # Today is Mon Mar 15 ...
echo "Path: $HOME/bin"      # Path: /home/user/bin

# Single quotes — EVERYTHING is literal, no substitution
echo 'Hello, $name'         # Hello, $name
echo 'Today is $(date)'    # Today is $(date)

# Backslash — escape single character
echo "The cost is \$5"      # The cost is $5
echo "She said \"hi\""      # She said "hi"

# $'...' — ANSI C quoting (interpret escape sequences)
echo $'Column1\tColumn2'    # tab between columns
echo $'Line1\nLine2'        # newline between lines

# IMPORTANT: Always double-quote variables to prevent:
# - Word splitting: unquoted variables split on whitespace
# - Glob expansion: unquoted * ? [] get expanded
file="my file.txt"
cat "$file"       # CORRECT: treats as one argument
cat $file         # WRONG: becomes cat my file.txt (two args)
```

---

## Conditionals

### if/elif/else

```bash
if [[ "$name" == "admin" ]]; then
    echo "Welcome, admin"
elif [[ "$name" == "guest" ]]; then
    echo "Limited access"
else
    echo "Unknown user: $name"
fi
```

### [[ ]] vs [ ]

Prefer `[[ ]]` (Bash built-in) over `[ ]` (POSIX):

```bash
# [[ ]] advantages:
# - No word splitting on variables (don't need quotes, but still good practice)
# - Supports && and || inside
# - Supports regex matching with =~
# - Supports pattern matching with ==

# String comparisons
[[ "$a" == "$b" ]]     # equal
[[ "$a" != "$b" ]]     # not equal
[[ "$a" < "$b" ]]      # lexicographic less than
[[ "$a" > "$b" ]]      # lexicographic greater than
[[ "$a" == pattern* ]] # glob pattern match
[[ "$a" =~ ^[0-9]+$ ]] # regex match

# Numeric comparisons (use -eq, -ne, -lt, etc. or (( )))
[[ "$a" -eq "$b" ]]    # equal
[[ "$a" -ne "$b" ]]    # not equal
[[ "$a" -lt "$b" ]]    # less than
[[ "$a" -le "$b" ]]    # less than or equal
[[ "$a" -gt "$b" ]]    # greater than
[[ "$a" -ge "$b" ]]    # greater than or equal

# Or use arithmetic context (cleaner for numbers)
(( a == b ))
(( a > 5 && a < 10 ))
(( count++ ))
```

### File Tests

```bash
[[ -f "$file" ]]     # is a regular file
[[ -d "$dir" ]]      # is a directory
[[ -e "$path" ]]     # exists (file or directory)
[[ -r "$file" ]]     # is readable
[[ -w "$file" ]]     # is writable
[[ -x "$file" ]]     # is executable
[[ -s "$file" ]]     # exists and is non-empty
[[ -L "$link" ]]     # is a symlink
[[ -p "$pipe" ]]     # is a named pipe
[[ -b "$dev" ]]      # is a block device
[[ -c "$dev" ]]      # is a character device
[[ "$a" -nt "$b" ]]  # a is newer than b
[[ "$a" -ot "$b" ]]  # a is older than b
```

### String Tests

```bash
[[ -z "$str" ]]      # is empty (zero length)
[[ -n "$str" ]]      # is non-empty
[[ "$str" ]]         # is non-empty (shorthand)
```

### Logical Operators

```bash
# Inside [[ ]]
[[ "$a" == "x" && "$b" == "y" ]]   # AND
[[ "$a" == "x" || "$b" == "y" ]]   # OR
[[ ! -f "$file" ]]                   # NOT

# Between commands
command1 && command2   # run command2 only if command1 succeeds
command1 || command2   # run command2 only if command1 fails
! command              # negate exit code
```

### case Statement

```bash
case "$input" in
    start|begin)
        echo "Starting..."
        ;;
    stop|end)
        echo "Stopping..."
        ;;
    restart)
        echo "Restarting..."
        ;;
    *.txt)
        echo "Text file"
        ;;
    *)
        echo "Unknown: $input"
        ;;
esac
```

---

## Loops

### for Loop

```bash
# Iterate over list
for item in apple banana cherry; do
    echo "$item"
done

# Iterate over files
for file in *.txt; do
    [[ -f "$file" ]] || continue   # skip if no matches (nullglob)
    echo "Processing: $file"
done

# Iterate over glob
for dir in /dev/ttyUSB*; do
    echo "Found serial port: $dir"
done

# C-style for loop
for ((i = 0; i < 10; i++)); do
    echo "$i"
done

# Range
for i in {1..10}; do echo "$i"; done
for i in {0..100..5}; do echo "$i"; done    # step by 5

# Iterate over command output
for user in $(cut -d: -f1 /etc/passwd); do
    echo "User: $user"
done

# Iterate over lines (handles spaces correctly)
while IFS= read -r line; do
    echo "$line"
done < "file.txt"

# Iterate over array
arr=(one two three)
for item in "${arr[@]}"; do
    echo "$item"
done
```

### while Loop

```bash
count=0
while (( count < 10 )); do
    echo "Count: $count"
    (( count++ ))
done

# Read lines from file
while IFS= read -r line; do
    echo "Line: $line"
done < "input.txt"

# Read from command output
while IFS= read -r line; do
    echo "$line"
done < <(find . -name "*.log")

# Infinite loop
while true; do
    check_sensor
    sleep 5
done

# Read with timeout
while IFS= read -r -t 5 line; do
    echo "$line"
done < /dev/ttyUSB0
```

### until Loop

```bash
# Loop until condition is true (opposite of while)
until ping -c1 8.8.8.8 &>/dev/null; do
    echo "Waiting for network..."
    sleep 2
done
echo "Network is up!"
```

### Loop Control

```bash
for i in {1..100}; do
    [[ "$i" -eq 5 ]] && continue   # skip iteration
    [[ "$i" -eq 10 ]] && break     # exit loop
    echo "$i"
done
```

---

## Functions

```bash
# Define
greet() {
    local name="$1"           # local variable (doesn't leak)
    local greeting="${2:-Hello}"  # default value
    echo "${greeting}, ${name}!"
}

# Call
greet "Alice"                 # Hello, Alice!
greet "Bob" "Hi"             # Hi, Bob!

# Return values
# Functions return exit codes (0-255), not values
# Use echo + command substitution for string return:
get_timestamp() {
    echo "$(date +%s)"
}
ts=$(get_timestamp)

# Or use a global variable:
RESULT=""
compute() {
    RESULT=$(( $1 * $2 ))
}
compute 6 7
echo "$RESULT"  # 42

# Arguments
my_func() {
    echo "All args: $@"      # all arguments (individually quoted)
    echo "All args: $*"      # all arguments (as single string)
    echo "Arg count: $#"     # number of arguments
    echo "First: $1"         # first argument
    echo "Second: $2"        # second argument
    shift                    # shift args: $2 becomes $1, etc.
    echo "After shift: $1"   # was $2
}

# Exit code
validate() {
    [[ -f "$1" ]] && return 0 || return 1
}
if validate "file.txt"; then
    echo "Valid"
fi
```

---

## Command Substitution and Process Substitution

```bash
# Command substitution: $()
files=$(ls -1 | wc -l)
current_branch=$(git branch --show-current)
ip_addr=$(hostname -I | awk '{print $1}')

# Nested
echo "$(basename "$(pwd)")"

# Process substitution: <() and >()
# Creates a temporary file descriptor from command output
# Useful when a command needs a filename but you have a pipe

# Compare two sorted command outputs
diff <(sort file1.txt) <(sort file2.txt)

# Use command output as if it were a file
while IFS= read -r line; do
    echo "$line"
done < <(find . -name "*.py")

# Feed to command that needs a file
paste <(cut -f1 data.tsv) <(cut -f3 data.tsv)
```

---

## Arrays

### Indexed Arrays

```bash
# Declare
arr=(one two three "four five")
arr[4]="six"

# Access
echo "${arr[0]}"         # one (zero-indexed)
echo "${arr[3]}"         # four five
echo "${arr[@]}"         # all elements
echo "${#arr[@]}"        # length (5)
echo "${!arr[@]}"        # all indices (0 1 2 3 4)

# Slice
echo "${arr[@]:1:3}"     # elements 1,2,3 (offset:count)

# Append
arr+=("seven" "eight")

# Delete
unset 'arr[2]'           # remove element (leaves gap!)

# Iterate
for item in "${arr[@]}"; do
    echo "$item"
done

# Build array from command
files=($(ls *.txt))              # DANGER: word splitting issues
mapfile -t files < <(ls *.txt)   # SAFE: handles spaces
readarray -t lines < file.txt    # read file into array
```

### Associative Arrays (Bash 4+)

```bash
# Declare (must use declare -A)
declare -A config
config[host]="192.168.1.100"
config[port]="8080"
config[protocol]="mqtt"

# Or inline
declare -A colors=(
    [red]="#FF0000"
    [green]="#00FF00"
    [blue]="#0000FF"
)

# Access
echo "${config[host]}"
echo "${colors[red]}"

# Check if key exists
[[ -v config[host] ]] && echo "host is set"

# All keys and values
echo "${!config[@]}"     # all keys
echo "${config[@]}"      # all values

# Iterate
for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done

# Length
echo "${#config[@]}"
```

---

## String Manipulation

```bash
str="Hello, World!"

# Length
echo "${#str}"                  # 13

# Substring
echo "${str:0:5}"               # Hello (offset:length)
echo "${str:7}"                 # World!
echo "${str: -6}"               # orld! (note the space before -)

# Search and replace
echo "${str/World/Bash}"        # Hello, Bash! (first occurrence)
echo "${str//l/L}"              # HeLLo, WorLd! (all occurrences)

# Remove from front (shortest match)
path="/home/user/docs/file.txt"
echo "${path#*/}"               # home/user/docs/file.txt

# Remove from front (longest match)
echo "${path##*/}"              # file.txt (like basename)

# Remove from back (shortest match)
echo "${path%/*}"               # /home/user/docs (like dirname)
echo "${path%.*}"               # /home/user/docs/file (remove extension)

# Remove from back (longest match)
echo "${path%%/*}"              # (empty — removes everything after first /)

# Case conversion (Bash 4+)
echo "${str,,}"                 # hello, world! (lowercase)
echo "${str^^}"                 # HELLO, WORLD! (uppercase)
echo "${str^}"                  # Hello, World! (capitalize first)

# Practical examples
filename=$(basename "$path")          # file.txt
extension="${filename##*.}"           # txt
name_only="${filename%.*}"            # file
dir=$(dirname "$path")                # /home/user/docs
```

---

## Exit Codes

```bash
# Every command returns an exit code
# 0 = success, non-zero = failure

# Check last exit code
some_command
echo $?   # exit code of some_command

# Exit with specific code
exit 0    # success
exit 1    # general error

# Common exit codes by convention:
# 0   Success
# 1   General error
# 2   Misuse of shell command
# 126 Command cannot execute (permission)
# 127 Command not found
# 128+n  Killed by signal n (e.g., 130 = SIGINT / Ctrl+C)

# Return from function with exit code
my_func() {
    [[ -f "$1" ]] && return 0 || return 1
}
```

---

## trap (Signal Handling and Cleanup)

```bash
# Run cleanup on exit (any reason)
cleanup() {
    rm -f "$tmpfile"
    echo "Cleaned up"
}
trap cleanup EXIT

# Trap specific signals
trap 'echo "Interrupted!"; exit 1' INT      # Ctrl+C
trap 'echo "Terminated!"; exit 1' TERM      # kill
trap '' INT    # ignore SIGINT (prevent Ctrl+C from stopping script)

# Common pattern: cleanup temp files
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

echo "data" > "$tmpfile"
# ... use tmpfile ...
# tmpfile automatically deleted when script exits (any reason)

# Trap ERR (any command failure, with set -e)
trap 'echo "Error on line $LINENO" >&2' ERR
```

---

## getopts (Argument Parsing)

```bash
#!/bin/bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <input_file>

Options:
  -o FILE   Output file (default: stdout)
  -p PORT   Serial port (default: /dev/ttyUSB0)
  -b BAUD   Baud rate (default: 115200)
  -v        Verbose mode
  -h        Show this help

Example:
  $(basename "$0") -p /dev/ttyACM0 -b 9600 -v data.txt
EOF
}

# Defaults
output=""
port="/dev/ttyUSB0"
baud=115200
verbose=false

while getopts ":o:p:b:vh" opt; do
    case "$opt" in
        o) output="$OPTARG" ;;
        p) port="$OPTARG" ;;
        b) baud="$OPTARG" ;;
        v) verbose=true ;;
        h) usage; exit 0 ;;
        :) echo "Error: -$OPTARG requires an argument" >&2; exit 1 ;;
        *) echo "Error: Unknown option -$OPTARG" >&2; usage; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Remaining arguments
if [[ $# -lt 1 ]]; then
    echo "Error: Input file required" >&2
    usage
    exit 1
fi
input_file="$1"

$verbose && echo "Port: $port, Baud: $baud, Input: $input_file"
```

---

## Heredocs

```bash
# Basic heredoc (variable substitution happens)
cat <<EOF
Hello, $USER!
Today is $(date).
Your home is $HOME.
EOF

# No substitution (quote the delimiter)
cat <<'EOF'
This is literal: $USER $(date)
No substitution happens here.
EOF

# Indented heredoc (<<- strips leading tabs)
if true; then
	cat <<-EOF
	This text is not indented in output.
	Tabs are stripped from the beginning.
	EOF
fi

# Heredoc to a variable
read -r -d '' message <<'EOF' || true
This is a
multi-line string
assigned to a variable.
EOF

# Heredoc to a file
cat > config.conf <<EOF
host=$host
port=$port
enabled=true
EOF

# Heredoc to a command
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS sensors;
USE sensors;
CREATE TABLE IF NOT EXISTS readings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    temperature FLOAT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
EOF
```

---

## Common Patterns

### Error Handling

```bash
#!/bin/bash
set -euo pipefail

# Logging functions
log()   { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2; }
die()   { error "$@"; exit 1; }

# Usage
log "Starting process..."
[[ -f "$config" ]] || die "Config file not found: $config"
```

### Temp Files

```bash
# Safe temp file creation
tmpfile=$(mktemp)
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpfile" "$tmpdir"' EXIT

# Use them
echo "data" > "$tmpfile"
cp important_files "$tmpdir/"
```

### Lock File (prevent concurrent execution)

```bash
LOCKFILE="/tmp/myscript.lock"

if ! mkdir "$LOCKFILE" 2>/dev/null; then
    echo "Script is already running" >&2
    exit 1
fi
trap 'rmdir "$LOCKFILE"' EXIT
```

### Checking Dependencies

```bash
for cmd in git python3 jq curl; do
    command -v "$cmd" &>/dev/null || die "Required: $cmd"
done
```

### Progress Indicator

```bash
spin() {
    local chars='|/-\'
    local i=0
    while kill -0 "$1" 2>/dev/null; do
        printf "\r[%c] Working..." "${chars:$((i % 4)):1}"
        ((i++))
        sleep 0.2
    done
    printf "\r[+] Done!          \n"
}

long_running_command &
spin $!
```

### Reading Config Files

```bash
# config.conf:
# HOST=192.168.1.100
# PORT=8080
# NAME="My Device"

if [[ -f "config.conf" ]]; then
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        # Remove leading/trailing whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        # Remove surrounding quotes
        value="${value%\"}"
        value="${value#\"}"
        declare "$key=$value"
    done < "config.conf"
fi

echo "Connecting to $HOST:$PORT..."
```

### Retry Pattern

```bash
retry() {
    local max_attempts=$1; shift
    local delay=$1; shift
    local attempt=1

    while (( attempt <= max_attempts )); do
        if "$@"; then
            return 0
        fi
        log "Attempt $attempt/$max_attempts failed, retrying in ${delay}s..."
        sleep "$delay"
        (( attempt++ ))
    done
    error "All $max_attempts attempts failed"
    return 1
}

retry 5 10 ping -c1 8.8.8.8
retry 3 5 curl -sf http://api.example.com/health
```

### Parallel Execution

```bash
# Run commands in background and wait
for host in 192.168.1.{1..10}; do
    ping -c1 -W1 "$host" &>/dev/null && echo "$host is up" &
done
wait  # wait for all background jobs

# Limit parallel jobs
max_jobs=4
for file in *.csv; do
    while (( $(jobs -r | wc -l) >= max_jobs )); do
        sleep 0.5
    done
    process_file "$file" &
done
wait
```

### Useful One-Liners for Field Work

```bash
# Find your IP address
ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1
hostname -I | awk '{print $1}'

# Scan local network for devices
for i in {1..254}; do
    ping -c1 -W1 192.168.1.$i &>/dev/null && echo "192.168.1.$i is up" &
done; wait

# Monitor serial port
stty -F /dev/ttyUSB0 115200 raw -echo
cat /dev/ttyUSB0

# Watch a log file
tail -f /var/log/syslog | grep --line-buffered "error"

# System info snapshot
echo "Hostname: $(hostname)"
echo "IP: $(hostname -I)"
echo "Uptime: $(uptime -p)"
echo "Disk: $(df -h / | tail -1 | awk '{print $5 " used"}')"
echo "Memory: $(free -m | awk '/Mem/{printf "%dMB/%dMB", $3, $2}')"
echo "CPU Temp: $(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{printf "%.1fC", $1/1000}')"
```
