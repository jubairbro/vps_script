#!/bin/bash

#=============[ Start Monitoring Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "MONITORING"
echo -e "${NC}"

# Monitoring Menu
echo -e "${BLUE}╔════════════ MONITORING ════════════╗${NC}"
echo -e "${BLUE}║ [01] Monitor CPU Usage            ║${NC}"
echo -e "${BLUE}║ [02] Monitor Memory Usage         ║${NC}"
echo -e "${BLUE}║ [03] Monitor Disk Usage           ║${NC}"
echo -e "${BLUE}║ [04] Monitor Network Traffic      ║${NC}"
echo -e "${BLUE}║ [05] Full System Overview         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Monitor CPU Usage
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Monitor CPU Usage           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        top -bn1 | head -n 3
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash monitoring.sh
        fi
        ;;
    2)
        # Monitor Memory Usage
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Monitor Memory Usage         ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        free -h
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash monitoring.sh
        fi
        ;;
    3)
        # Monitor Disk Usage
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Monitor Disk Usage          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        df -h
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash monitoring.sh
        fi
        ;;
    4)
        # Monitor Network Traffic
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Monitor Network Traffic       ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        vnstat -l -i eth0
        ;;
    5)
        # Full System Overview
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Full System Overview          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        echo -e "${YELLOW}CPU Usage:${NC}"
        top -bn1 | head -n 3
        echo -e "\n${YELLOW}Memory Usage:${NC}"
        free -h
        echo -e "\n${YELLOW}Disk Usage:${NC}"
        df -h
        echo -e "\n${YELLOW}Network Usage:${NC}"
        vnstat -i eth0
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash monitoring.sh
        fi
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash monitoring.sh
        ;;
esac