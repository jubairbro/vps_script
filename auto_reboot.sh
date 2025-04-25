#!/bin/bash

# Load utilities
if [ ! -f "utils.sh" ]; then
    echo -e "${RED}utils.sh not found! Please ensure it exists in the same directory.${NC}"
    exit 1
fi
source utils.sh

# Clear the screen
clear

# Display logo
display_logo

# Display Auto Reboot menu
display_header "Auto Reboot Menu"
echo -e "${BLUE}║ [1] Schedule Daily Reboot   ║${NC}"
echo -e "${BLUE}║ [2] Disable Auto Reboot     ║${NC}"
echo -e "${BLUE}║ [3] Check Reboot Status     ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash auto_reboot.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Schedule Daily Reboot"
        read -p "Enter hour (0-23) for daily reboot: " HOUR
        if ! [[ "$HOUR" =~ ^[0-9]+$ ]] || [ "$HOUR" -lt 0 ] || [ "$HOUR" -gt 23 ]; then
            echo -e "${RED}Invalid hour! Please enter a number between 0 and 23.${NC}"
            sleep 2
            bash auto_reboot.sh
        fi
        read -p "Enter minute (0-59) for daily reboot: " MINUTE
        if ! [[ "$MINUTE" =~ ^[0-9]+$ ]] || [ "$MINUTE" -lt 0 ] || [ "$MINUTE" -gt 59 ]; then
            echo -e "${RED}Invalid minute! Please enter a number between 0 and 59.${NC}"
            sleep 2
            bash auto_reboot.sh
        fi
        (crontab -l 2>/dev/null | grep -v "reboot"; echo "$MINUTE $HOUR * * * /sbin/shutdown -r now") | crontab - || {
            echo -e "${RED}Failed to schedule daily reboot!${NC}"
            sleep 2
            bash auto_reboot.sh
        }
        echo -e "${GREEN}Daily reboot scheduled at $HOUR:$MINUTE!${NC}"
        sleep 2
        bash auto_reboot.sh
        ;;
    2)
        clear
        display_header "Disable Auto Reboot"
        (crontab -l 2>/dev/null | grep -v "reboot") | crontab - || {
            echo -e "${RED}Failed to disable auto reboot!${NC}"
            sleep 2
            bash auto_reboot.sh
        }
        echo -e "${GREEN}Auto reboot disabled successfully!${NC}"
        sleep 2
        bash auto_reboot.sh
        ;;
    3)
        clear
        display_header "Check Reboot Status"
        if crontab -l 2>/dev/null | grep -q "reboot"; then
            CRON_LINE=$(crontab -l 2>/dev/null | grep "reboot")
            echo -e "${GREEN}Auto reboot is scheduled: $CRON_LINE${NC}"
        else
            echo -e "${RED}Auto reboot is not scheduled.${NC}"
        fi
        read -p "Press Enter to continue..."
        bash auto_reboot.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash auto_reboot.sh
        ;;
esac