# C/C++ for Embedded Systems

A practical reference for writing C and C++ on microcontrollers (Arduino, ESP32, STM32, AVR, ARM Cortex-M). Focused on the patterns and pitfalls specific to embedded development.

---

## Data Types and Sizes

Always use fixed-width integer types from `<stdint.h>` in embedded code. The size of `int`, `long`, etc. varies by platform.

```c
#include <stdint.h>

// Fixed-width types (USE THESE)
int8_t    val;   // signed 8-bit   (-128 to 127)
uint8_t   val;   // unsigned 8-bit (0 to 255)
int16_t   val;   // signed 16-bit  (-32768 to 32767)
uint16_t  val;   // unsigned 16-bit (0 to 65535)
int32_t   val;   // signed 32-bit  (-2,147,483,648 to 2,147,483,647)
uint32_t  val;   // unsigned 32-bit (0 to 4,294,967,295)
int64_t   val;   // signed 64-bit
uint64_t  val;   // unsigned 64-bit

// Size (bytes) — VARIES BY PLATFORM
//              8-bit AVR    32-bit ARM    64-bit PC
// char            1             1             1
// short           2             2             2
// int             2             4             4
// long            4             4             8
// long long       8             8             8
// float           4             4             4
// double          4*            8             8
// pointer         2             4             8
// size_t          2             4             8
// * AVR: double == float (32-bit), no real 64-bit float

// Boolean
#include <stdbool.h>
bool flag = true;   // C99+
// or: _Bool flag = 1;

// Size verification at compile time
_Static_assert(sizeof(uint32_t) == 4, "uint32_t must be 4 bytes");
```

### Arduino-Specific Types

```cpp
byte    b = 0xFF;      // same as uint8_t
word    w = 0xFFFF;    // uint16_t on AVR, may differ on ARM
boolean flag = true;   // same as bool
String  s = "hello";   // Arduino String class (avoid in production — see pitfalls)
```

---

## Pointers and Memory

```c
// Pointer basics
int x = 42;
int *ptr = &x;       // ptr holds address of x
int val = *ptr;       // dereference: val = 42
*ptr = 100;           // x is now 100

// Pointer arithmetic
uint8_t buf[10];
uint8_t *p = buf;     // points to buf[0]
p++;                   // now points to buf[1]
p += 3;               // now points to buf[4]
*(p + 2) = 0xFF;     // same as buf[6] = 0xFF

// Array and pointer relationship
buf[i]   ≡   *(buf + i)
&buf[i]  ≡   (buf + i)

// Void pointer (generic pointer, must cast to use)
void *generic = &x;
int *typed = (int *)generic;

// NULL pointer
int *p = NULL;
if (p != NULL) { /* safe to dereference */ }

// Function pointer
void (*callback)(int) = my_function;
callback(42);  // calls my_function(42)

// Pointer to struct
typedef struct {
    uint16_t x;
    uint16_t y;
} Point;

Point p = {10, 20};
Point *pp = &p;
pp->x = 30;           // access member through pointer
(*pp).y = 40;         // equivalent but uglier
```

### Memory Layout on an MCU

```
┌──────────────┐  High address
│    Stack     │  ↓ grows down (local variables, return addresses)
│              │
│   (free)     │
│              │
│    Heap      │  ↑ grows up (malloc, dynamic allocation)
├──────────────┤
│    .bss      │  Uninitialized global/static variables (zeroed at startup)
├──────────────┤
│    .data     │  Initialized global/static variables (copied from flash at startup)
├──────────────┤
│    .text     │  Program code (in flash, may be read-only)
├──────────────┤
│  Vectors     │  Interrupt vector table
└──────────────┘  Low address (0x0000)
```

### Dynamic Memory (use with extreme caution on MCU)

```c
// malloc/free — generally AVOID on small MCUs
// Reasons: fragmentation, no garbage collector, limited RAM, non-deterministic timing
uint8_t *buf = (uint8_t *)malloc(256);
if (buf == NULL) {
    // allocation failed — handle this!
}
free(buf);
buf = NULL;  // prevent use-after-free

// Prefer static allocation
static uint8_t buf[256];  // allocated at compile time, always available
```

