#!/bin/sh
# IWILL N1241 AI Firewall - Auto Configuration Script
# Run after OPNsense installation to set up AI-specific security

set -e

cat << "EOF"
========================================
  IWILL N1241 AI Firewall Setup
  OPNsense + Suricata + Zenarmor + CrowdSec
========================================
EOF

echo ""
echo "This script will configure:"
echo "  - 4 VLAN zones (LAN, AI-Lab, IoT, Guest)"
echo "  - Suricata IDS/IPS"
echo "  - AI-specific firewall rules"
echo "  - Egress filtering for cloud APIs"
echo ""
read -p "Continue? [Y/n] " CONFIRM
CONFIRM=${CONFIRM:-Y}

if [ "$CONFIRM" != "Y" ] && [ "$CONFIRM" != "y" ]; then
    echo "Setup cancelled."
    exit 0
fi

# Check if running on OPNsense
if [ ! -f /usr/local/opnsense/version/opnsense ]; then
    echo "ERROR: This script must run on OPNsense"
    exit 1
fi

echo ""
echo "[1/7] Installing required packages..."
pkg install -y curl wget jq

echo ""
echo "[2/7] Configuring VLANs..."

# Create VLANs via OPNsense API would go here
# For now, show manual instructions
cat << VLAN_EOF

VLANs must be configured via Web UI:
1. Interfaces → Other Types → VLAN
2. Create:
   - igc2.20 (AI-Lab)
   - igc3.30 (IoT)
3. Assign to OPT1, OPT2

Press Enter when done...
VLAN_EOF
read

echo ""
echo "[3/7] Installing Suricata..."
pkg install -y suricata

# Configure Suricata
cat > /usr/local/etc/suricata/suricata.yaml.sample << SURICATA_EOF
# Suricata configuration for AI Firewall
vars:
  address-groups:
    HOME_NET: "[192.168.1.0/24,192.168.20.0/24,192.168.30.0/24]"
    EXTERNAL_NET: "!$HOME_NET"

af-packet:
  - interface: igc0  # WAN
    threads: 2
    cluster-id: 98
    cluster-type: cluster_flow
  - interface: igc2  # AI-Lab
    threads: 2
    cluster-id: 97
  - interface: igc3  # IoT
    threads: 1
    cluster-id: 96

detect-engine:
  - profile: high
  - sgh-mpm-context: auto
  - inspection-recursion-limit: 3000

rule-files:
  - suricata.rules
  - emerging-threats.rules
SURICATA_EOF

echo "  Suricata installed. Enable via Web UI: Services → Intrusion Detection"

echo ""
echo "[4/7] Creating AI Cloud API aliases..."

# Cloud AI API domains
cat > /tmp/ai-cloud-apis.txt << APIS_EOF
# OpenAI
api.openai.com

# Anthropic Claude
api.anthropic.com

# Google Gemini
generativelanguage.googleapis.com
ai.google.dev

# Perplexity
api.perplexity.ai

# Mistral
api.mistral.ai
APIS_EOF

echo "  Cloud API list saved to /tmp/ai-cloud-apis.txt"
echo "  Import via: Firewall → Aliases → Import"

echo ""
echo "[5/7] Creating firewall rule templates..."

mkdir -p /root/firewall-rules

# AI Lab rules
cat > /root/firewall-rules/ai-lab-rules.txt << AI_RULES
# AI Lab Firewall Rules
# Apply to: AI_LAB interface

Rule 1: Block access to LAN
  Action: Block
  Source: AI_LAB net
  Destination: LAN net
  Description: Prevent AI from accessing trusted devices

Rule 2: Block access to IoT
  Action: Block
  Source: AI_LAB net
  Destination: IOT net
  Description: Isolate AI from IoT network

Rule 3: Allow Cloud AI APIs only
  Action: Pass
  Source: AI_LAB net
  Destination: AI_Cloud_APIs alias
  Destination Port: 443
  Description: Allow specific cloud AI endpoints

Rule 4: Block all other HTTPS
  Action: Block
  Source: AI_LAB net
  Protocol: TCP
  Destination Port: 443
  Description: Block unauthorized cloud access

Rule 5: Allow DNS
  Action: Pass
  Source: AI_LAB net
  Protocol: UDP
  Destination Port: 53
  Description: Allow DNS resolution

