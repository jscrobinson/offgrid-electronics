# Mesh Network Planning

How to design, deploy, and optimize a Meshtastic mesh network for reliable off-grid communication.

---

## Node Placement Strategy

### Height Is King

The single most important factor in LoRa range is antenna height. Radio waves at 915/868 MHz travel primarily by line of sight. Elevating a node even a few meters above ground level can dramatically increase coverage.

**Height vs Range (approximate, 915 MHz, flat terrain):**

| Antenna Height | Approximate LOS Horizon | Practical LoRa Range |
|---------------|------------------------|---------------------|
| 1.5m (handheld) | 4.4 km | 1-3 km (urban), 3-8 km (open) |
| 5m (roof of single story) | 8 km | 3-10 km |
| 10m (roof of two story) | 11.3 km | 5-15 km |
| 30m (tall building/tower) | 19.5 km | 10-30 km |
| 100m (hilltop/mountain) | 35.7 km | 20-60 km |

The formula for line-of-sight horizon distance (km) = 3.57 x sqrt(height in meters).

For two elevated stations, the maximum LOS distance is: 3.57 x (sqrt(h1) + sqrt(h2)).

### Optimal Node Locations
- **Rooftops** — the best accessible option for most people
- **Attic windows** — facing the direction of most nodes (glass/wood are nearly transparent to LoRa)
- **Elevated terrain** — hilltops, ridgelines, tall buildings
- **Water towers, fire lookouts, grain elevators** — with permission
- **Trees** — weatherproof enclosure + solar panel mounted in a tree canopy

### What Blocks LoRa
| Material | Attenuation | Notes |
|----------|-------------|-------|
| Glass/wood | Minimal (<3 dB) | LoRa passes through easily |
| Drywall | Minimal | Interior walls are mostly transparent |
| Brick | Moderate (5-10 dB) | One wall is OK, several will block |
| Concrete | High (10-20 dB) | Significant blockage |
| Metal | Very high (20+ dB) | Nearly opaque — metal buildings, vehicles |
| Earth/hills | Total blockage | No penetration — must go over terrain |
| Dense forest | Moderate (5-15 dB) | Wet foliage is worse than dry |
| Rain | Minimal at 915 MHz | Not a significant factor at LoRa frequencies |

---

## Role Assignment

### Network Architecture

A well-designed mesh assigns roles strategically:

**Routers:** fixed, elevated, always-on, high-power nodes
- Place at high points with wide coverage
- Use quality antennas (gain antenna, mounted as high as possible)
- Power from mains or solar (they need to be always-on)
- Set role to ROUTER
- Maximize TX power
- These are the backbone of your network

**Clients:** mobile user nodes
- T-Beams in pockets/backpacks, or Heltec V3 devices
- Set role to CLIENT (default)
- These connect to the network through routers
- Can also relay messages (unless set to CLIENT_MUTE)

**Repeaters:** simple signal extenders
- Place between areas that can't directly reach a router
- Set role to REPEATER
- Minimal configuration — just relay traffic
- Can be very simple: Heltec V3 + USB power bank in a window

---

## Hop Limit Considerations

Each hop in the mesh adds:
- **Latency:** LoRa transmissions take 0.5-5 seconds depending on modem preset. Each hop roughly doubles the round-trip time for an acknowledged message.
- **Airtime consumption:** each retransmission uses channel airtime, reducing capacity for other messages.

### Practical Guidance

| Network Size | Recommended Hop Limit | Notes |
|-------------|----------------------|-------|
| 2-5 nodes, local | 2 | Simple network, minimal hops needed |
| 5-20 nodes, neighborhood | 3 (default) | Good balance |
| 20-50 nodes, city-wide | 3-4 | Higher hops useful if network is spread out |
| 50+ nodes | 3 | Keep low to prevent congestion; use well-placed routers instead |

**The solution to range problems is better router placement, not more hops.** Adding hops beyond what's needed just wastes airtime.

---

## Channel Utilization and Congestion

LoRa is a shared medium. All nodes on the same channel share the same radio bandwidth.

### How Congestion Happens
- Each node transmitting uses the channel for the duration of the packet
- Other nodes must wait for the channel to be clear before transmitting
- With LONG_FAST: each packet takes ~1 second of airtime
- With LONG_SLOW: each packet takes ~5+ seconds of airtime
- Add message retransmissions, acknowledgments, and position broadcasts — airtime fills up fast

