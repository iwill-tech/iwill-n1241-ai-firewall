# IWILL N1241 AI Firewall

**Professional AI infrastructure protection — no subscriptions, no vendor lock-in.**

Complete deployment package for IWILL N1241 configured as an AI Firewall with OPNsense and Zenarmor AI-powered deep packet inspection and threat intelligence.

---

## 🎯 What This Is

Protection for **Self-Hosted and Hybrid AI** setups:
- **Local AI:** Ollama, OpenClaw, LM Studio, Stable Diffusion
- **Cloud AI:** OpenAI, Anthropic Claude, Google Gemini
- **Smart Home:** Home Assistant with AI integration
- **Development:** AI agents with filesystem/shell access

**The Problem:**
- 74% of AI users run hybrid setups (local + cloud APIs)
- Most run behind basic ISP routers with no firewall
- Ollama listens on port 11434 with no authentication
- AI agents execute commands and access files
- API keys stored in .env files
- No egress filtering = data can leak anywhere

**The Solution:**
IWILL N1241 + OPNsense = Enterprise-grade AI protection, open-source, no subscriptions.

---

## 📦 Package Contents

```
iwill-n1241-ai-firewall/
├── RAPID-DEPLOY.md             ← 🔥 20-minute quick install guide
├── QUICK-START.md              ← Setup checklist
├── README.md                   ← This file
├── docs/
│   ├── INSTALLATION-GUIDE.md   ← Full manual setup (60 min)
│   ├── AI-SECURITY-RULES.md    ← Firewall rules explained
│   ├── CUSTOMER-GUIDE.md       ← End-user documentation
│   └── TROUBLESHOOTING.md      ← Common issues
├── scripts/
│   ├── quick-setup.sh          ← Automated post-install helper
│   ├── create-vlan.sh          ← VLAN helper
│   └── monitor-ai-traffic.sh   ← Anomaly detection
├── configs/
│   ├── n1241-base-config.xml   ← 🔥 Pre-built complete config
│   ├── README.md               ← Config file documentation
│   └── aliases-cloud-apis.txt  ← Cloud API whitelist
└── templates/
    ├── home-ai-lab.xml         ← Config for home users
    ├── hybrid-ai.xml           ← Local + cloud setup
    └── enterprise-ai.xml       ← Multi-host AI infrastructure
```

---

## 🛡️ Security Stack

### Hardware: IWILL N1241
- **4× Intel i226-V 2.5G LAN** (WAN + 3 isolated zones)
- **Intel N100** (4 cores, 3.4GHz, AES-NI)
- **8-16GB DDR4** RAM
- **256GB SSD**
- **Fanless**, <15W, 24/7 operation

### Software
1. **OPNsense** - Open-source firewall OS (BSD-based)
2. **Zenarmor** - AI-powered Deep Packet Inspection + Cloud Threat Intelligence
   - Malware blocking
   - Botnet protection
   - Phishing prevention
   - Application control

### Network Topology

```
Internet (ISP)
    │
[Port 1: WAN]
    │
  N1241 AI Firewall
    │
    ├── [Port 2: LAN] ────────── Trusted Devices
    │                            (192.168.1.0/24)
    │
    ├── [Port 3: AI-LAB] ──────── AI Infrastructure
    │                            (192.168.20.0/24)
    │                            • Ollama
    │                            • OpenClaw
    │                            • LM Studio
    │                            • Cloud API access (filtered)
    │
    └── [Port 4: IOT] ─────────── Smart Devices
                                 (192.168.30.0/24)
                                 • Cameras
                                 • Sensors
                                 • Internet only
```

---

## 🔒 What It Protects Against

### 7 AI-Specific Threats

| Threat | Without Firewall | With N1241 AI Firewall |
|--------|------------------|------------------------|
| **Open LLM ports** | Ollama:11434 exposed | Port isolated in VLAN |
| **Prompt injection** | AI executes malicious code | Traffic inspection detects |
| **Data exfiltration** | Files leaked to unknown servers | Egress filtering blocks |
| **Poisoned plugins** | Crypto wallets stolen | DPI + threat intel blocks |
| **Lateral movement** | AI compromises whole network | VLAN isolation prevents |
| **API key theft** | Keys used for massive bills | Rate limiting + alerts |
| **Shadow AI** | Unknown cloud endpoints | DNS filtering catches |

---

## 🚀 Quick Start

### 🔥 Rapid Deployment (Recommended)

**Total time: ~20 minutes** using pre-built configuration!

1. **Download & Flash OPNsense** (5 min)
2. **Install to N1241** (15 min)
3. **Import config + Install Zenarmor** (3 min)
4. **Done!** ✅

👉 **See: [RAPID-DEPLOY.md](RAPID-DEPLOY.md)** for step-by-step guide

### Standard Deployment

**Total time: ~60 minutes** with manual configuration

1. **Download & Flash (5 min)**
   ```bash
   # Download OPNsense
   wget https://opnsense.org/download/ (amd64, vga image)
   
   # Flash to USB
   rufus.exe  # Windows
   dd if=opnsense.img of=/dev/sdX  # Linux/Mac
   ```

2. **Install (15 min)**
   - Boot N1241 from USB
   - Login: `installer` / `opnsense`
   - Install to SSD
   - Reboot

3. **Configure (40 min)**
   - Follow `docs/INSTALLATION-GUIDE.md`
   - Configure VLANs, rules, Zenarmor manually
   - Web UI: https://192.168.1.1

👉 **See: [docs/INSTALLATION-GUIDE.md](docs/INSTALLATION-GUIDE.md)** for detailed guide

### For End Users

See `docs/CUSTOMER-GUIDE.md` for:
- Connecting AI devices
- VPN setup for remote access
- Monitoring dashboard
- Troubleshooting

