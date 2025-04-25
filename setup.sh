#!/bin/bash

#=============[ Load Utilities ]================
if [ ! -f "utils.sh" ]; then
    echo -e "${RED}utils.sh not found! Please ensure it exists in the same directory.${NC}"
    exit 1
fi
source utils.sh

#=============[ Step 1: Initial System Checks ]================
check_system() {
    clear
    display_header "Checking System"

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
    echo -e "${GREEN}Root access: Confirmed${NC}"

    # Check RAM (minimum 512 MB)
    RAM=$(free -m | grep Mem | awk '{print $2}')
    if [ "$RAM" -lt 512 ]; then
        echo -e "${RED}Insufficient RAM! Minimum 512 MB required, found $RAM MB.${NC}"
        exit 1
    fi
    echo -e "${GREEN}RAM: $RAM MB - Sufficient${NC}"

    # Check storage (minimum 2 GB free)
    STORAGE=$(df -h / | tail -1 | awk '{print $4}' | sed 's/G//')
    if [ "${STORAGE%.*}" -lt 2 ]; then
        echo -e "${RED}Insufficient storage! Minimum 2 GB free required, found $STORAGE GB.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Storage: $STORAGE GB free - Sufficient${NC}"

    # Install kmod package for modprobe if not present
    if ! command -v modprobe &> /dev/null; then
        echo -e "${YELLOW}modprobe not found! Installing kmod package...${NC}"
        apt update && apt install -y kmod || {
            echo -e "${RED}Failed to install kmod package! Please install it manually and try again.${NC}"
            exit 1
        }
        echo -e "${GREEN}kmod package installed successfully.${NC}"
    fi

    # Check if tun module is available in the kernel
    if ! lsmod | grep -q tun && ! modprobe tun 2>/dev/null; then
        echo -e "${RED}Kernel module 'tun' not found or not enabled!${NC}"
        echo -e "${YELLOW}This module is required for OpenVPN.${NC}"
        echo -e "${YELLOW}Possible solutions:${NC}"
        echo -e "${YELLOW}- If you're using a VPS, contact your provider to enable the 'tun' module.${NC}"
        echoing -e "${YELLOW}- If you're using OpenVZ, you may need to enable TUN/TAP in the VPS control panel.${NC}"
        echo -e "${YELLOW}- Alternatively, you can use a different virtualization type (e.g., KVM) that supports 'tun' by default.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Kernel module 'tun': Available${NC}"

    sleep 2
}

#=============[ Step 2: Setup DNS and Check Internet ]================
setup_network() {
    clear
    display_header "Setting Up Network"

    # Setup DNS to avoid resolution issues
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf
    echo -e "${GREEN}DNS set to Google DNS (8.8.8.8, 8.8.4.4)${NC}"

    # Display network interface status for diagnostics
    echo -e "${YELLOW}Network Interface Status:${NC}"
    ip a || {
        echo -e "${RED}Failed to fetch network interface status!${NC}"
    }

    # Display current DNS settings
    echo -e "${YELLOW}Current DNS Settings:${NC}"
    cat /etc/resolv.conf || {
        echo -e "${RED}Failed to read /etc/resolv.conf!${NC}"
    }

    # Internet connection check using curl (more reliable than ping)
    echo -e "${YELLOW}Checking internet connection...${NC}"
    curl -s --connect-timeout 5 http://www.google.com > /dev/null
    if [ $? -ne 0 ]; then
        echo -e "${RED}No internet connection!${NC}"
        echo -e "${YELLOW}Please check your network configuration:${NC}"
        echo -e "${YELLOW}- Ensure your network interface is up (use 'ip a' to check).${NC}"
        echo -e "${YELLOW}- Verify DNS settings in /etc/resolv.conf (should have 'nameserver 8.8.8.8').${NC}"
        echo -e "${YELLOW}- Test DNS resolution (use 'nslookup google.com').${NC}"
        echo -e "${YELLOW}- Test connectivity (use 'curl -v http://www.google.com').${NC}"
        echo -e "${YELLOW}- Check if your VPS provider blocks outbound traffic (e.g., ICMP or HTTP).${NC}"
        echo -e "${YELLOW}- Contact your VPS provider if the issue persists.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Internet Connection: OK${NC}"

    sleep 2
}

#=============[ Step 3: Install Required Packages ]================
install_packages() {
    clear
    display_header "Installing Packages"

    apt update -y && apt upgrade -y || {
        echo -e "${RED}Failed to update package lists!${NC}"
        exit 1
    }
    apt install -y figlet toilet curl wget net-tools jq python3 python3-pip wondershaper fail2ban speedtest-cli vnstat ufw || {
        echo -e "${RED}Failed to install packages!${NC}"
        exit 1
    }
    echo -e "${GREEN}Packages installed successfully.${NC}"

    sleep 2
}