### Congestion Symptoms
- Messages taking a long time to deliver
- Messages failing to deliver (no ACK)
- High "channel utilization" percentage in device telemetry
- Duplicate messages

### Mitigation Strategies
- **Reduce hop limit** to the minimum needed
- **Use faster modem presets** (MEDIUM_FAST or SHORT_FAST) for dense local networks
- **Reduce position broadcast frequency** (every 15-30 minutes instead of every 2 minutes)
- **Use CLIENT_MUTE** for nodes that only need to listen
- **Separate traffic onto different channels** (e.g., general chat on one channel, telemetry on another)
- **Limit Store & Forward** to one or two nodes

### Airtime Budget
- Regulatory duty cycle limits (EU: 10% or 1% depending on sub-band)
- Practical limit even without regulation: keep below 25% channel utilization
- With 50 nodes, each broadcasting position every 15 minutes: 50 x 4 packets/hour = 200 packets/hour of just position data

---

## Range Testing

### Using the Range Test Module

1. **Configure the sender:**
   ```bash
   meshtastic --set range_test.enabled true
   meshtastic --set range_test.sender 30  # Send every 30 seconds
   ```

2. **Configure the receiver:**
   - Just enable range_test.enabled (but don't set sender)
   - Messages will appear with RSSI and SNR values

3. **Walk or drive with the sender** while monitoring RSSI/SNR on the receiver

### Understanding RSSI and SNR

**RSSI (Received Signal Strength Indicator):**
| RSSI | Signal Quality |
|------|---------------|
| -60 dBm | Excellent (very close) |
| -90 dBm | Good |
| -110 dBm | Fair |
| -120 dBm | Weak (near receiver sensitivity) |
| -130+ dBm | Unreliable or no reception |

**SNR (Signal-to-Noise Ratio):**
| SNR | Quality |
|-----|---------|
| +10 dB | Excellent |
| 0 dB | Decent |
| -5 dB | LoRa can still decode (spreading factor advantage) |
| -10 dB | Marginal |
| -20 dB | Only possible with highest spreading factors (LONG_SLOW) |

LoRa's superpower is the ability to decode signals well below the noise floor (negative SNR). This is what gives it such long range.

---

## Solar-Powered Relay Nodes

A solar-powered router is the backbone of a reliable mesh network. It needs to operate 24/7 without maintenance.

### Sizing (for a T-Beam Router)

**Power consumption estimate:**
- T-Beam ROUTER mode, GPS off, display off: ~50-60mA at 3.7V = ~0.2W
- Average including LoRa TX bursts: ~0.25W
- Daily consumption: 0.25W x 24h = **6 Wh/day**

**Battery sizing (3 days autonomy):**
- 6 Wh x 3 days = 18 Wh
- At 3.7V: 18 / 3.7 = 4865 mAh
- Use 2x 3000mAh 18650s in parallel: 6000mAh = 22.2 Wh (provides ~3.7 days autonomy)
- Or a single 21700 5000mAh cell: 18.5 Wh (about 3 days)

**Solar panel sizing:**
- Need to generate 6 Wh/day minimum
- Assume 4 peak sun hours (conservative)
- Account for losses (1.3x): 6 x 1.3 = 7.8 Wh
- Panel watts: 7.8 / 4 = ~2W minimum
- **Use a 5-6W panel for good margin** (cloudy days, winter, dust)

### Enclosure
- Use a weatherproof enclosure (IP65 or better)
- **Junction boxes** from the hardware store work well and are cheap
- Drill holes for the antenna cable and solar panel wire, seal with silicone
- Include silica gel desiccant packets to absorb moisture
- Paint the enclosure white or light color to reduce solar heating
- Mount with the cable entries facing down so water can't pool in them

### Mounting Example
```
         [Solar Panel]
              |
         [6V 5W panel] tilted toward sun
              |
    +---------+----------+
    |  Weatherproof Box  |
    |                    |
    |  [CN3791 charger]  |
    |       |            |
    |  [18650 x2 (2P)]  |
    |       |            |
    |  [T-Beam]          |
    |       |            |
    +---------+----------+
              |
         [Antenna] (mounted above box)
         e.g. slim jim or ground plane
```

---

## Antenna Selection

### Fixed Nodes (Routers/Relays)
- Use the highest gain omnidirectional antenna practical
- **Recommended:** 5/8 wave ground plane (5-6 dBi) or colinear vertical (6-9 dBi)
- Mount as high as possible with clear view of the coverage area
- Use low-loss coax (LMR-400 for runs over 3m; RG-316/RG-174 only for short pigtails)

### Mobile Nodes (Clients)
- Stock rubber ducky antenna is adequate for most situations
- Upgrade to a half-wave whip for better range
- Keep the antenna vertical for best performance with vertically polarized fixed antennas

### Directional Antennas
- **Yagi** antennas (8-12 dBi) are useful for point-to-point links between two fixed locations
- Must be aimed precisely at the other node
- Not useful for general mesh coverage (too narrow beam)

### Cable Losses
| Cable Type | Loss at 915 MHz (per meter) | Use Case |
|-----------|----------------------------|----------|
| RG-174 | ~1.0 dB/m | Short pigtails only (<0.5m) |
| RG-316 | ~0.8 dB/m | Short pigtails (<1m) |
| RG-58 | ~0.5 dB/m | Short runs (<3m) |
| LMR-240 | ~0.3 dB/m | Medium runs (3-10m) |
| LMR-400 | ~0.15 dB/m | Long runs (10m+) |

**Every 3 dB of loss cuts your signal in half.** A 10m run of RG-58 loses 5 dB — that's worse than using a lower gain antenna with shorter cable. Use the shortest, lowest-loss cable possible.

---

## Network Topology

### Star Topology
- One central router, all clients connect to it
- Simple, works well for small areas
- Single point of failure (if the router goes down, nobody can communicate)
- Not really a "mesh" — more of a hub

### Mesh Topology
- Multiple routers with overlapping coverage
- Messages can take multiple paths to reach their destination
- Redundant — if one node fails, messages route around it
- **This is the goal for a reliable network**

### Linear Chain
- Nodes arranged in a line (e.g., along a trail, river, or road)
- Each node can only reach the next one in each direction
- Fragile — any node failure breaks the chain
- Mitigate by having overlapping coverage where possible (some nodes can reach 2-3 neighbors)

---

## Scaling Considerations

### Realistic Node Limits
- **Per channel:** about 80-100 active nodes before congestion becomes a serious problem
- This depends heavily on:
  - Modem preset (faster = more capacity)
  - How often nodes transmit (position, telemetry, messages)
  - Hop limit (more hops = more airtime per message)
- With default settings (LONG_FAST, hop limit 3, 15-min position broadcast), 50-80 nodes is comfortable

### Large Network Strategies
- **Multiple channels:** split traffic (e.g., one channel for chat, one for telemetry)
- **Faster modem preset:** MEDIUM_FAST or SHORT_FAST for dense areas
- **Reduce broadcasts:** longer position intervals, disable unnecessary telemetry
- **CLIENT_MUTE nodes:** nodes that only listen don't add to airtime
- **Geographic segmentation:** separate channels for different areas, with gateway nodes that bridge between them

---

## Redundancy

### Building a Resilient Network

1. **Multiple paths:** ensure at least 2 router nodes can reach any part of the network
2. **Power redundancy:** solar + battery means nodes survive power outages
3. **Physical redundancy:** don't put all routers on the same building or tower
4. **Spare equipment:** keep at least one pre-configured spare node ready to deploy
5. **Documentation:** maintain a map of node locations, configurations, and responsible people

### Failure Modes to Plan For
- **Power outage:** all mains-powered nodes go down simultaneously. Solar nodes keep the network alive.
- **Single node failure:** if a key router fails, can messages still route around it?
- **Weather:** ice on antennas, snow on solar panels, high winds on tall antennas
- **Theft/vandalism:** outdoor nodes in accessible locations may be tampered with

### Testing
- Periodically turn off individual router nodes and verify messages still flow
- Send range test packets from the edges of your network to verify coverage
- Monitor battery levels and solar charging on all remote nodes through telemetry
- Keep firmware updated on all nodes (coordinate updates so you don't take down the whole network at once)
