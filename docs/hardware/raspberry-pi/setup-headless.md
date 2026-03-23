# Headless Raspberry Pi Setup

A "headless" setup means configuring and using the Pi without a monitor, keyboard, or mouse — only network access (SSH or VNC).

---

## Method 1: Raspberry Pi Imager (Recommended)

The Raspberry Pi Imager tool handles OS writing and pre-configuration in one step.

### Step 1: Download and Install Imager

- Download from: https://www.raspberrypi.com/software/
- Available for Windows, macOS, and Linux (also `sudo apt install rpi-imager` on Debian/Ubuntu)

### Step 2: Write the OS Image

1. Insert your microSD card into your computer
2. Launch Raspberry Pi Imager
3. Click "Choose Device" and select your Pi model
4. Click "Choose OS":
   - For headless server: **Raspberry Pi OS Lite (64-bit)**
   - For remote desktop: **Raspberry Pi OS with Desktop (64-bit)**
5. Click "Choose Storage" and select your microSD card
6. Click "Next"

### Step 3: Configure Settings (Advanced Options)

When prompted "Would you like to apply OS customisation settings?", click "Edit Settings":

**General tab:**
- Set hostname (e.g., `raspberrypi` — accessible as `raspberrypi.local` on the network)
- Set username and password (default `pi` user no longer created automatically on Bookworm)
- Configure wireless LAN: enter your WiFi SSID, password, and country code
- Set locale settings (timezone, keyboard layout)

**Services tab:**
- Enable SSH (select "Use password authentication" or "Allow public-key authentication only")
- If using public key: paste your public key (`cat ~/.ssh/id_ed25519.pub`)

Click "Save", then "Yes" to apply settings. Confirm writing to the SD card.

### Step 4: Boot the Pi

1. Insert the microSD card into the Pi
2. Connect Ethernet cable (if not using WiFi)
3. Connect power — the Pi boots automatically
4. Wait 1-2 minutes for first boot (it resizes the filesystem and applies your settings)

---

## Method 2: Manual Configuration

For when you do not have access to Raspberry Pi Imager.

### Step 1: Write the Image

Download the OS image from https://www.raspberrypi.com/software/operating-systems/

**Linux:**
```bash
# Find your SD card device (usually /dev/sdX or /dev/mmcblkX)
lsblk

# Write the image (CAREFUL: wrong device = data loss!)
sudo dd if=2024-03-15-raspios-bookworm-arm64-lite.img of=/dev/sdX bs=4M status=progress conv=fsync

# Or use:
sudo unzip -p 2024-03-15-raspios-bookworm-arm64-lite.img.xz | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
```