#=============[ Step 4: Install and Configure SSH ]================
install_ssh() {
    clear
    display_header "Installing SSH"

    apt install -y openssh-server || {
        echo -e "${RED}Failed to install openssh-server!${NC}"
        exit 1
    }
    systemctl enable ssh || {
        echo -e "${RED}Failed to enable SSH service!${NC}"
        exit 1
    }
    systemctl start ssh || {
        echo -e "${RED}Failed to start SSH service!${NC}"
        exit 1
    }
    echo -e "${GREEN}SSH installed and started successfully.${NC}"

    # Generate random user for SSH
    RANDOM_USER="vpsuser_$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)"
    RANDOM_PASS=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)
    useradd -m -s /bin/bash "$RANDOM_USER" || {
        echo -e "${RED}Failed to create random user!${NC}"
        exit 1
    }
    echo "$RANDOM_USER:$RANDOM_PASS" | chpasswd || {
        echo -e "${RED}Failed to set password for random user!${NC}"
        exit 1
    }
    echo -e "${GREEN}Random user created:${NC}"
    echo -e "${YELLOW}Username: $RANDOM_USER${NC}"
    echo -e "${YELLOW}Password: $RANDOM_PASS${NC}"

    sleep 2
}

#=============[ Step 5: Install and Configure OpenVPN ]================
install_openvpn() {
    clear
    display_header "Installing OpenVPN"

    apt install -y openvpn || {
        echo -e "${RED}Failed to install OpenVPN!${NC}"
        exit 1
    }
    wget -O /etc/openvpn/server.conf "https://raw.githubusercontent.com/OpenVPN/openvpn/master/sample-config-files/server.conf" || {
        echo -e "${RED}Failed to download OpenVPN config!${NC}"
        exit 1
    }
    sed -i 's/port 1194/port 1194/' /etc/openvpn/server.conf
    sed -i 's/proto udp/proto tcp/' /etc/openvpn/server.conf
    systemctl enable openvpn@server || {
        echo -e "${RED}Failed to enable OpenVPN service!${NC}"
        exit 1
    }
    systemctl start openvpn@server || {
        echo -e "${RED}Failed to start OpenVPN service!${NC}"
        exit 1
    }
    echo -e "${GREEN}OpenVPN installed and started successfully.${NC}"

    sleep 2
}

#=============[ Step 6: Install and Configure NGINX ]================
install_nginx() {
    clear
    display_header "Installing NGINX"

    apt install -y nginx || {
        echo -e "${RED}Failed to install NGINX!${NC}"
        exit 1
    }
    systemctl enable nginx || {
        echo -e "${RED}Failed to enable NGINX service!${NC}"
        exit 1
    }
    systemctl start nginx || {
        echo -e "${RED}Failed to start NGINX service!${NC}"
        exit 1
    }

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
    systemctl restart nginx || {
        echo -e "${RED}Failed to restart NGINX!${NC}"
        exit 1
    }
    echo -e "${GREEN}NGINX installed and configured successfully.${NC}"

    sleep 2
}

#=============[ Step 7: Install and Configure Dropbear ]================
install_dropbear() {
    clear
    display_header "Installing Dropbear"

    apt install -y dropbear || {
        echo -e "${RED}Failed to install Dropbear!${NC}"
        exit 1
    }
    sed -i 's/NO_START=1/NO_START=0/' /etc/default/dropbear
    sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=109/' /etc/default/dropbear
    systemctl enable dropbear || {
        echo -e "${RED}Failed to enable Dropbear service!${NC}"
        exit 1
    }
    systemctl start dropbear || {
        echo -e "${RED}Failed to start Dropbear service!${NC}"
        exit 1
    }
    echo -e "${GREEN}Dropbear installed and started successfully.${NC}"

    sleep 2
}

