# N1241 AI Firewall - Rapid Deployment Guide

**Total Time: ~20 minutes** (from USB to fully configured)

This guide uses pre-built configuration to skip manual setup steps.

---

## What You Need

- [ ] N1241 mini PC
- [ ] USB flash drive (4GB+) with OPNsense
- [ ] Ethernet cables (minimum 2)
- [ ] Computer for initial setup
- [ ] 20 minutes

---

## Phase 1: Install OPNsense (15 min)

### 1.1 Create Bootable USB

**Download OPNsense:**
- Go to https://opnsense.org/download/
- Architecture: **amd64**
- Image type: **vga**
- Download the `.img.bz2` file

**Flash to USB:**

**Windows (Rufus):**
```
1. Extract .img from .bz2 (use 7-Zip)
2. Open Rufus
3. Select USB drive
4. SELECT → choose .img file
5. START
```

**Mac/Linux:**
```bash
bunzip2 OPNsense-*.img.bz2
sudo dd if=OPNsense-*.img of=/dev/sdX bs=4M status=progress
sync
```

### 1.2 Connect Hardware

```
Port 1 → ISP Router/Modem (WAN)
Port 2 → Your laptop/computer (LAN)
Monitor + Keyboard → N1241
USB drive → N1241
```

### 1.3 Install to SSD

1. **Boot from USB** (press F7 if needed)
2. **Login:**
   - Username: `installer`
   - Password: `opnsense`
3. **Install:**
   - Choose: `Install (UFS)`
   - Keymap: `Default`
   - Partitioning: `Auto (UFS)` → Entire disk
   - Confirm: `Yes`
   - Wait ~5 minutes
4. **Set root password:**
   - Password: `[YOUR-PASSWORD]` (or your choice)
   - Confirm password
5. **Complete:**
   - Select: `Reboot`
   - **Remove USB drive** when prompted

**⏱️ Checkpoint: 15 minutes elapsed**

---

## Phase 2: Import Configuration (2 min)

After reboot, OPNsense will auto-configure interfaces.

### 2.1 Access Web UI

1. **Connect laptop to Port 2**
2. Get IP via DHCP (should be 192.168.1.x)
3. Open browser: `https://192.168.1.1`
4. Accept security warning
5. **Login:**
   - Username: `root`
   - Password: `[YOUR-PASSWORD]` (or what you set)

### 2.2 Skip First-Time Wizard

Click **"Logout"** or **"Skip wizard"** at the top right.

We're importing pre-made config instead!

### 2.3 Import Base Configuration

1. Go to: **System → Configuration → Backups**
2. Scroll to **"Restore Backup"** section
3. Click **"Choose File"**
4. Select: `configs/n1241-base-config.xml` (from this package)
5. Check: **"Skip backup re-encryption"** (if shown)
6. Click **"Restore Configuration"**
7. Wait ~30 seconds
8. Click **"Reboot"** when prompted
9. Wait ~2 minutes for reboot

**⏱️ Checkpoint: 17 minutes elapsed**

---

## Phase 3: Install Zenarmor & Finalize (3 min)

After reboot, log back into web UI.

### 3.1 Install Zenarmor Plugin

1. Go to: **System → Firmware → Plugins**
2. Search: `zenarmor`
3. Click **"+"** to install `os-zenarmor`
4. Wait ~2 minutes
5. Refresh page when complete

### 3.2 Configure Zenarmor

1. Go to: **Services → Zenarmor**
2. Click **"Setup Wizard"**
3. **Interfaces:** Select `WAN`, `AI_LAB`, `IOT`
4. **Deployment mode:** `Routed`
5. **Account:**
   - Go to https://www.sunnyvalley.io
   - Create free account
   - Copy activation key from email
   - Paste in wizard
6. **Security policies:**
   - Enable: `Malware Blocking`
   - Enable: `Botnet Protection`
   - Enable: `Phishing Prevention`
   - Enable: `Web Application Control`
7. Click **"Finish"**

### 3.3 Start Zenarmor Engine

1. On Dashboard, find **"Engine"** section (bottom left)
2. Click **three dots (...)** menu
3. Click **"Start"**
4. Toggle **"Start on boot"** to ON
5. Wait 30 seconds, refresh
6. Verify: Status = **"Running"** ✅

### 3.4 Verify WAN Connection

1. Go to: **Interfaces → Overview**
2. Check **WAN** has IP address
3. If not, go to **Interfaces → WAN** and configure:
   - **DHCP** (most common)
   - **Static IP** (if ISP gave you one)
   - **PPPoE** (if ISP uses username/password)

