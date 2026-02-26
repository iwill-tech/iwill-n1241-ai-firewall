# N1241 AI Firewall - Quick Start

## After OPNsense Installation

### ✅ Phase 1: Basic Setup (15 min)

1. **Access Web UI:**
   - Connect laptop to Port 2
   - Open: https://192.168.1.1
   - Login: root / [YOUR-PASSWORD]

2. **Run First-Time Wizard:**
   - Hostname: `ai-firewall`
   - DNS: `1.1.1.1`, `8.8.8.8`
   - Keep defaults, finish wizard

3. **Update System:**
   - System → Firmware → Updates
   - Click "Update" if available

---

### ✅ Phase 2: VLAN Setup (10 min)

**Create VLANs:**
1. Interfaces → Other Types → VLAN → **+**
   - Parent: `igc2`, Tag: `20`, Desc: `AI-Lab` → Save
   - Parent: `igc3`, Tag: `30`, Desc: `IoT` → Save

**Assign Interfaces:**
2. Interfaces → Assignments
   - Click **+** next to `igc2.20` and `igc3.30`
   - Save

**Configure IPs:**
3. Interfaces → [OPT1]
   - Enable: ✓
   - Description: `AI_LAB`
   - IPv4: Static → `192.168.20.1/24`
   - Save → Apply

4. Interfaces → [OPT2]
   - Enable: ✓
   - Description: `IOT`
   - IPv4: Static → `192.168.30.1/24`
   - Save → Apply

**Enable DHCP:**
5. Services → DHCPv4 → [AI_LAB]
   - Enable: ✓
   - Range: `192.168.20.10` - `192.168.20.250`
   - Save

6. Services → DHCPv4 → [IOT]
   - Enable: ✓
   - Range: `192.168.30.10` - `192.168.30.250`
   - Save

---

### ✅ Phase 3: Install Zenarmor (15 min)

**Install Plugin:**
1. System → Firmware → Plugins
   - Search: `zenarmor`
   - Install: `os-zenarmor`
   - Wait ~3 min

**Configure Zenarmor:**
2. Services → Zenarmor
   - Run Setup Wizard
   - Select interfaces: `WAN`, `AI_LAB`, `IOT`
   - Deployment mode: `Routed`
   - Create account at sunny.valley (free Home tier)
   - Enable: Malware, Botnet, Phishing, Web App Control
   - Finish wizard

**Start Engine:**
3. On Dashboard, find "Engine" section (bottom left)
   - Click three dots (...) → Start
   - Toggle "Start on boot" to ON
   - Wait 30 sec, refresh
   - Status should show "Running" ✅

> **Important:** Do NOT install Suricata - it conflicts with Zenarmor!

---

### ✅ Phase 4: Firewall Rules (15 min)

**AI_LAB Rules:**
1. Firewall → Rules → AI_LAB → **+**

**Rule 1: Block LAN access**
   - Action: Block
   - Source: AI_LAB net
   - Destination: LAN net
   - Description: `Block AI from LAN`
   - Save

**Rule 2: Allow internet**
   - Action: Pass
   - Source: AI_LAB net
   - Destination: any
   - Description: `Allow AI internet`
   - Save

**Apply Changes**

**IOT Rules:**
2. Firewall → Rules → IOT → **+**

**Rule 1: Block private nets**
   - Action: Block
   - Source: IOT net
   - Destination: LAN net, AI_LAB net
   - Description: `Isolate IoT`
   - Save

**Rule 2: Allow DNS+HTTPS**
   - Action: Pass
   - Protocol: TCP/UDP
   - Destination Port: 53, 443
   - Description: `IoT updates only`
   - Save

**Apply Changes**

---

### ✅ Phase 5: Test Everything (5 min)

**Test 1: Internet works**
```bash
# From LAN device (Windows)
ping 8.8.8.8  # Should get replies
```

**Test 2: Zenarmor running**
- Go to Services → Zenarmor → Dashboard
- Engine Status: **Running** (green) ✅
- Cloud Threat Intelligence: **UP** ✅
- Should see traffic graphs with activity

**Test 3: VLAN isolation (when devices connected)**
```bash
# From AI device (Port 3)
ping 8.8.8.8        # Should work ✅
ping 192.168.1.1    # Should FAIL ❌ (blocked)
```

---

## Quick Reference

| Zone | Port | Subnet | Access |
|------|------|--------|--------|
| **LAN** | 2 | 192.168.1.0/24 | Full access |
| **AI_LAB** | 3 | 192.168.20.0/24 | Internet only |
| **IOT** | 4 | 192.168.30.0/24 | Restricted |
| **WAN** | 1 | DHCP | Internet |

### Port Connections

```
Port 1 → ISP Router/Modem (WAN)
Port 2 → Switch → Laptop, NAS, Printer (LAN)
Port 3 → AI Host (Ollama, OpenClaw)
Port 4 → IoT devices (cameras, sensors)
```

### Login Info

- **Web UI:** https://192.168.1.1
- **Username:** root
- **Password:** [YOUR-PASSWORD]

---

## Optional: Advanced Features

### Cloud API Filtering (Hybrid AI)

1. **Create alias:**
   - Firewall → Aliases → **+**
   - Name: `AI_Cloud_APIs`
   - Type: Host(s)
   - Content:
     ```
     api.openai.com
     api.anthropic.com
     generativelanguage.googleapis.com
     ```
   - Save

2. **Add rule to AI_LAB:**
   - Action: Pass
   - Destination: AI_Cloud_APIs
   - Destination Port: 443
   - Move ABOVE "Allow internet" rule
   - Save

3. **Block other HTTPS:**
   - Action: Block
   - Protocol: TCP
   - Destination Port: 443
   - Move BETWEEN cloud API and "allow internet"
   - Save

Now AI can only reach approved cloud APIs!

---

## Troubleshooting

**Can't access web UI?**
- Console: Option 4 (Reset root password)

**VLAN not working?**
- Check: Interfaces → Assignments
- Make sure VLANs are enabled

**Suricata not starting?**
- System → Log Files → General
- Check for errors

**Need help?**
- Docs: `/docs/INSTALLATION-GUIDE.md`
- Email: support@iwilltech.co.uk
- Discord: [IWILL Community](https://discord.gg/NZnKRMFS)

---

## Next Steps

✅ Installation complete? → Test with real AI device  
✅ Rules working? → Install CrowdSec for threat intel  
✅ All good? → Document your setup for customers

**Total time:** ~60 minutes from USB to fully protected AI infrastructure!
