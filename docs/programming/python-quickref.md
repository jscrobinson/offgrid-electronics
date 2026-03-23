# Python Quick Reference

A practical offline reference for Python 3.8+.

---

## Data Types

```python
# Numeric
x = 42          # int (arbitrary precision)
y = 3.14        # float (64-bit double)
z = 2 + 3j      # complex
big = 1_000_000  # underscores for readability

# Boolean
flag = True      # also False; subclass of int (True == 1)

# Strings (immutable)
s = "hello"
s = 'hello'
s = """multi
line"""
raw = r"no\escape"
b = b"bytes"     # bytes literal

# None
x = None

# Sequences
lst = [1, 2, 3]           # list (mutable)
tup = (1, 2, 3)           # tuple (immutable)
rng = range(10)            # range object (lazy)

# Mappings
d = {"key": "value"}       # dict (ordered since 3.7)

# Sets
s = {1, 2, 3}             # set (mutable, unordered, unique)
fs = frozenset({1, 2, 3}) # immutable set

# Type checking
type(x)                    # returns type object
isinstance(x, int)         # preferred over type() ==
isinstance(x, (int, float))  # check multiple types
```

### Type Conversions

```python
int("42")        # 42
int("ff", 16)    # 255
float("3.14")    # 3.14
str(42)          # "42"
bool(0)          # False — falsy: 0, 0.0, "", [], {}, set(), None
list("abc")      # ['a', 'b', 'c']
tuple([1,2,3])   # (1, 2, 3)
set([1,1,2])     # {1, 2}
dict([("a",1)])  # {'a': 1}
bytes("hi","utf-8")  # b'hi'
```

---

## String Formatting

### f-strings (Python 3.6+, preferred)

```python
name = "world"
f"Hello, {name}!"                  # Hello, world!
f"{3.14159:.2f}"                   # 3.14
f"{42:08b}"                        # 00101010  (binary, 8 chars, zero-padded)
f"{255:#x}"                        # 0xff
f"{1000000:,}"                     # 1,000,000
f"{'hello':>20}"                   # right-align in 20 chars
f"{'hello':<20}"                   # left-align
f"{'hello':^20}"                   # center
f"{value!r}"                       # calls repr()
f"{value!s}"                       # calls str()
f"result: {2+3}"                   # expressions: result: 5
f"{ {1: 'a'} }"                   # dicts: use space inside braces
f"literal {{braces}}"             # escape braces by doubling
```

### .format() and % formatting

```python
"Hello, {}!".format(name)
"Hello, {name}!".format(name="world")
"{0} {1} {0}".format("a", "b")    # a b a
"Hello, %s! %d items" % (name, 5) # old style, still works
```

---

## Collections: List, Dict, Set

### Lists

```python
lst = [1, 2, 3, 4, 5]
lst[0]          # 1 (zero-indexed)
lst[-1]         # 5 (last element)
lst[1:3]        # [2, 3] (slice, end exclusive)
lst[::2]        # [1, 3, 5] (every 2nd)
lst[::-1]       # [5, 4, 3, 2, 1] (reversed)

lst.append(6)          # add to end
lst.extend([7, 8])     # add multiple
lst.insert(0, 0)       # insert at index
lst.pop()              # remove+return last
lst.pop(0)             # remove+return at index
lst.remove(3)          # remove first occurrence of value
lst.index(4)           # find index of value
lst.sort()             # in-place sort
lst.sort(reverse=True)
lst.sort(key=len)      # sort by key function
sorted(lst)            # returns new sorted list
lst.reverse()          # in-place reverse
len(lst)               # length
```

### Comprehensions

```python
# List comprehension
squares = [x**2 for x in range(10)]
evens = [x for x in range(20) if x % 2 == 0]
flat = [x for row in matrix for x in row]  # flatten

# Dict comprehension
d = {k: v for k, v in pairs}
d = {x: x**2 for x in range(5)}
inverted = {v: k for k, v in d.items()}

# Set comprehension
unique_lengths = {len(word) for word in words}

# Generator expression (lazy, memory efficient)
total = sum(x**2 for x in range(1000000))
```

### Dictionaries

