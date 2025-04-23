#!/bin/bash

#=============[ Start Log Manager Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "LOG MANAGER"
echo -e "${NC}"

# Log Manager Menu
echo -e "${BLUE}╔════════════ LOG MANAGER ════════════╗${NC}"
echo -e "${BLUE}║ [01] View Xray Logs                ║${NC}"
echo -e "${BLUE}║ [02] View SSH Logs                 ║${NC}"
echo -e "${BLUE}║ [03] Clear All Logs                ║${NC}"
echo -e "${BLUE}║ [04] View Bandwidth Usage          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # View Xray logs
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Viewing Xray Logs          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        tail -f /var/log/xray/access.log
        ;;
    2)
        # View SSH logs
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Viewing SSH Logs           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        tail -f /var/log/auth.log | grep sshd
        ;;
    3)
        # Clear all logs
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Clearing Logs              ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        truncate -s 0 /var/log/xray/access.log
        truncate -s 0 /var/log/xray/error.log
        truncate -s 0 /var/log/auth.log
        echo -e "${GREEN}All logs cleared!${NC}"
        sleep 2
        bash log_manager.sh
        ;;
    4)
        # View bandwidth usage
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Bandwidth Usage               ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        vnstat -i eth0
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash log_manager.sh
        fi
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash log_manager.sh
        ;;
esac