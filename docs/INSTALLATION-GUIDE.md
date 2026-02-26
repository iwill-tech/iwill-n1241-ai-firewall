# IWILL N1241 AI Firewall - Installation Guide

## Overview

Complete guide for deploying N1241 as an AI Firewall with OPNsense, Suricata IDS/IPS, Zenarmor AI-DPI, and CrowdSec.

**Hardware:** N1241 (8GB RAM, 256GB SSD, WiFi module)  
**Time:** ~60 minutes for complete setup

---

## What You're Building

```
Internet (ISP)
    │
[N1241 Port 1] ← WAN
    │
    AI Firewall (OPNsense)
    │
    ├── [Port 2] LAN (192.168.1.0/24)      → Trusted devices
    ├── [Port 3] AI-VLAN (192.168.20.0/24) → Ollama, OpenClaw, AI hosts
    └── [Port 4] IoT (192.168.30.0/24)     → Cameras, smart devices
```

**Security Stack:**
- OPNsense firewall
- Zenarmor AI-powered DPI (deep packet inspection + threat intelligence)
- VLAN isolation (4 zones)

---

## Prerequisites

- [ ] N1241 mini PC
- [ ] USB flash drive (4GB+)
- [ ] Keyboard + monitor
- [ ] Ethernet cables (minimum 2)
- [ ] Windows/Mac/Linux PC for preparation
- [ ] Internet connection

---

## Phase 1: Prepare Installation Media

### Download OPNsense

1. Go to https://opnsense.org/download/
2. Select:
   - **Architecture:** amd64
   - **Image type:** vga (serial console for N1241)
   - **Mirror:** Choose nearest
3. Download `OPNsense-XX.X-vga-amd64.img.bz2`

### Create Bootable USB

#### On Windows (Rufus):

1. Download Rufus from https://rufus.ie
2. Extract the `.img` file from `.bz2` (use 7-Zip)
3. Insert USB drive
4. Open Rufus:
   - Device: Select your USB
   - Boot selection: **SELECT** → choose `.img` file
   - Partition scheme: **MBR**
   - Click **START**
5. Wait ~3 minutes

#### On Mac/Linux:

```bash
# Extract
bunzip2 OPNsense-*.img.bz2

# Find USB (careful!)
diskutil list  # Mac
lsblk         # Linux

# Write (replace /dev/diskX)
sudo dd if=OPNsense-*.img of=/dev/diskX bs=4M status=progress
sync
```

---

## Phase 2: Install OPNsense on N1241

### Physical Setup

1. **Connect cables:**
   - Port 1: To ISP router/modem (WAN)
   - Port 2: To your laptop/computer (LAN)
   - Keyboard + monitor to N1241

2. **Insert USB drive** into N1241
3. **Power on** N1241

### Installation Process

1. **Boot menu:** Press `F7` during startup if needed to select USB
2. OPNsense boots automatically
3. **Login prompt:**
   - Username: `installer`
   - Password: `opnsense`

4. **Install OPNsense:**
   - Choose: `Install (UFS)`
   - Keymap: `Default`
   - Partitioning: `Auto (UFS)` → Entire disk
   - Confirm: `Yes` (this will erase the SSD)
   - Wait ~5 minutes
   - Root password: `[YOUR-PASSWORD]` (or your choice)
   - Complete installation: `Reboot`

5. **Remove USB drive** when prompted

---

## Phase 3: Initial Configuration

After reboot, OPNsense will auto-detect interfaces.

### Interface Assignment

OPNsense will show detected interfaces:
```
igc0 (Port 1) → WAN
igc1 (Port 2) → LAN  
igc2 (Port 3) → (unassigned)
igc3 (Port 4) → (unassigned)
```

At the console:

1. **Assign interfaces?** → `y`
2. **VLANs now?** → `n` (we'll do this in web UI)
3. **WAN interface:** `igc0`
4. **LAN interface:** `igc1`
5. **Optional interfaces:** Press `Enter` (skip for now)

### Set LAN IP

1. Select option `2` (Set interface IP addresses)
2. Choose `2` (LAN)
3. Configure IPv4: `y`
4. LAN IP: `192.168.1.1`
5. Subnet: `24`
6. IPv6: `n`
7. Enable DHCP: `y`
8. DHCP range start: `192.168.1.10`
9. DHCP range end: `192.168.1.250`
10. Revert to HTTP: `n`

**LAN is now accessible at:** `https://192.168.1.1`

---

## Phase 4: Web Interface Setup

1. **Connect laptop to Port 2 (LAN)**
2. Get IP via DHCP (should be 192.168.1.x)
3. Open browser: `https://192.168.1.1`
   - Accept security warning
4. **Login:**
   - Username: `root`
   - Password: `[YOUR-PASSWORD]` (or what you set)

### First-Time Wizard

1. **Welcome** → Next
2. **General Info:**
   - Hostname: `ai-firewall`
   - Domain: `local`
   - DNS servers: `1.1.1.1`, `8.8.8.8`
   - Next
3. **Time Server:**
   - Timezone: `Europe/Sofia` (or yours)
   - Next
4. **WAN Configuration:**
   - Type: `DHCP` (or Static if needed)
   - Block private networks: `✓`
   - Block bogon networks: `✓`
   - Next
5. **LAN Configuration:**
   - IP: `192.168.1.1/24`
   - Next
6. **Root Password:**
   - New password: `[YOUR-PASSWORD]` (confirm)
   - Next
7. **Reload** → Reload configuration
8. **Finish**

---

## Phase 5: Configure VLANs (AI Lab + IoT)

### Create VLANs

1. Go to **Interfaces → Other Types → VLAN**
2. Click **+** to add VLAN

**VLAN for AI Lab:**
- Parent interface: `igc2`
- VLAN tag: `20`
- Description: `AI-Lab`
- Save

**VLAN for IoT:**
- Parent interface: `igc3`
- VLAN tag: `30`
- Description: `IoT`
- Save

### Assign VLANs to Interfaces

1. Go to **Interfaces → Assignments**
2. Click **+** next to `igc2.20` → Assign
3. Click **+** next to `igc3.30` → Assign
4. Save

### Configure AI-Lab Interface (OPT1)

1. Go to **Interfaces → [OPT1]**
2. **Enable:** `✓`
3. **Description:** `AI_LAB`
4. **IPv4 Configuration:** `Static`
5. **IPv4 address:** `192.168.20.1/24`
6. Save → Apply

### Configure IoT Interface (OPT2)

1. Go to **Interfaces → [OPT2]**
2. **Enable:** `✓`
3. **Description:** `IOT`
4. **IPv4 Configuration:** `Static`
5. **IPv4 address:** `192.168.30.1/24`
6. Save → Apply

### Enable DHCP for VLANs

**For AI_LAB:**
1. Go to **Services → DHCPv4 → [AI_LAB]**
2. **Enable:** `✓`
3. Range: `192.168.20.10` to `192.168.20.250`
4. DNS: `192.168.20.1`
5. Save

**For IOT:**
1. Go to **Services → DHCPv4 → [IOT]**
2. **Enable:** `✓`
3. Range: `192.168.30.10` to `192.168.30.250`
4. DNS: `192.168.30.1`
5. Save

---

## Phase 6: Configure Firewall Rules

### AI_LAB Rules

1. Go to **Firewall → Rules → AI_LAB**
2. Click **+** (Add rule)

**Rule 1: Block access to LAN**
- Action: `Block`
- Interface: `AI_LAB`
- Source: `AI_LAB net`
- Destination: `LAN net`
- Description: `Block AI from accessing LAN`
- Save

**Rule 2: Allow internet**
- Action: `Pass`
- Interface: `AI_LAB`
- Source: `AI_LAB net`
- Destination: `any`
- Description: `Allow AI to internet`
- Save

**Apply Changes**

### IOT Rules

1. Go to **Firewall → Rules → IOT**
2. Add rules:

**Rule 1: Block LAN & AI**
- Action: `Block`
- Source: `IOT net`
- Destination: `LAN net, AI_LAB net`
- Description: `Isolate IoT`
- Save

**Rule 2: Allow DNS + HTTPS only**
- Action: `Pass`
- Protocol: `TCP/UDP`
- Destination port: `53, 443`
- Description: `IoT internet only`
- Save

**Apply Changes**

---

## Phase 7: Install Zenarmor Security

### Install Zenarmor Plugin

1. Go to **System → Firmware → Plugins**
2. Search: `zenarmor`
3. Install: `os-zenarmor`
4. Wait ~3 minutes for installation

### Configure Zenarmor

1. Go to **Services → Zenarmor**
2. Click **Setup Wizard**
3. **Interfaces:** Select `WAN`, `AI_LAB`, `IOT`
4. **Deployment mode:** `Routed`
5. **Create account:** Sign up at Sunny Valley (free Home tier)
6. **Activate license:** Copy activation key from email
7. **Security policies:**
   - Enable: `Malware Blocking`
   - Enable: `Botnet Protection`
   - Enable: `Phishing Prevention`
   - Enable: `Web Application Control`
8. Click **Finish**

### Start Zenarmor Engine

1. On the Dashboard, locate the **Engine** section (bottom left)
2. Click the **three dots (...)** menu
3. Click **Start**
4. Toggle **"Start on boot"** to ON (blue switch)
5. Wait 30 seconds and refresh - should show "Status: Running"

**✅ Zenarmor is now protecting your network with AI-powered threat detection!**

> **Note:** Do NOT install Suricata alongside Zenarmor. Both use netmap mode for inline inspection and will conflict, causing the Zenarmor engine to crash with "Device busy" errors. Zenarmor provides superior application-aware filtering for AI traffic.

---

## Phase 8: AI-Specific Configuration

### Egress Filtering (Cloud AI APIs)

If using hybrid AI (local + cloud):

1. Go to **Firewall → Rules → AI_LAB**
2. Add rule:

**Allow only specific cloud APIs:**
- Action: `Pass`
- Source: `AI_LAB net`
- Destination: `Address/Alias` → Create alias:
  - Name: `AI_Cloud_APIs`
  - Type: `Host(s)`
  - Content:
    ```
    api.openai.com
    api.anthropic.com
    generativelanguage.googleapis.com
    ```
- Description: `Allow Cloud AI APIs only`
- Save

**Block all other outbound HTTPS:**
- Action: `Block`
- Protocol: `TCP`
- Destination port: `443`
- Description: `Block unauthorized HTTPS`
- Save

### Rate Limiting (Prevent API Abuse)

1. Go to **Firewall → Settings → Advanced**
2. **Firewall Optimization:** `Aggressive`
3. Enable: `Limit states per source`
4. **Max states:** `100`
5. Save

---

## Phase 9: Monitoring & Alerts

### Enable System Logging

1. Go to **System → Settings → Logging**
2. **Log level:** `Informational`
3. **Preserve logs:** `✓`
4. **Log firewall:** `✓`
5. Save

### Zenarmor Reporting

**Built-in dashboards:**
1. **Services → Zenarmor → Dashboard** - Real-time overview
2. **Services → Zenarmor → Security → Threats** - Blocked threats
3. **Services → Zenarmor → Reports → Applications** - App usage
4. **Services → Zenarmor → Reports → Web** - Web activity

### Optional: Email Alerts

1. Go to **System → Settings → Notifications**
2. Configure SMTP settings
3. Enable notifications for:
   - High CPU/memory
   - Interface down
   - Firmware updates

---

## Testing & Verification

### Test 1: Basic Internet Connectivity

**From LAN device (Port 2):**
```bash
# Windows
ping 8.8.8.8

# Linux/Mac
ping -c 4 8.8.8.8
```
**Expected:** Replies from 8.8.8.8 with ~2ms latency ✅

### Test 2: Zenarmor Dashboard

1. Go to **Services → Zenarmor → Dashboard**
2. **Verify:**
   - Engine Status: **Running** (green)
   - Cloud Threat Intelligence: **UP**
   - Traffic graphs showing activity
   - "Today, zenarmor detected X activities"

### Test 3: VLAN Isolation (when devices connected)

**From AI_LAB device (Port 3):**
```bash
ping 8.8.8.8        # Should work ✅
ping 192.168.1.1    # Should FAIL ❌ (blocked by firewall rule)
```

**From IOT device (Port 4):**
```bash
ping 8.8.8.8        # Should work ✅
ping 192.168.1.1    # Should FAIL ❌
ping 192.168.20.1   # Should FAIL ❌ (AI_LAB blocked)
```

### Test 4: Zenarmor Threat Detection

1. Browse to a test malware site from LAN: `http://malware.wicar.org/data/eicar.com`
2. Go to **Services → Zenarmor → Security → Threats**
3. **Expected:** Blocked threat logged ✅

---

## Quick Reference

| Item | Value |
|------|-------|
| Web UI | https://192.168.1.1 |
| Username | root |
| Password | [YOUR-PASSWORD] |
| LAN Subnet | 192.168.1.0/24 |
| AI Lab | 192.168.20.0/24 (Port 3) |
| IoT | 192.168.30.0/24 (Port 4) |

### Port Assignment
- **Port 1 (igc0):** WAN → ISP
- **Port 2 (igc1):** LAN → Trusted devices
- **Port 3 (igc2):** AI-Lab → Ollama, OpenClaw
- **Port 4 (igc3):** IoT → Cameras, sensors

---

## Troubleshooting

### Can't access web UI?

Reset admin password via console:
```
Option 4: Reset root password
```

### VLANs not working?

Check interface assignment:
```
Interfaces → Assignments
```
Make sure VLANs are assigned and enabled.

### Zenarmor engine keeps stopping?

**Error:** `netmap_register_if: igc0: NIOCREGIF ioctl failed: Device busy`

**Cause:** Another service (like Suricata) is using netmap mode on the same interface.

**Fix:**
1. Go to **Services → Intrusion Detection → Administration**
2. Uncheck **"Enabled"** or uncheck **"IPS mode"**
3. Click **Apply**
4. Restart Zenarmor engine

### No internet after installation?

1. Check WAN has IP: **Interfaces → Overview**
2. Test gateway: `ping 8.8.8.8` from **Diagnostics → Ping**
3. Check firewall rules: **Firewall → Rules → WAN** (should have default allow)

### DHCP not working on VLANs?

1. Verify DHCP is enabled: **Services → DHCPv4 → [Interface]**
2. Check interface has IP: **Interfaces → Overview**
3. Look for errors: **System → Log Files → DHCP**

---

## Next Steps

- See `AI-SECURITY-RULES.md` for advanced firewall rules
- See `CUSTOMER-GUIDE.md` for end-user documentation
- See `MONITORING.md` for dashboard setup

---

**Installation complete!** 🎉

Your N1241 is now an AI Firewall protecting your local and hybrid AI infrastructure.