**Windows/macOS:** Use balenaEtcher (https://etcher.balena.io/) — select image, select drive, flash.

### Step 2: Enable SSH

Mount the boot partition (FAT32, should auto-mount on most systems) and create an empty file named `ssh`:

```bash
# Linux (adjust mount point as needed)
touch /media/$USER/bootfs/ssh

# macOS
touch /Volumes/bootfs/ssh

# Windows (PowerShell)
New-Item -Path "E:\ssh" -ItemType File    # E: = boot partition drive letter
```

### Step 3: Create a User Account

On Raspberry Pi OS Bookworm and later, there is no default `pi` user. You must create one.

Create a file called `userconf.txt` in the boot partition:

```bash
# Generate encrypted password
echo 'mypassword' | openssl passwd -6 -stdin
# Output: $6$xxxx...long hash...xxxx

# Create the file with format: username:encrypted-password
echo 'pi:$6$xxxx...long hash...xxxx' > /media/$USER/bootfs/userconf.txt
```

Or create `userconf` (no .txt extension) with the same content.

### Step 4: Configure WiFi

Create `wpa_supplicant.conf` in the boot partition:

```bash
cat > /media/$USER/bootfs/wpa_supplicant.conf << 'EOF'
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="YourNetworkName"
    psk="YourPassword"
    key_mgmt=WPA-PSK
}
EOF
```

**Note:** On Raspberry Pi OS Bookworm, WiFi is managed by NetworkManager, not wpa_supplicant. The `wpa_supplicant.conf` method works on Bullseye and earlier. For Bookworm, use Raspberry Pi Imager's advanced settings or configure after first boot.

### Step 5: Boot and Connect

Insert SD card, connect power, wait 1-2 minutes, then SSH in.

---

## Finding the Pi on Your Network

### Method 1: mDNS / Bonjour

If you set a hostname (e.g., `raspberrypi`), try:

```bash
ssh pi@raspberrypi.local
```

mDNS works on:
- Linux (with avahi-daemon, usually pre-installed)
- macOS (built-in Bonjour)
- Windows (may need Bonjour Print Services installed, or use the full hostname)

### Method 2: Network Scan with nmap

```bash
# Scan your local subnet for devices with SSH port open
nmap -sn 192.168.1.0/24

# Or specifically look for SSH
nmap -p 22 --open 192.168.1.0/24
```

Look for a device with "Raspberry Pi" in the MAC address vendor field.

### Method 3: ARP Table

```bash
# After the Pi has been on the network for a minute
arp -a

# Or on Linux
ip neigh show
```

### Method 4: Router Admin Page

Log into your router's admin interface (usually 192.168.1.1 or 192.168.0.1) and check the DHCP client list. Look for a device named `raspberrypi` or with a MAC address starting with `B8:27:EB` (Pi 3 and earlier), `DC:A6:32` (Pi 4), or `D8:3A:DD` (Pi 5).

### Method 5: Check with ping

```bash
# Try common addresses if you know your subnet
ping raspberrypi.local

# If that doesn't work, try scanning
for i in $(seq 1 254); do ping -c 1 -W 0.1 192.168.1.$i &>/dev/null && echo "192.168.1.$i is up"; done
```

---

## First SSH Connection

```bash
ssh pi@raspberrypi.local
# Or:
ssh pi@192.168.1.XXX
```

Accept the host key fingerprint when prompted (type `yes`).

### First Steps After Login

```bash
# Change password (if you haven't already set one)
passwd

# Update package lists and upgrade all packages
sudo apt update && sudo apt full-upgrade -y

# Set timezone
sudo timediff set-timezone America/New_York
# Or use raspi-config:
sudo raspi-config   # Localisation Options > Timezone

# Expand filesystem (usually automatic, but just in case)
sudo raspi-config   # Advanced Options > Expand Filesystem

# Reboot to apply changes
sudo reboot
```

---

## Setting a Static IP Address

### Method 1: NetworkManager (Bookworm)

```bash
# List connections
nmcli con show

# Set static IP for wired connection
sudo nmcli con mod "Wired connection 1" \
    ipv4.method manual \
    ipv4.addresses "192.168.1.100/24" \
    ipv4.gateway "192.168.1.1" \
    ipv4.dns "192.168.1.1,8.8.8.8"

# Set static IP for WiFi
sudo nmcli con mod "preconfigured" \
    ipv4.method manual \
    ipv4.addresses "192.168.1.101/24" \
    ipv4.gateway "192.168.1.1" \
    ipv4.dns "192.168.1.1,8.8.8.8"

# Apply changes
sudo nmcli con up "Wired connection 1"
```

### Method 2: dhcpcd (Bullseye and earlier)

Edit `/etc/dhcpcd.conf`:

```bash
sudo nano /etc/dhcpcd.conf
```

Add at the bottom:

```
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8

interface wlan0
static ip_address=192.168.1.101/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8
```

Restart networking:
```bash
sudo systemctl restart dhcpcd
```

### Method 3: Router DHCP Reservation

The most reliable method: configure your router to always assign the same IP address to the Pi's MAC address. This requires no changes on the Pi itself. Find the option in your router's DHCP settings (often called "DHCP reservation" or "static lease").

---

## VNC Setup (Remote Desktop)

### Enable VNC Server

```bash
sudo raspi-config
# Interface Options > VNC > Enable
```

Or install manually:

```bash
# On Bookworm (uses wayvnc for Wayland)
sudo apt install wayvnc

# On Bullseye (uses RealVNC)
sudo apt install realvnc-vnc-server
sudo systemctl enable vncserver-x11-serviced
sudo systemctl start vncserver-x11-serviced
```

### Set Screen Resolution for Headless VNC

Without a monitor attached, you need to set a default resolution:

```bash
sudo raspi-config
# Display Options > VNC Resolution > 1920x1080 (or your preference)
```

Or edit `/boot/firmware/config.txt`:
```ini
# Force HDMI output even without a monitor
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=82    # 1920x1080 60Hz
```

### Connect with VNC Client

1. Install a VNC viewer on your computer:
   - RealVNC Viewer (https://www.realvnc.com/en/connect/download/viewer/) — free for personal use
   - TigerVNC (open source)
   - Remmina (Linux, open source)
2. Connect to `raspberrypi.local:5900` or `192.168.1.100:5900`
3. Enter your Pi username and password

---

## SSH Key-Based Authentication

Password authentication works but key-based auth is more secure and convenient.

### Step 1: Generate an SSH Key (on your computer)

```bash
# Generate Ed25519 key (recommended)
ssh-keygen -t ed25519 -C "your-email@example.com"

# Or RSA (wider compatibility)
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```

This creates:
- `~/.ssh/id_ed25519` — Private key (keep secret!)
- `~/.ssh/id_ed25519.pub` — Public key (safe to share)

### Step 2: Copy the Public Key to the Pi

```bash
# Easiest method:
ssh-copy-id pi@raspberrypi.local

# Manual method (if ssh-copy-id isn't available):
cat ~/.ssh/id_ed25519.pub | ssh pi@raspberrypi.local "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

### Step 3: Test Key-Based Login

```bash
ssh pi@raspberrypi.local
# Should log in without asking for a password
```

### Step 4: Disable Password Authentication (Optional but Recommended)

Edit `/etc/ssh/sshd_config` on the Pi:

```bash
sudo nano /etc/ssh/sshd_config
```

Change these settings:
```
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
```

Restart SSH:
```bash
sudo systemctl restart ssh
```

**Warning:** Make sure key-based login works BEFORE disabling password authentication, or you may lock yourself out.

### SSH Config File (on your computer)

Create `~/.ssh/config` for convenient access:

```
Host pi
    HostName raspberrypi.local
    User pi
    IdentityFile ~/.ssh/id_ed25519
    # Optional: keep connection alive
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Now you can simply type:
```bash
ssh pi
```

---

## Additional Hardening

### Change the SSH Port

Edit `/etc/ssh/sshd_config`:
```
Port 2222
```

```bash
sudo systemctl restart ssh
# Connect with: ssh -p 2222 pi@raspberrypi.local
```

### Install fail2ban

Blocks IPs after repeated failed login attempts:

```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### Enable the Firewall

```bash
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh         # Or: sudo ufw allow 2222/tcp (if you changed the port)
sudo ufw enable
sudo ufw status
```

### Automatic Security Updates

```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
# Select "Yes" to enable automatic updates
```

---

## Troubleshooting

| Problem | Possible Cause | Solution |
|---|---|---|
| Cannot find Pi on network | WiFi credentials wrong | Re-flash SD card with correct SSID/password |
| SSH connection refused | SSH not enabled | Create `ssh` file in boot partition |
| `Permission denied` on SSH | Wrong username/password | Check userconf.txt; default user is no longer `pi` on Bookworm |
| WiFi not connecting | Country code not set | Set `country=XX` in wpa_supplicant.conf or via Imager |
| Pi keeps rebooting | Insufficient power supply | Use recommended PSU; check for undervoltage in `dmesg` |
| SD card corruption | Cheap SD card or power loss | Use quality A2 card; always `sudo shutdown -h now` before unplugging |
| mDNS (.local) not resolving | Avahi not running or not installed on client | Install Bonjour (Windows) or use IP address directly |
| VNC shows "Cannot currently show desktop" | No display resolution set | Set resolution in raspi-config or config.txt |
