# MQTT Protocol

## Overview

MQTT (Message Queuing Telemetry Transport) is a lightweight publish/subscribe messaging protocol designed for constrained devices and unreliable networks. It is the de facto standard for IoT communication.

```
              ┌─────────────┐
              │   Broker     │
              │ (Mosquitto)  │
              └──┬──┬──┬──┬─┘
                 │  │  │  │
     ┌───────────┘  │  │  └───────────┐
     │              │  │              │
  ┌──┴──┐     ┌────┴┐ ├────┐     ┌──┴──┐
  │ESP32│     │ Pi  │ │Node│     │Phone│
  │Pub  │     │Sub  │ │Sub │     │ App │
  └─────┘     └─────┘ └────┘     └─────┘
```

**Key characteristics:**
- **Publish/Subscribe model:** Decoupled communication through a broker
- **Lightweight:** Minimal overhead (2-byte header minimum), ideal for constrained devices
- **Topics:** Hierarchical string-based addressing (e.g., `home/bedroom/temperature`)
- **QoS levels:** Three quality-of-service levels (0, 1, 2)
- **Retained messages:** Broker stores last message per topic
- **Last Will and Testament (LWT):** Broker publishes a message if client disconnects unexpectedly
- **TCP-based:** Runs over TCP/IP (port 1883 unencrypted, 8883 TLS encrypted)

---

## Publish/Subscribe Model

Unlike HTTP (request/response), MQTT uses a publish/subscribe pattern:

1. **Publisher** sends a message to a **topic** on the **broker**
2. **Broker** forwards the message to all **subscribers** of that topic
3. Publishers and subscribers never communicate directly — the broker handles routing

**Benefits:**
- Publishers and subscribers don't need to know about each other
- Devices can publish and subscribe simultaneously
- A subscriber can receive messages from many publishers
- Temporal decoupling: publisher and subscriber don't need to be online at the same time (with QoS > 0 and persistent sessions)

---

## Topics

Topics are hierarchical UTF-8 strings separated by forward slashes:

```
home/livingroom/temperature
home/livingroom/humidity
home/bedroom/light/status
home/bedroom/light/brightness
farm/greenhouse/sensor/1/soil_moisture
```

### Topic Naming Best Practices

- Use lowercase, no spaces
- Use `/` as hierarchy separator
- Be specific but not too deep (3-5 levels typical)
- Include device/location context
- Don't start with `/` (creates empty first level)

### Wildcards (Subscribers Only)

**Single-level wildcard `+`:** Matches exactly one level
```
home/+/temperature      → matches home/bedroom/temperature
                         → matches home/kitchen/temperature
                         → NOT home/bedroom/sensor/temperature
```

**Multi-level wildcard `#`:** Matches any number of levels (must be last)
```
home/bedroom/#           → matches home/bedroom/temperature
                         → matches home/bedroom/light/status
                         → matches home/bedroom/light/brightness

home/#                   → matches ALL topics under home/
#                        → matches ALL topics (use with caution!)
```

### System Topics

Brokers publish information on `$SYS/` topics:
```
$SYS/broker/clients/connected     — number of connected clients
$SYS/broker/messages/received     — total messages received
$SYS/broker/uptime                — broker uptime in seconds
```

---

## Quality of Service (QoS)

| QoS Level | Name              | Delivery Guarantee     | Use Case                         |
|-----------|-------------------|------------------------|----------------------------------|
| 0         | At most once      | Fire and forget        | Sensor data, frequent updates    |
| 1         | At least once     | Delivered, may duplicate| Commands, alerts                |
| 2         | Exactly once      | Delivered exactly once | Billing, critical state changes  |

### QoS 0 — At Most Once

```
Publisher ──PUBLISH──► Broker ──PUBLISH──► Subscriber
```

No acknowledgment. Message may be lost if the network drops. Fastest, lowest overhead.

### QoS 1 — At Least Once

```
Publisher ──PUBLISH──► Broker ──PUBACK──► Publisher
Broker ──PUBLISH──► Subscriber ──PUBACK──► Broker
```

Broker acknowledges receipt. If no ACK received, the publisher retransmits. May result in duplicate messages — subscriber must handle duplicates.

### QoS 2 — Exactly Once

```
Publisher ──PUBLISH──► Broker
Publisher ◄──PUBREC── Broker
Publisher ──PUBREL──► Broker
Publisher ◄──PUBCOMP── Broker
```

Four-step handshake ensures exactly one delivery. Slowest, highest overhead. Rarely needed in IoT.

**Recommendation:** Use QoS 0 for telemetry/sensor data. Use QoS 1 for commands and important events. Avoid QoS 2 unless absolutely necessary.

