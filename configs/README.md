# Configuration Files

Pre-built configuration files for rapid deployment.

---

## n1241-base-config.xml

**Base configuration for N1241 AI Firewall**

### What's Included

✅ **VLANs:**
- AI_LAB (VLAN 20 on igc2/Port 3) → 192.168.20.0/24
- IOT (VLAN 30 on igc3/Port 4) → 192.168.30.0/24

✅ **Interface Assignments:**
- Port 1 (igc0): WAN → DHCP by default
- Port 2 (igc1): LAN → 192.168.1.1/24
- Port 3 (igc2.20): AI_LAB → 192.168.20.1/24
- Port 4 (igc3.30): IOT → 192.168.30.1/24

✅ **DHCP Servers:**
- LAN: 192.168.1.10-250
- AI_LAB: 192.168.20.10-250
- IOT: 192.168.30.10-250

✅ **Firewall Rules:**
- AI_LAB: Internet allowed, LAN blocked
- IOT: DNS/HTTPS only, all internal networks blocked
- LAN: Full access to everything

✅ **System Settings:**
- Hostname: ai-firewall.local
- DNS: 1.1.1.1, 8.8.8.8
- Timezone: Europe/Sofia (change after import if needed)
- SSH: Enabled
- Unbound DNS resolver: Enabled with DNSSEC

✅ **Security:**
- Block private networks on WAN
- Block bogons on WAN
- Hardware offloading optimized
- NAT: Automatic outbound

### What's NOT Included

The following must be configured manually (they're unique to each installation):

❌ **Zenarmor plugin**
- Must be installed separately
- Requires Sunny Valley account

❌ **Root password**
- Set during OPNsense installation

❌ **WAN-specific settings**
- ISP type varies (DHCP/Static/PPPoE)
- Default is DHCP - change if needed

❌ **SSL certificates**
- Default self-signed cert included
- Replace with Let's Encrypt if desired

---

## How to Use

### Method 1: Web UI Import (Easiest)

1. Install OPNsense fresh
2. Access web UI: https://192.168.1.1
3. Login: root / (password you set)
4. Go to: **System → Configuration → Backups**
5. Scroll to **"Restore Backup"** section
6. Upload: `n1241-base-config.xml`
7. Click **"Restore Configuration"**
8. Reboot when prompted

### Method 2: SCP + SSH (Faster)

```bash
# Copy config to firewall
scp n1241-base-config.xml root@192.168.1.1:/conf/config.xml

# Reload configuration
ssh root@192.168.1.1 /etc/rc.reload_all

# Or just reboot
ssh root@192.168.1.1 reboot
```

### Method 3: Console (Emergency)

```bash
# Copy file to USB drive as 'config.xml'
# Insert USB in N1241
# Boot to console
# Select option 7: Import configuration
# Choose USB device
# Reboot
```

---

## Post-Import Checklist

After importing the config:

1. ✅ **Verify interfaces:**
   - Go to: Interfaces → Overview
   - Check all 4 interfaces are up

2. ✅ **Configure WAN:**
   - Go to: Interfaces → WAN
   - Set correct type for your ISP

3. ✅ **Test internet:**
   - Go to: Diagnostics → Ping
   - Ping: 8.8.8.8
   - Should work

4. ✅ **Install Zenarmor:**
   - Go to: System → Firmware → Plugins
   - Install: os-zenarmor
   - Configure wizard

5. ✅ **Backup final config:**
   - Go to: System → Configuration → Backups
   - Download working config

---

## Customization

To change default settings:

### Change Subnets

Edit the XML before importing:

```xml
<!-- LAN -->
<ipaddr>192.168.1.1</ipaddr>
<subnet>24</subnet>

<!-- AI_LAB -->
<ipaddr>192.168.20.1</ipaddr>
<subnet>24</subnet>

<!-- IOT -->
<ipaddr>192.168.30.1</ipaddr>
<subnet>24</subnet>
```

### Change Hostname

```xml
<hostname>ai-firewall</hostname>
<domain>local</domain>
```

### Change DNS Servers

```xml
<dnsserver>1.1.1.1</dnsserver>
<dnsserver>8.8.8.8</dnsserver>
```

### Change Timezone

```xml
<timezone>Europe/Sofia</timezone>
```

Find your timezone: https://www.php.net/manual/en/timezones.php

---

## Troubleshooting

### Config import failed

**Error:** "The configuration could not be restored"

**Causes:**
- OPNsense version mismatch
- Corrupted XML file
- Missing required plugins

**Fix:**
1. Verify XML is valid (open in text editor)
2. Try fresh OPNsense install
3. Use manual configuration instead

### Interfaces not coming up after import

1. **Reboot:**
   - System → Power → Reboot
   
2. **Check interface names:**
   - Console → Option 1 (Assign interfaces)
   - Verify igc0, igc1, igc2, igc3 exist

3. **Check VLANs:**
   - Interfaces → Other Types → VLAN
   - Should see igc2.20 and igc3.30

### WAN not working

**Problem:** No internet after import

**Fix:**
1. Go to: Interfaces → WAN
2. Verify IP address assigned
3. If not, check WAN type:
   - DHCP: Most common
   - Static: If ISP gave you IP
   - PPPoE: If username/password needed
4. Save and reboot

### Can't access web UI after import

**Problem:** https://192.168.1.1 doesn't respond

**Fix:**
1. Verify laptop is on Port 2
2. Check laptop IP: should be 192.168.1.x
3. Try console: Option 2 → Set LAN IP
4. Reset if needed: Option 4 → Reset root password

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-11 | Initial release |
|     |            | - 4 interfaces configured |
|     |            | - VLANs for AI_LAB and IOT |
|     |            | - Firewall rules for isolation |
|     |            | - DHCP servers on all networks |

---

## Security Notice

⚠️ **This configuration is a template!**

After importing:
1. **Change root password**
2. **Review firewall rules** for your environment
3. **Update WAN settings** for your ISP
4. **Enable 2FA** if needed
5. **Keep OPNsense updated**

This config provides a secure baseline but should be reviewed and customized for production use.

---

## License

This configuration file is provided as-is for IWILL N1241 customers and partners.

- Free to use and modify
- No warranty provided
- Test before production use

---

## Support

Questions about this config?
- Email: support@iwilltech.co.uk
- Docs: ../docs/INSTALLATION-GUIDE.md
- Quick start: ../RAPID-DEPLOY.md
