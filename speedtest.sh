#!/bin/bash

#=============[ Start Speedtest Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "SPEEDTEST"
echo -e "${NC}"

# Speedtest Menu
echo -e "${BLUE}╔════════════ SPEEDTEST ════════════╗${NC}"
echo -e "${BLUE}║ [01] Run Speedtest               ║${NC}"
echo -e "${BLUE}║ [02] View Last Speedtest Result  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Run speedtest
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Running Speedtest          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        speedtest-cli --simple > /root/vps_script/speedtest_result.txt
        cat /root/vps_script/speedtest_result.txt
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash speedtest.sh
        fi
        ;;
    2)
        # View last speedtest result
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║       Last Speedtest Result          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        if [ -f /root/vps_script/speedtest_result.txt ]; then
            cat /root/vps_script/speedtest_result.txt
        else
            echo -e "${YELLOW}No speedtest result found!${NC}"
        fi
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash speedtest.sh
        fi
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash speedtest.sh
        ;;
esac