```python
d = {"a": 1, "b": 2}
d["a"]                  # 1 (KeyError if missing)
d.get("c", 0)          # 0 (default if missing)
d["c"] = 3             # set
del d["c"]             # delete
"a" in d               # True (key membership)
d.keys()               # dict_keys view
d.values()             # dict_values view
d.items()              # dict_items view — (key, value) pairs
d.update({"c": 3})     # merge in
d.pop("a")             # remove + return value
d.setdefault("x", []) # return existing or set default
d | {"c": 3}           # merge (Python 3.9+)
d |= {"c": 3}          # merge in-place (Python 3.9+)

# Iteration
for key in d:
    print(key, d[key])
for key, value in d.items():
    print(key, value)
```

### Sets

```python
s = {1, 2, 3}
s.add(4)
s.remove(4)       # KeyError if missing
s.discard(4)      # no error if missing
s | t             # union
s & t             # intersection
s - t             # difference
s ^ t             # symmetric difference
s <= t            # subset
s >= t            # superset
```

---

## Functions

```python
def greet(name, greeting="Hello"):
    """Docstring: describe what the function does."""
    return f"{greeting}, {name}!"

# Positional and keyword arguments
greet("Alice")                    # Hello, Alice!
greet("Alice", greeting="Hi")    # Hi, Alice!

# *args and **kwargs
def func(*args, **kwargs):
    # args is a tuple of positional args
    # kwargs is a dict of keyword args
    for a in args:
        print(a)
    for k, v in kwargs.items():
        print(f"{k}={v}")

func(1, 2, 3, x=10, y=20)

# Keyword-only arguments (after *)
def func(a, b, *, option=False):
    pass  # option MUST be passed as keyword

# Positional-only arguments (before /) — Python 3.8+
def func(a, b, /, c):
    pass  # a, b MUST be positional

# Lambda (anonymous functions)
square = lambda x: x**2
sorted(items, key=lambda x: x.name)

# Unpacking
def func(a, b, c):
    pass
args = [1, 2, 3]
func(*args)           # unpack list
kwargs = {"a": 1, "b": 2, "c": 3}
func(**kwargs)        # unpack dict
```

---

## Classes

```python
class Animal:
    species_count = 0   # class variable (shared)

    def __init__(self, name, sound):
        self.name = name       # instance variable
        self.sound = sound
        Animal.species_count += 1

    def speak(self):
        return f"{self.name} says {self.sound}"

    def __repr__(self):
        return f"Animal({self.name!r}, {self.sound!r})"

    def __str__(self):
        return self.name

    @classmethod
    def from_dict(cls, data):
        return cls(data["name"], data["sound"])

    @staticmethod
    def is_valid_name(name):
        return len(name) > 0

# Inheritance
class Dog(Animal):
    def __init__(self, name, breed):
        super().__init__(name, "Woof")
        self.breed = breed

    def speak(self):          # override
        return f"{super().speak()}! (a {self.breed})"

# Dataclasses (Python 3.7+)
from dataclasses import dataclass, field

@dataclass
class Point:
    x: float
    y: float
    label: str = "origin"
    tags: list = field(default_factory=list)  # mutable default

    def distance(self):
        return (self.x**2 + self.y**2) ** 0.5

# Properties
class Circle:
    def __init__(self, radius):
        self._radius = radius

    @property
    def radius(self):
        return self._radius

    @radius.setter
    def radius(self, value):
        if value < 0:
            raise ValueError("Radius cannot be negative")
        self._radius = value

    @property
    def area(self):
        return 3.14159 * self._radius ** 2
```

### Common Dunder Methods

```python
__init__(self)       # constructor
__repr__(self)       # developer string (unambiguous)
__str__(self)        # user-friendly string
__len__(self)        # len(obj)
__getitem__(self, k) # obj[k]
__setitem__(self, k, v) # obj[k] = v
__contains__(self, x)   # x in obj
__iter__(self)       # for x in obj
__next__(self)       # next(obj)
__eq__(self, other)  # obj == other
__lt__(self, other)  # obj < other (enables sorting)
__hash__(self)       # hash(obj) — needed for set/dict keys
__enter__, __exit__  # context manager (with statement)
__call__(self)       # obj() — callable
```

---

## File I/O

