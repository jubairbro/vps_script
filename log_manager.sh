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

# Display Log Manager menu
display_header "Log Manager Menu"
echo -e "${BLUE}║ [1] View Xray Logs          ║${NC}"
echo -e "${BLUE}║ [2] Clear Xray Logs         ║${NC}"
echo -e "${BLUE}║ [3] View System Logs        ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash log_manager.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "View Xray Logs"
        if [ -f "/var/log/xray/access.log" ]; then
            tail -n 50 /var/log/xray/access.log || {
                echo -e "${RED}Failed to read Xray access log!${NC}"
                sleep 2
                bash log_manager.sh
            }
        else
            echo -e "${RED}Xray access log not found!${NC}"
        fi
        if [ -f "/var/log/xray/error.log" ]; then
            tail -n 50 /var/log/xray/error.log || {
                echo -e "${RED}Failed to read Xray error log!${NC}"
                sleep 2
                bash log_manager.sh
            }
        else
            echo -e "${RED}Xray error log not found!${NC}"
        fi
        read -p "Press Enter to continue..."
        bash log_manager.sh
        ;;
    2)
        clear
        display_header "Clear Xray Logs"
        if [ -f "/var/log/xray/access.log" ]; then
            > /var/log/xray/access.log || {
                echo -e "${RED}Failed to clear Xray access log!${NC}"
                sleep 2
                bash log_manager.sh
            }
            echo -e "${GREEN}Xray access log cleared successfully!${NC}"
        else
            echo -e "${RED}Xray access log not found!${NC}"
        fi
        if [ -f "/var/log/xray/error.log" ]; then
            > /var/log/xray/error.log || {
                echo -e "${RED}Failed to clear Xray error log!${NC}"
                sleep 2
                bash log_manager.sh
            }
            echo -e "${GREEN}Xray error log cleared successfully!${NC}"
        else
            echo -e "${RED}Xray error log not found!${NC}"
        fi
        sleep 2
        bash log_manager.sh
        ;;
    3)
        clear
        display_header "View System Logs"
        journalctl -n 50 --no-pager || {
            echo -e "${RED}Failed to read system logs!${NC}"
            sleep 2
            bash log_manager.sh
        }
        read -p "Press Enter to continue..."
        bash log_manager.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash log_manager.sh
        ;;
esac