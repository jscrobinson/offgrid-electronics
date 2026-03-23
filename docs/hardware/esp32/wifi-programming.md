# ESP32 WiFi Programming Reference

## Overview

The ESP32's WiFi capabilities include 802.11 b/g/n on 2.4 GHz (WiFi 6 on ESP32-C6). It can operate as a station (client), access point (hotspot), or both simultaneously. This document covers practical WiFi programming using the Arduino framework.

---

## Station Mode (Connecting to an Access Point)

### Basic Connection

```cpp
#include <WiFi.h>

const char *SSID = "MyNetwork";
const char *PASSWORD = "MyPassword";

void setup() {
    Serial.begin(115200);

    WiFi.mode(WIFI_STA);
    WiFi.begin(SSID, PASSWORD);

    Serial.print("Connecting");
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }

    Serial.println();
    Serial.print("Connected! IP: ");
    Serial.println(WiFi.localIP());
    Serial.print("Signal strength (RSSI): ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
}
```

### Connection with Static IP

```cpp
IPAddress local_IP(192, 168, 1, 100);
IPAddress gateway(192, 168, 1, 1);
IPAddress subnet(255, 255, 255, 0);
IPAddress dns1(8, 8, 8, 8);
IPAddress dns2(8, 8, 4, 4);

void setup() {
    WiFi.mode(WIFI_STA);

    if (!WiFi.config(local_IP, gateway, subnet, dns1, dns2)) {
        Serial.println("Static IP config failed");
    }

    WiFi.begin(SSID, PASSWORD);
    // ... wait for connection
}
```

### Robust Connection with Event Handling

```cpp
#include <WiFi.h>

void WiFiEvent(WiFiEvent_t event) {
    switch (event) {
        case ARDUINO_EVENT_WIFI_STA_CONNECTED:
            Serial.println("Connected to AP");
            break;
        case ARDUINO_EVENT_WIFI_STA_GOT_IP:
            Serial.print("Got IP: ");
            Serial.println(WiFi.localIP());
            break;
        case ARDUINO_EVENT_WIFI_STA_DISCONNECTED:
            Serial.println("Disconnected - reconnecting...");
            WiFi.reconnect();
            break;
        case ARDUINO_EVENT_WIFI_STA_LOST_IP:
            Serial.println("Lost IP address");
            break;
    }
}

void setup() {
    Serial.begin(115200);
    WiFi.onEvent(WiFiEvent);
    WiFi.mode(WIFI_STA);
    WiFi.setAutoReconnect(true);
    WiFi.begin(SSID, PASSWORD);
}
```

### WiFi Status Codes

| WiFi.status() | Meaning |
|---------------|---------|
| WL_IDLE_STATUS (0) | Changing between statuses |
| WL_NO_SSID_AVAIL (1) | SSID not found |
| WL_SCAN_COMPLETED (2) | Scan finished |
| WL_CONNECTED (3) | Connected |
| WL_CONNECT_FAILED (4) | Connection failed (wrong password, etc.) |
| WL_CONNECTION_LOST (5) | Connection lost |
| WL_DISCONNECTED (6) | Disconnected |

### Connection Timeout Pattern

```cpp
bool connectWiFi(const char *ssid, const char *pass, unsigned long timeout_ms) {
    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, pass);

    unsigned long start = millis();
    while (WiFi.status() != WL_CONNECTED) {
        if (millis() - start > timeout_ms) {
            Serial.println("WiFi connection timeout");
            WiFi.disconnect();
            return false;
        }
        delay(100);
    }
    return true;
}
```

---

## Access Point Mode (Creating a Hotspot)

### Basic AP

```cpp
#include <WiFi.h>

const char *AP_SSID = "ESP32-Config";
const char *AP_PASS = "12345678";  // Min 8 chars, or "" for open

void setup() {
    Serial.begin(115200);

    WiFi.mode(WIFI_AP);
    WiFi.softAP(AP_SSID, AP_PASS);

    Serial.print("AP IP: ");
    Serial.println(WiFi.softAPIP());  // Default: 192.168.4.1
}
```

### AP with Custom Configuration