---

## volatile Keyword

**Critical for embedded.** Tells the compiler a variable can change outside the normal program flow (hardware registers, ISR variables). Without `volatile`, the compiler may optimize away reads, leading to bugs.

```c
// 1. Hardware registers — ALWAYS volatile
volatile uint32_t *GPIO_OUT = (volatile uint32_t *)0x40004004;
*GPIO_OUT |= (1 << 5);  // set bit 5

// 2. Variables shared between ISR and main code — ALWAYS volatile
volatile bool data_ready = false;
volatile uint16_t adc_value = 0;

// ISR (Interrupt Service Routine)
void ADC_IRQHandler(void) {
    adc_value = ADC->RESULT;  // read hardware register
    data_ready = true;
}

// Main loop
while (1) {
    if (data_ready) {          // compiler MUST re-read this each time
        process(adc_value);    // compiler MUST re-read this too
        data_ready = false;
    }
}

// 3. Memory-mapped I/O — ALWAYS volatile
// Without volatile, compiler might:
// - Cache the value in a register and never re-read
// - Eliminate "redundant" writes
// - Reorder reads/writes

// BAD (without volatile):
uint32_t *status = (uint32_t *)0x40004000;
while (*status & 0x01) { }  // compiler may read once, loop forever

// GOOD (with volatile):
volatile uint32_t *status = (volatile uint32_t *)0x40004000;
while (*status & 0x01) { }  // compiler re-reads every iteration
```

---

## const and static

```c
// const — value cannot be modified
const uint8_t MAX_RETRIES = 3;
const char *message = "Hello";      // pointer to const data
char *const ptr = buffer;           // const pointer to mutable data
const char *const name = "fixed";   // const pointer to const data

// const with arrays (stored in flash on many MCUs, saving RAM)
const uint8_t lookup_table[] = {0, 1, 1, 2, 3, 5, 8, 13, 21};
// On AVR, use PROGMEM: const uint8_t table[] PROGMEM = {...};

// static — two meanings depending on context
// 1. Inside a function: persists between calls
void count_calls(void) {
    static uint32_t count = 0;  // initialized once, persists
    count++;
    printf("Called %lu times\n", count);
}

// 2. At file scope: limits visibility to this file (internal linkage)
static void helper_function(void) { /* only visible in this .c file */ }
static uint8_t module_state = 0;    /* only visible in this .c file */
```

---

## #define vs const

```c
// #define — preprocessor text substitution
#define LED_PIN 13
#define MAX_BUF_SIZE 256
#define SQUARE(x) ((x) * (x))          // ALWAYS parenthesize macro args
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define BIT(n) (1UL << (n))

// Pitfalls of #define macros:
// SQUARE(i++) expands to ((i++) * (i++)) — double increment!
// No type safety, no scope

// const — typed, scoped, debuggable
static const uint8_t LED_PIN = 13;
static const size_t MAX_BUF_SIZE = 256;

// enum — for related integer constants
typedef enum {
    STATE_IDLE = 0,
    STATE_RUNNING,
    STATE_ERROR,
    STATE_COUNT     // useful: equals number of states
} State;

// When to use which:
// #define: conditional compilation (#ifdef), stringification, token pasting
// const: typed values, array sizes (in C99+), prefer over #define
// enum: related named integer constants, state machines
```

---

## Structs

