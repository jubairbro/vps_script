#!/bin/bash

#=============[ Start VMess Menu Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "VMESS MENU"
echo -e "${NC}"

# VMess Menu
echo -e "${BLUE}╔════════════ VMESS MENU ════════════╗${NC}"
echo -e "${BLUE}║ [01] Create VMess User            ║${NC}"
echo -e "${BLUE}║ [02] Delete VMess User            ║${NC}"
echo -e "${BLUE}║ [03] List VMess Users             ║${NC}"
echo -e "${BLUE}║ [04] Monitor VMess Logs           ║${NC}"
echo -e "${BLUE}║ [05] Extend VMess User            ║${NC}"
echo -e "${BLUE}║ [06] Delete Expired Users         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Create VMess user
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Create VMess User           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username: " USERNAME
        read -p "Enter Expiry Days (e.g., 30): " EXPIRY_DAYS
        
        # Generate UUID
        UUID=$(cat /proc/sys/kernel/random/uuid)
        
        # Add VMess user to Xray config
        jq '.inbounds[0].settings.clients += [{"id": "'$UUID'", "email": "'$USERNAME'"}]' /etc/xray/config.json > /tmp/xray_config_tmp.json
        mv /tmp/xray_config_tmp.json /etc/xray/config.json
        systemctl restart xray
        
        # Set expiry date
        EXPIRY_DATE=$(date -d "+$EXPIRY_DAYS days" +%Y-%m-%d)
        
        # Generate VMess links
        DOMAIN=$(hostname)
        CITY=$(curl -s ipinfo.io/city)
        ISP=$(curl -s ipinfo.io/org)
        
        VMESS_WS_TLS=$(echo -n '{"v":"2","ps":"'$USERNAME'","add":"'$DOMAIN'","port":"443","id":"'$UUID'","aid":"0","net":"ws","path":"/vmess","type":"none","host":"'$DOMAIN'","sni":"'$DOMAIN'","tls":"tls"}' | base64 -w 0)
        VMESS_WS_NO_TLS=$(echo -n '{"v":"2","ps":"'$USERNAME'","add":"'$DOMAIN'","port":"80","id":"'$UUID'","aid":"0","net":"ws","path":"/vmess","type":"none","host":"'$DOMAIN'","sni":"'$DOMAIN'","tls":"none"}' | base64 -w 0)
        VMESS_GRPC=$(echo -n '{"v":"2","ps":"'$USERNAME'","add":"'$DOMAIN'","port":"443","id":"'$UUID'","aid":"0","net":"grpc","path":"vmess","type":"none","host":"'$DOMAIN'","sni":"'$DOMAIN'","tls":"tls"}' | base64 -w 0)
        VMESS_UPGRADE_TLS=$(echo -n '{"v":"2","ps":"'$USERNAME'","add":"'$DOMAIN'","port":"443","id":"'$UUID'","aid":"0","net":"httpupgrade","path":"/upvmess","type":"none","host":"'$DOMAIN'","sni":"'$DOMAIN'","tls":"tls"}' | base64 -w 0)
        VMESS_UPGRADE_NO_TLS=$(echo -n '{"v":"2","ps":"'$USERNAME'","add":"'$DOMAIN'","port":"80","id":"'$UUID'","aid":"0","net":"httpupgrade","path":"/upvmess","type":"none","host":"'$DOMAIN'","sni":"'$DOMAIN'","tls":"none"}' | base64 -w 0)
        
        # Output in specified format
        echo -e "————————————————————————————————————"
        echo -e "               VMESS               "
        echo -e "————————————————————————————————————"
        echo -e "${YELLOW}Remarks        : ${GREEN}$USERNAME${NC}"
        echo -e "${YELLOW}CITY           : ${GREEN}$CITY${NC}"
        echo -e "${YELLOW}ISP            : ${GREEN}$ISP${NC}"
        echo -e "${YELLOW}Domain         : ${GREEN}$DOMAIN${NC}"
        echo -e "${YELLOW}Port TLS       : ${GREEN}443,8443${NC}"
        echo -e "${YELLOW}Port none TLS  : ${GREEN}80,8080${NC}"
        echo -e "${YELLOW}Port any       : ${GREEN}2052,2053,8880${NC}"
        echo -e "${YELLOW}id             : ${GREEN}$UUID${NC}"
        echo -e "${YELLOW}alterId        : ${GREEN}0${NC}"
        echo -e "${YELLOW}Security       : ${GREEN}auto${NC}"
        echo -e "${YELLOW}network        : ${GREEN}ws,grpc,upgrade${NC}"
        echo -e "${YELLOW}path ws        : ${GREEN}/vmess - /whatever${NC}"
        echo -e "${YELLOW}serviceName    : ${GREEN}vmess${NC}"
        echo -e "${YELLOW}path upgrade   : ${GREEN}/upvmess${NC}"
        echo -e "${YELLOW}Expired On     : ${GREEN}$EXPIRY_DATE${NC}"
        echo -e "————————————————————————————————————"
        echo -e "           VMESS WS TLS            "
        echo -e "————————————————————————————————————"
        echo -e "${GREEN}vmess://$VMESS_WS_TLS${NC}"
        echo -e "————————————————————————————————————"
        echo -e "          VMESS WS NO TLS          "
        echo -e "————————————————————————————————————"
        echo -e "${GREEN}vmess://$VMESS_WS_NO_TLS${NC}"
        echo -e "————————————————————————————————————"
        echo -e "             VMESS GRPC            "
        echo -e "————————————————————————————————————"
        echo -e "${GREEN}vmess://$VMESS_GRPC${NC}"
        echo -e "————————————————————————————————————"
        echo -e "         VMESS Upgrade TLS         "
        echo -e "————————————————————————————————————"
        echo -e "${GREEN}vmess://$VMESS_UPGRADE_TLS${NC}"
        echo -e "————————————————————————————————————"
        echo -e "        VMESS Upgrade NO TLS       "
        echo -e "————————————————————————————————————"
        echo -e "${GREEN}vmess://$VMESS_UPGRADE_NO_TLS${NC}"
        echo -e "————————————————————————————————————"
        
        # Save user info (for expiry tracking)
        echo "$USERNAME:$UUID:$EXPIRY_DATE" >> /root/vps_script/vmess_users.txt
        sleep 5
        bash vmess_menu.sh
        ;;
    2)
        # Delete VMess user
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Delete VMess User           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username to Delete: " USERNAME
        
        # Remove user from Xray config
        jq 'del(.inbounds[0].settings.clients[] | select(.email == "'$USERNAME'"))' /etc/xray/config.json > /tmp/xray_config_tmp.json
        mv /tmp/xray_config_tmp.json /etc/xray/config.json
        systemctl restart xray
        
        # Remove from user list
        sed -i "/$USERNAME:/d" /root/vps_script/vmess_users.txt
        echo -e "${GREEN}VMess user $USERNAME deleted successfully!${NC}"
        sleep 2
        bash vmess_menu.sh
        ;;
    3)
        # List VMess users
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           List VMess Users           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        cat /root/vps_script/vmess_users.txt | awk -F: '{print $1}'
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash vmess_menu.sh
        fi
        ;;
    4)
        # Monitor VMess logs
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Monitor VMess Logs          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        tail -f /var/log/xray/access.log | grep vmess
        ;;
    5)
        # Extend VMess user
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Extend VMess User           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username: " USERNAME
        read -p "Enter Additional Days (e.g., 30): " ADD_DAYS
        
        # Check if user exists
        if grep -q "$USERNAME:" /root/vps_script/vmess_users.txt; then
            CURRENT_EXPIRY=$(grep "$USERNAME:" /root/vps_script/vmess_users.txt | awk -F: '{print $3}')
            NEW_EXPIRY=$(date -d "$CURRENT_EXPIRY + $ADD_DAYS days" +%Y-%m-%d)
            UUID=$(grep "$USERNAME:" /root/vps_script/vmess_users.txt | awk -F: '{print $2}')
            sed -i "s/$USERNAME:$UUID:$CURRENT_EXPIRY/$USERNAME:$UUID:$NEW_EXPIRY/" /root/vps_script/vmess_users.txt
            echo -e "${GREEN}VMess user $USERNAME extended until $NEW_EXPIRY!${NC}"
        else
            echo -e "${RED}User $USERNAME does not exist!${NC}"
        fi
        sleep 2
        bash vmess_menu.sh
        ;;
    6)
        # Delete expired VMess users
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Delete Expired Users          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        TODAY=$(date +%Y-%m-%d)
        while IFS=: read -r USERNAME UUID EXPIRY; do
            if [[ "$EXPIRY" < "$TODAY" ]]; then
                jq 'del(.inbounds[0].settings.clients[] | select(.email == "'$USERNAME'"))' /etc/xray/config.json > /tmp/xray_config_tmp.json
                mv /tmp/xray_config_tmp.json /etc/xray/config.json
                sed -i "/$USERNAME:/d" /root/vps_script/vmess_users.txt
                echo -e "${GREEN}Deleted expired VMess user: $USERNAME${NC}"
            fi
        done < /root/vps_script/vmess_users.txt
        systemctl restart xray
        sleep 2
        bash vmess_menu.sh
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash vmess_menu.sh
        ;;
esac