```cpp
void setup() {
    WiFi.mode(WIFI_AP);

    // Custom IP for the AP
    IPAddress apIP(10, 0, 0, 1);
    IPAddress subnet(255, 255, 255, 0);
    WiFi.softAPConfig(apIP, apIP, subnet);

    // AP with channel, hidden SSID, max connections
    WiFi.softAP(
        "ESP32-Config",   // SSID
        "12345678",       // Password
        6,                // Channel (1-13)
        false,            // Hidden SSID
        4                 // Max connections (1-10, default 4)
    );

    Serial.printf("AP started. IP: %s\n", WiFi.softAPIP().toString().c_str());
    Serial.printf("Connected stations: %d\n", WiFi.softAPgetStationNum());
}
```

### Monitoring Connected Clients

```cpp
void loop() {
    static int lastCount = -1;
    int count = WiFi.softAPgetStationNum();
    if (count != lastCount) {
        Serial.printf("Clients connected: %d\n", count);
        lastCount = count;
    }
    delay(1000);
}
```

---

## AP + Station Simultaneous Mode

The ESP32 can connect to a WiFi network while simultaneously hosting its own AP. This is useful for configuration portals or mesh-like setups.

```cpp
void setup() {
    Serial.begin(115200);

    WiFi.mode(WIFI_AP_STA);

    // Start AP
    WiFi.softAP("ESP32-Bridge", "password123");
    Serial.printf("AP IP: %s\n", WiFi.softAPIP().toString().c_str());

    // Connect to existing network
    WiFi.begin("HomeNetwork", "homepassword");

    unsigned long start = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - start < 10000) {
        delay(100);
    }

    if (WiFi.status() == WL_CONNECTED) {
        Serial.printf("STA IP: %s\n", WiFi.localIP().toString().c_str());
    } else {
        Serial.println("Could not connect to home network");
        // AP is still running, so devices can still connect to ESP32
    }
}
```

**Note:** The AP and STA share the same radio, so they must be on the same WiFi channel. The STA channel is determined by the AP it connects to. The soft AP channel will automatically match.

---

## WiFi Scanning

### Basic Scan

```cpp
void scanNetworks() {
    Serial.println("Scanning...");

    int n = WiFi.scanNetworks();  // Blocking scan

    if (n == 0) {
        Serial.println("No networks found");
    } else {
        Serial.printf("%d networks found:\n", n);
        for (int i = 0; i < n; i++) {
            Serial.printf("  %2d: %-32s  Ch:%2d  RSSI:%4d  %s\n",
                i + 1,
                WiFi.SSID(i).c_str(),
                WiFi.channel(i),
                WiFi.RSSI(i),
                (WiFi.encryptionType(i) == WIFI_AUTH_OPEN) ? "Open" : "Encrypted"
            );
        }
    }

    WiFi.scanDelete();  // Free scan results memory
}
```

### Async Scan (Non-Blocking)

```cpp
void setup() {
    Serial.begin(115200);
    WiFi.mode(WIFI_STA);
    WiFi.scanNetworks(true);  // true = async
}

void loop() {
    int result = WiFi.scanComplete();

    if (result >= 0) {
        Serial.printf("Found %d networks\n", result);
        for (int i = 0; i < result; i++) {
            Serial.printf("  %s (%d dBm)\n", WiFi.SSID(i).c_str(), WiFi.RSSI(i));
        }
        WiFi.scanDelete();

        // Rescan after a delay
        delay(10000);
        WiFi.scanNetworks(true);
    } else if (result == WIFI_SCAN_FAILED) {
        Serial.println("Scan failed, retrying...");
        WiFi.scanNetworks(true);
    }
    // result == WIFI_SCAN_RUNNING means still scanning

    delay(100);
}
```

### Encryption Types

| Value | Meaning |
|-------|---------|
| WIFI_AUTH_OPEN | No encryption |
| WIFI_AUTH_WEP | WEP |
| WIFI_AUTH_WPA_PSK | WPA-PSK |
| WIFI_AUTH_WPA2_PSK | WPA2-PSK |
| WIFI_AUTH_WPA_WPA2_PSK | WPA/WPA2-PSK |
| WIFI_AUTH_WPA2_ENTERPRISE | WPA2 Enterprise |
| WIFI_AUTH_WPA3_PSK | WPA3-PSK |

