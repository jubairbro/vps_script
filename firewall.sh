#!/bin/bash

#=============[ Start Firewall Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "FIREWALL"
echo -e "${NC}"

# Firewall Menu
echo -e "${BLUE}╔════════════ FIREWALL ════════════╗${NC}"
echo -e "${BLUE}║ [01] Enable Basic Firewall       ║${NC}"
echo -e "${BLUE}║ [02] Disable Firewall            ║${NC}"
echo -e "${BLUE}║ [03] Allow Specific Port         ║${NC}"
echo -e "${BLUE}║ [04] Block Specific Port         ║${NC}"
echo -e "${BLUE}║ [05] View Firewall Rules         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Enable Basic Firewall
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Enable Basic Firewall         ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        ufw allow 22/tcp
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw allow 1194/tcp
        ufw allow 10000:10003/tcp
        ufw enable
        echo -e "${GREEN}Basic firewall enabled! Allowed ports: 22, 80, 443, 1194, 10000-10003${NC}"
        sleep 2
        bash firewall.sh
        ;;
    2)
        # Disable Firewall
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Disable Firewall            ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        ufw disable
        echo -e "${GREEN}Firewall disabled!${NC}"
        sleep 2
        bash firewall.sh
        ;;
    3)
        # Allow Specific Port
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Allow Specific Port          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Port to Allow (e.g., 8080): " PORT
        ufw allow "$PORT"
        echo -e "${GREEN}Port $PORT allowed!${NC}"
        sleep 2
        bash firewall.sh
        ;;
    4)
        # Block Specific Port
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Block Specific Port          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Port to Block (e.g., 8080): " PORT
        ufw deny "$PORT"
        echo -e "${GREEN}Port $PORT blocked!${NC}"
        sleep 2
        bash firewall.sh
        ;;
    5)
        # View Firewall Rules
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         View Firewall Rules          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        ufw status
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash firewall.sh
        fi
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash firewall.sh
        ;;
esac