**⏱️ Checkpoint: 20 minutes elapsed**

---

## Phase 4: Testing (2 min)

### 4.1 Internet Connectivity

From your laptop (connected to Port 2):

**Windows:**
```cmd
ping 8.8.8.8
```

**Mac/Linux:**
```bash
ping -c 4 8.8.8.8
```

**Expected:** Replies from 8.8.8.8 ✅

### 4.2 Zenarmor Status

1. Go to: **Services → Zenarmor → Dashboard**
2. **Verify:**
   - Engine Status: **Running** (green)
   - Cloud Threat Intelligence: **UP**
   - Traffic graphs showing activity

### 4.3 VLANs Ready

Check **Interfaces → Overview**:
- **LAN:** 192.168.1.1/24 ✅
- **AI_LAB:** 192.168.20.1/24 ✅
- **IOT:** 192.168.30.1/24 ✅

---

## Phase 5: Connect Devices

### AI Devices (Port 3)

**Connect to Port 3:**
- Ollama server
- OpenClaw host
- LM Studio machine
- AI development workstation

**They will get:**
- IP: 192.168.20.x (via DHCP)
- Internet: ✅ Full access
- LAN access: ❌ **Blocked by firewall**

**Test isolation:**
```bash
ping 8.8.8.8        # Should work ✅
ping 192.168.1.1    # Should FAIL ❌
```

### IoT Devices (Port 4)

**Connect to Port 4:**
- Security cameras
- Smart sensors
- IoT devices

**They will get:**
- IP: 192.168.30.x (via DHCP)
- Internet: ⚠️ **DNS + HTTPS only** (for updates)
- LAN/AI_LAB: ❌ **Completely isolated**

---

## Quick Reference Card

Print this for your tech team:

```
╔═══════════════════════════════════════════════════╗
║  IWILL N1241 AI Firewall - Quick Reference       ║
╠═══════════════════════════════════════════════════╣
║                                                   ║
║  Web UI:  https://192.168.1.1                    ║
║  Login:   root / [YOUR-PASSWORD]                       ║
║                                                   ║
║  Port 1 (WAN):     ISP Connection                ║
║  Port 2 (LAN):     192.168.1.0/24  - Trusted     ║
║  Port 3 (AI_LAB):  192.168.20.0/24 - Internet    ║
║  Port 4 (IOT):     192.168.30.0/24 - Restricted  ║
║                                                   ║
║  AI_LAB Rules:                                   ║
║    ✓ Internet access                             ║
║    ✗ Cannot reach LAN                            ║
║                                                   ║
║  IOT Rules:                                      ║
║    ⚠ DNS + HTTPS only                            ║
║    ✗ Cannot reach LAN or AI_LAB                  ║
║                                                   ║
║  Security: Zenarmor (AI-powered DPI)             ║
║    • Malware blocking                            ║
║    • Botnet protection                           ║
║    • Phishing prevention                         ║
║    • Cloud threat intelligence                   ║
║                                                   ║
║  Dashboard: Services → Zenarmor → Dashboard      ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
```

---

## What This Config Includes

✅ **VLANs:**
- AI_LAB (VLAN 20 on Port 3)
- IOT (VLAN 30 on Port 4)

✅ **DHCP Servers:**
- LAN: 192.168.1.10-250
- AI_LAB: 192.168.20.10-250
- IOT: 192.168.30.10-250

✅ **Firewall Rules:**
- AI_LAB → Internet: **Allow**
- AI_LAB → LAN: **Block**
- IOT → DNS/HTTPS: **Allow**
- IOT → Everything else: **Block**
- LAN → Everywhere: **Allow**

✅ **DNS:**
- Unbound resolver enabled
- Upstream: 1.1.1.1, 8.8.8.8
- DNSSEC enabled

✅ **Security:**
- Anti-lockout disabled (all interfaces accessible)
- SSH enabled
- Hardware offloading optimized
- NAT configured

---

## What You Still Need to Do Manually

The config file can't pre-configure these (they're unique to each installation):

⚠️ **WAN Settings**
- ISP-specific (DHCP/Static/PPPoE)
- Configure in: Interfaces → WAN

⚠️ **Zenarmor Account**
- Requires Sunny Valley account
- Free tier: https://www.sunnyvalley.io
- Configure in: Services → Zenarmor → Setup Wizard

⚠️ **Root Password**
- Set during OPNsense installation
- Can change in: System → Access → Users