Rule 6: Allow limited internet
  Action: Pass
  Source: AI_LAB net
  Destination: any
  Description: Allow other protocols (updates, etc.)
AI_RULES

# IoT rules
cat > /root/firewall-rules/iot-rules.txt << IOT_RULES
# IoT Network Rules
# Apply to: IOT interface

Rule 1: Block all RFC1918 (private networks)
  Action: Block
  Source: IOT net
  Destination: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
  Description: Total isolation from internal networks

Rule 2: Allow DNS only to firewall
  Action: Pass
  Source: IOT net
  Destination: IOT address
  Destination Port: 53
  Description: DNS via firewall only

Rule 3: Allow HTTPS for updates
  Action: Pass
  Source: IOT net
  Protocol: TCP
  Destination Port: 443
  Description: Allow device updates

Rule 4: Block everything else
  Action: Block
  Source: IOT net
  Destination: any
  Description: Default deny
IOT_RULES

echo "  Rule templates saved to /root/firewall-rules/"

echo ""
echo "[6/7] Setting up monitoring..."

# Create monitoring script
cat > /usr/local/bin/ai-firewall-monitor.sh << 'MONITOR_EOF'
#!/bin/sh
# AI Firewall Monitoring - Check for anomalies

LOG_FILE="/var/log/ai-firewall-monitor.log"

# Check for high outbound traffic from AI_LAB
AI_TRAFFIC=$(pfctl -s state | grep "192.168.20" | grep "443:443" | wc -l)
if [ "$AI_TRAFFIC" -gt 100 ]; then
    echo "$(date): WARNING - High HTTPS traffic from AI_LAB: $AI_TRAFFIC connections" >> $LOG_FILE
    # Send alert (configure notification method)
fi

# Check for blocked connections
BLOCKED=$(grep "block" /var/log/filter.log | grep "AI_LAB" | tail -1)
if [ -n "$BLOCKED" ]; then
    echo "$(date): ALERT - AI_LAB blocked connection: $BLOCKED" >> $LOG_FILE
fi

# Check Suricata alerts
SURICATA_ALERTS=$(grep -c "Priority: 1" /var/log/suricata/fast.log 2>/dev/null || echo 0)
if [ "$SURICATA_ALERTS" -gt 0 ]; then
    echo "$(date): CRITICAL - $SURICATA_ALERTS high-priority Suricata alerts" >> $LOG_FILE
fi
MONITOR_EOF

chmod +x /usr/local/bin/ai-firewall-monitor.sh

# Add to cron (every 5 minutes)
echo "*/5 * * * * root /usr/local/bin/ai-firewall-monitor.sh" >> /etc/crontab

echo "  Monitor script installed: /usr/local/bin/ai-firewall-monitor.sh"
echo "  Logs: /var/log/ai-firewall-monitor.log"

echo ""
echo "[7/7] Creating backup configuration..."

# Export current config
/usr/local/etc/rc.backup_config.sh

echo "  Config backed up to /conf/backup/"

cat << COMPLETE_EOF

========================================
  Setup Complete!
========================================

Next steps:

1. Web UI Configuration:
   - Go to https://192.168.1.1
   - Import AI Cloud APIs alias from /tmp/ai-cloud-apis.txt
   - Apply firewall rules from /root/firewall-rules/

2. Install Plugins:
   System → Firmware → Plugins
   - os-suricata (if not already)
   - os-zenarmor (AI-powered DPI)
   - os-crowdsec (threat intelligence)

3. Enable Suricata:
   Services → Intrusion Detection
   - Enable IPS mode
   - Select interfaces: WAN, AI_LAB, IOT
   - Download ET Open rules

4. Configure Zenarmor:
   Services → Zenarmor
   - Run setup wizard
   - Enable: Malware, Botnet, Phishing

5. Test Isolation:
   From AI device (192.168.20.x):
     ping 8.8.8.8          # Should work
     ping 192.168.1.1      # Should fail
     curl https://api.openai.com  # Should work
     curl https://badapi.com      # Should block

6. Monitor:
   tail -f /var/log/ai-firewall-monitor.log

Documentation:
  - Installation: /root/docs/INSTALLATION-GUIDE.md
  - Security rules: /root/firewall-rules/
  - Monitoring: /var/log/ai-firewall-monitor.log

Support: support@iwilltech.co.uk

========================================
EOF
