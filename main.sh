#!/bin/bash

#=============[ Start Main Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ASCII Logo and Branding
echo -e "${RED}"
figlet -f big "VPS PANEL"
echo -e "${YELLOW}Version: v2.1 Ultimate${NC}"
echo -e "${YELLOW}Developer: Jubair | Telegram: @JubairFF${NC}"
echo -e "${NC}"

# System Info Panel
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           System Information         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"

OS=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
ARCH=$(uname -m)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
RAM=$(free -m | grep Mem | awk '{print $3"/"$2" MB"}')
SWAP=$(free -m | grep Swap | awk '{print $3"/"$2" MB"}')
UPTIME=$(uptime -p)
IP=$(curl -s ifconfig.me)
ISP=$(curl -s ipinfo.io/org)
CITY=$(curl -s ipinfo.io/city)
COUNTRY=$(curl -s ipinfo.io/country)
DOMAIN=$(hostname)
EXPIRY_DATE="2090-12-04"

echo -e "${YELLOW}OS          : ${GREEN}$OS ($ARCH)${NC}"
echo -e "${YELLOW}CPU         : ${GREEN}$CPU%${NC}"
echo -e "${YELLOW}RAM         : ${GREEN}$RAM${NC}"
echo -e "${YELLOW}SWAP        : ${GREEN}$SWAP${NC}"
echo -e "${YELLOW}UPTIME      : ${GREEN}$UPTIME${NC}"
echo -e "${YELLOW}IP VPS      : ${GREEN}$IP${NC}"
echo -e "${YELLOW}ISP         : ${GREEN}$ISP${NC}"
echo -e "${YELLOW}City        : ${GREEN}$CITY${NC}"
echo -e "${YELLOW}Country     : ${GREEN}$COUNTRY${NC}"
echo -e "${YELLOW}Domain      : ${GREEN}$DOMAIN${NC}"
echo -e "${YELLOW}Script Expiry: ${GREEN}$EXPIRY_DATE${NC}"

# Service Status and User Count
echo -e "\n${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Service Status & User Count     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"

# Service status
source service_status.sh

# User count
SSH_USERS=$(grep -c "sshd.*accepted" /var/log/auth.log)
XRAY_USERS=$(grep -c "xray" /var/log/xray/access.log)
TOTAL_USERS=$(getent passwd | grep '/bin/bash' | wc -l)

echo -e "${YELLOW}Active SSH Users  : ${GREEN}$SSH_USERS${NC}"
echo -e "${YELLOW}Active Xray Users : ${GREEN}$XRAY_USERS${NC}"
echo -e "${YELLOW}Total Users Created: ${GREEN}$TOTAL_USERS${NC}"

# Box-Style Main Menu
echo -e "\n${BLUE}╔════════════ MENU ════════════╗${NC}"
echo -e "${BLUE}║ [01] SSH Menu               ║${NC}"
echo -e "${BLUE}║ [02] VMESS Menu             ║${NC}"
echo -e "${BLUE}║ [03] VLESS Menu             ║${NC}"
echo -e "${BLUE}║ [04] TROJAN Menu            ║${NC}"
echo -e "${BLUE}║ [05] SHADOWSOCKS Menu       ║${NC}"
echo -e "${BLUE}║ [06] System Status          ║${NC}"
echo -e "${BLUE}║ [07] Auto Reboot            ║${NC}"
echo -e "${BLUE}║ [08] Speedtest              ║${NC}"
echo -e "${BLUE}║ [09] Backup & Restore       ║${NC}"
echo -e "${BLUE}║ [10] Telegram Bot           ║${NC}"
echo -e "${BLUE}║ [11] Update Script          ║${NC}"
echo -e "${BLUE}║ [12] Log Manager            ║${NC}"
echo -e "${BLUE}║ [13] Change Theme           ║${NC}"
echo -e "${BLUE}║ [14] Telegram Join          ║${NC}"
echo -e "${BLUE}║ [15] Hidden Storage         ║${NC}"
echo -e "${BLUE}║ [16] User Stats             ║${NC}"
echo -e "${BLUE}║ [17] Cleanup                ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"
echo -e "${RED}[0] Exit${NC}"

# User input
read -p "Select Menu: " MENU

case $MENU in
    0)
        exit 0
        ;;
    1)
        bash ssh_menu.sh
        ;;
    2)
        bash vmess_menu.sh
        ;;
    3)
        bash vless_menu.sh
        ;;
    4)
        bash trojan_menu.sh
        ;;
    5)
        bash shadow_menu.sh
        ;;
    6)
        bash service_status.sh
        ;;
    7)
        bash auto_reboot.sh
        ;;
    8)
        bash speedtest.sh
        ;;
    9)
        bash backup_restore.sh
        ;;
    10)
        bash telegram_bot.sh
        ;;
    11)
        bash update_script.sh
        ;;
    12)
        bash log_manager.sh
        ;;
    13)
        bash change_theme.sh
        ;;
    14)
        bash telegram_join.sh
        ;;
    15)
        bash hidden_storage.sh
        ;;
    16)
        bash user_stats.sh
        ;;
    17)
        bash cleanup.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash main.sh
        ;;
esac