```python
# Reading
with open("file.txt", "r") as f:
    content = f.read()          # entire file as string
    # or
    lines = f.readlines()       # list of lines (with \n)
    # or
    for line in f:              # iterate lines (memory efficient)
        print(line.strip())

# Writing
with open("file.txt", "w") as f:    # overwrite
    f.write("hello\n")
with open("file.txt", "a") as f:    # append
    f.write("more\n")

# Binary
with open("file.bin", "rb") as f:
    data = f.read()
with open("file.bin", "wb") as f:
    f.write(b"\x00\x01\x02")

# Encoding
with open("file.txt", "r", encoding="utf-8") as f:
    content = f.read()

# JSON
import json
with open("data.json", "r") as f:
    data = json.load(f)              # file -> Python object
with open("data.json", "w") as f:
    json.dump(data, f, indent=2)     # Python object -> file

s = json.dumps(data)                 # Python object -> string
data = json.loads(s)                 # string -> Python object

# CSV
import csv
with open("data.csv", "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        print(row["column_name"])
```

---

## Exception Handling

```python
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero")
except (TypeError, ValueError) as e:
    print(f"Error: {e}")
except Exception as e:
    print(f"Unexpected: {e}")
    raise                          # re-raise the exception
else:
    print("No exception occurred")  # runs only if no exception
finally:
    print("Always runs")            # cleanup code

# Raising exceptions
raise ValueError("Invalid input")
raise RuntimeError("Something went wrong") from original_error

# Custom exceptions
class SensorError(Exception):
    def __init__(self, sensor_id, message):
        self.sensor_id = sensor_id
        super().__init__(f"Sensor {sensor_id}: {message}")

# Common built-in exceptions
# ValueError     — wrong value for correct type
# TypeError      — wrong type
# KeyError       — dict key not found
# IndexError     — list index out of range
# AttributeError — attribute not found
# FileNotFoundError — file doesn't exist
# IOError        — I/O operation failed
# RuntimeError   — generic runtime error
# StopIteration  — iterator exhausted
# ImportError     — module import failed
# OSError        — OS-level error
```

---

## Context Managers

```python
# Using with statement (calls __enter__ and __exit__)
with open("file.txt") as f:
    data = f.read()
# file automatically closed, even on exception

# Multiple context managers
with open("in.txt") as fin, open("out.txt", "w") as fout:
    fout.write(fin.read())

# Custom context manager with class
class Timer:
    def __enter__(self):
        self.start = time.time()
        return self
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.elapsed = time.time() - self.start
        return False  # don't suppress exceptions

with Timer() as t:
    do_something()
print(f"Took {t.elapsed:.2f}s")

# Custom context manager with contextlib
from contextlib import contextmanager

@contextmanager
def temp_directory():
    import tempfile, shutil
    d = tempfile.mkdtemp()
    try:
        yield d
    finally:
        shutil.rmtree(d)

with temp_directory() as tmpdir:
    # use tmpdir...
    pass
```

---

## Generators

```python
# Generator function (yields values lazily)
def fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

fib = fibonacci()
next(fib)    # 0
next(fib)    # 1
next(fib)    # 1

# Take first n items
from itertools import islice
first_10 = list(islice(fibonacci(), 10))

# Generator expression
squares = (x**2 for x in range(1000000))  # lazy, no memory

# yield from (delegate to sub-generator)
def chain(*iterables):
    for it in iterables:
        yield from it

# Send values into generator
def accumulator():
    total = 0
    while True:
        value = yield total
        total += value

acc = accumulator()
next(acc)         # prime the generator, returns 0
acc.send(10)      # 10
acc.send(20)      # 30
```

---

## Decorators

```python
# A decorator wraps a function, modifying its behavior
import functools
import time

def timer(func):
    @functools.wraps(func)  # preserves func name and docstring
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        print(f"{func.__name__} took {elapsed:.4f}s")
        return result
    return wrapper

@timer
def slow_function():
    time.sleep(1)

# Decorator with arguments
def retry(max_attempts=3, delay=1):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    time.sleep(delay)
        return wrapper
    return decorator

@retry(max_attempts=5, delay=0.5)
def unreliable_network_call():
    pass

# Class-based decorator
class CacheResult:
    def __init__(self, func):
        self.func = func
        self.cache = {}
    def __call__(self, *args):
        if args not in self.cache:
            self.cache[args] = self.func(*args)
        return self.cache[args]

# Built-in decorators
@staticmethod       # no self parameter
@classmethod        # cls instead of self
@property           # getter
@functools.lru_cache(maxsize=128)  # memoization
@dataclass          # auto-generate __init__, __repr__, etc.
```