#=============[ Step 8: Install and Configure Xray ]================
install_xray() {
    clear
    display_header "Installing Xray"

    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install || {
        echo -e "${RED}Failed to install Xray!${NC}"
        exit 1
    }
    systemctl enable xray || {
        echo -e "${RED}Failed to enable Xray service!${NC}"
        exit 1
    }
    systemctl start xray || {
        echo -e "${RED}Failed to start Xray service!${NC}"
        exit 1
    }

    # Configure Xray
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
    systemctl restart xray || {
        echo -e "${RED}Failed to restart Xray!${NC}"
        exit 1
    }
    echo -e "${GREEN}Xray installed and configured successfully.${NC}"

    # Encrypt the config file
    ENCRYPTION_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
    mkdir -p /root/vps_script/.JubairVault
    chmod 700 /root/vps_script/.JubairVault || {
        echo -e "${RED}Failed to set permissions for .JubairVault!${NC}"
        exit 1
    }
    openssl enc -aes-256-cbc -salt -in /etc/xray/config.json -out /root/vps_script/.JubairVault/config.enc -pass pass:"$ENCRYPTION_KEY" || {
        echo -e "${RED}Failed to encrypt Xray config file!${NC}"
        exit 1
    }
    echo -e "${GREEN}Xray config file encrypted successfully.${NC}"
    echo -e "${YELLOW}Encryption Key: $ENCRYPTION_KEY (Save this key for decryption)${NC}"

    sleep 2
}

#=============[ Step 9: Install and Configure HAProxy ]================
install_haproxy() {
    clear
    display_header "Installing HAProxy"

    apt install -y haproxy || {
        echo -e "${RED}Failed to install HAProxy!${NC}"
        exit 1
    }
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
    systemctl enable haproxy || {
        echo -e "${RED}Failed to enable HAProxy service!${NC}"
        exit 1
    }
    systemctl start haproxy || {
        echo -e "${RED}Failed to start HAProxy service!${NC}"
        exit 1
    }
    echo -e "${GREEN}HAProxy installed and configured successfully.${NC}"

    sleep 2
}

#=============[ Step 10: Install SlowDNS ]================
install_slowdns() {
    clear
    display_header "Installing SlowDNS"

    wget -O /root/slowdns.sh "https://raw.githubusercontent.com/ilyassnobee/slowdns/main/install.sh" || {
        echo -e "${RED}Failed to download SlowDNS installer!${NC}"
        exit 1
    }
    bash /root/slowdns.sh || {
        echo -e "${RED}Failed to install SlowDNS!${NC}"
        exit 1
    }
    systemctl enable slowdns || {
        echo -e "${RED}Failed to enable SlowDNS service!${NC}"
        exit 1
    }
    systemctl start slowdns || {
        echo -e "${RED}Failed to start SlowDNS service!${NC}"
        exit 1
    }
    echo -e "${GREEN}SlowDNS installed and started successfully.${NC}"

    sleep 2
}

#=============[ Step 11: Install Python Dependencies for Telegram Bot ]================
install_python_deps() {
    clear
    display_header "Installing Python Dependencies"

    pip3 install python-telegram-bot || {
        echo -e "${RED}Failed to install python-telegram-bot!${NC}"
        exit 1
    }
    echo -e "${GREEN}Python dependencies installed successfully.${NC}"

    sleep 2
}

#=============[ Step 12: Configure Fail2Ban and iptables ]================
configure_security() {
    clear
    display_header "Configuring Security"

    # Configure Fail2Ban
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
    systemctl enable fail2ban || {
        echo -e "${RED}Failed to enable Fail2Ban service!${NC}"
        exit 1
    }
    systemctl start fail2ban || {
        echo -e "${RED}Failed to start Fail2Ban service!${NC}"
        exit 1
    }
    echo -e "${GREEN}Fail2Ban configured successfully.${NC}"

    # Setup iptables rules for DDoS protection
    iptables -A INPUT -p tcp --dport 22 -m connlimit --connlimit-above 3 -j DROP || {
        echo -e "${RED}Failed to set iptables rules for SSH!${NC}"
        exit 1
    }
    iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT || {
        echo -e "${RED}Failed to set iptables rules for SYN flood protection!${NC}"
        exit 1
    }
    echo -e "${GREEN}iptables rules for DDoS protection set successfully.${NC}"

    sleep 2
}

#=============[ Step 13: Configure UFW ]================
configure_ufw() {
    clear
    display_header "Configuring UFW"

    ufw allow 22/tcp || {
        echo -e "${RED}Failed to allow port 22 in UFW!${NC}"
        exit 1
    }
    ufw allow 80/tcp || {
        echo -e "${RED}Failed to allow port 80 in UFW!${NC}"
        exit 1
    }
    ufw allow 443/tcp || {
        echo -e "${RED}Failed to allow port 443 in UFW!${NC}"
        exit 1
    }
    ufw allow 1194/tcp || {
        echo -e "${RED}Failed to allow port 1194 in UFW!${NC}"
        exit 1
    }
    ufw allow 10000:10003/tcp || {
        echo -e "${RED}Failed to allow ports 10000-10003 in UFW!${NC}"
        exit 1
    }
    ufw --force enable || {
        echo -e "${RED}Failed to enable UFW!${NC}"
        exit 1
    }
    echo -e "${GREEN}UFW configured successfully.${NC}"

    sleep 2
}

