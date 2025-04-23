#!/bin/bash

#=============[ Start Security Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "SECURITY"
echo -e "${NC}"

# Security Menu
echo -e "${BLUE}╔════════════ SECURITY ════════════╗${NC}"
echo -e "${BLUE}║ [01] Ban IP Address             ║${NC}"
echo -e "${BLUE}║ [02] Unban IP Address           ║${NC}"
echo -e "${BLUE}║ [03] View Banned IPs            ║${NC}"
echo -e "${BLUE}║ [04] Limit Bandwidth Globally   ║${NC}"
echo -e "${BLUE}║ [05] Remove Bandwidth Limit     ║${NC}"
echo -e "${BLUE}║ [06] Check Fail2Ban Status      ║${NC}"
echo -e "${BLUE}╚═════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Ban IP address
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Ban IP Address             ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter IP Address to Ban: " IP_ADDRESS
        if [[ ! "$IP_ADDRESS" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo -e "${RED}Invalid IP address format!${NC}"
            sleep 2
            bash security.sh
        fi
        iptables -A INPUT -s "$IP_ADDRESS" -j DROP
        echo -e "${GREEN}IP $IP_ADDRESS has been banned!${NC}"
        sleep 2
        bash security.sh
        ;;
    2)
        # Unban IP address
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Unban IP Address            ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter IP Address to Unban: " IP_ADDRESS
        if [[ ! "$IP_ADDRESS" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo -e "${RED}Invalid IP address format!${NC}"
            sleep 2
            bash security.sh
        fi
        iptables -D INPUT -s "$IP_ADDRESS" -j DROP
        echo -e "${GREEN}IP $IP_ADDRESS has been unbanned!${NC}"
        sleep 2
        bash security.sh
        ;;
    3)
        # View banned IPs
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          View Banned IPs             ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        iptables -L INPUT -v -n | grep DROP
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash security.sh
        fi
        ;;
    4)
        # Limit bandwidth globally
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║      Limit Bandwidth Globally        ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Upload Speed Limit (e.g., 100kbit): " UPLOAD_LIMIT
        read -p "Enter Download Speed Limit (e.g., 100kbit): " DOWNLOAD_LIMIT
        wondershaper -a eth0 -u "$UPLOAD_LIMIT" -d "$DOWNLOAD_LIMIT"
        echo -e "${GREEN}Bandwidth limited to Upload: $UPLOAD_LIMIT, Download: $DOWNLOAD_LIMIT${NC}"
        sleep 2
        bash security.sh
        ;;
    5)
        # Remove bandwidth limit
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║      Remove Bandwidth Limit          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        wondershaper -a eth0 -c
        echo -e "${GREEN}Bandwidth limit removed!${NC}"
        sleep 2
        bash security.sh
        ;;
    6)
        # Check Fail2Ban status
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Check Fail2Ban Status         ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        fail2ban-client status sshd
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash security.sh
        fi
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash security.sh
        ;;
esac