---

## 📊 Use Cases

### Home AI Lab
**Setup:** N1241 + 1× AI host (N3422/N3281)
- Ollama for local models
- OpenClaw AI agent
- Cloud APIs for complex tasks
- 4 VLANs: LAN, AI, IoT, Guest

**Time:** 60 min  

### Small Business Hybrid AI
**Setup:** N1241 + multiple AI hosts
- Local: Llama 3, Mistral (privacy)
- Cloud: Claude Opus, GPT-5 (intelligence)
- Egress filtering: only approved APIs
- Rate limiting: prevent API abuse

**Time:** 90 min  

### Enterprise AI Gateway
**Setup:** N3281 (8 ports) + AI cluster
- 8 physical zones
- Zenarmor Premium (advanced features)
- Elasticsearch for log aggregation
- Full DPI + compliance logging

**Time:** 2-3 hours  

---

## 📚 Documentation

| Document | Audience | Time | Purpose |
|----------|----------|------|---------|
| 🔥 [RAPID-DEPLOY.md](RAPID-DEPLOY.md) | Tech team | **20 min** | Import pre-built config |
| [INSTALLATION-GUIDE.md](docs/INSTALLATION-GUIDE.md) | Tech team | 60 min | Manual setup steps |
| [QUICK-START.md](QUICK-START.md) | Tech team | 60 min | Setup checklist |
| [configs/README.md](configs/README.md) | Tech team | - | Config file docs |
| [AI-SECURITY-RULES.md](docs/AI-SECURITY-RULES.md) | Advanced users | - | Rule explanations |
| [CUSTOMER-GUIDE.md](docs/CUSTOMER-GUIDE.md) | End users | - | Daily usage |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Everyone | - | Common issues |

---

## 🎓 Training Materials

### For Sales Team
- Product overview (this README)
- ROI calculator
- Comparison charts
- Demo script

### For Technical Team
- Installation checklist
- Configuration templates
- Troubleshooting guide
- API for automation

### For Customers
- User guide (non-technical)
- VPN setup instructions
- FAQ
- Video tutorials (coming soon)

---

## 🔧 Technical Specs

### N1241 Hardware
- **CPU:** Intel Alder Lake N100 (4C/4T, 3.4GHz)
- **RAM:** 8-16GB DDR4 3200MHz
- **Storage:** 256GB M.2 SATA SSD
- **NICs:** 4× Intel i226-V 2.5G
- **Power:** 12V, <15W
- **Dimensions:** 144 × 136.7 × 42 mm
- **Weight:** 0.79 kg

### Software Requirements
- OPNsense 24.x or later
- 8GB+ RAM recommended for Zenarmor DPI
- 256GB+ storage for traffic logs and reports

### Network Requirements
- ISP connection (DHCP or Static)
- Minimum 2 cables (WAN + LAN)
- Optional: Managed switch for more VLANs

---

## 🎯 Features

### ✅ Core Features
- [x] 4-port VLAN isolation
- [x] AI-powered DPI (Zenarmor)
- [x] Cloud threat intelligence
- [x] Malware/Botnet/Phishing blocking
- [x] Application control
- [x] Egress filtering (cloud API whitelist)
- [x] DNS filtering
- [x] Rate limiting
- [x] Real-time monitoring dashboard
- [x] Automated security alerts

### 🔜 Coming Soon
- [ ] Pre-configured ISO image
- [ ] Video installation guide
- [ ] Mobile dashboard app
- [ ] Automated reporting
- [ ] AI-specific dashboards

---

## 🤝 Support

**Pre-Sales:**
- Email: support@iwilltech.co.uk
- Web: https://www.iwilltech.co.uk/n1241

**Technical:**
- Documentation: This repository
- Community: OPNsense forums
- Professional: Support contracts available

**Training:**
- On-site installation
- Remote configuration
- Custom rule development

---

## 📝 License

- **Documentation:** CC BY 4.0
- **Scripts:** MIT License
- **OPNsense:** BSD 2-Clause
- **Suricata:** GPLv2
- **Zenarmor:** Proprietary (free tier available)

---

## 🚨 Security Notice

This firewall protects AI infrastructure but is not a magic solution:
- Keep OPNsense updated (weekly security patches)
- Review logs regularly
- Backup configurations
- Use strong passwords
- Enable 2FA where available
- Follow principle of least privilege

**No firewall replaces good security practices.**

---

## 🌟 Why N1241?

### vs. Software Firewall
- ✅ Dedicated hardware = no CPU steal
- ✅ 4 physical ports = true isolation
- ✅ AES-NI = wire-speed VPN
- ✅ Fanless = silent, reliable

### vs. Enterprise Firewalls
- ✅ 90% cheaper (3-year TCO)
- ✅ No vendor lock-in
- ✅ Open-source = community support
- ✅ Full control = no cloud dependencies

### vs. ISP Router
- ✅ Real IDS/IPS vs. basic NAT
- ✅ VLAN isolation vs. flat network
- ✅ DPI vs. no inspection
- ✅ Threat intel vs. blind

---

## 📞 Ready to Deploy?

1. **Order Hardware:**
   - N1241 (available at [iwilltech.co.uk](https://www.iwilltech.co.uk/n1241))
   - Cables, USB drive

2. **Prepare:**
   - Download OPNsense ISO
   - Print installation guide
   - Schedule 90 minutes

3. **Install:**
   - Follow `QUICK-START.md`
   - Or hire us for remote setup

4. **Deploy:**
   - Connect AI devices
   - Test isolation
   - Monitor for 24h

**Questions?** Contact support@iwilltech.co.uk

---

**IWILL N1241 AI Firewall**  
*Protecting the AI revolution, one network at a time.* 🛡️🤖
