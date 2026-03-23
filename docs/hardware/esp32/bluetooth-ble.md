# ESP32 Bluetooth and BLE Programming

## Overview

The ESP32 supports two Bluetooth protocols:

- **Classic Bluetooth (BT):** Available only on the original ESP32. Includes SPP (Serial Port Profile) for wireless serial communication and A2DP for audio streaming.
- **Bluetooth Low Energy (BLE):** Available on ESP32, ESP32-S3, ESP32-C3, and ESP32-C6. Used for low-power sensor broadcasting, beacons, and short data exchanges.

The ESP32-S2 has no Bluetooth at all.

---

## Classic Bluetooth: Serial Port Profile (SPP)

SPP provides a wireless serial port, behaving exactly like a UART. Useful for sending data to a phone or PC wirelessly without WiFi infrastructure.

### Basic Bluetooth Serial

```cpp
#include "BluetoothSerial.h"

BluetoothSerial SerialBT;

void setup() {
    Serial.begin(115200);

    if (!SerialBT.begin("ESP32-Sensor")) {  // Bluetooth device name
        Serial.println("Bluetooth init failed!");
        return;
    }

    Serial.println("Bluetooth started. Pair with 'ESP32-Sensor'");
}

void loop() {
    // Forward data between USB Serial and Bluetooth Serial
    if (Serial.available()) {
        SerialBT.write(Serial.read());
    }
    if (SerialBT.available()) {
        Serial.write(SerialBT.read());
    }
    delay(1);
}
```

### Bluetooth Serial with PIN

```cpp
void setup() {
    SerialBT.begin("ESP32-Sensor");
    SerialBT.setPin("1234");  // Pairing PIN
    Serial.println("Bluetooth started with PIN: 1234");
}
```

### Checking Connection Status

```cpp
void loop() {
    if (SerialBT.connected()) {
        SerialBT.printf("Uptime: %lu sec\n", millis() / 1000);
    }
    delay(1000);
}
```

### Bluetooth Serial Callbacks

```cpp
void btCallback(esp_spp_cb_event_t event, esp_spp_cb_param_t *param) {
    switch (event) {
        case ESP_SPP_SRV_OPEN_EVT:
            Serial.println("Client connected");
            break;
        case ESP_SPP_CLOSE_EVT:
            Serial.println("Client disconnected");
            break;
    }
}

void setup() {
    SerialBT.register_callback(btCallback);
    SerialBT.begin("ESP32-Sensor");
}
```

**Note:** Classic Bluetooth is only available on the original ESP32. It is NOT available on S2, S3, C3, or C6.

---

## BLE Fundamentals

### GATT Architecture

BLE communication is based on GATT (Generic Attribute Profile):

```
Server (ESP32)
  └── Service (e.g., "Environmental Sensing")
        ├── Characteristic (e.g., "Temperature")
        │     ├── Value: 23.5
        │     ├── Properties: Read, Notify
        │     └── Descriptor (e.g., CCCD for enabling notifications)
        └── Characteristic (e.g., "Humidity")
              ├── Value: 65.2
              └── Properties: Read
```

- **Server:** The device that holds data (usually the ESP32 sensor)
- **Client:** The device that reads data (usually a phone or computer)
- **Service:** A collection of related characteristics (identified by UUID)
- **Characteristic:** A single data point (identified by UUID)
- **Descriptor:** Metadata about a characteristic

### Standard UUIDs vs Custom UUIDs

Standard Bluetooth SIG UUIDs are 16-bit (e.g., `0x180F` = Battery Service). Custom UUIDs are 128-bit (e.g., `4fafc201-1fb5-459e-8fcc-c5c9c331914b`). Generate custom UUIDs at https://www.uuidgenerator.net/.

---

## BLE GATT Server (Sensor Broadcasting)

This is the most common pattern: ESP32 as a sensor that phones/computers can read.

