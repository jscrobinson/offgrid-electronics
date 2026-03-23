# Modbus Protocol

## Overview

Modbus is a serial communication protocol originally published by Modicon (now Schneider Electric) in 1979 for use with programmable logic controllers (PLCs). It has become a de facto standard for industrial communication and is widely used in building automation, energy monitoring, and industrial IoT.

```
Modbus RTU (RS-485):

Master ──[RS-485 Bus]──┬── Slave 1 (addr 1)
                        ├── Slave 2 (addr 2)
                        ├── Slave 3 (addr 3)
                        └── ...up to 247 slaves

Modbus TCP (Ethernet):

Client ──[TCP/IP Network]──┬── Server 1 (IP:port 502)
                            ├── Server 2 (IP:port 502)
                            └── Server 3 (IP:port 502)
```

**Key characteristics:**
- **Master-slave** architecture (RTU/ASCII) or client-server (TCP)
- **Simple:** Register-based data model, well-defined function codes
- **Open standard:** No licensing fees, widely supported
- **Two main variants:** RTU (serial/RS-485) and TCP (Ethernet)
- **Request-response:** Master always initiates, slave responds
- **Up to 247 slave devices** on one RTU bus

---

## Modbus Variants

| Variant     | Physical Layer | Framing        | Speed         | Notes                          |
|------------|----------------|----------------|---------------|--------------------------------|
| Modbus RTU | RS-485 (or RS-232) | Binary, CRC-16 | 1200-115200 baud | Most common serial variant |
| Modbus ASCII| RS-485 (or RS-232) | ASCII hex, LRC | 1200-19200 baud | Human-readable, slower     |
| Modbus TCP | Ethernet (TCP/IP) | Binary, no CRC | Network speed | Port 502, most modern variant |
| Modbus RTU over TCP | Ethernet | RTU frame wrapped in TCP | Network speed | Hybrid, used by some gateways |

**Modbus RTU** is the most common for RS-485 field devices (sensors, meters, inverters).
**Modbus TCP** is used for Ethernet-connected devices, SCADA, and gateways.

---

## Data Model — Register Types

Modbus organizes data into four types of registers:

| Register Type      | Address Range    | Size    | Access     | Description                          |
|-------------------|-----------------|---------|------------|--------------------------------------|
| Coils             | 00001-09999     | 1 bit   | Read/Write | Digital outputs (relays, switches)   |
| Discrete Inputs   | 10001-19999     | 1 bit   | Read Only  | Digital inputs (sensors, buttons)    |
| Input Registers   | 30001-39999     | 16 bits | Read Only  | Analog inputs (sensor readings)      |
| Holding Registers | 40001-49999     | 16 bits | Read/Write | Configuration, setpoints, R/W data   |

**Address convention:**
- Modbus documentation often uses 1-based addresses (40001, 40002, etc.)
- The actual protocol uses 0-based addresses (0x0000, 0x0001, etc.)
- So "Holding Register 40001" = protocol address 0x0000
- **This off-by-one confusion causes many integration errors.** Always verify whether addresses are 0-based or 1-based in your device documentation

### Data Representation

Registers are 16-bit (two bytes). For values that don't fit in 16 bits:

| Data Type      | Registers | Byte Order Notes                          |
|---------------|-----------|-------------------------------------------|
| 16-bit integer | 1 register | Unsigned: 0-65535, Signed: -32768 to 32767 |
| 32-bit integer | 2 registers | Word order varies by device (check docs!) |
| 32-bit float   | 2 registers | IEEE 754, word order varies               |
| 64-bit value   | 4 registers | Rare, word order varies                   |

**Big-endian vs little-endian word order is NOT standardized across devices.** Some use register[0]=high word, register[1]=low word. Others reverse it. Always check the device documentation or test empirically.

---

## Function Codes

| Code | Name                      | Description                           |
|------|---------------------------|---------------------------------------|
| 0x01 | Read Coils               | Read 1-2000 coil bits                |
| 0x02 | Read Discrete Inputs     | Read 1-2000 discrete input bits      |
| 0x03 | Read Holding Registers   | Read 1-125 holding registers         |
| 0x04 | Read Input Registers     | Read 1-125 input registers           |
| 0x05 | Write Single Coil        | Write one coil (ON=0xFF00, OFF=0x0000)|
| 0x06 | Write Single Register    | Write one holding register           |
| 0x0F | Write Multiple Coils     | Write 1-1968 coils                   |
| 0x10 | Write Multiple Registers | Write 1-123 holding registers        |

