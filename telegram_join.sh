#!/bin/bash

#=============[ Start Telegram Join Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "TELEGRAM JOIN"
echo -e "${NC}"

# Telegram Join Menu
echo -e "${BLUE}╔════════════ TELEGRAM JOIN ════════════╗${NC}"
echo -e "${BLUE}║ [01] Join Official Telegram Group    ║${NC}"
echo -e "${BLUE}║ [02] Check Telegram Link             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Join Official Telegram Group
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║    Joining Official Telegram Group   ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        TELEGRAM_LINK="https://t.me/JubairFF"
        echo -e "${YELLOW}Opening Telegram link: $TELEGRAM_LINK${NC}"
        xdg-open "$TELEGRAM_LINK" 2>/dev/null || echo -e "${RED}xdg-open not available. Please open the link manually: $TELEGRAM_LINK${NC}"
        sleep 2
        bash telegram_join.sh
        ;;
    2)
        # Check Telegram Link
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Check Telegram Link           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        TELEGRAM_LINK="https://t.me/JubairFF"
        echo -e "${GREEN}Current Telegram Link: $TELEGRAM_LINK${NC}"
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash telegram_join.sh
        fi
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash telegram_join.sh
        ;;
esac