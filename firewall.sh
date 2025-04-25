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

# Display Firewall menu
display_header "Firewall Menu"
echo -e "${BLUE}║ [1] Enable Firewall         ║${NC}"
echo -e "${BLUE}║ [2] Disable Firewall        ║${NC}"
echo -e "${BLUE}║ [3] Add Firewall Rule       ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash firewall.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Enable Firewall"
        ufw --force enable || {
            echo -e "${RED}Failed to enable firewall!${NC}"
            sleep 2
            bash firewall.sh
        }
        echo -e "${GREEN}Firewall enabled successfully!${NC}"
        sleep 2
        bash firewall.sh
        ;;
    2)
        clear
        display_header "Disable Firewall"
        ufw disable || {
            echo -e "${RED}Failed to disable firewall!${NC}"
            sleep 2
            bash firewall.sh
        }
        echo -e "${GREEN}Firewall disabled successfully!${NC}"
        sleep 2
        bash firewall.sh
        ;;
    3)
        clear
        display_header "Add Firewall Rule"
        read -p "Enter port to allow (e.g., 22): " PORT
        validate_port "$PORT" || {
            sleep 2
            bash firewall.sh
        }
        read -p "Enter protocol (tcp/udp): " PROTOCOL
        if [ "$PROTOCOL" != "tcp" ] && [ "$PROTOCOL" != "udp" ]; then
            echo -e "${RED}Invalid protocol! Please enter 'tcp' or 'udp'.${NC}"
            sleep 2
            bash firewall.sh
        fi
        ufw allow "$PORT/$PROTOCOL" || {
            echo -e "${RED}Failed to add firewall rule!${NC}"
            sleep 2
            bash firewall.sh
        }
        echo -e "${GREEN}Firewall rule added: Allow $PORT/$PROTOCOL${NC}"
        sleep 2
        bash firewall.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash firewall.sh
        ;;
esac