**Most commonly used:** 0x03 (Read Holding Registers) and 0x06/0x10 (Write Single/Multiple Registers).

### Error Responses

If a slave encounters an error, it responds with the function code + 0x80 and an exception code:

| Exception Code | Name                | Description                         |
|---------------|---------------------|-------------------------------------|
| 0x01          | Illegal Function    | Function code not supported         |
| 0x02          | Illegal Data Address| Register address doesn't exist      |
| 0x03          | Illegal Data Value  | Value out of range                  |
| 0x04          | Slave Device Failure| Internal device error               |
| 0x06          | Slave Device Busy   | Device is busy, retry later         |

---

## Modbus RTU Frame Format

```
| Slave Addr | Function Code | Data            | CRC-16   |
| 1 byte     | 1 byte        | N bytes         | 2 bytes  |
| (1-247)    |               | (varies by FC)  | (low, high) |
```

**Example: Read Holding Register 40001 from slave 1:**

Request (Master → Slave):
```
| 01 | 03 | 00 00 | 00 01 | 84 0A |
| Addr | FC | Start Reg | Quantity | CRC  |
```

Response (Slave → Master):
```
| 01 | 03 | 02 | 01 F4 | B8 44 |
| Addr | FC | Byte Count | Data (500) | CRC |
```

### Timing (RTU)

Modbus RTU uses silence (gaps) to delimit frames:
- **Inter-frame gap:** At least 3.5 character times of silence between frames
- **Inter-character gap:** Maximum 1.5 character times between bytes within a frame
- If the inter-character gap is exceeded, the frame is discarded

At 9600 baud (8E1 = 11 bits/char):
- 1 character time = 11 / 9600 = 1.146 ms
- 3.5 char gap = ~4.0 ms
- 1.5 char gap = ~1.7 ms

**Common configuration:** 9600 baud, 8 data bits, Even parity, 1 stop bit (8E1). Some devices use 8N1 or 8N2 instead.

---

## RS-485 Physical Layer

RS-485 is a differential signaling standard used for Modbus RTU wiring.

### Two-Wire RS-485 (Half-Duplex)

Most common for Modbus RTU:

```
                          A (D+)
Master ──[MAX485]─────────┬──────────────────────┬── [MAX485]── Slave 1
                          │     Twisted pair      │
                  B (D-)  │                       │
         ────────────────┬┼──────────────────────┬┼── ────── Slave 2
                         ││                      ││
                      [120Ω]                   [120Ω]
                   (Termination)            (Termination)
                         ││                      ││
                        GND ──────────────────── GND
```

### RS-485 Transceiver ICs

| IC        | Voltage | Speed     | Half/Full Duplex | Notes                      |
|-----------|---------|-----------|------------------|----------------------------|
| MAX485    | 5V      | 2.5 Mbps  | Half duplex      | Classic, most common        |
| MAX3485   | 3.3V    | 10 Mbps   | Half duplex      | 3.3V version of MAX485     |
| SP3485    | 3.3V    | 10 Mbps   | Half duplex      | Drop-in MAX485 replacement |
| MAX13487  | 3.3V    | 500 kbps  | Half duplex      | Auto-direction, no DE/RE   |
| SN65HVD12 | 3.3V   | 1 Mbps    | Half duplex      | TI alternative              |

### MAX485 Wiring

```
              MAX485
          ┌──────────┐
 RO  ←────┤1       8├──── Vcc (5V)
 RE  ─────┤2       7├──── B (D-)  ──── Bus B
 DE  ─────┤3       6├──── A (D+)  ──── Bus A
 DI  ────►┤4       5├──── GND
          └──────────┘

MCU connections:
  RO → MCU RX (receive data from bus)
  DI ← MCU TX (transmit data to bus)
  DE + RE tied together ← MCU GPIO (direction control)
    HIGH = Transmit mode
    LOW  = Receive mode
```

**Direction control:** The master must switch DE/RE HIGH before transmitting, then switch to LOW after the last byte is fully sent (including the stop bit). Switching too early truncates the transmission.