```c
// Define a struct
typedef struct {
    uint8_t  id;
    int16_t  temperature;  // in 0.1 degree units
    uint16_t humidity;     // in 0.1% units
    uint32_t timestamp;
} SensorReading;

// Use
SensorReading reading = {
    .id = 1,
    .temperature = 225,   // 22.5 degrees
    .humidity = 450,       // 45.0%
    .timestamp = 1000
};

reading.temperature = 230;

// Packed struct (no padding — for binary protocols)
typedef struct __attribute__((packed)) {
    uint8_t  header;
    uint16_t length;
    uint32_t data;
    uint8_t  checksum;
} Packet;   // exactly 8 bytes, no padding

// Without packed, compiler may insert padding bytes for alignment:
typedef struct {
    uint8_t  a;    // 1 byte
    // 3 bytes padding (to align b to 4-byte boundary)
    uint32_t b;    // 4 bytes
    uint8_t  c;    // 1 byte
    // 3 bytes padding
} Padded;          // sizeof = 12, not 6!

// Bit fields (for compact flag storage)
typedef struct {
    uint8_t enabled  : 1;   // 1 bit
    uint8_t mode     : 3;   // 3 bits (0-7)
    uint8_t channel  : 4;   // 4 bits (0-15)
} Config;  // total: 1 byte
```

---

## Bitwise Operations

Essential for register-level programming.

```c
// Operators
a & b     // AND: both bits must be 1
a | b     // OR: either bit can be 1
a ^ b     // XOR: bits must differ
~a        // NOT: invert all bits
a << n    // left shift by n positions (multiply by 2^n)
a >> n    // right shift by n positions (divide by 2^n)
```

### Bit Manipulation Patterns

These are the fundamental patterns used constantly in embedded code:

```c
// Set a bit (turn ON)
reg |= (1 << bit);
// Example: set bit 5 of PORTB
PORTB |= (1 << 5);             // PORTB = PORTB | 0b00100000

// Clear a bit (turn OFF)
reg &= ~(1 << bit);
// Example: clear bit 3 of PORTB
PORTB &= ~(1 << 3);            // PORTB = PORTB & 0b11110111

// Toggle a bit (flip)
reg ^= (1 << bit);
// Example: toggle bit 2
PORTB ^= (1 << 2);

// Check a bit (read)
if (reg & (1 << bit)) { /* bit is set */ }
// Example: check if bit 7 of PINB is high
if (PINB & (1 << 7)) {
    // pin 7 is HIGH
}

// Set multiple bits
PORTB |= (1 << 5) | (1 << 3) | (1 << 1);

// Clear multiple bits
PORTB &= ~((1 << 5) | (1 << 3));

// Modify a field within a register (read-modify-write)
// Clear the field first, then set new value
reg = (reg & ~(0x07 << 4)) | (new_value << 4);
// Example: set bits 6:4 to 0b101
// Clear: reg & ~(0b01110000) = reg & 0b10001111
// Set:   | (0b101 << 4)     = | 0b01010000

// Extract a field
uint8_t field = (reg >> 4) & 0x07;  // extract bits 6:4

// Useful macros
#define BIT_SET(reg, bit)    ((reg) |= (1UL << (bit)))
#define BIT_CLEAR(reg, bit)  ((reg) &= ~(1UL << (bit)))
#define BIT_TOGGLE(reg, bit) ((reg) ^= (1UL << (bit)))
#define BIT_CHECK(reg, bit)  ((reg) & (1UL << (bit)))
#define BIT_WRITE(reg, bit, val) \
    ((val) ? BIT_SET(reg, bit) : BIT_CLEAR(reg, bit))
```

### Common Bit Tricks

```c
// Check if power of 2
bool is_power_of_2 = (x != 0) && ((x & (x - 1)) == 0);

// Round up to next power of 2
uint32_t next_pow2(uint32_t v) {
    v--; v |= v>>1; v |= v>>2; v |= v>>4; v |= v>>8; v |= v>>16;
    return v + 1;
}

// Count set bits (population count)
uint8_t count_bits(uint32_t v) {
    uint8_t count = 0;
    while (v) { count += v & 1; v >>= 1; }
    return count;
}
// Or use __builtin_popcount(v) on GCC/Clang

// Swap bytes (endian conversion)
uint16_t swap16(uint16_t v) { return (v << 8) | (v >> 8); }
uint32_t swap32(uint32_t v) {
    return ((v >> 24) & 0xFF) | ((v >> 8) & 0xFF00) |
           ((v << 8) & 0xFF0000) | ((v << 24) & 0xFF000000);
}
// Or use __builtin_bswap16(v), __builtin_bswap32(v)

// Create bitmask of n bits
#define BITMASK(n) ((1UL << (n)) - 1)   // BITMASK(4) = 0x0F

// Byte extraction
#define LOW_BYTE(x)  ((uint8_t)((x) & 0xFF))
#define HIGH_BYTE(x) ((uint8_t)(((x) >> 8) & 0xFF))
```

