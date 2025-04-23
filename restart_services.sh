#!/bin/bash

#=============[ Start Restart Services Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "RESTART SERVICES"
echo -e "${NC}"

# Restart Services Menu
echo -e "${BLUE}╔════════════ RESTART SERVICES ════════════╗${NC}"
echo -e "${BLUE}║ [01] Restart SSH Service                ║${NC}"
echo -e "${BLUE}║ [02] Restart OpenVPN Service            ║${NC}"
echo -e "${BLUE}║ [03] Restart Xray Service               ║${NC}"
echo -e "${BLUE}║ [04] Restart Nginx Service              ║${NC}"
echo -e "${BLUE}║ [05] Restart All Services               ║${NC}"
echo -e "${BLUE}╚═════════════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Restart SSH Service
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Restart SSH Service          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        systemctl restart ssh
        echo -e "${GREEN}SSH service restarted!${NC}"
        sleep 2
        bash restart_services.sh
        ;;
    2)
        # Restart OpenVPN Service
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║       Restart OpenVPN Service        ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        systemctl restart openvpn@server
        echo -e "${GREEN}OpenVPN service restarted!${NC}"
        sleep 2
        bash restart_services.sh
        ;;
    3)
        # Restart Xray Service
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Restart Xray Service         ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        systemctl restart xray
        echo -e "${GREEN}Xray service restarted!${NC}"
        sleep 2
        bash restart_services.sh
        ;;
    4)
        # Restart Nginx Service
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Restart Nginx Service         ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        systemctl restart nginx
        echo -e "${GREEN}Nginx service restarted!${NC}"
        sleep 2
        bash restart_services.sh
        ;;
    5)
        # Restart All Services
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Restart All Services         ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        systemctl restart ssh
        systemctl restart openvpn@server
        systemctl restart xray
        systemctl restart nginx
        echo -e "${GREEN}All services restarted!${NC}"
        sleep 2
        bash restart_services.sh
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash restart_services.sh
        ;;
esac