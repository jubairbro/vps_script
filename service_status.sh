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

# Display Service Status menu
display_header "Service Status Menu"
echo -e "${BLUE}║ [1] Check Xray Status       ║${NC}"
echo -e "${BLUE}║ [2] Check Nginx Status      ║${NC}"
echo -e "${BLUE}║ [3] Check All Services      ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash service_status.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Check Xray Status"
        check_service "xray"
        read -p "Press Enter to continue..."
        bash service_status.sh
        ;;
    2)
        clear
        display_header "Check Nginx Status"
        check_service "nginx"
        read -p "Press Enter to continue..."
        bash service_status.sh
        ;;
    3)
        clear
        display_header "Check All Services"
        echo -e "${YELLOW}Checking all services...${NC}"
        check_service "xray"
        check_service "nginx"
        check_service "openvpn@server"
        check_service "dropbear"
        check_service "haproxy"
        check_service "slowdns"
        read -p "Press Enter to continue..."
        bash service_status.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash service_status.sh
        ;;
esac