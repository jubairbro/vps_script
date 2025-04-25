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

# Display Update Script menu
display_header "Update Script Menu"
echo -e "${BLUE}║ [1] Check for Updates       ║${NC}"
echo -e "${BLUE}║ [2] Update Script           ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash update_script.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Check for Updates"
        CURRENT_VERSION=$(cat /root/vps_script/update.txt 2>/dev/null | grep VERSION | cut -d= -f2)
        if [ -z "$CURRENT_VERSION" ]; then
            echo -e "${RED}Failed to read current version!${NC}"
            sleep 2
            bash update_script.sh
        fi
        REMOTE_VERSION=$(curl -s https://raw.githubusercontent.com/jubairbro/vps_script/main/update.txt | grep VERSION | cut -d= -f2)
        if [ -z "$REMOTE_VERSION" ]; then
            echo -e "${RED}Failed to fetch remote version! Please check your internet connection.${NC}"
            sleep 2
            bash update_script.sh
        fi
        if [ "$CURRENT_VERSION" != "$REMOTE_VERSION" ]; then
            echo -e "${YELLOW}New version available: $REMOTE_VERSION (Current: $CURRENT_VERSION)${NC}"
        else
            echo -e "${GREEN}You are already on the latest version: $CURRENT_VERSION${NC}"
        fi
        read -p "Press Enter to continue..."
        bash update_script.sh
        ;;
    2)
        clear
        display_header "Update Script"
        CURRENT_VERSION=$(cat /root/vps_script/update.txt 2>/dev/null | grep VERSION | cut -d= -f2)
        if [ -z "$CURRENT_VERSION" ]; then
            echo -e "${RED}Failed to read current version!${NC}"
            sleep 2
            bash update_script.sh
        fi
        REMOTE_VERSION=$(curl -s https://raw.githubusercontent.com/jubairbro/vps_script/main/update.txt | grep VERSION | cut -d= -f2)
        if [ -z "$REMOTE_VERSION" ]; then
            echo -e "${RED}Failed to fetch remote version! Please check your internet connection.${NC}"
            sleep 2
            bash update_script.sh
        fi
        if [ "$CURRENT_VERSION" != "$REMOTE_VERSION" ]; then
            cd /root/vps_script || {
                echo -e "${RED}Failed to change directory to /root/vps_script!${NC}"
                sleep 2
                bash update_script.sh
            }
            git pull origin main || {
                echo -e "${RED}Failed to update script! Please check your git configuration.${NC}"
                sleep 2
                bash update_script.sh
            }
            echo -e "${GREEN}Script updated to version $REMOTE_VERSION${NC}"
        else
            echo -e "${GREEN}You are already on the latest version: $CURRENT_VERSION${NC}"
        fi
        sleep 2
        bash update_script.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 2.${NC}"
        sleep 2
        bash update_script.sh
        ;;
esac