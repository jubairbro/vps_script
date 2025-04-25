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

# Display Telegram Join menu
display_header "Telegram Join Menu"
echo -e "${BLUE}║ [1] Join Telegram Group     ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash telegram_join.sh
fi

# Telegram group link
TELEGRAM_GROUP="https://t.me/jubairFF"

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Join Telegram Group"
        echo -e "${GREEN}Opening Telegram group link: $TELEGRAM_GROUP${NC}"
        # Attempt to open the link (depends on the system)
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$TELEGRAM_GROUP" || {
                echo -e "${RED}Failed to open Telegram link! Please open it manually: $TELEGRAM_GROUP${NC}"
                sleep 2
                bash telegram_join.sh
            }
        elif command -v open >/dev/null 2>&1; then
            open "$TELEGRAM_GROUP" || {
                echo -e "${RED}Failed to open Telegram link! Please open it manually: $TELEGRAM_GROUP${NC}"
                sleep 2
                bash telegram_join.sh
            }
        else
            echo -e "${YELLOW}No browser opener found. Please open this link manually: $TELEGRAM_GROUP${NC}"
        fi
        read -p "Press Enter to continue..."
        bash telegram_join.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 1.${NC}"
        sleep 2
        bash telegram_join.sh
        ;;
esac