```cpp
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// UUIDs - generate your own for custom services
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define TEMP_CHAR_UUID      "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define HUMIDITY_CHAR_UUID  "8c8e9c42-5a3b-4c72-bf0e-1d3e7c9a5f12"

BLEServer *pServer = nullptr;
BLECharacteristic *pTempChar = nullptr;
BLECharacteristic *pHumChar = nullptr;
bool deviceConnected = false;
bool oldDeviceConnected = false;

class ServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer *pServer) {
        deviceConnected = true;
        Serial.println("Client connected");
    }

    void onDisconnect(BLEServer *pServer) {
        deviceConnected = false;
        Serial.println("Client disconnected");
    }
};

void setup() {
    Serial.begin(115200);

    // Initialize BLE
    BLEDevice::init("ESP32-Sensor");

    // Create server
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new ServerCallbacks());

    // Create service
    BLEService *pService = pServer->createService(SERVICE_UUID);

    // Create temperature characteristic (Read + Notify)
    pTempChar = pService->createCharacteristic(
        TEMP_CHAR_UUID,
        BLECharacteristic::PROPERTY_READ |
        BLECharacteristic::PROPERTY_NOTIFY
    );
    pTempChar->addDescriptor(new BLE2902());  // Required for notifications

    // Create humidity characteristic (Read only)
    pHumChar = pService->createCharacteristic(
        HUMIDITY_CHAR_UUID,
        BLECharacteristic::PROPERTY_READ
    );

    // Start service
    pService->start();

    // Start advertising
    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);  // iPhone connection parameter hint
    BLEDevice::startAdvertising();

    Serial.println("BLE server started, waiting for connections...");
}

void loop() {
    if (deviceConnected) {
        // Read sensor (simulated here)
        float temperature = 22.5 + random(-20, 20) / 10.0;
        float humidity = 55.0 + random(-50, 50) / 10.0;

        // Update characteristics
        char tempStr[8];
        snprintf(tempStr, sizeof(tempStr), "%.1f", temperature);
        pTempChar->setValue(tempStr);
        pTempChar->notify();  // Push to connected client

        char humStr[8];
        snprintf(humStr, sizeof(humStr), "%.1f", humidity);
        pHumChar->setValue(humStr);

        Serial.printf("Sent: temp=%.1f, hum=%.1f\n", temperature, humidity);
    }

    // Handle reconnection
    if (!deviceConnected && oldDeviceConnected) {
        delay(500);  // Give Bluetooth stack time to clean up
        BLEDevice::startAdvertising();  // Restart advertising
        Serial.println("Restarted advertising");
    }
    oldDeviceConnected = deviceConnected;

    delay(2000);
}
```

### Writing to ESP32 from Client (Receiving Commands)

```cpp
#define COMMAND_CHAR_UUID "e3223119-9445-4e96-a4a1-85358c4046a2"

class CommandCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        String value = pCharacteristic->getValue();
        if (value.length() > 0) {
            Serial.printf("Received command: %s\n", value.c_str());

            if (value == "LED_ON") {
                digitalWrite(2, HIGH);
            } else if (value == "LED_OFF") {
                digitalWrite(2, LOW);
            } else if (value == "STATUS") {
                // Respond by updating a characteristic
                pTempChar->setValue("OK");
                pTempChar->notify();
            }
        }
    }
};

// In setup(), add a writable characteristic:
BLECharacteristic *pCommandChar = pService->createCharacteristic(
    COMMAND_CHAR_UUID,
    BLECharacteristic::PROPERTY_WRITE
);
pCommandChar->setCallbacks(new CommandCallbacks());
```

---

## BLE Scanning (Finding Nearby Devices)

```cpp
#include <BLEDevice.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>

class ScanCallbacks : public BLEAdvertisedDeviceCallbacks {
    void onResult(BLEAdvertisedDevice advertisedDevice) {
        Serial.printf("Found: %s", advertisedDevice.toString().c_str());

        if (advertisedDevice.haveName()) {
            Serial.printf("  Name: %s", advertisedDevice.getName().c_str());
        }
        if (advertisedDevice.haveRSSI()) {
            Serial.printf("  RSSI: %d", advertisedDevice.getRSSI());
        }
        if (advertisedDevice.haveServiceUUID()) {
            Serial.printf("  Service: %s", advertisedDevice.getServiceUUID().toString().c_str());
        }
        Serial.println();
    }
};

void setup() {
    Serial.begin(115200);
    BLEDevice::init("");

    BLEScan *pScan = BLEDevice::getScan();
    pScan->setAdvertisedDeviceCallbacks(new ScanCallbacks());
    pScan->setActiveScan(true);  // Active scan gets more info but uses more power
    pScan->setInterval(100);     // Scan interval (ms)
    pScan->setWindow(99);        // Scan window (ms), <= interval

    Serial.println("Scanning for BLE devices...");
}

void loop() {
    BLEScanResults results = BLEDevice::getScan()->start(5, false);  // 5 second scan
    Serial.printf("Scan complete. Found %d devices.\n\n", results.getCount());

    BLEDevice::getScan()->clearResults();  // Free memory
    delay(10000);  // Wait before next scan
}
```