---

## Virtual Environments and pip

```python
# Create virtual environment
python3 -m venv myenv

# Activate
source myenv/bin/activate        # Linux/macOS
myenv\Scripts\activate.bat       # Windows CMD
myenv\Scripts\Activate.ps1       # Windows PowerShell

# Deactivate
deactivate

# pip commands
pip install requests             # install package
pip install requests==2.28.0     # specific version
pip install -r requirements.txt  # install from file
pip freeze > requirements.txt    # save installed packages
pip list                         # show installed
pip show requests                # show package info
pip install --upgrade pip        # upgrade pip itself
pip install -e .                 # install package in editable mode

# Offline pip (for this USB stick)
pip install --no-index --find-links ./packages/ requests
pip download -d ./packages/ -r requirements.txt  # download for offline
```

---

## Common Standard Library Modules

### os and sys

```python
import os
os.getcwd()                    # current working directory
os.listdir(".")                # list directory contents
os.makedirs("a/b/c", exist_ok=True)  # mkdir -p
os.path.join("a", "b", "c")   # "a/b/c" (platform-aware)
os.path.exists("file.txt")
os.path.isfile("file.txt")
os.path.isdir("mydir")
os.path.basename("/a/b/c.txt") # "c.txt"
os.path.dirname("/a/b/c.txt")  # "/a/b"
os.path.splitext("file.txt")   # ("file", ".txt")
os.environ["HOME"]              # environment variable
os.environ.get("VAR", "default")
os.remove("file.txt")
os.rename("old", "new")
os.chmod("file.sh", 0o755)
os.getpid()

import sys
sys.argv                       # command line arguments
sys.exit(1)                    # exit with code
sys.stdin, sys.stdout, sys.stderr
sys.path                       # module search paths
sys.platform                   # "linux", "win32", "darwin"
sys.version                    # Python version string
sys.getsizeof(obj)             # memory size in bytes
```

### pathlib (modern path handling, preferred over os.path)

```python
from pathlib import Path

p = Path("/home/user/docs")
p / "file.txt"                 # Path("/home/user/docs/file.txt")
p.exists()
p.is_file()
p.is_dir()
p.name                         # "docs"
p.stem                         # filename without suffix
p.suffix                       # ".txt"
p.parent                       # Path("/home/user")
p.resolve()                    # absolute path
p.glob("*.txt")                # generator of matching paths
p.rglob("*.py")               # recursive glob
p.read_text()                  # read entire file
p.write_text("hello")          # write entire file
p.read_bytes()                 # binary read
p.mkdir(parents=True, exist_ok=True)
p.unlink()                     # delete file
Path.home()                    # home directory
Path.cwd()                     # current directory

# Iterate a directory
for f in Path(".").iterdir():
    if f.is_file():
        print(f.name, f.stat().st_size)
```

### re (regular expressions)

```python
import re

# Search (first match anywhere in string)
m = re.search(r"\d+", "abc 123 def")
if m:
    m.group()    # "123"
    m.start()    # 4
    m.end()      # 7

# Match (from start of string only)
m = re.match(r"\d+", "123 abc")

# Find all
re.findall(r"\d+", "12 abc 34 def 56")   # ['12', '34', '56']

# Find all with groups
re.findall(r"(\w+)=(\d+)", "a=1 b=2")    # [('a','1'), ('b','2')]

# Substitution
re.sub(r"\d+", "X", "abc 123 def 456")   # "abc X def X"

# Split
re.split(r"[,;\s]+", "a,b;c d")          # ['a', 'b', 'c', 'd']

# Compile for reuse
pattern = re.compile(r"^\d{3}-\d{4}$")
pattern.match("555-1234")

# Flags
re.search(r"hello", text, re.IGNORECASE)
re.search(r"^start", text, re.MULTILINE)
```