#=============[ Step 14: Create File Structure ]================
create_file_structure() {
    clear
    display_header "Creating File Structure"

    mkdir -p /root/vps_script || {
        echo -e "${RED}Failed to create /root/vps_script directory!${NC}"
        exit 1
    }
    mkdir -p /var/log/xray || {
        echo -e "${RED}Failed to create /var/log/xray directory!${NC}"
        exit 1
    }
    mkdir -p /root/backups || {
        echo -e "${RED}Failed to create /root/backups directory!${NC}"
        exit 1
    }
    mkdir -p /root/vps_script/.JubairVault || {
        echo -e "${RED}Failed to create .JubairVault directory!${NC}"
        exit 1
    }
    chmod 700 /root/vps_script/.JubairVault || {
        echo -e "${RED}Failed to set permissions for .JubairVault!${NC}"
        exit 1
    }
    cd /root/vps_script || {
        echo -e "${RED}Failed to change directory to /root/vps_script!${NC}"
        exit 1
    }

    # Create script files
    touch main.sh service_status.sh ssh_menu.sh vmess_menu.sh vless_menu.sh trojan_menu.sh shadow_menu.sh auto_reboot.sh speedtest.sh backup_restore.sh update_script.sh telegram_bot.sh log_manager.sh change_theme.sh telegram_join.sh hidden_storage.sh user_stats.sh cleanup.sh firewall.sh monitoring.sh restart_services.sh || {
        echo -e "${RED}Failed to create script files!${NC}"
        exit 1
    }

    # Create telegram-bot.py
    cat > telegram-bot.py << 'EOL'
import os
import subprocess
import logging
import json
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes, ConversationHandler

# Configure logging
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

# Paths
CONFIG_FILE = "/root/vps_script/.JubairVault/bot_config.json"
WHITELIST_FILE = "/root/vps_script/.JubairVault/whitelist.txt"
LOG_FILE = "/root/vps_script/telegram-bot.log"

# Conversation states
SET_TOKEN, SET_CHAT_ID = range(2)

# Load or initialize bot configuration
def load_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, "r") as f:
            return json.load(f)
    return {"bot_token": None, "chat_id": None}

# Save bot configuration
def save_config(config):
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=4)

# Check if user is authorized
def is_authorized(user_id: int) -> bool:
    try:
        with open(WHITELIST_FILE, "r") as f:
            authorized_ids = f.read().splitlines()
        return str(user_id) in authorized_ids
    except Exception as e:
        logger.error(f"Error reading whitelist: {e}")
        return False

# Start command
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return
    await update.message.reply_text(
        "Welcome to VPS Panel Bot!\n"
        "Available Commands:\n"
        "/setconfig - Set bot token and chat ID\n"
        "/status - Check service status\n"
        "/restart - Restart services\n"
        "/speedtest - Run a speedtest\n"
        "/users - Show active users\n"
        "/logs - View recent logs\n"
        "/cancel - Cancel current operation"
    )