---

## Register-Level Programming

Direct hardware register access on ARM Cortex-M (STM32 example):

```c
// Memory-mapped registers are accessed through pointers
// Base addresses are defined in the MCU header file

// STM32 GPIO example — toggle LED on PA5 (Nucleo boards)
#define GPIOA_BASE    0x40020000
#define GPIOA_MODER   (*(volatile uint32_t *)(GPIOA_BASE + 0x00))
#define GPIOA_ODR     (*(volatile uint32_t *)(GPIOA_BASE + 0x14))
#define GPIOA_BSRR    (*(volatile uint32_t *)(GPIOA_BASE + 0x18))

// Configure PA5 as output (MODER bits 11:10 = 01)
GPIOA_MODER &= ~(0x3 << 10);  // clear bits
GPIOA_MODER |=  (0x1 << 10);  // set as output

// Set PA5 high
GPIOA_ODR |= (1 << 5);

// Set PA5 low
GPIOA_ODR &= ~(1 << 5);

// Atomic set/reset (no read-modify-write needed)
GPIOA_BSRR = (1 << 5);         // set PA5 (bits 15:0 = set)
GPIOA_BSRR = (1 << (5 + 16));  // reset PA5 (bits 31:16 = reset)

// In practice, use the vendor's CMSIS/HAL structs:
#include "stm32f4xx.h"
GPIOA->MODER |= GPIO_MODER_MODER5_0;   // PA5 output
GPIOA->ODR ^= GPIO_ODR_OD5;             // toggle PA5
```

### AVR Register Example

```c
// AVR ATmega328P (Arduino Uno)
#include <avr/io.h>

// Configure PB5 (Arduino pin 13) as output
DDRB |= (1 << DDB5);

// Set PB5 high
PORTB |= (1 << PORTB5);

// Set PB5 low
PORTB &= ~(1 << PORTB5);

// Read PB0 (digital input)
if (PINB & (1 << PINB0)) {
    // pin is HIGH
}

// Configure ADC
ADMUX = (1 << REFS0);           // AVcc reference
ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
// Enable ADC, prescaler = 128

// Start conversion and wait
ADCSRA |= (1 << ADSC);
while (ADCSRA & (1 << ADSC));   // wait for completion
uint16_t result = ADC;           // read 10-bit result
```

---

## Function Pointers

Used extensively for callbacks, state machines, and driver abstractions.

```c
// Basic function pointer
int add(int a, int b) { return a + b; }
int sub(int a, int b) { return a - b; }

int (*operation)(int, int) = add;  // pointer to function
int result = operation(3, 4);       // calls add(3, 4) = 7
operation = sub;
result = operation(3, 4);           // calls sub(3, 4) = -1

// Typedef for cleaner syntax
typedef void (*IRQHandler)(void);
typedef int (*CompareFunc)(const void *, const void *);

// Callback pattern (common in drivers)
typedef void (*DataCallback)(uint8_t *data, size_t len);

typedef struct {
    void (*init)(void);
    void (*write)(const uint8_t *data, size_t len);
    int  (*read)(uint8_t *buf, size_t maxlen);
    void (*set_callback)(DataCallback cb);
} UARTDriver;

// State machine with function pointers
typedef void (*StateFunc)(void);

void state_idle(void);
void state_running(void);
void state_error(void);

StateFunc current_state = state_idle;

// Main loop
while (1) {
    current_state();  // calls whatever state we're in
}

void state_idle(void) {
    if (start_button_pressed()) {
        current_state = state_running;
    }
}
```

---

## Memory-Mapped I/O

