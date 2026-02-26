# Deploy ES Boot Repair Script
## One-time setup on any N1241 unit

### Step 1 — Copy script to firewall
```bash
scp es-boot-repair.sh root@192.168.1.1:/usr/local/etc/rc.d/es_repair
```

### Step 2 — Set permissions and enable
```bash
ssh root@192.168.1.1
chmod +x /usr/local/etc/rc.d/es_repair
sysrc es_repair_enable="YES"
sysrc elasticsearch_enable="YES"
```

### Step 3 — Test it (simulate boot)
```bash
service es_repair start
cat /var/log/es-repair.log
```

### Step 4 — Reboot and verify
```bash
reboot
# After reboot:
cat /var/log/es-repair.log
service elasticsearch status
```

---

## What it does (every boot, before Elasticsearch starts)

1. **Creates the datastore directory** if missing (power cut during write = gone)
2. **Removes stale node.lock** (dirty shutdown leaves this behind, blocks ES start)
3. **Runs background fsck** to fix soft-update inconsistencies on root filesystem
4. **Clears ES data** if critical inconsistency detected (ES rebuilds from scratch)
5. **Logs everything** to `/var/log/es-repair.log`

## Result
After any power cut — unit boots, repairs itself, Elasticsearch and Zenarmor start normally.
**Zero manual intervention required.**
