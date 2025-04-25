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

# Display Cleanup menu
display_header "Cleanup Menu"
echo -e "${BLUE}║ [1] Clear Temporary Files   ║${NC}"
echo -e "${BLUE}║ [2] Clear Old Logs          ║${NC}"
echo -e "${BLUE}║ [3] Clear Package Cache     ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# Userრ

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash cleanup.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Clear Temporary Files"
        rm -rf /tmp/* || {
            echo -e "${RED}Failed to clear temporary files!${NC}"
            sleep 2
            bash cleanup.sh
        }
        echo -e "${GREEN}Temporary files cleared successfully!${NC}"
        sleep 2
        bash cleanup.sh
        ;;
    2)
        clear
        display_header "Clear Old Logs"
        find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; || {
            echo -e "${RED}Failed to clear old logs!${NC}"
            sleep 2
            bash cleanup.sh
        }
        echo -e "${GREEN}Old logs cleared successfully!${NC}"
        sleep 2
        bash cleanup.sh
        ;;
    3)
        clear
        display_header "Clear Package Cache"
        apt-get clean || {
            echo -e "${RED}Failed to clear package cache!${NC}"
            sleep 2
            bash cleanup.sh
        }
        echo -e "${GREEN}Package cache cleared successfully!${NC}"
        sleep 2
        bash cleanup.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash cleanup.sh
        ;;
esac