#!/bin/bash

#=============[ Start Change Theme Script ]================
clear

# Color variables for output (default theme)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "CHANGE THEME"
echo -e "${NC}"

# Change Theme Menu
echo -e "${BLUE}╔════════════ CHANGE THEME ════════════╗${NC}"
echo -e "${BLUE}║ [01] Default Theme (Red/Green)      ║${NC}"
echo -e "${BLUE}║ [02] Blue Theme (Blue/Cyan)         ║${NC}"
echo -e "${BLUE}║ [03] Purple Theme (Purple/Magenta)  ║${NC}"
echo -e "${BLUE}╚═════════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Default Theme (Red/Green)
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Applying Default Theme       ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        sed -i 's/RED=.*/RED="\\033[0;31m"/' /root/vps_script/main.sh
        sed -i 's/GREEN=.*/GREEN="\\033[0;32m"/' /root/vps_script/main.sh
        sed -i 's/YELLOW=.*/YELLOW="\\033[1;33m"/' /root/vps_script/main.sh
        sed -i 's/BLUE=.*/BLUE="\\033[0;34m"/' /root/vps_script/main.sh
        echo -e "${GREEN}Default theme applied!${NC}"
        sleep 2
        bash change_theme.sh
        ;;
    2)
        # Blue Theme (Blue/Cyan)
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Applying Blue Theme          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        sed -i 's/RED=.*/RED="\\033[0;36m"/' /root/vps_script/main.sh
        sed -i 's/GREEN=.*/GREEN="\\033[0;96m"/' /root/vps_script/main.sh
        sed -i 's/YELLOW=.*/YELLOW="\\033[1;34m"/' /root/vps_script/main.sh
        sed -i 's/BLUE=.*/BLUE="\\033[0;94m"/' /root/vps_script/main.sh
        echo -e "${GREEN}Blue theme applied!${NC}"
        sleep 2
        bash change_theme.sh
        ;;
    3)
        # Purple Theme (Purple/Magenta)
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Applying Purple Theme         ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        sed -i 's/RED=.*/RED="\\033[0;35m"/' /root/vps_script/main.sh
        sed -i 's/GREEN=.*/GREEN="\\033[0;95m"/' /root/vps_script/main.sh
        sed -i 's/YELLOW=.*/YELLOW="\\033[1;93m"/' /root/vps_script/main.sh
        sed -i 's/BLUE=.*/BLUE="\\033[0;34m"/' /root/vps_script/main.sh
        echo -e "${GREEN}Purple theme applied!${NC}"
        sleep 2
        bash change_theme.sh
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash change_theme.sh
        ;;
esac