### datetime

```python
from datetime import datetime, date, time, timedelta, timezone

now = datetime.now()                      # local time
utc_now = datetime.now(timezone.utc)      # UTC
dt = datetime(2024, 3, 15, 10, 30, 0)    # specific datetime

# Formatting
now.strftime("%Y-%m-%d %H:%M:%S")        # "2024-03-15 10:30:00"
now.isoformat()                           # "2024-03-15T10:30:00"

# Parsing
dt = datetime.strptime("2024-03-15", "%Y-%m-%d")

# Common format codes
# %Y=2024  %m=03  %d=15  %H=10  %M=30  %S=00
# %I=12hr  %p=AM/PM  %a=Mon  %A=Monday  %b=Mar  %B=March

# Arithmetic
delta = timedelta(days=7, hours=3)
future = now + delta
diff = datetime(2024,12,31) - datetime(2024,1,1)
diff.days        # 365
diff.total_seconds()

# Timestamp
ts = now.timestamp()              # float (Unix timestamp)
dt = datetime.fromtimestamp(ts)   # back to datetime
```

### collections

```python
from collections import (
    Counter, defaultdict, OrderedDict, namedtuple, deque
)

# Counter — count occurrences
c = Counter("abracadabra")       # Counter({'a':5, 'b':2, ...})
c.most_common(3)                  # [('a',5), ('b',2), ('r',2)]
Counter(words)                    # count word frequencies

# defaultdict — dict with default factory
dd = defaultdict(list)
dd["key"].append(1)               # no KeyError, auto-creates []

dd = defaultdict(int)
dd["count"] += 1                  # default 0

# namedtuple — lightweight class
Point = namedtuple("Point", ["x", "y"])
p = Point(3, 4)
p.x, p.y                         # attribute access
x, y = p                         # unpacking

# deque — double-ended queue (fast append/pop both ends)
dq = deque([1, 2, 3], maxlen=100)
dq.append(4)          # right end
dq.appendleft(0)      # left end
dq.pop()              # right end
dq.popleft()          # left end
dq.rotate(1)          # rotate right
```

### itertools

```python
from itertools import (
    chain, islice, cycle, repeat, count,
    product, permutations, combinations,
    groupby, starmap, zip_longest, accumulate
)

# chain — concatenate iterables
list(chain([1,2], [3,4], [5,6]))     # [1,2,3,4,5,6]

# islice — slice an iterator
list(islice(range(100), 5, 10))      # [5,6,7,8,9]

# cycle — repeat endlessly
colors = cycle(["red", "green", "blue"])

# count — infinite counter
for i in count(start=10, step=2):    # 10, 12, 14, ...
    if i > 20: break

# product — cartesian product
list(product("AB", "12"))  # [('A','1'),('A','2'),('B','1'),('B','2')]

# permutations and combinations
list(permutations("ABC", 2))  # all 2-element orderings
list(combinations("ABC", 2))  # all 2-element subsets

# groupby — group consecutive items
data = sorted(items, key=lambda x: x.category)
for key, group in groupby(data, key=lambda x: x.category):
    print(key, list(group))

# zip_longest — zip with fill value
list(zip_longest([1,2,3], [4,5], fillvalue=0))  # [(1,4),(2,5),(3,0)]
```

### struct (binary data packing)

```python
import struct

# Pack Python values into bytes
data = struct.pack(">BHI", 0xFF, 1024, 70000)
# > = big-endian, B = uint8, H = uint16, I = uint32

# Unpack bytes into Python values
values = struct.unpack(">BHI", data)   # (255, 1024, 70000)

# Format characters:
# b/B = int8/uint8    h/H = int16/uint16    i/I = int32/uint32
# q/Q = int64/uint64  f = float32  d = float64
# s = char[]  ? = bool
# Byte order: > big-endian  < little-endian  = native  ! network (big)

struct.calcsize(">BHI")   # 7 bytes
```

### socket

