# N1241 AI Firewall — Pre-Ship Checklist
## Complete procedure before shipping to customer

**Goal:** Every N1241 leaves the warehouse fully configured, tested, and self-healing.

---

## Phase 1: OPNsense Install (~15 min)

### Option A: UFS (existing units)
1. Boot from OPNsense USB (F7 for boot menu)
2. Login: `installer` / `opnsense`
3. Install → UFS → Entire disk → Confirm
4. Set root password: `[YOUR-PASSWORD]`
5. Reboot, remove USB

### Option B: ZFS (recommended for new units)
1. Boot from OPNsense USB
2. Login: `installer` / `opnsense`
3. Install → **ZFS** → stripe → select disk (ada0)
4. Set root password: `[YOUR-PASSWORD]`
5. Reboot, remove USB

> ⚠️ **ZFS eliminates filesystem corruption from power cuts entirely.** Use for all new units.
> See `ZFS-INSTALL-GUIDE.md` for details.

---

## Phase 2: Base Configuration (~5 min)

1. Connect laptop to **Port 2**, open `https://192.168.1.1`
2. Login: `root` / `[YOUR-PASSWORD]`
3. Run first-time wizard:
   - Hostname: `ai-firewall`
   - DNS: `1.1.1.1`, `8.8.8.8`
4. **OR** import pre-built config:
   - System → Configuration → Backups → Restore
   - Upload `configs/n1241-base-config.xml`
   - Reboot

### Interface assignments:
| Port | Interface | Network | Purpose |
|------|-----------|---------|---------|
| 1 | igc0 (WAN) | DHCP | ISP connection |
| 2 | igc1 (LAN) | 192.168.1.0/24 | Trusted devices |
| 3 | igc2 (AI_LAB) | 192.168.20.0/24 | AI devices |
| 4 | igc3 (IOT) | 192.168.30.0/24 | IoT devices |

---

## Phase 3: Install Zenarmor (~5 min)

1. System → Firmware → Plugins → Search `zenarmor` → Install `os-zenarmor`
2. Wait ~3 min for install
3. Services → Zenarmor → Setup Wizard:
   - **Deployment mode:** Routed Mode (L3) with emulated netmap driver
   - **Interfaces:** igc1 (LAN) + igc2 (AI_LAB) — set security zones
   - **Database:** Elasticsearch (localhost)
4. Finish wizard
5. Verify engine status: **Running** ✅
6. Toggle **"Start on boot"** → ON

> ⚠️ Do NOT install Suricata — it conflicts with Zenarmor!

---

## Phase 4: Enable Elasticsearch on boot

```bash
ssh root@192.168.1.1
sysrc elasticsearch_enable=YES
```

---

## Phase 5: Deploy Self-Healing Boot Script (~2 min)

**This is critical — prevents customer calls after power cuts.**

### From your workstation:
```bash
scp es-boot-repair.sh root@192.168.1.1:/usr/local/etc/rc.d/es_repair
```

### On the firewall:
```bash
ssh root@192.168.1.1
chmod +x /usr/local/etc/rc.d/es_repair
sysrc es_repair_enable=YES
```

### Create first settings.db backup:
```bash
cp /usr/local/zenarmor/userdefined/config/settings.db /usr/local/zenarmor/userdefined/config/settings.db.good
```

### What the script does on every boot:
1. ✅ Runs `fsck` to fix filesystem corruption (UFS only)
2. ✅ Ensures Elasticsearch datastore directory exists
3. ✅ Removes stale ES lock files
4. ✅ Checks Zenarmor `settings.db` — restores from backup if corrupt
5. ✅ Regenerates `workers.map` if missing

**Result:** After any power cut, unit boots and self-heals. Zero manual intervention.

---

## Phase 6: Test (~5 min)

### Power cut simulation:
1. Pull the power cable while unit is running
2. Plug it back in
3. Wait 3 minutes for boot
4. Verify:
   - `service elasticsearch status` → running
   - `zenarmorctl engine status` → running
   - `cat /var/log/es-repair.log` → shows repair ran
5. Check Zenarmor dashboard in browser → working

### Network test:
```bash
# From LAN device
ping 8.8.8.8           # ✅ Should work
ping 192.168.1.1       # ✅ Should work (firewall UI)

# From AI_LAB device (Port 3)
ping 8.8.8.8           # ✅ Internet works
ping 192.168.1.1       # ❌ Blocked (isolated from LAN)
```

### Zenarmor test:
- Open http://testmyids.com from a LAN device
- Check Zenarmor dashboard → should show alert/block

---

## Phase 7: Final Backup (~1 min)

```bash
ssh root@192.168.1.1
# Backup OPNsense config
cp /conf/config.xml /conf/config.xml.factory

# Backup Zenarmor settings (should already exist from Phase 5)
ls -la /usr/local/zenarmor/userdefined/config/settings.db.good
```

Also download config from UI:
- System → Configuration → Backups → Download

---

## Pre-Ship Verification Checklist

```
□ OPNsense installed (ZFS preferred, UFS acceptable)
□ Root password set
□ WAN/LAN/AI_LAB/IOT interfaces configured
□ DHCP enabled on LAN, AI_LAB, IOT
□ Zenarmor installed and running
□ Zenarmor engine starts on boot
□ Elasticsearch enabled on boot
□ es_repair boot script deployed and enabled
□ settings.db.good backup created
□ Power cut test PASSED (pull power, verify self-heal)
□ Internet connectivity test PASSED
□ VLAN isolation test PASSED
□ Zenarmor threat detection test PASSED
□ Config backup downloaded
□ Customer documentation included
```

---

## What Ships with the Unit

1. **N1241 hardware** (fully configured)
2. **Quick Reference Card** (printed) — login info, port map
3. **Customer Guide** — basic usage, how to access dashboard
4. **Power cable + Ethernet cables**

---

## Known Issues & Workarounds

| Issue | Cause | Solution |
|-------|-------|----------|
| ES won't start after power cut | Stale lock file / missing dir | Boot script handles automatically |
| Zenarmor "Page couldn't load" | Corrupted settings.db | Boot script restores from backup |
| workers.map missing | Power cut during write | Boot script regenerates from DB |
| 100Mbps instead of Gigabit | Bad ethernet cable | Use Cat5e/Cat6, not Cat5 |
| WiFi AP not working (built-in) | Intel iwm driver limitation | Use external AP (Mercusys, TP-Link) |

---

## Estimated Total Time: ~35 minutes per unit