---

## HTTP Server (WebServer Library)

### Basic Web Server

```cpp
#include <WiFi.h>
#include <WebServer.h>

WebServer server(80);

void handleRoot() {
    String html = "<html><body>";
    html += "<h1>ESP32 Web Server</h1>";
    html += "<p>Uptime: " + String(millis() / 1000) + " seconds</p>";
    html += "<p><a href='/led/on'>LED ON</a> | <a href='/led/off'>LED OFF</a></p>";
    html += "</body></html>";
    server.send(200, "text/html", html);
}

void handleLedOn() {
    digitalWrite(2, HIGH);
    server.sendHeader("Location", "/");
    server.send(303);  // Redirect to root
}

void handleLedOff() {
    digitalWrite(2, LOW);
    server.sendHeader("Location", "/");
    server.send(303);
}

void handleNotFound() {
    server.send(404, "text/plain", "Not Found");
}

void setup() {
    Serial.begin(115200);
    pinMode(2, OUTPUT);

    WiFi.begin("SSID", "password");
    while (WiFi.status() != WL_CONNECTED) delay(500);
    Serial.println(WiFi.localIP());

    server.on("/", handleRoot);
    server.on("/led/on", handleLedOn);
    server.on("/led/off", handleLedOff);
    server.onNotFound(handleNotFound);
    server.begin();
}

void loop() {
    server.handleClient();
}
```

### Handling POST Data and JSON

```cpp
#include <ArduinoJson.h>  // Install via library manager

void handleApi() {
    if (server.method() != HTTP_POST) {
        server.send(405, "text/plain", "Method Not Allowed");
        return;
    }

    String body = server.arg("plain");
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, body);

    if (error) {
        server.send(400, "application/json", "{\"error\":\"Invalid JSON\"}");
        return;
    }

    const char *action = doc["action"];
    int value = doc["value"];

    // Process...

    // Respond with JSON
    JsonDocument response;
    response["status"] = "ok";
    response["received_action"] = action;
    String output;
    serializeJson(response, output);
    server.send(200, "application/json", output);
}

// Register: server.on("/api", HTTP_POST, handleApi);
```

### Serving Files from SPIFFS/LittleFS

```cpp
#include <LittleFS.h>

void setup() {
    LittleFS.begin(true);

    // Serve specific file
    server.on("/style.css", []() {
        File file = LittleFS.open("/style.css", "r");
        server.streamFile(file, "text/css");
        file.close();
    });

    // Serve any file from filesystem
    server.onNotFound([]() {
        String path = server.uri();
        if (path.endsWith("/")) path += "index.html";

        String contentType = "text/plain";
        if (path.endsWith(".html")) contentType = "text/html";
        else if (path.endsWith(".css")) contentType = "text/css";
        else if (path.endsWith(".js")) contentType = "application/javascript";
        else if (path.endsWith(".json")) contentType = "application/json";
        else if (path.endsWith(".png")) contentType = "image/png";

        if (LittleFS.exists(path)) {
            File file = LittleFS.open(path, "r");
            server.streamFile(file, contentType);
            file.close();
        } else {
            server.send(404, "text/plain", "Not Found");
        }
    });
}
```

### ESPAsyncWebServer (Recommended for Production)

The built-in `WebServer` is synchronous and blocks on each request. For better performance, use ESPAsyncWebServer:

```cpp
// Install: AsyncTCP and ESPAsyncWebServer libraries
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

AsyncWebServer server(80);

void setup() {
    // ... WiFi setup ...

    server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
        request->send(200, "text/html", "<h1>Hello Async!</h1>");
    });

    // Serve files from LittleFS
    server.serveStatic("/", LittleFS, "/www/").setDefaultFile("index.html");

    // Handle parameters
    server.on("/api/set", HTTP_GET, [](AsyncWebServerRequest *request) {
        if (request->hasParam("temp")) {
            String temp = request->getParam("temp")->value();
            request->send(200, "text/plain", "Set temp to: " + temp);
        } else {
            request->send(400, "text/plain", "Missing temp parameter");
        }
    });

    // Server-Sent Events (SSE) for real-time updates
    AsyncEventSource events("/events");
    events.onConnect([](AsyncEventSourceClient *client) {
        client->send("connected", NULL, millis(), 1000);
    });
    server.addHandler(&events);

    server.begin();

    // Send events from anywhere:
    // events.send(String(temperature).c_str(), "temperature", millis());
}

void loop() {
    // No server.handleClient() needed - it's async!
}
```