On microcontrollers, peripherals (GPIO, UART, SPI, ADC, timers) are controlled by reading and writing to specific memory addresses.

```c
// Generic pattern for memory-mapped register access
#define REG32(addr) (*(volatile uint32_t *)(addr))

// Peripheral base addresses (from datasheet)
#define UART0_BASE   0x40004000
#define UART0_DATA   REG32(UART0_BASE + 0x00)
#define UART0_STATUS REG32(UART0_BASE + 0x04)
#define UART0_CTRL   REG32(UART0_BASE + 0x08)
#define UART0_BAUD   REG32(UART0_BASE + 0x0C)

// Send a byte
void uart_putc(char c) {
    while (!(UART0_STATUS & (1 << 5)));  // wait for TX ready
    UART0_DATA = c;
}

// Receive a byte
char uart_getc(void) {
    while (!(UART0_STATUS & (1 << 0)));  // wait for RX data
    return (char)(UART0_DATA & 0xFF);
}

// Using struct overlay (cleaner approach)
typedef struct {
    volatile uint32_t DATA;
    volatile uint32_t STATUS;
    volatile uint32_t CTRL;
    volatile uint32_t BAUD;
} UART_TypeDef;

#define UART0 ((UART_TypeDef *)0x40004000)
#define UART1 ((UART_TypeDef *)0x40005000)

void uart_send(UART_TypeDef *uart, char c) {
    while (!(uart->STATUS & (1 << 5)));
    uart->DATA = c;
}

uart_send(UART0, 'A');
uart_send(UART1, 'B');
```

---

## Linking and Startup

### Linker Script Basics

The linker script defines where code and data are placed in memory:

```ld
/* Simplified linker script for ARM Cortex-M */
MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 512K
    SRAM  (rwx) : ORIGIN = 0x20000000, LENGTH = 128K
}

SECTIONS
{
    .text :          /* Code (in flash) */
    {
        *(.isr_vector)   /* Interrupt vector table first */
        *(.text*)        /* All code */
        *(.rodata*)      /* Read-only data (const, strings) */
    } > FLASH

    .data :          /* Initialized data (copied from flash to RAM at startup) */
    {
        *(.data*)
    } > SRAM AT > FLASH

    .bss :           /* Uninitialized data (zeroed at startup) */
    {
        *(.bss*)
    } > SRAM

    _stack_top = ORIGIN(SRAM) + LENGTH(SRAM);
}
```

### Startup Code

Before `main()` runs, startup code must:
1. Set up the stack pointer
2. Copy `.data` section from flash to RAM
3. Zero the `.bss` section
4. Call `main()`

```c
// Startup (simplified)
extern uint32_t _sidata, _sdata, _edata, _sbss, _ebss;

void Reset_Handler(void) {
    // Copy .data from flash to RAM
    uint32_t *src = &_sidata;
    uint32_t *dst = &_sdata;
    while (dst < &_edata) *dst++ = *src++;

    // Zero .bss
    dst = &_sbss;
    while (dst < &_ebss) *dst++ = 0;

    // Call main
    main();
    while (1);  // should never reach here
}
```

---

## Common Pitfalls

### Integer Overflow

```c
// DANGER: unsigned overflow wraps silently
uint8_t x = 255;
x++;              // x = 0 (no warning!)

// DANGER: signed overflow is undefined behavior
int8_t y = 127;
y++;              // UNDEFINED — could be -128, could be anything

// DANGER: integer promotion surprises
uint8_t a = 200;
uint8_t b = 100;
uint8_t c = a + b;   // overflow: c = 44 (300 - 256)

// FIX: use larger type for intermediate calculations
uint16_t c = (uint16_t)a + b;  // c = 300

// DANGER: mixing signed and unsigned
int8_t temp = -1;
uint8_t sensor = 200;
if (temp < sensor) { /* might not work! -1 becomes 255 as unsigned */ }
// FIX: explicit cast to same type
if ((int16_t)temp < (int16_t)sensor) { /* correct */ }
```

### Uninitialized Variables

