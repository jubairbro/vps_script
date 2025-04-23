#!/bin/bash

#=============[ Start Trojan Menu Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "TROJAN MENU"
echo -e "${NC}"

# Trojan Menu
echo -e "${BLUE}╔════════════ TROJAN MENU ════════════╗${NC}"
echo -e "${BLUE}║ [01] Create Trojan User           ║${NC}"
echo -e "${BLUE}║ [02] Delete Trojan User           ║${NC}"
echo -e "${BLUE}║ [03] List Trojan Users            ║${NC}"
echo -e "${BLUE}║ [04] Monitor Trojan Logs          ║${NC}"
echo -e "${BLUE}║ [05] Extend Trojan User           ║${NC}"
echo -e "${BLUE}║ [06] Delete Expired Users         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Create Trojan user
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Create Trojan User          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username: " USERNAME
        read -p "Enter Expiry Days (e.g., 30): " EXPIRY_DAYS
        
        # Generate Password
        PASSWORD=$(cat /proc/sys/kernel/random/uuid)
        
        # Add Trojan user to Xray config
        jq '.inbounds[2].settings.clients += [{"password": "'$PASSWORD'", "email": "'$USERNAME'"}]' /etc/xray/config.json > /tmp/xray_config_tmp.json
        mv /tmp/xray_config_tmp.json /etc/xray/config.json
        systemctl restart xray
        
        # Set expiry date
        EXPIRY_DATE=$(date -d "+$EXPIRY_DAYS days" +%Y-%m-%d)
        
        # Generate Trojan links (simplified for WS and gRPC)
        DOMAIN=$(hostname)
        TROJAN_WS="trojan://$PASSWORD@$DOMAIN:443?security=tls&type=ws&path=/trojan#$USERNAME"
        TROJAN_GRPC="trojan://$PASSWORD@$DOMAIN:443?security=tls&type=grpc&serviceName=trojan#$USERNAME"
        
        # Output (simplified format for Trojan)
        echo -e "————————————————————————————————————"
        echo -e "               TROJAN              "
        echo -e "————————————————————————————————————"
        echo -e "${YELLOW}Username       : ${GREEN}$USERNAME${NC}"
        echo -e "${YELLOW}Password       : ${GREEN}$PASSWORD${NC}"
        echo -e "${YELLOW}Domain         : ${GREEN}$DOMAIN${NC}"
        echo -e "${YELLOW}Port TLS       : ${GREEN}443${NC}"
        echo -e "${YELLOW}Network        : ${GREEN}ws, grpc${NC}"
        echo -e "${YELLOW}Path WS        : ${GREEN}/trojan${NC}"
        echo -e "${YELLOW}ServiceName    : ${GREEN}trojan${NC}"
        echo -e "${YELLOW}Expired On     : ${GREEN}$EXPIRY_DATE${NC}"
        echo -e "————————————————————————————————————"
        echo -e "            TROJAN WS TLS          "
        echo -e "————————————————————————————————————"
        echo -e "${GREEN}$TROJAN_WS${NC}"
        echo -e "————————————————————————————————————"
        echo -e "            TROJAN GRPC            "
        echo -e "————————————————————————————————————"
        echo -e "${GREEN}$TROJAN_GRPC${NC}"
        echo -e "————————————————————————————————————"
        
        # Save user info (for expiry tracking)
        echo "$USERNAME:$PASSWORD:$EXPIRY_DATE" >> /root/vps_script/trojan_users.txt
        sleep 5
        bash trojan_menu.sh
        ;;
    2)
        # Delete Trojan user
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Delete Trojan User          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username to Delete: " USERNAME
        
        # Remove user from Xray config
        jq 'del(.inbounds[2].settings.clients[] | select(.email == "'$USERNAME'"))' /etc/xray/config.json > /tmp/xray_config_tmp.json
        mv /tmp/xray_config_tmp.json /etc/xray/config.json
        systemctl restart xray
        
        # Remove from user list
        sed -i "/$USERNAME:/d" /root/vps_script/trojan_users.txt
        echo -e "${GREEN}Trojan user $USERNAME deleted successfully!${NC}"
        sleep 2
        bash trojan_menu.sh
        ;;
    3)
        # List Trojan users
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           List Trojan Users          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        cat /root/vps_script/trojan_users.txt | awk -F: '{print $1}'
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash trojan_menu.sh
        fi
        ;;
    4)
        # Monitor Trojan logs
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Monitor Trojan Logs          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        tail -f /var/log/xray/access.log | grep trojan
        ;;
    5)
        # Extend Trojan user
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Extend Trojan User          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username: " USERNAME
        read -p "Enter Additional Days (e.g., 30): " ADD_DAYS
        
        # Check if user exists
        if grep -q "$USERNAME:" /root/vps_script/trojan_users.txt; then
            CURRENT_EXPIRY=$(grep "$USERNAME:" /root/vps_script/trojan_users.txt | awk -F: '{print $3}')
            NEW_EXPIRY=$(date -d "$CURRENT_EXPIRY + $ADD_DAYS days" +%Y-%m-%d)
            PASSWORD=$(grep "$USERNAME:" /root/vps_script/trojan_users.txt | awk -F: '{print $2}')
            sed -i "s/$USERNAME:$PASSWORD:$CURRENT_EXPIRY/$USERNAME:$PASSWORD:$NEW_EXPIRY/" /root/vps_script/trojan_users.txt
            echo -e "${GREEN}Trojan user $USERNAME extended until $NEW_EXPIRY!${NC}"
        else
            echo -e "${RED}User $USERNAME does not exist!${NC}"
        fi
        sleep 2
        bash trojan_menu.sh
        ;;
    6)
        # Delete expired Trojan users
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Delete Expired Users          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        TODAY=$(date +%Y-%m-%d)
        while IFS=: read -r USERNAME PASSWORD EXPIRY; do
            if [[ "$EXPIRY" < "$TODAY" ]]; then
                jq 'del(.inbounds[2].settings.clients[] | select(.email == "'$USERNAME'"))' /etc/xray/config.json > /tmp/xray_config_tmp.json
                mv /tmp/xray_config_tmp.json /etc/xray/config.json
                sed -i "/$USERNAME:/d" /root/vps_script/trojan_users.txt
                echo -e "${GREEN}Deleted expired Trojan user: $USERNAME${NC}"
            fi
        done < /root/vps_script/trojan_users.txt
        systemctl restart xray
        sleep 2
        bash trojan_menu.sh
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash trojan_menu.sh
        ;;
esac