#!/bin/bash

#=============[ Start VLess Menu Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "VLESS MENU"
echo -e "${NC}"

# VLess Menu
echo -e "${BLUE}╔════════════ VLESS MENU ════════════╗${NC}"
echo -e "${BLUE}║ [01] Create VLess User            ║${NC}"
echo -e "${BLUE}║ [02] Delete VLess User            ║${NC}"
echo -e "${BLUE}║ [03] List VLess Users             ║${NC}"
echo -e "${BLUE}║ [04] Monitor VLess Logs           ║${NC}"
echo -e "${BLUE}║ [05] Extend VLess User            ║${NC}"
echo -e "${BLUE}║ [06] Delete Expired Users         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Create VLess user
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Create VLess User           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username: " USERNAME
        read -p "Enter Expiry Days (e.g., 30): " EXPIRY_DAYS
        
        # Generate UUID
        UUID=$(cat /proc/sys/kernel/random/uuid)
        
        # Add VLess user to Xray config
        jq '.inbounds[1].settings.clients += [{"id": "'$UUID'", "email": "'$USERNAME'"}]' /etc/xray/config.json > /tmp/xray_config_tmp.json
        mv /tmp/xray_config_tmp.json /etc/xray/config.json
        systemctl restart xray
        
        # Set expiry date
        EXPIRY_DATE=$(date -d "+$EXPIRY_DAYS days" +%Y-%m-%d)
        
        # Generate VLess links
        DOMAIN=$(hostname)
        CITY=$(curl -s ipinfo.io/city)
        ISP=$(curl -s ipinfo.io/org)
        
        VLESS_WS_TLS="vless://$UUID@$DOMAIN:443?path=/vless&security=tls&encryption=none&type=ws#$USERNAME"
        VLESS_WS_NO_TLS="vless://$UUID@$DOMAIN:80?path=/vless&encryption=none&type=ws#$USERNAME"
        VLESS_GRPC="vless://$UUID@$DOMAIN:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless&sni=bug.com#$USERNAME"
        
        # Output in specified format
        echo -e "————————————————————————————————————"
        echo -e "               VLESS               "
        echo -e "————————————————————————————————————"
        echo -e "${YELLOW}Remarks        : ${GREEN}$USERNAME${NC}"
        echo -e "${YELLOW}CITY           : ${GREEN}$CITY${NC}"
        echo -e "${YELLOW}ISP            : ${GREEN}$ISP${NC}"
        echo -e "${YELLOW}Domain         : ${GREEN}$DOMAIN${NC}"
        echo -e "${YELLOW}Port TLS       : ${GREEN}443${NC}"
        echo -e "${YELLOW}Port none TLS  : ${GREEN}80${NC}"
        echo -e "${YELLOW}Port GRPC      : ${GREEN}443${NC}"
        echo -e "${YELLOW}id             : ${GREEN}$UUID${NC}"
        echo -e "${YELLOW}Encryption     : ${GREEN}none${NC}"
        echo -e "${YELLOW}Network        : ${GREEN}ws - grpc${NC}"
        echo -e "${YELLOW}Path           : ${GREEN}/vless${NC}"
        echo -e "${YELLOW}serviceName    : ${GREEN}vless${NC}"
        echo -e "${YELLOW}Expired On     : ${GREEN}$EXPIRY_DATE${NC}"
        echo -e "————————————————————————————————————"
        echo -e "            VLESS WS TLS           "
        echo -e "————————————————————————————————————"
        echo -e "${GREEN}$VLESS_WS_TLS${NC}"
        echo -e "————————————————————————————————————"
        echo -e "          VLESS WS NO TLS          "
        echo -e "————————————————————————————————————"
        echo -e "${GREEN}$VLESS_WS_NO_TLS${NC}"
        echo -e "————————————————————————————————————"
        echo -e "             VLESS GRPC            "
        echo -e "————————————————————————————————————"
        echo -e "${GREEN}$VLESS_GRPC${NC}"
        echo -e "————————————————————————————————————"
        
        # Save user info (for expiry tracking)
        echo "$USERNAME:$UUID:$EXPIRY_DATE" >> /root/vps_script/vless_users.txt
        sleep 5
        bash vless_menu.sh
        ;;
    2)
        # Delete VLess user
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Delete VLess User           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username to Delete: " USERNAME
        
        # Remove user from Xray config
        jq 'del(.inbounds[1].settings.clients[] | select(.email == "'$USERNAME'"))' /etc/xray/config.json > /tmp/xray_config_tmp.json
        mv /tmp/xray_config_tmp.json /etc/xray/config.json
        systemctl restart xray
        
        # Remove from user list
        sed -i "/$USERNAME:/d" /root/vps_script/vless_users.txt
        echo -e "${GREEN}VLess user $USERNAME deleted successfully!${NC}"
        sleep 2
        bash vless_menu.sh
        ;;
    3)
        # List VLess users
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           List VLess Users           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        cat /root/vps_script/vless_users.txt | awk -F: '{print $1}'
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash vless_menu.sh
        fi
        ;;
    4)
        # Monitor VLess logs
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Monitor VLess Logs          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        tail -f /var/log/xray/access.log | grep vless
        ;;
    5)
        # Extend VLess user
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Extend VLess User           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username: " USERNAME
        read -p "Enter Additional Days (e.g., 30): " ADD_DAYS
        
        # Check if user exists
        if grep -q "$USERNAME:" /root/vps_script/vless_users.txt; then
            CURRENT_EXPIRY=$(grep "$USERNAME:" /root/vps_script/vless_users.txt | awk -F: '{print $3}')
            NEW_EXPIRY=$(date -d "$CURRENT_EXPIRY + $ADD_DAYS days" +%Y-%m-%d)
            UUID=$(grep "$USERNAME:" /root/vps_script/vless_users.txt | awk -F: '{print $2}')
            sed -i "s/$USERNAME:$UUID:$CURRENT_EXPIRY/$USERNAME:$UUID:$NEW_EXPIRY/" /root/vps_script/vless_users.txt
            echo -e "${GREEN}VLess user $USERNAME extended until $NEW_EXPIRY!${NC}"
        else
            echo -e "${RED}User $USERNAME does not exist!${NC}"
        fi
        sleep 2
        bash vless_menu.sh
        ;;
    6)
        # Delete expired VLess users
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Delete Expired Users          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        TODAY=$(date +%Y-%m-%d)
        while IFS=: read -r USERNAME UUID EXPIRY; do
            if [[ "$EXPIRY" < "$TODAY" ]]; then
                jq 'del(.inbounds[1].settings.clients[] | select(.email == "'$USERNAME'"))' /etc/xray/config.json > /tmp/xray_config_tmp.json
                mv /tmp/xray_config_tmp.json /etc/xray/config.json
                sed -i "/$USERNAME:/d" /root/vps_script/vless_users.txt
                echo -e "${GREEN}Deleted expired VLess user: $USERNAME${NC}"
            fi
        done < /root/vps_script/vless_users.txt
        systemctl restart xray
        sleep 2
        bash vless_menu.sh
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash vless_menu.sh
        ;;
esac