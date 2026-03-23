#!/usr/bin/env python3
"""Verify all planned documentation files exist."""
import sys
from pathlib import Path

REQUIRED_DOCS = [
    "docs/index.md",
    # Hardware - LoRa
    "docs/hardware/lora/overview.md",
    "docs/hardware/lora/lilygo-tbeam-v1.2.md",
    "docs/hardware/lora/heltec-esp32-v3.md",
    "docs/hardware/lora/lora-parameters.md",
    "docs/hardware/lora/range-optimization.md",
    # Hardware - ESP32
    "docs/hardware/esp32/overview.md",
    "docs/hardware/esp32/esp-idf-setup.md",
    "docs/hardware/esp32/platformio-setup.md",
    "docs/hardware/esp32/arduino-framework.md",
    "docs/hardware/esp32/wifi-programming.md",
    "docs/hardware/esp32/bluetooth-ble.md",
    "docs/hardware/esp32/deep-sleep.md",
    # Hardware - Arduino
    "docs/hardware/arduino/overview.md",
    "docs/hardware/arduino/pinouts.md",
    "docs/hardware/arduino/programming-guide.md",
    "docs/hardware/arduino/libraries.md",
    "docs/hardware/arduino/serial-communication.md",
    "docs/hardware/arduino/interrupts-timers.md",
    # Hardware - Raspberry Pi
    "docs/hardware/raspberry-pi/overview.md",
    "docs/hardware/raspberry-pi/gpio-pinout.md",
    "docs/hardware/raspberry-pi/setup-headless.md",
    "docs/hardware/raspberry-pi/networking.md",
    "docs/hardware/raspberry-pi/common-projects.md",
    # Hardware - Displays
    "docs/hardware/displays/oled-ssd1306.md",
    "docs/hardware/displays/lcd-1602-2004.md",
    "docs/hardware/displays/tft-displays.md",
    "docs/hardware/displays/e-ink.md",
    # Hardware - Peripherals
    "docs/hardware/peripherals/sensors.md",
    "docs/hardware/peripherals/relays-mosfets.md",
    "docs/hardware/peripherals/motor-control.md",
    "docs/hardware/peripherals/gps-modules.md",
    "docs/hardware/peripherals/cameras.md",
    # Protocols
    "docs/protocols/i2c.md",
    "docs/protocols/spi.md",
    "docs/protocols/uart-serial.md",
    "docs/protocols/onewire.md",
    "docs/protocols/pwm.md",
    "docs/protocols/adc-dac.md",
    "docs/protocols/mqtt.md",
    "docs/protocols/modbus.md",
    # Electronics
    "docs/electronics/fundamentals.md",
    "docs/electronics/resistor-color-codes.md",
    "docs/electronics/capacitors.md",
    "docs/electronics/transistors.md",
    "docs/electronics/diodes.md",
    "docs/electronics/voltage-regulators.md",
    "docs/electronics/op-amps.md",
    "docs/electronics/common-circuits.md",
    "docs/electronics/soldering.md",
    "docs/electronics/pcb-design.md",
    "docs/electronics/test-equipment.md",
    # Power
    "docs/power/battery-types.md",
    "docs/power/battery-management.md",
    "docs/power/solar-charging.md",
    "docs/power/power-calculations.md",
    "docs/power/18650-guide.md",
    # Radio
    "docs/radio/fundamentals.md",
    "docs/radio/amateur-radio-bands.md",
    "docs/radio/frs-gmrs-pmr.md",
    "docs/radio/baofeng-uv5r.md",
    "docs/radio/chirp-programming.md",
    "docs/radio/morse-code.md",
    "docs/radio/phonetic-alphabet.md",
    "docs/radio/q-codes.md",
    "docs/radio/antenna-basics.md",
    "docs/radio/repeater-basics.md",
    "docs/radio/emergency-frequencies.md",
    "docs/radio/radio-regulations.md",
    # SDR
    "docs/sdr/overview.md",
    "docs/sdr/rtl-sdr-setup.md",
    "docs/sdr/sdrsharp.md",
    "docs/sdr/gqrx.md",
    "docs/sdr/cubicsdr.md",
    "docs/sdr/gnu-radio.md",
    "docs/sdr/rtl_433.md",
    "docs/sdr/adsb-tracking.md",
    "docs/sdr/ais-marine.md",
    "docs/sdr/weather-satellites.md",
    "docs/sdr/trunking.md",
    "docs/sdr/digital-modes.md",
    "docs/sdr/frequency-reference.md",
    # Mesh Networking
    "docs/mesh-networking/meshtastic-overview.md",
    "docs/mesh-networking/meshtastic-setup.md",
    "docs/mesh-networking/meshtastic-config.md",
    "docs/mesh-networking/meshtastic-tbeam.md",
    "docs/mesh-networking/meshtastic-heltec.md",
    "docs/mesh-networking/mesh-network-planning.md",
    "docs/mesh-networking/lora-mesh-alternatives.md",
    # Programming
    "docs/programming/python-quickref.md",
    "docs/programming/micropython.md",
    "docs/programming/circuitpython.md",
    "docs/programming/nodejs-quickref.md",
    "docs/programming/c-cpp-embedded.md",
    "docs/programming/bash-scripting.md",
    "docs/programming/git-reference.md",
    "docs/programming/regex-reference.md",
    # Networking
    "docs/networking/ip-subnetting.md",
    "docs/networking/wifi-setup.md",
    "docs/networking/ssh-reference.md",
    "docs/networking/vpn-wireguard.md",
    "docs/networking/dns-dhcp.md",
    # Survival
    "docs/survival/solar-setup-guide.md",
    "docs/survival/water-resistant-enclosures.md",
    "docs/survival/field-repair.md",
    "docs/survival/usb-stick-usage-guide.md",
]


def main():
    missing = []
    for doc in REQUIRED_DOCS:
        if not Path(doc).exists():
            missing.append(doc)

    if missing:
        print(f"FAIL: {len(missing)} required doc(s) missing:")
        for m in missing:
            print(f"  - {m}")
        sys.exit(1)

    print(f"OK: All {len(REQUIRED_DOCS)} required docs exist.")

    # Check no docs are empty
    empty = []
    for doc in REQUIRED_DOCS:
        if Path(doc).stat().st_size < 100:
            empty.append(doc)

    if empty:
        print(f"FAIL: {len(empty)} doc(s) appear empty (<100 bytes):")
        for e in empty:
            print(f"  - {e} ({Path(e).stat().st_size} bytes)")
        sys.exit(1)

    print(f"OK: All docs have content (>100 bytes).")


if __name__ == "__main__":
    main()