---

## HTTP Client

### Simple GET Request

```cpp
#include <HTTPClient.h>

void fetchData() {
    if (WiFi.status() != WL_CONNECTED) return;

    HTTPClient http;
    http.begin("http://api.example.com/data");

    int httpCode = http.GET();

    if (httpCode > 0) {
        if (httpCode == HTTP_CODE_OK) {
            String payload = http.getString();
            Serial.println(payload);
        }
    } else {
        Serial.printf("HTTP GET failed: %s\n", http.errorToString(httpCode).c_str());
    }

    http.end();
}
```

### POST Request with JSON

```cpp
void postData(float temperature, float humidity) {
    if (WiFi.status() != WL_CONNECTED) return;

    HTTPClient http;
    http.begin("http://api.example.com/sensor");
    http.addHeader("Content-Type", "application/json");

    JsonDocument doc;
    doc["device"] = "esp32-01";
    doc["temperature"] = temperature;
    doc["humidity"] = humidity;
    doc["timestamp"] = millis();

    String json;
    serializeJson(doc, json);

    int httpCode = http.POST(json);

    if (httpCode > 0) {
        Serial.printf("POST response: %d\n", httpCode);
        Serial.println(http.getString());
    } else {
        Serial.printf("POST failed: %s\n", http.errorToString(httpCode).c_str());
    }

    http.end();
}
```

### HTTPS (TLS) Request

```cpp
#include <WiFiClientSecure.h>

// Root CA certificate (get from browser or Let's Encrypt)
const char *rootCA = R"(
-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
... (full certificate here) ...
-----END CERTIFICATE-----
)";

void httpsGet() {
    WiFiClientSecure client;
    client.setCACert(rootCA);
    // Or to skip verification (insecure, for testing only):
    // client.setInsecure();

    HTTPClient http;
    http.begin(client, "https://api.example.com/secure");

    int httpCode = http.GET();
    if (httpCode == HTTP_CODE_OK) {
        Serial.println(http.getString());
    }
    http.end();
}
```

---

## WebSocket Support

### WebSocket Server (using ESPAsyncWebServer)

```cpp
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

void onWebSocketEvent(AsyncWebSocket *server, AsyncWebSocketClient *client,
                      AwsEventType type, void *arg, uint8_t *data, size_t len) {
    switch (type) {
        case WS_EVT_CONNECT:
            Serial.printf("Client #%u connected from %s\n",
                client->id(), client->remoteIP().toString().c_str());
            client->text("{\"type\":\"welcome\",\"id\":" + String(client->id()) + "}");
            break;

        case WS_EVT_DISCONNECT:
            Serial.printf("Client #%u disconnected\n", client->id());
            break;

        case WS_EVT_DATA: {
            AwsFrameInfo *info = (AwsFrameInfo *)arg;
            if (info->final && info->index == 0 && info->len == len && info->opcode == WS_TEXT) {
                data[len] = 0;  // Null-terminate
                String msg = (char *)data;
                Serial.printf("Received from #%u: %s\n", client->id(), msg.c_str());

                // Echo back to all clients
                ws.textAll("{\"type\":\"echo\",\"data\":\"" + msg + "\"}");
            }
            break;
        }

        case WS_EVT_ERROR:
            Serial.printf("WebSocket error on client #%u\n", client->id());
            break;
    }
}

void setup() {
    // ... WiFi setup ...

    ws.onEvent(onWebSocketEvent);
    server.addHandler(&ws);

    server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
        request->send(200, "text/html", R"rawliteral(
            <html><body>
            <script>
                var ws = new WebSocket('ws://' + location.host + '/ws');
                ws.onmessage = function(e) { console.log(e.data); };
                ws.onopen = function() { ws.send('Hello from browser!'); };
            </script>
            </body></html>
        )rawliteral");
    });

    server.begin();
}

void loop() {
    ws.cleanupClients();  // Remove disconnected clients
    delay(100);
}
```