---

## BLE Client (Connecting to Another BLE Device)

```cpp
#include <BLEDevice.h>
#include <BLEClient.h>

// UUID of the service/characteristic on the remote device
static BLEUUID serviceUUID("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
static BLEUUID charUUID("beb5483e-36e1-4688-b7f5-ea07361b26a8");

static BLEAdvertisedDevice *targetDevice;
static boolean doConnect = false;
static boolean connected = false;

class ClientCallbacks : public BLEClientCallbacks {
    void onConnect(BLEClient *client) {
        Serial.println("Connected to server");
    }
    void onDisconnect(BLEClient *client) {
        Serial.println("Disconnected from server");
        connected = false;
    }
};

// Notification callback
void notifyCallback(BLERemoteCharacteristic *pChar, uint8_t *data, size_t length, bool isNotify) {
    String value((char *)data, length);
    Serial.printf("Notification: %s\n", value.c_str());
}

bool connectToServer() {
    BLEClient *pClient = BLEDevice::createClient();
    pClient->setClientCallbacks(new ClientCallbacks());

    if (!pClient->connect(targetDevice)) {
        Serial.println("Failed to connect");
        return false;
    }

    BLERemoteService *pService = pClient->getService(serviceUUID);
    if (pService == nullptr) {
        Serial.println("Service not found");
        pClient->disconnect();
        return false;
    }

    BLERemoteCharacteristic *pChar = pService->getCharacteristic(charUUID);
    if (pChar == nullptr) {
        Serial.println("Characteristic not found");
        pClient->disconnect();
        return false;
    }

    // Read value
    if (pChar->canRead()) {
        String value = pChar->readValue();
        Serial.printf("Value: %s\n", value.c_str());
    }

    // Subscribe to notifications
    if (pChar->canNotify()) {
        pChar->registerForNotify(notifyCallback);
    }

    connected = true;
    return true;
}

// Scan callback to find our target device
class ScanCallbacks : public BLEAdvertisedDeviceCallbacks {
    void onResult(BLEAdvertisedDevice advertisedDevice) {
        if (advertisedDevice.haveServiceUUID() &&
            advertisedDevice.isAdvertisingService(serviceUUID)) {
            Serial.printf("Found target device: %s\n", advertisedDevice.getName().c_str());
            targetDevice = new BLEAdvertisedDevice(advertisedDevice);
            doConnect = true;
            BLEDevice::getScan()->stop();
        }
    }
};

void setup() {
    Serial.begin(115200);
    BLEDevice::init("ESP32-Client");

    BLEScan *pScan = BLEDevice::getScan();
    pScan->setAdvertisedDeviceCallbacks(new ScanCallbacks());
    pScan->setActiveScan(true);
    pScan->start(30);  // Scan for 30 seconds
}

void loop() {
    if (doConnect && !connected) {
        connectToServer();
        doConnect = false;
    }
    delay(1000);
}
```

---

## BLE Beacons

### iBeacon

```cpp
#include <BLEDevice.h>
#include <BLEBeacon.h>

// iBeacon UUID - use a unique one for your deployment
#define BEACON_UUID "8ec76ea3-6668-48da-9866-75be8bc86f4d"

void setup() {
    BLEDevice::init("");

    BLEServer *pServer = BLEDevice::createServer();
    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();

    // iBeacon data
    BLEBeacon beacon;
    beacon.setManufacturerId(0x4C00);  // Apple
    beacon.setProximityUUID(BLEUUID(BEACON_UUID));
    beacon.setMajor(1);     // e.g., building number
    beacon.setMinor(100);   // e.g., room number
    beacon.setSignalPower(-59);  // Calibrated RSSI at 1 meter

    // Build advertisement data
    BLEAdvertisementData advData;
    advData.setFlags(0x06);  // BR_EDR_NOT_SUPPORTED | LE_GENERAL_DISC

    std::string payload;
    payload += (char)0x02;  // Length
    payload += (char)0x01;  // Type: flags
    payload += (char)0x06;  // Flags value
    payload += (char)0x1A;  // Length of iBeacon data
    payload += (char)0xFF;  // Type: manufacturer specific
    payload += beacon.getData();

    advData.addData(payload);
    pAdvertising->setAdvertisementData(advData);

    pAdvertising->start();
    Serial.println("iBeacon started");
}
```