```cpp
#define DE_RE_PIN 4

void sendModbusFrame(uint8_t *frame, int len) {
    digitalWrite(DE_RE_PIN, HIGH);  // Enable transmit
    Serial1.write(frame, len);
    Serial1.flush();                // Wait for all bytes to transmit
    digitalWrite(DE_RE_PIN, LOW);   // Back to receive mode
}
```

### Auto-Direction Transceiver

The **MAX13487** automatically detects transmission direction without a DE/RE pin. Simplifies wiring but adds ~10us latency.

### RS-485 Wiring Best Practices

1. **Use twisted pair cable** — Cat5/Cat6 works well (use one pair for A/B)
2. **Termination resistors:** 120 ohm at each end of the bus (first and last device)
3. **Bias resistors:** Pull A to Vcc through 390-680 ohm, pull B to GND through 390-680 ohm (keeps bus in known state when idle)
4. **Common ground:** All devices must share a ground reference. Run a separate ground wire alongside A/B
5. **Bus topology:** Linear (daisy chain) only — NO star/T topology
6. **Maximum length:** 1200m at low baud rates (9600), shorter at higher speeds
7. **Maximum devices:** 32 unit loads per segment (use repeaters for more)
8. **Shielding:** Use shielded twisted pair in electrically noisy environments. Ground shield at ONE end only

```
Correct (daisy chain):
Master ──── Slave 1 ──── Slave 2 ──── Slave 3
[120Ω]                                  [120Ω]

Wrong (star):
              Slave 1
             /
Master ──── Hub ──── Slave 2
             \
              Slave 3
```

---

## Modbus TCP

Modbus TCP wraps the Modbus PDU (Protocol Data Unit) in a TCP/IP packet. It uses standard Ethernet networking on port 502.

### Modbus TCP Frame (MBAP Header + PDU)

```
| Transaction ID | Protocol ID | Length | Unit ID | Function Code | Data    |
| 2 bytes        | 2 bytes (0) | 2 bytes| 1 byte  | 1 byte        | N bytes |
```

- **Transaction ID:** Matches request with response (incremented by client)
- **Protocol ID:** Always 0x0000 for Modbus
- **Length:** Byte count of remaining fields
- **Unit ID:** Slave address (for RS-485 gateways), typically 1 or 0xFF for direct TCP devices
- No CRC needed (TCP handles error detection)

---

## Arduino Modbus (RTU Slave)

### Using ModbusMaster Library (RTU Master)

```cpp
#include <ModbusMaster.h>

#define DE_RE_PIN 4

ModbusMaster node;

void preTransmission() {
    digitalWrite(DE_RE_PIN, HIGH);
}

void postTransmission() {
    digitalWrite(DE_RE_PIN, LOW);
}

void setup() {
    Serial.begin(115200);     // Debug
    Serial1.begin(9600);      // Modbus RTU bus (8N1 or 8E1)

    pinMode(DE_RE_PIN, OUTPUT);
    digitalWrite(DE_RE_PIN, LOW);

    node.begin(1, Serial1);   // Slave address 1, on Serial1
    node.preTransmission(preTransmission);
    node.postTransmission(postTransmission);
}

void loop() {
    uint8_t result;

    // Read 2 holding registers starting at address 0 from slave 1
    result = node.readHoldingRegisters(0, 2);

    if (result == node.ku8MBSuccess) {
        uint16_t reg0 = node.getResponseBuffer(0);
        uint16_t reg1 = node.getResponseBuffer(1);
        Serial.printf("Register 0: %d, Register 1: %d\n", reg0, reg1);
    } else {
        Serial.printf("Modbus error: 0x%02X\n", result);
    }

    delay(1000);
}
```

### Using ModbusRTU Library (RTU Slave on ESP32)

```cpp
#include <ModbusRTU.h>

#define DE_RE_PIN 4

ModbusRTU mb;

void setup() {
    Serial.begin(115200);
    Serial1.begin(9600, SERIAL_8E1, 16, 17);  // RX=16, TX=17

    mb.begin(&Serial1, DE_RE_PIN);
    mb.slave(1);  // Slave address 1

    // Add holding registers (address, default value)
    mb.addHreg(0, 0);    // Register 0
    mb.addHreg(1, 0);    // Register 1
    mb.addHreg(2, 0);    // Register 2
}

void loop() {
    mb.task();  // Process Modbus requests

    // Update register values from sensors
    mb.Hreg(0, analogRead(34));       // Register 0 = ADC reading
    mb.Hreg(1, (uint16_t)(25.5 * 10)); // Register 1 = temperature × 10

    delay(10);
}
```

