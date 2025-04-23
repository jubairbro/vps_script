#!/bin/bash

#=============[ Start Auto Reboot Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "AUTO REBOOT"
echo -e "${NC}"

# Auto Reboot Menu
echo -e "${BLUE}╔════════════ AUTO REBOOT ════════════╗${NC}"
echo -e "${BLUE}║ [01] Set Daily Reboot              ║${NC}"
echo -e "${BLUE}║ [02] Set Weekly Reboot             ║${NC}"
echo -e "${BLUE}║ [03] Disable Auto Reboot           ║${NC}"
echo -e "${BLUE}║ [04] Check Current Schedule        ║${NC}"
echo -e "${BLUE}║ [05] Reboot Now                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Set daily reboot
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Set Daily Reboot           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Reboot Time (HH:MM, e.g., 04:00): " REBOOT_TIME
        
        # Validate time format
        if [[ ! "$REBOOT_TIME" =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
            echo -e "${RED}Invalid time format! Use HH:MM (e.g., 04:00)${NC}"
            sleep 2
            bash auto_reboot.sh
        fi
        
        # Set cron job for daily reboot
        HOUR=$(echo $REBOOT_TIME | cut -d: -f1)
        MINUTE=$(echo $REBOOT_TIME | cut -d: -f2)
        (crontab -l 2>/dev/null | grep -v "reboot"; echo "$MINUTE $HOUR * * * /sbin/reboot") | crontab -
        echo -e "${GREEN}Daily reboot scheduled at $REBOOT_TIME!${NC}"
        sleep 2
        bash auto_reboot.sh
        ;;
    2)
        # Set weekly reboot
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Set Weekly Reboot           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Reboot Time (HH:MM, e.g., 04:00): " REBOOT_TIME
        read -p "Enter Day of Week (0-6, 0=Sunday): " DAY
        
        # Validate inputs
        if [[ ! "$REBOOT_TIME" =~ ^[0-2][0-9]:[0-5][0-9]$ || ! "$DAY" =~ ^[0-6]$ ]]; then
            echo -e "${RED}Invalid input! Time: HH:MM, Day: 0-6${NC}"
            sleep 2
            bash auto_reboot.sh
        fi
        
        # Set cron job for weekly reboot
        HOUR=$(echo $REBOOT_TIME | cut -d: -f1)
        MINUTE=$(echo $REBOOT_TIME | cut -d: -f2)
        (crontab -l 2>/dev/null | grep -v "reboot"; echo "$MINUTE $HOUR * * $DAY /sbin/reboot") | crontab -
        echo -e "${GREEN}Weekly reboot scheduled at $REBOOT_TIME on day $DAY!${NC}"
        sleep 2
        bash auto_reboot.sh
        ;;
    3)
        # Disable auto reboot
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Disable Auto Reboot          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        (crontab -l 2>/dev/null | grep -v "reboot") | crontab -
        echo -e "${GREEN}Auto reboot disabled!${NC}"
        sleep 2
        bash auto_reboot.sh
        ;;
    4)
        # Check current schedule
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Check Current Schedule        ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        crontab -l | grep "reboot" || echo -e "${YELLOW}No reboot schedule set!${NC}"
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash auto_reboot.sh
        fi
        ;;
    5)
        # Reboot now
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║             Reboot Now               ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        echo -e "${YELLOW}Rebooting VPS...${NC}"
        sleep 2
        reboot
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash auto_reboot.sh
        ;;
esac