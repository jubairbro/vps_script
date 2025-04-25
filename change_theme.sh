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

# Display Change Theme menu
display_header "Change Theme Menu"
echo -e "${BLUE}║ [1] Set Blue Theme          ║${NC}"
echo -e "${BLUE}║ [2] Set Green Theme         ║${NC}"
echo -e "${BLUE}║ [3] Set Red Theme           ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash change_theme.sh
fi

# Theme file
THEME_FILE="/root/vps_script/.JubairVault/theme.txt"

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Set Blue Theme"
        echo "BLUE='\033[0;34m'" > "$THEME_FILE" || {
            echo -e "${RED}Failed to set blue theme!${NC}"
            sleep 2
            bash change_theme.sh
        }
        echo -e "${GREEN}Blue theme set successfully!${NC}"
        sleep 2
        bash change_theme.sh
        ;;
    2)
        clear
        display_header "Set Green Theme"
        echo "BLUE='\033[0;32m'" > "$THEME_FILE" || {
            echo -e "${RED}Failed to set green theme!${NC}"
            sleep 2
            bash change_theme.sh
        }
        echo -e "${GREEN}Green theme set successfully!${NC}"
        sleep 2
        bash change_theme.sh
        ;;
    3)
        clear
        display_header "Set Red Theme"
        echo "BLUE='\033[0;31m'" > "$THEME_FILE" || {
            echo -e "${RED}Failed to set red theme!${NC}"
            sleep 2
            bash change_theme.sh
        }
        echo -e "${GREEN}Red theme set successfully!${NC}"
        sleep 2
        bash change_theme.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash change_theme.sh
        ;;
esac