---

## mDNS (Multicast DNS)

mDNS lets you access the ESP32 by hostname (e.g., `http://esp32-sensor.local`) instead of IP address.

```cpp
#include <ESPmDNS.h>

void setup() {
    // ... WiFi connect ...

    if (MDNS.begin("esp32-sensor")) {  // hostname
        Serial.println("mDNS: http://esp32-sensor.local");

        // Advertise services
        MDNS.addService("http", "tcp", 80);
        MDNS.addService("ws", "tcp", 80);        // WebSocket
        MDNS.addServiceTxt("http", "tcp", "board", "esp32");
    } else {
        Serial.println("mDNS failed to start");
    }
}
```

### Discovering mDNS Services

```cpp
void discoverServices() {
    int n = MDNS.queryService("http", "tcp");  // Find HTTP servers

    if (n == 0) {
        Serial.println("No services found");
    } else {
        for (int i = 0; i < n; i++) {
            Serial.printf("  %s - %s:%d\n",
                MDNS.hostname(i).c_str(),
                MDNS.IP(i).toString().c_str(),
                MDNS.port(i));
        }
    }
}
```

---

## WiFiManager (Captive Portal Configuration)

WiFiManager creates a captive portal so users can configure WiFi credentials without hardcoding them. The ESP32 starts in AP mode, presents a web page, and the user enters their SSID and password.

```cpp
// Install: "WiFiManager by tzapu" or "WiFiManager by tablatronix" (ESP32 fork)
#include <WiFiManager.h>

void setup() {
    Serial.begin(115200);

    WiFiManager wm;

    // Uncomment to reset saved credentials (for testing)
    // wm.resetSettings();

    // Auto-connect: tries saved credentials first, starts config portal if they fail
    // Portal SSID = "ESP32-Setup", password = "configme"
    bool connected = wm.autoConnect("ESP32-Setup", "configme");

    if (!connected) {
        Serial.println("Failed to connect. Restarting...");
        delay(3000);
        ESP.restart();
    }

    Serial.print("Connected! IP: ");
    Serial.println(WiFi.localIP());

    // WiFi credentials are now saved in NVS and will be used on next boot
}
```

### Adding Custom Parameters

```cpp
void setup() {
    WiFiManager wm;

    // Add custom fields to the config portal
    WiFiManagerParameter mqttServer("mqtt", "MQTT Server", "192.168.1.100", 40);
    WiFiManagerParameter mqttPort("port", "MQTT Port", "1883", 6);
    WiFiManagerParameter deviceName("name", "Device Name", "sensor-01", 32);

    wm.addParameter(&mqttServer);
    wm.addParameter(&mqttPort);
    wm.addParameter(&deviceName);

    wm.autoConnect("ESP32-Setup");

    // Retrieve values after connection
    String server = mqttServer.getValue();
    int port = atoi(mqttPort.getValue());
    String name = deviceName.getValue();

    Serial.printf("MQTT: %s:%d, Device: %s\n",
        server.c_str(), port, name.c_str());

    // Save to Preferences for use after reboot
    Preferences prefs;
    prefs.begin("config", false);
    prefs.putString("mqtt_server", server);
    prefs.putInt("mqtt_port", port);
    prefs.putString("device_name", name);
    prefs.end();
}
```

### Triggering Config Portal on Demand

```cpp
// Press button on GPIO0 to enter config mode
void setup() {
    Serial.begin(115200);
    pinMode(0, INPUT_PULLUP);

    WiFiManager wm;

    if (digitalRead(0) == LOW) {
        Serial.println("Button pressed - starting config portal");
        wm.startConfigPortal("ESP32-Setup", "configme");
    } else {
        wm.autoConnect("ESP32-Setup", "configme");
    }
}
```

---

## Power Saving with WiFi

### Modem Sleep (Default)

WiFi modem powers down between DTIM intervals. Enabled by default when connected.