---

## Retained Messages

When a message is published with the `retain` flag set, the broker stores the last retained message for that topic. Any new subscriber immediately receives the last retained value.

```
Publisher publishes: topic="home/status", payload="online", retain=true

Later, a new subscriber subscribes to "home/status"
→ Broker immediately sends the retained message "online"
```

**Use cases:**
- Device status (online/offline)
- Configuration values
- Last known sensor readings

**To clear a retained message:** Publish an empty payload with retain=true to the same topic.

---

## Last Will and Testament (LWT)

A client can register a "will" message when connecting. If the client disconnects ungracefully (network loss, crash), the broker publishes the will message on behalf of the dead client.

```
Client connects with will:
  topic: "devices/sensor1/status"
  payload: "offline"
  retain: true

Client publishes on connect:
  topic: "devices/sensor1/status"
  payload: "online"
  retain: true

If client loses connection → Broker publishes "offline" (the will)
```

This is the standard pattern for device availability tracking.

---

## Ports and Security

| Port | Protocol | Description                    |
|------|----------|--------------------------------|
| 1883 | TCP      | MQTT unencrypted (default)     |
| 8883 | TLS/SSL  | MQTT encrypted (standard)      |
| 9001 | WebSocket| MQTT over WebSockets           |
| 9883 | WSS      | MQTT over WebSockets + TLS     |

### Authentication

**Username/Password:** Basic authentication supported by all brokers.

**Mosquitto configuration:**
```
# /etc/mosquitto/mosquitto.conf
listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwd
```

```bash
# Create password file
sudo mosquitto_passwd -c /etc/mosquitto/passwd myuser
# Add more users
sudo mosquitto_passwd /etc/mosquitto/passwd anotheruser
```

### TLS Encryption

For production systems, always use TLS:

```
# /etc/mosquitto/mosquitto.conf
listener 8883
cafile /etc/mosquitto/certs/ca.crt
certfile /etc/mosquitto/certs/server.crt
keyfile /etc/mosquitto/certs/server.key
require_certificate false
```

### Access Control Lists (ACL)

```
# /etc/mosquitto/acl
# User "sensor1" can publish to its own topics
user sensor1
topic write home/sensor1/#
topic read home/sensor1/commands

# User "dashboard" can read everything
user dashboard
topic read home/#
```

```
# mosquitto.conf
acl_file /etc/mosquitto/acl
```

---

## Mosquitto Broker on Raspberry Pi

### Installation

```bash
# Install Mosquitto broker and client tools
sudo apt update
sudo apt install mosquitto mosquitto-clients

# Start and enable service
sudo systemctl enable mosquitto
sudo systemctl start mosquitto

# Check status
sudo systemctl status mosquitto
```

### Configuration

```bash
# Edit config
sudo nano /etc/mosquitto/mosquitto.conf
```

**Minimal production config:**
```
# /etc/mosquitto/mosquitto.conf
pid_file /run/mosquitto/mosquitto.pid

persistence true
persistence_location /var/lib/mosquitto/

log_dest file /var/log/mosquitto/mosquitto.log

listener 1883 0.0.0.0
allow_anonymous false
password_file /etc/mosquitto/passwd
```

```bash
# Create password file
sudo mosquitto_passwd -c /etc/mosquitto/passwd admin
sudo mosquitto_passwd /etc/mosquitto/passwd esp32sensor

# Restart broker
sudo systemctl restart mosquitto
```

### Command-Line Testing

```bash
# Subscribe to all topics (for debugging)
mosquitto_sub -h localhost -t "#" -v

# Subscribe to specific topic
mosquitto_sub -h localhost -t "home/temperature" -u admin -P password

# Publish a message
mosquitto_pub -h localhost -t "home/temperature" -m "23.5" -u admin -P password

# Publish with retain flag
mosquitto_pub -h localhost -t "home/status" -m "online" -r -u admin -P password

# Publish with QoS 1
mosquitto_pub -h localhost -t "home/alert" -m "door open" -q 1

# Subscribe with verbose output (shows topic and payload)
mosquitto_sub -h localhost -t "home/#" -v
```

---

## Client Libraries

### Arduino/ESP32: PubSubClient

The most popular MQTT library for Arduino-based projects.

