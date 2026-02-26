#!/bin/sh
#
# IWILL N1241 AI Firewall - Quick Setup Script
# Run this after importing the base configuration
#
# Usage: curl -sSL https://example.com/quick-setup.sh | sh
#        OR: scp quick-setup.sh root@192.168.1.1:/tmp/ && ssh root@192.168.1.1 /tmp/quick-setup.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
clear
echo "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo "${BLUE}║  IWILL N1241 AI Firewall - Quick Setup        ║${NC}"
echo "${BLUE}║  Automated Configuration Assistant            ║${NC}"
echo "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running on OPNsense
if [ ! -f /usr/local/etc/config.xml ]; then
    echo "${RED}ERROR: This doesn't appear to be OPNsense!${NC}"
    echo "This script must run on the firewall console."
    exit 1
fi

echo "${GREEN}✓${NC} Running on OPNsense"
echo ""

# Step 1: Check base config imported
echo "${YELLOW}[1/5]${NC} Checking configuration..."
if ! grep -q "AI_LAB" /usr/local/etc/config.xml 2>/dev/null; then
    echo "${RED}✗ Base configuration not found!${NC}"
    echo ""
    echo "Please import the base config first:"
    echo "  1. Log into web UI: https://192.168.1.1"
    echo "  2. Go to: System → Configuration → Backups"
    echo "  3. Upload: n1241-base-config.xml"
    echo "  4. Click 'Restore Configuration'"
    echo "  5. Reboot and run this script again"
    echo ""
    exit 1
fi
echo "${GREEN}✓${NC} Base configuration detected"
echo ""

# Step 2: Install Zenarmor
echo "${YELLOW}[2/5]${NC} Installing Zenarmor plugin..."
if pkg info | grep -q "os-zenarmor"; then
    echo "${GREEN}✓${NC} Zenarmor already installed"
else
    echo "Installing os-zenarmor package..."
    pkg install -y os-zenarmor
    echo "${GREEN}✓${NC} Zenarmor installed"
fi
echo ""

# Step 3: WAN Configuration
echo "${YELLOW}[3/5]${NC} WAN Configuration"
echo ""
echo "How does your ISP provide internet?"
echo "  1) DHCP (automatic IP)"
echo "  2) Static IP"
echo "  3) PPPoE (username/password)"
echo "  4) Skip (already configured)"
echo ""
printf "Select [1-4]: "
read WAN_TYPE

case $WAN_TYPE in
    1)
        echo "${BLUE}→${NC} Setting WAN to DHCP..."
        # Config already has DHCP, just confirm
        echo "${GREEN}✓${NC} WAN set to DHCP (default)"
        ;;
    2)
        echo ""
        printf "Static IP address (e.g., 203.0.113.10): "
        read WAN_IP
        printf "Subnet mask (e.g., 255.255.255.0): "
        read WAN_MASK
        printf "Gateway (e.g., 203.0.113.1): "
        read WAN_GW
        
        echo "${BLUE}→${NC} Configuring static WAN..."
        # Note: This is simplified - real config would use pluginctl or config.xml manipulation
        echo "${YELLOW}!${NC} Manual step required:"
        echo "   Go to: Interfaces → WAN"
        echo "   Set: IPv4 Configuration Type = Static"
        echo "   IP: ${WAN_IP}"
        echo "   Mask: ${WAN_MASK}"
        echo "   Gateway: ${WAN_GW}"
        ;;
    3)
        echo ""
        printf "PPPoE username: "
        read PPPOE_USER
        printf "PPPoE password: "
        read -s PPPOE_PASS
        echo ""
        
        echo "${YELLOW}!${NC} Manual step required:"
        echo "   Go to: Interfaces → WAN"
        echo "   Set: IPv4 Configuration Type = PPPoE"
        echo "   Username: ${PPPOE_USER}"
        echo "   Password: (enter manually)"
        ;;
    4)
        echo "${GREEN}✓${NC} Skipping WAN config"
        ;;
    *)
        echo "${RED}Invalid choice${NC}"
        ;;
esac
echo ""

# Step 4: Zenarmor Setup
echo "${YELLOW}[4/5]${NC} Zenarmor Configuration"
echo ""
echo "To complete Zenarmor setup:"
echo "  1. Open web UI: ${BLUE}https://192.168.1.1${NC}"
echo "  2. Go to: ${BLUE}Services → Zenarmor${NC}"
echo "  3. Click ${BLUE}'Setup Wizard'${NC}"
echo "  4. Select interfaces: ${BLUE}WAN, AI_LAB, IOT${NC}"
echo "  5. Deployment mode: ${BLUE}Routed${NC}"
echo "  6. Create account at: ${BLUE}https://www.sunnyvalley.io${NC}"
echo "  7. Activate license (free Home tier)"
echo "  8. Enable: ${BLUE}Malware, Botnet, Phishing, Web App Control${NC}"
echo "  9. On Dashboard: Start Engine (three dots menu)"
echo "  10. Enable: ${BLUE}Start on boot${NC}"
echo ""
printf "Press Enter when Zenarmor is configured..."
read

# Step 5: Final checks
echo ""
echo "${YELLOW}[5/5]${NC} Running final checks..."
echo ""

# Check interfaces
echo "Checking network interfaces..."
if ifconfig igc0 | grep -q "inet "; then
    echo "${GREEN}✓${NC} WAN interface has IP"
else
    echo "${YELLOW}!${NC} WAN might need configuration"
fi

if ifconfig igc1 | grep -q "192.168.1.1"; then
    echo "${GREEN}✓${NC} LAN interface configured"
fi

if ifconfig igc2.20 2>/dev/null | grep -q "192.168.20.1"; then
    echo "${GREEN}✓${NC} AI_LAB VLAN configured"
fi

if ifconfig igc3.30 2>/dev/null | grep -q "192.168.30.1"; then
    echo "${GREEN}✓${NC} IOT VLAN configured"
fi

echo ""
echo "${GREEN}═══════════════════════════════════════════════${NC}"
echo "${GREEN}   Installation Complete! 🎉${NC}"
echo "${GREEN}═══════════════════════════════════════════════${NC}"
echo ""
echo "Network Configuration:"
echo "  ${BLUE}Web UI:${NC}      https://192.168.1.1"
echo "  ${BLUE}Username:${NC}    root"
echo "  ${BLUE}Password:${NC}    (what you set)"
echo ""
echo "  ${BLUE}LAN:${NC}         192.168.1.0/24   (Port 2)"
echo "  ${BLUE}AI_LAB:${NC}      192.168.20.0/24  (Port 3)"
echo "  ${BLUE}IOT:${NC}         192.168.30.0/24  (Port 4)"
echo ""
echo "Next Steps:"
echo "  1. Connect AI devices to Port 3"
echo "  2. Connect IoT devices to Port 4"
echo "  3. Test isolation (ping tests)"
echo "  4. Monitor Zenarmor Dashboard"
echo ""
echo "Documentation:"
echo "  ${BLUE}~/iwill-n1241-ai-firewall/docs/${NC}"
echo ""
echo "${YELLOW}Tip:${NC} Check Zenarmor Dashboard for real-time traffic!"
echo ""