---

## Python Modbus

### pymodbus (RTU Master)

```python
from pymodbus.client import ModbusSerialClient
import struct

# RTU connection
client = ModbusSerialClient(
    port='/dev/ttyUSB0',
    baudrate=9600,
    bytesize=8,
    parity='E',       # 'N', 'E', or 'O'
    stopbits=1,
    timeout=1
)

client.connect()

# Read 2 holding registers from slave 1, starting at address 0
result = client.read_holding_registers(address=0, count=2, slave=1)

if not result.isError():
    print(f"Register 0: {result.registers[0]}")
    print(f"Register 1: {result.registers[1]}")

    # Decode 32-bit float from two 16-bit registers
    raw = struct.pack('>HH', result.registers[0], result.registers[1])
    value = struct.unpack('>f', raw)[0]
    print(f"Float value: {value:.2f}")
else:
    print(f"Error: {result}")

# Write single register
client.write_register(address=0, value=1000, slave=1)

# Write multiple registers
client.write_registers(address=0, values=[100, 200, 300], slave=1)

# Read coils
coils = client.read_coils(address=0, count=8, slave=1)
if not coils.isError():
    print(f"Coils: {coils.bits[:8]}")

# Write single coil
client.write_coil(address=0, value=True, slave=1)

client.close()
```

### pymodbus (TCP Client)

```python
from pymodbus.client import ModbusTcpClient

client = ModbusTcpClient('192.168.1.100', port=502)
client.connect()

result = client.read_holding_registers(address=0, count=10, slave=1)
if not result.isError():
    for i, val in enumerate(result.registers):
        print(f"Register {i}: {val}")

client.close()
```

### pymodbus (RTU Slave/Server)

```python
from pymodbus.server import StartSerialServer
from pymodbus.datastore import (
    ModbusSlaveContext,
    ModbusServerContext,
    ModbusSequentialDataBlock
)

# Create data blocks
store = ModbusSlaveContext(
    di=ModbusSequentialDataBlock(0, [0]*100),  # Discrete inputs
    co=ModbusSequentialDataBlock(0, [0]*100),  # Coils
    hr=ModbusSequentialDataBlock(0, [0]*100),  # Holding registers
    ir=ModbusSequentialDataBlock(0, [0]*100),  # Input registers
)

context = ModbusServerContext(slaves={1: store}, single=False)

# Start RTU server (slave)
StartSerialServer(
    context=context,
    port='/dev/ttyUSB0',
    baudrate=9600,
    parity='E',
    stopbits=1,
)
```

Install: `pip install pymodbus`

### minimalmodbus (Simpler Alternative)

```python
import minimalmodbus

# Connect to instrument on slave address 1
instrument = minimalmodbus.Instrument('/dev/ttyUSB0', 1)
instrument.serial.baudrate = 9600
instrument.serial.parity = 'E'
instrument.serial.timeout = 1

# Read holding register 0
value = instrument.read_register(0, functioncode=3)
print(f"Value: {value}")

# Read with decimal places (auto-divides)
temp = instrument.read_register(0, number_of_decimals=1, functioncode=3)
print(f"Temperature: {temp}")

# Write register
instrument.write_register(0, 1000, functioncode=6)

# Read float (two registers)
value = instrument.read_float(0, functioncode=3, number_of_registers=2)
print(f"Float: {value}")
```

Install: `pip install minimalmodbus`

---

## Common Modbus Devices

| Device Type           | Typical Registers                      | Notes                        |
|----------------------|----------------------------------------|------------------------------|
| Energy meter (SDM120)| Voltage, current, power, energy, freq  | Holding registers, float     |
| Solar inverter       | DC voltage/current, AC power, status   | Varies by manufacturer       |
| Temperature sensor   | Temperature, humidity, dew point       | Input or holding registers   |
| VFD (motor drive)    | Speed, frequency, current, status      | Holding registers, control   |
| PLC                  | I/O status, process variables          | All register types           |
| Battery BMS          | Voltage, current, SOC, temperature     | Input registers typically    |
| Flow meter           | Flow rate, total volume                | Input registers, float       |