### Eddystone-URL (Physical Web)

```cpp
void setupEddystoneURL() {
    BLEDevice::init("");
    BLEServer *pServer = BLEDevice::createServer();
    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();

    BLEAdvertisementData advData;
    advData.setFlags(0x06);

    // Eddystone-URL frame
    // Service UUID: 0xFEAA (Eddystone)
    char eddystone[] = {
        0x03, 0x03, 0xAA, 0xFE,  // Complete list of 16-bit UUIDs
        0x0E, 0x16, 0xAA, 0xFE,  // Service data, Eddystone UUID
        0x10,                      // Frame type: URL
        0xF8,                      // TX power at 0m
        0x03,                      // URL scheme: "https://"
        'e', 'x', 'a', 'm', 'p', 'l', 'e',  // URL
        0x07                       // ".com"
    };

    advData.addData(std::string(eddystone, sizeof(eddystone)));
    pAdvertising->setAdvertisementData(advData);
    pAdvertising->start();
}
```

---

## NimBLE (Lightweight Alternative)

NimBLE is a lighter, faster BLE stack that uses significantly less flash and RAM than the default Bluedroid stack. Highly recommended if you don't need Classic Bluetooth.

### Installation

- **PlatformIO:** Add `h2zero/NimBLE-Arduino@^1.4.0` to `lib_deps`
- **Arduino IDE:** Install "NimBLE-Arduino" from Library Manager

### NimBLE Server Example

```cpp
#include <NimBLEDevice.h>

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHAR_UUID           "beb5483e-36e1-4688-b7f5-ea07361b26a8"

NimBLEServer *pServer;
NimBLECharacteristic *pChar;
bool deviceConnected = false;

class ServerCallbacks : public NimBLEServerCallbacks {
    void onConnect(NimBLEServer *pServer, NimBLEConnInfo &connInfo) {
        deviceConnected = true;
        Serial.printf("Client connected: %s\n", connInfo.getAddress().toString().c_str());

        // Allow multiple connections
        NimBLEDevice::startAdvertising();
    }

    void onDisconnect(NimBLEServer *pServer, NimBLEConnInfo &connInfo, int reason) {
        deviceConnected = false;
        Serial.printf("Client disconnected (reason: %d)\n", reason);
        NimBLEDevice::startAdvertising();
    }
};

class CharCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic *pChar, NimBLEConnInfo &connInfo) {
        std::string value = pChar->getValue();
        Serial.printf("Received: %s\n", value.c_str());
    }

    void onRead(NimBLECharacteristic *pChar, NimBLEConnInfo &connInfo) {
        Serial.println("Client reading value");
    }
};

void setup() {
    Serial.begin(115200);

    NimBLEDevice::init("ESP32-NimBLE");
    NimBLEDevice::setPower(ESP_PWR_LVL_P9);  // Max power

    pServer = NimBLEDevice::createServer();
    pServer->setCallbacks(new ServerCallbacks());

    NimBLEService *pService = pServer->createService(SERVICE_UUID);

    pChar = pService->createCharacteristic(
        CHAR_UUID,
        NIMBLE_PROPERTY::READ |
        NIMBLE_PROPERTY::WRITE |
        NIMBLE_PROPERTY::NOTIFY
    );
    pChar->setCallbacks(new CharCallbacks());

    pService->start();

    NimBLEAdvertising *pAdvertising = NimBLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->start();

    Serial.println("NimBLE server started");
}

void loop() {
    if (deviceConnected) {
        float value = analogRead(34) * 3.3 / 4095.0;
        char buf[8];
        snprintf(buf, sizeof(buf), "%.2f", value);
        pChar->setValue(buf);
        pChar->notify();
    }
    delay(2000);
}
```

### NimBLE vs Bluedroid Comparison

| Feature | Bluedroid (default) | NimBLE |
|---------|-------------------|--------|
| Flash usage | ~350 KB | ~110 KB |
| RAM usage | ~50 KB | ~15 KB |
| Classic BT | Yes | No |
| BLE | Yes | Yes |
| Multiple connections | Yes | Yes (up to 3 default, configurable) |
| API compatibility | ESP32 BLE Arduino | Similar, with some differences |
| Performance | Good | Often faster |

