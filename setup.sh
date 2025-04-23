#!/bin/bash

#=============[ Start Installation Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "VPS SETUP"
echo -e "${NC}"

# System check
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Checking System            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"

# OS detection
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo -e "${RED}OS could not be detected!${NC}"
    exit 1
fi

if [[ "$OS" != *"Ubuntu"* && "$OS" != *"Debian"* ]]; then
    echo -e "${RED}Only Ubuntu 20.04+ and Debian 10+ are supported!${NC}"
    exit 1
fi

echo -e "${GREEN}OS: $OS $VER - Supported${NC}"

# Root check
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root!${NC}"
    exit 1
fi

# Internet connection check using curl
echo -e "${YELLOW}Checking Internet Connection...${NC}"
curl -s --connect-timeout 5 http://google.com > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}No internet connection detected!${NC}"
    echo -e "${YELLOW}Some features (e.g., package installation, updates) may not work without internet.${NC}"
    read -p "Do you want to continue anyway? (y/n): " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        echo -e "${RED}Exiting script.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Internet Connection: OK${NC}"
fi

#=============[ Install Required Packages ]================
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Installing Packages          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"

# Update and install base packages
apt update -y && apt upgrade -y || echo -e "${YELLOW}Failed to update packages (possibly no internet). Continuing...${NC}"
apt install -y figlet toilet toilet-fonts curl wget net-tools jq python3 python3-pip wondershaper fail2ban speedtest-cli vnstat ufw || echo -e "${YELLOW}Failed to install some packages (possibly no internet). Continuing...${NC}"

# Install SSH and OpenVPN
apt install -y openssh-server openvpn || echo -e "${YELLOW}Failed to install SSH/OpenVPN (possibly no internet). Continuing...${NC}"
systemctl enable ssh > /dev/null 2>&1
systemctl start ssh > /dev/null 2>&1

# Configure OpenVPN
wget -O /etc/openvpn/server.conf "https://raw.githubusercontent.com/OpenVPN/openvpn/master/sample-config-files/server.conf" || echo -e "${YELLOW}Failed to download OpenVPN config (possibly no internet). Continuing...${NC}"
sed -i 's/port 1194/port 1194/' /etc/openvpn/server.conf 2>/dev/null
sed -i 's/proto udp/proto tcp/' /etc/openvpn/server.conf 2>/dev/null
systemctl enable openvpn@server > /dev/null 2>&1
systemctl start openvpn@server > /dev/null 2>&1

# Install NGINX
apt install -y nginx || echo -e "${YELLOW}Failed to install Nginx (possibly no internet). Continuing...${NC}"
systemctl enable nginx > /dev/null 2>&1
systemctl start nginx > /dev/null 2>&1