⚠️ **Optional: Cloud API Filtering**
- If using hybrid AI (local + cloud)
- See: docs/AI-SECURITY-RULES.md

---

## Troubleshooting

### Can't access web UI?

Reset root password via console:
```
Option 4: Reset root password
```

### Config import failed?

1. Make sure you're on OPNsense 24.x or later
2. Try uploading again
3. If still fails, follow full `INSTALLATION-GUIDE.md` instead

### Zenarmor won't start?

**Error:** "Device busy"
- **Cause:** Suricata is also installed
- **Fix:** Uninstall Suricata:
  ```
  System → Firmware → Plugins → os-suricata → Delete
  ```

### No internet after import?

1. Check WAN: Interfaces → WAN
2. Make sure WAN type matches your ISP
3. Verify gateway: System → Gateways → Single
4. Test: Diagnostics → Ping → 8.8.8.8

### VLANs not showing?

1. Reboot: Power → Reboot
2. Check: Interfaces → Other Types → VLAN
3. Should see igc2.20 and igc3.30

---

## Time Comparison

| Method | Time | Complexity |
|--------|------|------------|
| **Manual (INSTALLATION-GUIDE.md)** | ~60 min | Medium |
| **Rapid Deploy (this guide)** | ~20 min | Low |
| **Expert (console + script)** | ~10 min | High |

---

## Advanced: Fully Automated (Experts Only)

If you want to automate even more:

1. **Pre-configure USB:**
   - Copy `n1241-base-config.xml` to USB:/conf/
   - OPNsense can auto-import on first boot

2. **Script everything:**
   ```bash
   # On fresh install
   scp configs/n1241-base-config.xml root@192.168.1.1:/conf/config.xml
   ssh root@192.168.1.1 /etc/rc.reload_all
   ssh root@192.168.1.1 pkg install -y os-zenarmor
   ```

3. **Pre-bake ISO:**
   - Build custom OPNsense ISO with config
   - Requires FreeBSD build environment
   - See: docs/CUSTOM-ISO-BUILD.md (coming soon)

---

## Next Steps After Deployment

1. **Test isolation:**
   - Connect device to Port 3
   - Verify it can't reach Port 2 devices

2. **Monitor traffic:**
   - Services → Zenarmor → Dashboard
   - Check for threats, unusual patterns

3. **Optional hardening:**
   - Enable 2FA: System → Access → Users
   - Change SSH port: System → Settings → Administration
   - Set up VPN: VPN → WireGuard

4. **Backup config:**
   - System → Configuration → Backups
   - Download backup regularly

5. **Keep updated:**
   - System → Firmware → Updates
   - Check weekly for security patches

---

## Support

**Problems during deployment?**
- Check: `docs/TROUBLESHOOTING.md`
- Email: support@iwilltech.co.uk
- Discord: [IWILL Community](https://discord.gg/NZnKRMFS)

**Want professional installation?**
- On-site setup available
- Remote setup available
- Custom configuration available

**Websites:** [iwilltech.co.uk](https://www.iwilltech.co.uk) · [iwillmena.com](https://www.iwillmena.com) · [iwill.pt](https://www.iwill.pt) · [iwill.pl](https://www.iwill.pl) · [iwill.bg](https://www.iwill.bg)

---

## Deployment Checklist

Print this for installation tracking:

```
□ Downloaded OPNsense ISO
□ Created bootable USB
□ Connected cables (WAN, LAN)
□ Installed OPNsense to SSD (~15 min)
□ Set root password
□ Accessed web UI (https://192.168.1.1)
□ Imported n1241-base-config.xml
□ Rebooted firewall
□ Installed Zenarmor plugin
□ Created Sunny Valley account
□ Configured Zenarmor wizard
□ Started Zenarmor engine
□ Enabled "Start on boot"
□ Verified WAN has internet
□ Tested ping 8.8.8.8
□ Checked Zenarmor dashboard
□ Connected AI device to Port 3
□ Tested AI isolation (can't ping LAN)
□ Connected IoT device to Port 4
□ Verified IoT restrictions
□ Backed up final configuration

Installation Date: _______________
Installed By: ____________________
Customer: _______________________
Notes: __________________________
```

---

**🎉 Congratulations!**

Your N1241 AI Firewall is ready to protect your AI infrastructure!

**Total deployment time:** ~20 minutes  
**Configuration imported:** Yes ✅  
**Security enabled:** Yes ✅  
**Network isolated:** Yes ✅

Questions? Read `docs/INSTALLATION-GUIDE.md` for deep dive or `docs/CUSTOMER-GUIDE.md` for end-user documentation.