**Recommendation:** Use NimBLE unless you specifically need Classic Bluetooth (SPP, A2DP).

---

## Simultaneous WiFi + BLE

Running WiFi and BLE at the same time is supported but requires care.

### Memory Considerations

WiFi + BLE together uses significant RAM. Tips:
- Use NimBLE instead of Bluedroid (saves ~200 KB)
- Reduce WiFi buffers if possible
- Use "Huge APP" partition scheme (the combined binary is large)
- Monitor free heap: `Serial.printf("Free heap: %d\n", ESP.getFreeHeap());`

### Timing Considerations

WiFi and BLE share the same 2.4 GHz radio and coexist through time-division multiplexing. This means:
- BLE advertising/scanning intervals may be extended when WiFi is active
- WiFi throughput may decrease slightly during BLE operations
- Connections are generally stable, but latency may increase

### Example: WiFi Web Server + BLE Sensor

```cpp
#include <WiFi.h>
#include <WebServer.h>
#include <NimBLEDevice.h>

WebServer server(80);
NimBLEServer *pBLEServer;
NimBLECharacteristic *pSensorChar;

float sensorValue = 0;

void setup() {
    Serial.begin(115200);

    // Start BLE first (uses less RAM initially)
    NimBLEDevice::init("ESP32-Dual");
    pBLEServer = NimBLEDevice::createServer();
    NimBLEService *pService = pBLEServer->createService("181A");  // Environmental Sensing
    pSensorChar = pService->createCharacteristic(
        "2A6E",  // Temperature
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY
    );
    pService->start();
    NimBLEDevice::getAdvertising()->addServiceUUID("181A");
    NimBLEDevice::getAdvertising()->start();

    // Then start WiFi
    WiFi.begin("SSID", "password");
    while (WiFi.status() != WL_CONNECTED) delay(500);
    Serial.println(WiFi.localIP());

    server.on("/", []() {
        String html = "<h1>Sensor: " + String(sensorValue) + "</h1>";
        server.send(200, "text/html", html);
    });
    server.begin();

    Serial.printf("Free heap: %d bytes\n", ESP.getFreeHeap());
}

void loop() {
    server.handleClient();

    // Update sensor value
    sensorValue = analogRead(34) * 3.3 / 4095.0;

    // Update BLE characteristic
    char buf[8];
    snprintf(buf, sizeof(buf), "%.2f", sensorValue);
    pSensorChar->setValue(buf);
    pSensorChar->notify();

    delay(1000);
}
```

---

## BLE Security (Pairing and Bonding)

### Setting Up Secure BLE

```cpp
// NimBLE security
class SecurityCallbacks : public NimBLEServerCallbacks {
    uint32_t onPassKeyRequest() {
        Serial.println("Passkey requested");
        return 123456;  // Static passkey
    }

    void onAuthenticationComplete(NimBLEConnInfo &connInfo) {
        if (connInfo.isEncrypted()) {
            Serial.println("Pairing successful, connection encrypted");
        } else {
            Serial.println("Pairing failed");
            // Optionally disconnect
        }
    }

    bool onConfirmPIN(uint32_t pin) {
        Serial.printf("Confirm PIN: %d\n", pin);
        return true;  // Accept
    }
};

void setup() {
    NimBLEDevice::init("Secure-ESP32");
    NimBLEDevice::setSecurityAuth(true, true, true);  // bonding, MITM, secure connections
    NimBLEDevice::setSecurityPasskey(123456);
    NimBLEDevice::setSecurityIOCap(BLE_HS_IO_DISPLAY_ONLY);

    pServer = NimBLEDevice::createServer();
    pServer->setCallbacks(new SecurityCallbacks());
    // ... rest of setup
}
```

---

## Useful BLE Tools for Testing

- **nRF Connect** (Android/iOS): Best app for BLE development. Scan, connect, read/write characteristics, enable notifications.
- **LightBlue** (iOS): Simple BLE explorer.
- **Web Bluetooth** (Chrome): Test from a browser using the Web Bluetooth API.
- **btmon** (Linux): Low-level Bluetooth packet monitor.
- **hcitool** (Linux): Command-line BLE scanning.

### Testing with nRF Connect

1. Open nRF Connect on your phone
2. Scan for devices, find your ESP32 by name
3. Connect
4. Expand the service UUID
5. Read characteristics, write values, enable notifications
6. The log shows all BLE communication in real time