# Configure NGINX for WebSocket
cat > /etc/nginx/conf.d/vps.conf << EOL
server {
    listen 80;
    server_name _;
    location /vmess {
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    location /vless {
        proxy_pass http://127.0.0.1:10001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    location /trojan {
        proxy_pass http://127.0.0.1:10002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOL
systemctl restart nginx > /dev/null 2>&1

# Install Dropbear
apt install -y dropbear || echo -e "${YELLOW}Failed to install Dropbear (possibly no internet). Continuing...${NC}"
sed -i 's/NO_START=1/NO_START=0/' /etc/default/dropbear 2>/dev/null
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=109/' /etc/default/dropbear 2>/dev/null
systemctl enable dropbear > /dev/null 2>&1
systemctl start dropbear > /dev/null 2>&1

# Install Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install || echo -e "${YELLOW}Failed to install Xray (possibly no internet). Continuing...${NC}"
systemctl enable xray > /dev/null 2>&1
systemctl start xray > /dev/null 2>&1

# Configure Xray for VMess, VLess, Trojan, Shadowsocks
mkdir -p /etc/xray
cat > /etc/xray/config.json << EOL
{
  "log": {
    "loglevel": "info",
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log"
  },
  "inbounds": [
    {
      "port": 10000,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess"
        }
      }
    },
    {
      "port": 10001,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vless"
        }
      }
    },
    {
      "port": 10002,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/trojan"
        }
      }
    },
    {
      "port": 10003,
      "protocol": "shadowsocks",
      "settings": {
        "clients": [],
        "method": "aes-256-gcm"
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOL
systemctl restart xray > /dev/null 2>&1

# Install HAProxy
apt install -y haproxy || echo -e "${YELLOW}Failed to install HAProxy (possibly no internet). Continuing...${NC}"
cat > /etc/haproxy/haproxy.cfg << EOL
global
    log /dev/log local0
    maxconn 4096
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode tcp
    option tcplog
    timeout connect 5000
    timeout client 50000
    timeout server 50000

frontend http_front
    bind *:80
    mode http
    default_backend http_back

backend http_back
    mode http
    balance roundrobin
    server backend1 127.0.0.1:10000 check

frontend ws_front
    bind *:443
    mode tcp
    default_backend ws_back

backend ws_back
    mode tcp
    balance roundrobin
    server ws1 127.0.0.1:10000 check
EOL
systemctl enable haproxy > /dev/null 2>&1
systemctl start haproxy > /dev/null 2>&1

# Install SlowDNS
wget -O /root/slowdns.sh "https://raw.githubusercontent.com/ilyassnobee/slowdns/main/install.sh" || echo -e "${YELLOW}Failed to download SlowDNS script (possibly no internet). Continuing...${NC}"
bash /root/slowdns.sh > /dev/null 2>&1
systemctl enable slowdns > /dev/null 2>&1
systemctl start slowdns > /dev/null 2>&1

# Install Python dependencies for Telegram bot
pip3 install python-telegram-bot > /dev/null 2>&1 || echo -e "${YELLOW}Failed to install python-telegram-bot (possibly no internet). Continuing...${NC}"

# Configure Fail2Ban for security
cat > /etc/fail2ban/jail.local << EOL
[DEFAULT]
bantime  = 600
findtime  = 600
maxretry = 5

[sshd]
enabled = true
port    = 22
filter  = sshd
logpath = /var/log/auth.log
maxretry = 5
EOL
systemctl enable fail2ban > /dev/null 2>&1
systemctl start fail2ban > /dev/null 2>&1

# Configure UFW (Firewall)
ufw allow 22/tcp > /dev/null 2>&1
ufw allow 80/tcp > /dev/null 2>&1
ufw allow 443/tcp > /dev/null 2>&1
ufw allow 1194/tcp > /dev/null 2>&1
ufw allow 10000:10003/tcp > /dev/null 2>&1
ufw --force enable > /dev/null 2>&1

#=============[ Create File Structure ]================
mkdir -p /root/vps_script
mkdir -p /var/log/xray
mkdir -p /root/backups
cd /root/vps_script

# Create main script and other scripts
touch main.sh service_status.sh ssh_menu.sh vmess_menu.sh vless_menu.sh trojan_menu.sh shadow_menu.sh auto_reboot.sh speedtest.sh backup_restore.sh update_script.sh telegram_bot.sh log_manager.sh change_theme.sh telegram_join.sh hidden_storage.sh user_stats.sh cleanup.sh firewall.sh monitoring.sh restart_services.sh
chmod +x *.sh

#=============[ Setup Menu Command ]================
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Setting Up Menu Command      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"

# Create the menu command in /usr/local/bin
cat > /usr/local/bin/menu << EOL
#!/bin/bash
/root/vps_script/main.sh
EOL

# Set permissions for the menu command
chmod +x /usr/local/bin/menu
echo -e "${GREEN}Menu command setup completed! Now you can run the script by typing 'menu' from anywhere.${NC}"

#=============[ Installation Complete ]================
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      Installation Completed          ║${NC}"
echo -e "${GREEN}║      Run: menu                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"

# Automatically run main script
menu
