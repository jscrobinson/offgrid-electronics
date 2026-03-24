# Tech Survival USB — Documentation Index

> Offline reference library for electronics, radio, and mesh networking.

## Hardware

### LoRa Devices
- [LoRa Overview](hardware/lora/overview.md) — Technology fundamentals
- [Lilygo T-Beam v1.2](hardware/lora/lilygo-tbeam-v1.2.md) — ESP32 + SX1276/62 + GPS + AXP2101
- [Heltec ESP32 V3](hardware/lora/heltec-esp32-v3.md) — ESP32-S3 + SX1262 + OLED
- [LoRa Parameters](hardware/lora/lora-parameters.md) — SF, BW, CR, frequency plans
- [Range Optimization](hardware/lora/range-optimization.md)

### ESP32
- [ESP32 Overview](hardware/esp32/overview.md) — ESP32 vs S3 vs C3
- [ESP-IDF Setup](hardware/esp32/esp-idf-setup.md)
- [PlatformIO Setup](hardware/esp32/platformio-setup.md)
- [Arduino Framework](hardware/esp32/arduino-framework.md)
- [WiFi Programming](hardware/esp32/wifi-programming.md)
- [Bluetooth / BLE](hardware/esp32/bluetooth-ble.md)
- [Deep Sleep](hardware/esp32/deep-sleep.md)

### Arduino
- [Arduino Overview](hardware/arduino/overview.md) — Uno, Nano, Mega
- [Pinouts](hardware/arduino/pinouts.md)
- [Programming Guide](hardware/arduino/programming-guide.md)
- [Libraries](hardware/arduino/libraries.md)
- [Serial Communication](hardware/arduino/serial-communication.md)
- [Interrupts & Timers](hardware/arduino/interrupts-timers.md)

### Raspberry Pi
- [Raspberry Pi Overview](hardware/raspberry-pi/overview.md)
- [GPIO Pinout](hardware/raspberry-pi/gpio-pinout.md)
- [Headless Setup](hardware/raspberry-pi/setup-headless.md)
- [Networking](hardware/raspberry-pi/networking.md)
- [Common Projects](hardware/raspberry-pi/common-projects.md)

### Displays
- [OLED SSD1306](hardware/displays/oled-ssd1306.md)
- [LCD 1602/2004](hardware/displays/lcd-1602-2004.md)
- [TFT Displays](hardware/displays/tft-displays.md)
- [E-Ink Displays](hardware/displays/e-ink.md)

### Peripherals
- [Sensors](hardware/peripherals/sensors.md)
- [Relays & MOSFETs](hardware/peripherals/relays-mosfets.md)
- [Motor Control](hardware/peripherals/motor-control.md)
- [GPS Modules](hardware/peripherals/gps-modules.md)
- [Cameras](hardware/peripherals/cameras.md)

## Communication Protocols
- [I2C](protocols/i2c.md)
- [SPI](protocols/spi.md)
- [UART / Serial](protocols/uart-serial.md)
- [OneWire](protocols/onewire.md)
- [PWM](protocols/pwm.md)
- [ADC / DAC](protocols/adc-dac.md)
- [MQTT](protocols/mqtt.md)
- [Modbus](protocols/modbus.md)

## Electronics Fundamentals
- [Fundamentals](electronics/fundamentals.md) — Ohm's law, Kirchhoff, dividers
- [Resistor Color Codes](electronics/resistor-color-codes.md)
- [Capacitors](electronics/capacitors.md)
- [Transistors](electronics/transistors.md)
- [Diodes](electronics/diodes.md)
- [Voltage Regulators](electronics/voltage-regulators.md)
- [Op-Amps](electronics/op-amps.md)
- [Common Circuits](electronics/common-circuits.md)
- [Soldering](electronics/soldering.md)
- [PCB Design](electronics/pcb-design.md)
- [Test Equipment](electronics/test-equipment.md)

## Power Systems
- [Battery Types](power/battery-types.md)
- [Battery Management](power/battery-management.md)
- [Solar Charging](power/solar-charging.md)
- [Power Calculations](power/power-calculations.md)
- [18650 Guide](power/18650-guide.md)

## Radio
- [RF Fundamentals](radio/fundamentals.md)
- [Amateur Radio Bands](radio/amateur-radio-bands.md)
- [FRS / GMRS / PMR](radio/frs-gmrs-pmr.md)
- [Baofeng UV-5R / JucJet UV5RH](radio/baofeng-uv5r.md)
- [CHIRP Programming](radio/chirp-programming.md)
- [Morse Code](radio/morse-code.md)
- [NATO Phonetic Alphabet](radio/phonetic-alphabet.md)
- [Q-Codes](radio/q-codes.md)
- [Antenna Basics](radio/antenna-basics.md)
- [Repeater Basics](radio/repeater-basics.md)
- [Emergency Frequencies](radio/emergency-frequencies.md)
- [Radio Regulations](radio/radio-regulations.md)

## Software Defined Radio (SDR)
- [SDR Overview](sdr/overview.md)
- [RTL-SDR Setup](sdr/rtl-sdr-setup.md)
- [SDR# (SDRSharp)](sdr/sdrsharp.md)
- [GQRX](sdr/gqrx.md)
- [CubicSDR](sdr/cubicsdr.md)
- [GNU Radio](sdr/gnu-radio.md)
- [rtl_433 — ISM Decoding](sdr/rtl_433.md)
- [ADS-B Aircraft Tracking](sdr/adsb-tracking.md)
- [AIS Marine Tracking](sdr/ais-marine.md)
- [Weather Satellites](sdr/weather-satellites.md)
- [Trunked Radio](sdr/trunking.md)
- [Digital Modes](sdr/digital-modes.md)
- [Frequency Reference](sdr/frequency-reference.md)

## Mesh Networking
- [Meshtastic Overview](mesh-networking/meshtastic-overview.md)
- [Meshtastic Setup](mesh-networking/meshtastic-setup.md)
- [Meshtastic Config](mesh-networking/meshtastic-config.md)
- [Meshtastic on T-Beam](mesh-networking/meshtastic-tbeam.md)
- [Meshtastic on Heltec V3](mesh-networking/meshtastic-heltec.md)
- [MeshCore](mesh-networking/meshcore.md)
- [Mesh Network Planning](mesh-networking/mesh-network-planning.md)
- [LoRa Mesh Alternatives](mesh-networking/lora-mesh-alternatives.md)

## Programming
- [Python Quick Reference](programming/python-quickref.md)
- [MicroPython](programming/micropython.md)
- [CircuitPython](programming/circuitpython.md)
- [Node.js Quick Reference](programming/nodejs-quickref.md)
- [C/C++ Embedded](programming/c-cpp-embedded.md)
- [Bash Scripting](programming/bash-scripting.md)
- [Git Reference](programming/git-reference.md)
- [Regex Reference](programming/regex-reference.md)

## Networking
- [IP & Subnetting](networking/ip-subnetting.md)
- [WiFi Setup (AP Mode)](networking/wifi-setup.md)
- [SSH Reference](networking/ssh-reference.md)
- [VPN — WireGuard](networking/vpn-wireguard.md)
- [DNS & DHCP](networking/dns-dhcp.md)

## Survival / Field
- [Solar Setup Guide](survival/solar-setup-guide.md)
- [Water-Resistant Enclosures](survival/water-resistant-enclosures.md)
- [Field Repair](survival/field-repair.md)
- [USB Stick Usage Guide](survival/usb-stick-usage-guide.md)