```cpp
#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "YourWiFi";
const char* password = "YourPassword";
const char* mqtt_server = "192.168.1.100";
const int mqtt_port = 1883;
const char* mqtt_user = "esp32sensor";
const char* mqtt_pass = "sensorpass";

WiFiClient espClient;
PubSubClient client(espClient);

// Callback for received messages
void callback(char* topic, byte* payload, unsigned int length) {
    Serial.print("Message on [");
    Serial.print(topic);
    Serial.print("]: ");

    char msg[length + 1];
    memcpy(msg, payload, length);
    msg[length] = '\0';
    Serial.println(msg);

    // Handle commands
    if (strcmp(topic, "home/esp32/command") == 0) {
        if (strcmp(msg, "ON") == 0) {
            digitalWrite(LED_BUILTIN, HIGH);
        } else if (strcmp(msg, "OFF") == 0) {
            digitalWrite(LED_BUILTIN, LOW);
        }
    }
}

void reconnect() {
    while (!client.connected()) {
        Serial.print("Connecting to MQTT...");
        String clientId = "ESP32-" + String(random(0xffff), HEX);

        // Connect with LWT
        if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass,
                          "home/esp32/status", 1, true, "offline")) {
            Serial.println("connected");

            // Publish online status (retained)
            client.publish("home/esp32/status", "online", true);

            // Subscribe to command topic
            client.subscribe("home/esp32/command", 1);
        } else {
            Serial.print("failed, rc=");
            Serial.println(client.state());
            delay(5000);
        }
    }
}

void setup() {
    Serial.begin(115200);
    pinMode(LED_BUILTIN, OUTPUT);

    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("\nWiFi connected");

    client.setServer(mqtt_server, mqtt_port);
    client.setCallback(callback);
    client.setBufferSize(512);  // Increase if publishing large payloads
}

void loop() {
    if (!client.connected()) {
        reconnect();
    }
    client.loop();  // MUST call in every loop iteration

    // Publish sensor data every 10 seconds
    static unsigned long lastPublish = 0;
    if (millis() - lastPublish > 10000) {
        lastPublish = millis();

        float temp = readTemperature();  // Your sensor function
        char payload[32];
        snprintf(payload, sizeof(payload), "%.1f", temp);
        client.publish("home/esp32/temperature", payload);
    }
}
```

**PubSubClient limitations:**
- Max message size: 256 bytes default (increase with `setBufferSize()`)
- QoS 0 only for publishing (subscribes at QoS 0 or 1)
- No QoS 2 support
- Single-threaded (must call `client.loop()` frequently)

### Python: paho-mqtt

```python
import paho.mqtt.client as mqtt
import json
import time

BROKER = "192.168.1.100"
PORT = 1883
USER = "piuser"
PASS = "pipassword"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to broker")
        # Subscribe on connect (auto-resubscribe on reconnect)
        client.subscribe("home/+/temperature", qos=1)
        client.subscribe("home/esp32/command", qos=1)
        # Publish online status
        client.publish("home/pi/status", "online", retain=True)
    else:
        print(f"Connection failed with code {rc}")

def on_message(client, userdata, msg):
    print(f"[{msg.topic}] {msg.payload.decode()}")

    # Parse and act on messages
    if "temperature" in msg.topic:
        temp = float(msg.payload.decode())
        if temp > 30.0:
            client.publish("home/alerts", f"High temp: {temp}C")

def on_disconnect(client, userdata, rc):
    print(f"Disconnected (rc={rc})")

# Create client
client = mqtt.Client(client_id="pi-gateway")

# Set credentials
client.username_pw_set(USER, PASS)

# Set LWT
client.will_set("home/pi/status", "offline", retain=True)

# Set callbacks
client.on_connect = on_connect
client.on_message = on_message
client.on_disconnect = on_disconnect

# Connect and start loop
client.connect(BROKER, PORT, keepalive=60)

# Blocking loop (runs forever, handles reconnection)
client.loop_forever()

# --- OR non-blocking: ---
# client.loop_start()  # Starts background thread
# while True:
#     client.publish("home/pi/cpu_temp", get_cpu_temp())
#     time.sleep(60)
```

Install: `pip install paho-mqtt`

### JavaScript/Node.js: mqtt.js

```javascript
const mqtt = require('mqtt');

const client = mqtt.connect('mqtt://192.168.1.100:1883', {
    username: 'jsuser',
    password: 'jspassword',
    clientId: 'node-dashboard',
    will: {
        topic: 'home/dashboard/status',
        payload: 'offline',
        retain: true
    }
});

client.on('connect', () => {
    console.log('Connected');
    client.publish('home/dashboard/status', 'online', { retain: true });
    client.subscribe('home/#');
});

client.on('message', (topic, message) => {
    console.log(`${topic}: ${message.toString()}`);
});

client.on('error', (err) => {
    console.error('MQTT error:', err);
});

// Publish
client.publish('home/command', JSON.stringify({ device: 'light1', action: 'on' }));
```

