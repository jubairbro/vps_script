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

# Display Speedtest menu
display_header "Speedtest Menu"
echo -e "${BLUE}║ [1] Run Speedtest           ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash speedtest.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Running Speedtest"
        if ! command -v speedtest-cli >/dev/null 2>&1; then
            echo -e "${RED}speedtest-cli not found! Please ensure it is installed.${NC}"
            sleep 2
            bash speedtest.sh
        fi
        speedtest-cli --simple || {
            echo -e "${RED}Failed to run speedtest! Please check your internet connection.${NC}"
            sleep 2
            bash speedtest.sh
        }
        read -p "Press Enter to continue..."
        bash speedtest.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 1.${NC}"
        sleep 2
        bash speedtest.sh
        ;;
esac