```cpp
// Already active by default. To verify or configure:
WiFi.setSleep(true);   // Enable modem sleep (default)
WiFi.setSleep(false);  // Disable (for lowest latency, highest power)
```

### Light Sleep with WiFi

The CPU sleeps between WiFi beacons. Wakes automatically for WiFi events.

```cpp
#include "esp_wifi.h"
#include "esp_pm.h"

void enableLightSleep() {
    // Configure power management
    esp_pm_config_esp32_t pm_config = {
        .max_freq_mhz = 240,
        .min_freq_mhz = 80,
        .light_sleep_enable = true
    };
    esp_pm_configure(&pm_config);

    // Set WiFi power save mode
    esp_wifi_set_ps(WIFI_PS_MAX_MODEM);
}
```

### WiFi Power Level

Reduce transmit power to save energy (at the cost of range):

```cpp
#include "esp_wifi.h"

// Power levels (in 0.25 dBm units):
// WIFI_POWER_19_5dBm = 78 (default, max range)
// WIFI_POWER_15dBm = 60
// WIFI_POWER_11dBm = 44
// WIFI_POWER_8_5dBm = 34
// WIFI_POWER_7dBm = 28
// WIFI_POWER_5dBm = 20
// WIFI_POWER_2dBm = 8

WiFi.setTxPower(WIFI_POWER_8_5dBm);  // Reduce for close-range operation
```

### Full WiFi Shutdown

```cpp
// Disconnect and stop WiFi entirely
WiFi.disconnect(true);  // true = disable WiFi
WiFi.mode(WIFI_OFF);

// Or via ESP-IDF for complete radio shutdown:
esp_wifi_stop();
esp_wifi_deinit();
```

---

## Useful WiFi Utility Functions

```cpp
// Get MAC address
Serial.println(WiFi.macAddress());

// Get hostname
Serial.println(WiFi.getHostname());

// Set hostname (before WiFi.begin())
WiFi.setHostname("my-esp32");

// Get channel
Serial.println(WiFi.channel());

// Get BSSID (AP MAC) of connected network
Serial.println(WiFi.BSSIDstr());

// Get DNS server
Serial.println(WiFi.dnsIP().toString());

// Get gateway
Serial.println(WiFi.gatewayIP().toString());

// Get subnet mask
Serial.println(WiFi.subnetMask().toString());

// Check if connected
if (WiFi.isConnected()) { ... }

// Get auto-reconnect state
Serial.println(WiFi.getAutoReconnect());
```

---

## Practical Pattern: Robust WiFi Connection Manager

```cpp
#include <WiFi.h>

class WiFiConnection {
public:
    void begin(const char *ssid, const char *pass) {
        _ssid = ssid;
        _pass = pass;
        WiFi.mode(WIFI_STA);
        WiFi.setAutoReconnect(true);
        WiFi.onEvent([this](WiFiEvent_t event, WiFiEventInfo_t info) {
            this->onEvent(event, info);
        });
        connect();
    }

    bool isConnected() { return WiFi.status() == WL_CONNECTED; }

    void check() {
        if (!isConnected() && millis() - _lastAttempt > 30000) {
            Serial.println("WiFi lost, reconnecting...");
            connect();
        }
    }

private:
    const char *_ssid;
    const char *_pass;
    unsigned long _lastAttempt = 0;

    void connect() {
        WiFi.disconnect();
        WiFi.begin(_ssid, _pass);
        _lastAttempt = millis();
    }

    void onEvent(WiFiEvent_t event, WiFiEventInfo_t info) {
        switch (event) {
            case ARDUINO_EVENT_WIFI_STA_GOT_IP:
                Serial.printf("Connected: %s\n", WiFi.localIP().toString().c_str());
                break;
            case ARDUINO_EVENT_WIFI_STA_DISCONNECTED:
                Serial.printf("Disconnected (reason: %d)\n", info.wifi_sta_disconnected.reason);
                break;
        }
    }
};

WiFiConnection wifi;

void setup() {
    Serial.begin(115200);
    wifi.begin("SSID", "password");
}

void loop() {
    wifi.check();
    // ... your code
    delay(100);
}
```