```c
// Local variables are NOT initialized to 0 (unlike globals)
void func(void) {
    int x;            // contains garbage!
    uint8_t buf[64];  // contains garbage!

    // ALWAYS initialize
    int x = 0;
    uint8_t buf[64] = {0};  // zero-fill
    memset(buf, 0, sizeof(buf));
}

// Global and static variables ARE initialized to 0
static int count;     // guaranteed 0
int global_var;       // guaranteed 0
```

### Stack Overflow on MCU

```c
// MCUs have tiny stacks (often 1-4KB)
// Stack overflow corrupts memory silently — hard to debug

// DANGER: large local arrays
void bad_function(void) {
    uint8_t buffer[2048];  // may overflow stack on small MCU!
}

// FIX: use static or global buffers
static uint8_t buffer[2048];  // in .bss, not on stack

// DANGER: deep recursion
int fibonacci(int n) {
    if (n <= 1) return n;
    return fibonacci(n-1) + fibonacci(n-2);  // stack grows with each call
}

// DANGER: printf and friends use lots of stack
printf("Value: %f\n", 3.14);  // may use 500+ bytes of stack on some platforms

// Check stack usage: compile with -fstack-usage (GCC)
// Monitor at runtime: fill stack with pattern, check how much was overwritten
```

### Other Common Issues

```c
// Alignment errors (ARM Cortex-M may fault on unaligned access)
uint8_t buf[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
uint32_t *p = (uint32_t *)&buf[1];  // UNALIGNED! May crash
// FIX: use memcpy
uint32_t val;
memcpy(&val, &buf[1], sizeof(val));

// Forgetting volatile on ISR variables (see volatile section)

// Race conditions between ISR and main code
// WRONG:
volatile uint16_t adc_value;  // 16-bit value on 8-bit MCU
uint16_t local = adc_value;   // NOT atomic! ISR could change between byte reads
// FIX: disable interrupts briefly
cli();                         // disable interrupts (AVR)
uint16_t local = adc_value;
sei();                         // re-enable interrupts

// Or use atomic operations on ARM:
// __disable_irq();
// uint16_t local = adc_value;
// __enable_irq();

// Floating point on MCU without FPU — VERY slow
// Prefer fixed-point math:
// Instead of float temp = 22.5;
int16_t temp_x10 = 225;  // store as 22.5 * 10 = 225

// String constants eating RAM (AVR specific)
// On AVR, "hello" is copied to RAM by default
// FIX: Use PROGMEM
const char msg[] PROGMEM = "Hello, World!";
// Read with: pgm_read_byte(&msg[i]) or use F() macro in Arduino
Serial.println(F("This stays in flash"));
```

---

## Compilation Quick Reference

```bash
# GCC for ARM (typical for STM32, nRF52, etc.)
arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -Os -Wall -Werror \
    -std=c11 -ffunction-sections -fdata-sections \
    -c main.c -o main.o

arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb \
    -Wl,--gc-sections -T linker_script.ld \
    main.o -o firmware.elf

arm-none-eabi-objcopy -O binary firmware.elf firmware.bin
arm-none-eabi-size firmware.elf   # show code/data size

# Useful compiler flags
-Wall -Wextra -Werror    # enable warnings, treat as errors
-Os                       # optimize for size (common for MCU)
-O2                       # optimize for speed
-g                        # include debug info
-ffunction-sections       # each function in its own section
-fdata-sections           # each variable in its own section
-Wl,--gc-sections         # linker: remove unused sections
-fstack-usage             # generate .su files with stack usage per function
-Wstack-usage=256         # warn if function uses more than 256 bytes of stack

# AVR GCC (Arduino Uno, ATmega328P)
avr-gcc -mmcu=atmega328p -Os -Wall -std=c11 -c main.c -o main.o
avr-gcc -mmcu=atmega328p main.o -o main.elf
avr-objcopy -O ihex main.elf main.hex
avrdude -p m328p -c arduino -P /dev/ttyACM0 -U flash:w:main.hex
```