Install: `npm install mqtt`

**Browser usage (WebSocket):**
```javascript
const client = mqtt.connect('ws://192.168.1.100:9001');
```

Requires Mosquitto WebSocket listener:
```
# mosquitto.conf
listener 9001
protocol websockets
```

---

## Topic Design Patterns

### Home Automation

```
home/{room}/{device}/{property}

home/bedroom/light/state         → "on" / "off"
home/bedroom/light/brightness    → "0" to "100"
home/bedroom/temperature         → "22.5"
home/kitchen/motion/detected     → "true" / "false"
```

### Sensor Network

```
sensors/{location}/{sensor_id}/{measurement}

sensors/greenhouse/esp32-01/temperature    → "24.3"
sensors/greenhouse/esp32-01/humidity       → "65.2"
sensors/greenhouse/esp32-01/soil_moisture  → "450"
sensors/greenhouse/esp32-01/battery        → "3.82"
sensors/greenhouse/esp32-01/status         → "online"
```

### Command/Response

```
# Commands (subscribe by device)
devices/{device_id}/command     → {"action": "reboot"}

# Responses (published by device)
devices/{device_id}/response    → {"status": "ok", "uptime": 3600}

# Status (retained)
devices/{device_id}/status      → "online" / "offline"
```

### Home Assistant Discovery

If using Home Assistant, follow its MQTT discovery topic format:
```
homeassistant/{component}/{node_id}/{object_id}/config

Example:
homeassistant/sensor/esp32_01/temperature/config
Payload (JSON):
{
    "name": "ESP32 Temperature",
    "state_topic": "home/esp32-01/temperature",
    "unit_of_measurement": "°C",
    "device_class": "temperature",
    "unique_id": "esp32_01_temp"
}
```

---

## Persistent Sessions

When a client connects with `clean_session=False` (MQTT v3.1.1) or `clean_start=False` (MQTT v5):
- The broker stores subscriptions for the client
- QoS 1 and 2 messages are queued while the client is offline
- On reconnect, queued messages are delivered

```python
# Python example with persistent session
client = mqtt.Client(client_id="sensor1", clean_session=False)
```

```cpp
// Arduino PubSubClient — clean session is set in connect()
client.connect("sensor1", user, pass);  // clean_session=true by default
// PubSubClient doesn't directly support persistent sessions
```

**Important:** The client ID must be consistent across reconnections for persistent sessions to work.

---

## Payload Formats

### Plain Text (Simple)
```
home/temperature → "23.5"
home/light/state → "on"
```

### JSON (Structured — Recommended)
```
home/esp32/data → {"temperature": 23.5, "humidity": 65, "battery": 3.82}
```

### Binary/Protobuf (Compact)
For bandwidth-constrained applications, use binary encoding. MQTT payloads can contain any binary data.

**Recommendation:** Use JSON for most IoT projects. It's human-readable, easy to parse, and supported everywhere. Use plain text for trivial single-value topics.

---

## Troubleshooting

| Problem                        | Likely Cause                       | Fix                                  |
|-------------------------------|-------------------------------------|--------------------------------------|
| Can't connect to broker       | Wrong IP/port, firewall             | Check IP, open port 1883, check logs |
| Authentication failed         | Wrong username/password             | Verify credentials, check passwd file|
| No messages received          | Wrong topic, not subscribed         | Use `#` wildcard to see all messages |
| Messages arrive twice         | QoS 1 redelivery                   | Handle duplicates in code            |
| Retained messages won't clear | Must publish empty payload + retain | `mosquitto_pub -t topic -r -n`       |
| Connection drops frequently   | Keepalive timeout, network issues   | Increase keepalive, check WiFi       |
| ESP32 disconnects on publish  | Payload too large for buffer        | `client.setBufferSize(1024)`         |
| Broker won't start            | Config error, port in use           | Check logs: `journalctl -u mosquitto`|
| WebSocket clients can't connect| No WS listener configured          | Add `listener 9001` + `protocol websockets` |
| LWT not firing                | Client disconnected cleanly         | LWT only fires on ungraceful disconnect |

### Useful Debug Commands

```bash
# Watch all MQTT traffic on broker
mosquitto_sub -h localhost -t "#" -v

# Check broker logs
sudo tail -f /var/log/mosquitto/mosquitto.log

# Test connectivity
mosquitto_pub -h broker_ip -t "test" -m "hello"
mosquitto_sub -h broker_ip -t "test"

# Check if broker is reachable
nc -zv broker_ip 1883
```