```python
import socket

# TCP Client
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect(("192.168.1.100", 8080))
    s.sendall(b"Hello")
    data = s.recv(1024)

# TCP Server
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("0.0.0.0", 8080))
    s.listen(5)
    while True:
        conn, addr = s.accept()
        with conn:
            data = conn.recv(1024)
            conn.sendall(b"Response")

# UDP
with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
    s.sendto(b"Hello", ("192.168.1.100", 9999))
    data, addr = s.recvfrom(1024)

# Get local IP
socket.gethostname()
socket.gethostbyname(socket.gethostname())
```

### threading

```python
import threading

# Basic thread
def worker(name):
    print(f"Thread {name} running")

t = threading.Thread(target=worker, args=("A",))
t.start()
t.join()       # wait for completion

# Lock (mutex)
lock = threading.Lock()
with lock:
    # critical section — only one thread at a time
    shared_data += 1

# Event (signal between threads)
event = threading.Event()
event.wait()       # block until set
event.set()        # unblock waiters
event.clear()      # reset

# Timer
t = threading.Timer(5.0, my_function)
t.start()          # runs my_function after 5 seconds

# Thread-safe queue
from queue import Queue
q = Queue()
q.put(item)
item = q.get()     # blocks until available
q.task_done()
```

### subprocess

```python
import subprocess

# Simple command (Python 3.5+)
result = subprocess.run(
    ["ls", "-la"],
    capture_output=True,    # capture stdout and stderr
    text=True,              # decode to string (not bytes)
    check=True,             # raise CalledProcessError on non-zero exit
    timeout=30              # seconds
)
print(result.stdout)
print(result.returncode)

# Shell command (use sparingly — security risk)
result = subprocess.run("echo $HOME", shell=True, capture_output=True, text=True)

# Piping
p1 = subprocess.Popen(["cat", "file.txt"], stdout=subprocess.PIPE)
p2 = subprocess.Popen(["grep", "pattern"], stdin=p1.stdout, stdout=subprocess.PIPE)
p1.stdout.close()
output = p2.communicate()[0]

# Streaming output
process = subprocess.Popen(
    ["ping", "-c", "5", "8.8.8.8"],
    stdout=subprocess.PIPE,
    text=True
)
for line in process.stdout:
    print(line, end="")
```

---

## Type Hints (Python 3.5+)

```python
# Basic type hints
def greet(name: str) -> str:
    return f"Hello, {name}"

x: int = 42
y: float = 3.14
flag: bool = True

# Collections
from typing import List, Dict, Tuple, Set, Optional, Union

def process(items: List[int]) -> Dict[str, int]:
    return {"sum": sum(items)}

# Python 3.9+ — use built-in types directly
def process(items: list[int]) -> dict[str, int]:
    return {"sum": sum(items)}

# Optional (can be None)
def find(name: str) -> Optional[int]:   # same as Union[int, None]
    ...

# Union
def handle(x: Union[int, str]) -> None:
    ...

# Python 3.10+ — use | for union
def handle(x: int | str) -> None:
    ...

# Callable
from typing import Callable
def apply(func: Callable[[int, int], int], a: int, b: int) -> int:
    return func(a, b)

# TypedDict
from typing import TypedDict
class Config(TypedDict):
    host: str
    port: int
    debug: bool
```

---

## Useful One-Liners and Patterns

```python
# Swap variables
a, b = b, a

# Ternary / conditional expression
x = "yes" if condition else "no"

# Walrus operator (Python 3.8+)
if (n := len(data)) > 10:
    print(f"Too long: {n}")

# Flatten nested list
flat = [x for sublist in nested for x in sublist]

# Merge dicts
merged = {**dict1, **dict2}          # Python 3.5+
merged = dict1 | dict2               # Python 3.9+

# Remove duplicates preserving order
unique = list(dict.fromkeys(items))

# Enumerate with start index
for i, item in enumerate(items, start=1):
    print(f"{i}. {item}")

# Zip and unzip
pairs = list(zip(names, scores))
names, scores = zip(*pairs)

# Any / all
any(x > 0 for x in numbers)  # True if any positive
all(x > 0 for x in numbers)  # True if all positive

# Min/max with key
oldest = max(people, key=lambda p: p.age)

# Check if string is numeric
"42".isdigit()   # True
"3.14".replace(".", "", 1).isdigit()  # True

# Read a file into a list of stripped lines
lines = Path("file.txt").read_text().splitlines()
```
