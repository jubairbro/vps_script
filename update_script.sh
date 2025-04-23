#!/bin/bash

#=============[ Start Update Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "UPDATE SCRIPT"
echo -e "${NC}"

# Update Script Menu
echo -e "${BLUE}╔════════════ UPDATE SCRIPT ════════════╗${NC}"
echo -e "${BLUE}║ [01] Check for Updates              ║${NC}"
echo -e "${BLUE}║ [02] Update Now                     ║${NC}"
echo -e "${BLUE}╚═════════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Check for updates
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Check for Updates           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        CURRENT_VERSION="v2.1 Ultimate"
        UPDATE_URL="https://raw.githubusercontent.com/jubairbro/vps_script/main/update.txt"
        LATEST_VERSION=$(curl -s "$UPDATE_URL" | grep "VERSION" | cut -d'=' -f2)

        echo -e "${YELLOW}Current Version: $CURRENT_VERSION${NC}"
        echo -e "${YELLOW}Latest Version : $LATEST_VERSION${NC}"

        if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
            echo -e "${GREEN}Update Available!${NC}"
        else
            echo -e "${GREEN}You are using the latest version!${NC}"
        fi
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash update_script.sh
        fi
        ;;
    2)
        # Update script
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║            Updating Script           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        wget -O /root/vps_script/main.sh "https://raw.githubusercontent.com/jubairbro/vps_script/main/main.sh"
        wget -O /root/vps_script/service_status.sh "https://raw.githubusercontent.com/jubairbro/vps_script/main/service_status.sh"
        wget -O /root/vps_script/ssh_menu.sh "https://raw.githubusercontent.com/jubairbro/vps_script/main/ssh_menu.sh"
        wget -O /root/vps_script/vmess_menu.sh "https://raw.githubusercontent.com/jubairbro/vps_script/main/vmess_menu.sh"
        wget -O /root/vps_script/vless_menu.sh "https://raw.githubusercontent.com/jubairbro/vps_script/main/vless_menu.sh"
        wget -O /root/vps_script/trojan_menu.sh "https://raw.githubusercontent.com/jubairbro/vps_script/main/trojan_menu.sh"
        wget -O /root/vps_script/shadow_menu.sh "https://raw.githubusercontent.com/jubairbro/vps_script/main/shadow_menu.sh"
        chmod +x /root/vps_script/*.sh
        echo -e "${GREEN}Script updated to version $LATEST_VERSION!${NC}"
        sleep 2
        bash main.sh
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash update_script.sh
        ;;
esac