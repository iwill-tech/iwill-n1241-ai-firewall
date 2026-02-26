# N1241 — OPNsense ZFS Installation Guide
## Why ZFS? The Power-Cut Problem Solved.

UFS (default OPNsense filesystem) can corrupt on dirty shutdowns.
**ZFS is copy-on-write** — power cut mid-write? It rolls back to last clean state.
No corruption. No fsck. No manual recovery. Ever.

---

## Fresh Install with ZFS (New Units)

### Step 1 — Download OPNsense
- Get the latest OPNsense DVD image: https://opnsense.org/download/
- Architecture: amd64, Image type: **dvd** (ISO)
- Write to USB: `dd if=OPNsense-*.iso of=/dev/sdX bs=4M` (Linux/Mac)
- Or use Rufus on Windows

### Step 2 — Boot from USB
- Connect display + keyboard to N1241
- Boot from USB (F7 or DEL for boot menu on most N1241 units)

### Step 3 — Install with ZFS
At the installer:
1. Select **Install (UFS or ZFS)**
2. Choose **ZFS** when prompted for filesystem
3. Select **stripe** (single disk — N1241 has one SSD)
4. Choose the correct disk (`ada0` typically)
5. Confirm and let it install

### Step 4 — Post-install configuration
After first boot, configure same as UFS install:
- WAN/LAN interface assignment
- IP addresses
- Zenarmor installation
- Elasticsearch setup

---

## Verify ZFS After Install
```bash
ssh root@192.168.1.1
zpool status        # Should show: state: ONLINE
zfs list            # Shows datasets
```

---

## Key Differences vs UFS

| | UFS (old) | ZFS (new) |
|---|---|---|
| Power cut corruption | ❌ Yes — needs fsck | ✅ No — auto rollback |
| Recovery after bad shutdown | Manual fsck | Automatic on boot |
| RAM usage | ~50MB | ~200-300MB extra |
| Performance | Good | Equal or better |
| Snapshots | No | Yes (bonus!) |
| Customer calls after power cut | Inevitable | Zero |

---

## For Existing Units — Upgrade Path

**Option A: Reinstall (recommended for clean slate)**
- Back up OPNsense config: System → Configuration → Backups → Download
- Fresh ZFS install (15 min)
- Restore config from backup
- Redeploy Zenarmor

**Option B: Keep UFS + deploy es_repair script**
- See `DEPLOY-ES-REPAIR.md`
- Handles most power-cut scenarios automatically
- Use for units already deployed at customer sites

---

## Recommendation

| Scenario | Action |
|---|---|
| New N1241 units (not shipped yet) | ZFS install — make it the standard |
| Units at customer sites | Deploy es_repair script remotely |
| Your home unit | es_repair now, ZFS on next reinstall |