### SDM120 Energy Meter Example (Popular for Solar)

```python
import minimalmodbus

meter = minimalmodbus.Instrument('/dev/ttyUSB0', 1)
meter.serial.baudrate = 2400  # SDM120 default is 2400
meter.serial.parity = 'N'
meter.mode = minimalmodbus.MODE_RTU

# SDM120 registers (IEEE 754 float, 2 registers each)
voltage     = meter.read_float(0x0000, functioncode=4, number_of_registers=2)
current     = meter.read_float(0x0006, functioncode=4, number_of_registers=2)
power       = meter.read_float(0x000C, functioncode=4, number_of_registers=2)
frequency   = meter.read_float(0x0046, functioncode=4, number_of_registers=2)
total_kwh   = meter.read_float(0x0156, functioncode=4, number_of_registers=2)

print(f"Voltage: {voltage:.1f} V")
print(f"Current: {current:.3f} A")
print(f"Power: {power:.1f} W")
print(f"Frequency: {frequency:.1f} Hz")
print(f"Total: {total_kwh:.2f} kWh")
```

---

## Modbus Tools

### Command-Line Tools

```bash
# modpoll — Modbus polling tool (free)
# Read 10 holding registers from slave 1 at address 0
modpoll -m rtu -a 1 -r 1 -c 10 -b 9600 -p even /dev/ttyUSB0

# mbpoll — Another Modbus CLI tool
sudo apt install mbpoll
mbpoll -m rtu -a 1 -b 9600 -P even -r 1 -c 10 /dev/ttyUSB0

# Read Modbus TCP
mbpoll -m tcp -a 1 -r 1 -c 10 192.168.1.100
```

### GUI Tools

- **QModMaster** — Free, cross-platform Modbus master (good for testing)
- **ModRSsim2** — Windows Modbus slave simulator
- **CAS Modbus Scanner** — Windows, auto-scans registers
- **mbtget** — Simple command-line Modbus TCP client

---

## Troubleshooting

| Problem                    | Likely Cause                        | Fix                                    |
|---------------------------|-------------------------------------|----------------------------------------|
| No response from slave    | Wrong baud rate or parity           | Match exactly (check device manual)    |
| No response from slave    | Wrong slave address                 | Verify address (some start at 1, others 0) |
| No response from slave    | A/B wires swapped                   | Swap A and B                           |
| No response from slave    | DE/RE not switching correctly       | Check direction control timing         |
| CRC error                 | Noise on RS-485 bus                 | Add termination resistors, check wiring|
| CRC error                 | Wrong parity setting                | Match parity on both ends              |
| Wrong values              | Register address off by one         | Check 0-based vs 1-based addressing   |
| Wrong values (float)      | Word order (byte swap) wrong        | Try swapping the two registers         |
| Timeout                   | Cable too long without termination  | Add 120 ohm termination at both ends   |
| Works for one device, not multiple | Missing bias resistors    | Add bias resistors to bus              |
| Intermittent errors       | Bus topology is star, not daisy chain| Re-wire as linear daisy chain         |
| Multiple masters conflict | Only one master allowed on RTU bus  | Use one master, or switch to TCP       |

### Debugging Steps

1. **Verify physical layer first:** Use a multimeter to check A-B voltage (should be ~200mV to ~5V differential)
2. **Use a USB-RS485 adapter** with a PC to test: connect to the bus and try reading with QModMaster
3. **Check with a logic analyzer** or oscilloscope on the A/B lines
4. **Start with one slave** and verify communication before adding more
5. **Match all settings exactly:** baud rate, parity, stop bits, slave address, register addresses

### Common Serial Settings by Device

| Device Category           | Typical Settings       |
|--------------------------|------------------------|
| Energy meters (Eastron)  | 2400/9600, 8N1         |
| Solar inverters (SMA)    | 9600, 8N1              |
| Solar inverters (Huawei) | 9600, 8N1 (Modbus TCP preferred) |
| VFDs                     | 9600/19200, 8E1        |
| Temperature controllers  | 9600, 8N1 or 8E1       |
| PLCs (Siemens, Allen-Bradley) | 9600/19200, 8E1  |