# Start configuration conversation
async def set_config(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return ConversationHandler.END
    await update.message.reply_text("Please provide the bot token:")
    return SET_TOKEN

# Set bot token
async def set_token(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    config = load_config()
    config["bot_token"] = update.message.text.strip()
    save_config(config)
    await update.message.reply_text("Bot token set successfully! Now provide the chat ID:")
    return SET_CHAT_ID

# Set chat ID
async def set_chat_id(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    config = load_config()
    chat_id = update.message.text.strip()
    if not chat_id.isdigit():
        await update.message.reply_text("Chat ID must be a number! Please try again:")
        return SET_CHAT_ID
    config["chat_id"] = chat_id
    save_config(config)
    await update.message.reply_text("Chat ID set successfully! Configuration complete.")
    return ConversationHandler.END

# Cancel configuration
async def cancel(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    await update.message.reply_text("Operation cancelled.")
    return ConversationHandler.END

# Status command
async def status(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return
    try:
        services = ["xray", "nginx", "openvpn@server", "dropbear", "haproxy", "slowdns"]
        response = "Service Status:\n"
        for service in services:
            status = subprocess.run(["systemctl", "is-active", service], capture_output=True, text=True).stdout.strip()
            response += f"{service}: {'Running' if status == 'active' else 'Not Running'}\n"
        await update.message.reply_text(response)
    except Exception as e:
        logger.error(f"Error checking status: {e}")
        await update.message.reply_text(f"Error checking status: {str(e)}")

# Restart command
async def restart(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return
    try:
        services = ["xray", "nginx", "openvpn@server", "dropbear", "haproxy", "slowdns"]
        response = "Restarting Services:\n"
        for service in services:
            subprocess.run(["systemctl", "restart", service], check=True)
            response += f"{service}: Restarted\n"
        await update.message.reply_text(response)
    except Exception as e:
        logger.error(f"Error restarting services: {e}")
        await update.message.reply_text(f"Error restarting services: {str(e)}")

# Speedtest command
async def speedtest(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return
    try:
        await update.message.reply_text("Running speedtest... Please wait.")
        result = subprocess.run(["speedtest-cli", "--simple"], capture_output=True, text=True).stdout.strip()
        await update.message.reply_text(f"Speedtest Result:\n{result}")
    except Exception as e:
        logger.error(f"Error running speedtest: {e}")
        await update.message.reply_text(f"Error running speedtest: {str(e)}")

# Users command
async def users(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return
    try:
        result = subprocess.run(["who"], capture_output=True, text=True).stdout.strip()
        if not result:
            await update.message.reply_text("No active users found.")
        else:
            await update.message.reply_text(f"Active Users:\n{result}")
    except Exception as e:
        logger.error(f"Error fetching users: {e}")
        await update.message.reply_text(f"Error fetching users: {str(e)}")

# Logs command
async def logs(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return
    try:
        log_file = "/var/log/xray/error.log"
        if os.path.exists(log_file):
            with open(log_file, "r") as f:
                log_lines = f.readlines()[-10:]  # Last 10 lines
            logs = "".join(log_lines)
            await update.message.reply_text(f"Recent Xray Error Logs:\n{logs}")
        else:
            await update.message.reply_text("No Xray error logs found.")
    except Exception as e:
        logger.error(f"Error fetching logs: {e}")
        await update.message.reply_text(f"Error fetching logs: {str(e)}")

# Main function to run the bot
def main() -> None:
    config = load_config()
    bot_token = config.get("bot_token")
    if not bot_token:
        logger.error("Bot token not set! Please set it using /setconfig command.")
        return

    # Create the Application and pass it your bot's token
    application = Application.builder().token(bot_token).build()

    # Add command handlers
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("status", status))
    application.add_handler(CommandHandler("restart", restart))
    application.add_handler(CommandHandler("speedtest", speedtest))
    application.add_handler(CommandHandler("users", users))
    application.add_handler(CommandHandler("logs", logs))

    # Add conversation handler for setting config
    conv_handler = ConversationHandler(
        entry_points=[CommandHandler("setconfig", set_config)],
        states={
            SET_TOKEN: [MessageHandler(filters.TEXT & ~filters.COMMAND, set_token)],
            SET_CHAT_ID: [MessageHandler(filters.TEXT & ~filters.COMMAND, set_chat_id)],
        },
        fallbacks=[CommandHandler("cancel", cancel)],
    )
    application.add_handler(conv_handler)

    # Start the bot
    logger.info("Bot is running...")
    application.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == "__main__":
    main()
EOL

    chmod +x *.sh telegram-bot.py || {
        echo -e "${RED}Failed to set execute permissions for scripts!${NC}"
        exit 1
    }
    echo -e "${GREEN}File structure created successfully.${NC}"

    sleep 2
}

#=============[ Step 15: Setup Menu Command ]================
setup_menu_command() {
    clear
    display_header "Setting Up Menu Command"

    cat > /usr/local/bin/menu << EOL
#!/bin/bash
/root/vps_script/main.sh
EOL
    chmod +x /usr/local/bin/menu || {
        echo -e "${RED}Failed to set execute permissions for menu command!${NC}"
        exit 1
    }
    echo -e "${GREEN}Menu command setup completed! Now you can run the script by typing 'menu' from anywhere.${NC}"

    sleep 2
}

#=============[ Step 16: Installation Complete ]================
installation_complete() {
    clear
    display_header "Installation Completed"
    echo -e "${GREEN}║      Run: menu                      ║${NC}"
    echo -e "${GREEN}╚═════════════════════════════╝${NC}"

    # Automatically run main script
    menu
}

#=============[ Execute All Steps ]================
check_system
setup_network
install_packages
install_ssh
install_openvpn
install_nginx
install_dropbear
install_xray
install_haproxy
install_slowdns
install_python_deps
configure_security
configure_ufw
create_file_structure
setup_menu_command
installation_complete
