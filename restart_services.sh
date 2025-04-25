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

# Display Restart Services menu
display_header "Restart Services Menu"
echo -e "${BLUE}║ [1] Restart Xray            ║${NC}"
echo -e "${BLUE}║ [2] Restart Nginx           ║${NC}"
echo -e "${BLUE}║ [3] Restart All Services    ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash restart_services.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Restart Xray"
        systemctl restart xray || {
            echo -e "${RED}Failed to restart Xray!${NC}"
            sleep 2
            bash restart_services.sh
        }
        echo -e "${GREEN}Xray restarted successfully!${NC}"
        sleep 2
        bash restart_services.sh
        ;;
    2)
        clear
        display_header "Restart Nginx"
        systemctl restart nginx || {
            echo -e "${RED}Failed to restart Nginx!${NC}"
            sleep 2
            bash restart_services.sh
        }
        echo -e "${GREEN}Nginx restarted successfully!${NC}"
        sleep 2
        bash restart_services.sh
        ;;
    3)
        clear
        display_header "Restart All Services"
        systemctl restart xray || {
            echo -e "${RED}Failed to restart Xray!${NC}"
            sleep 2
            bash restart_services.sh
        }
        systemctl restart nginx || {
            echo -e "${RED}Failed to restart Nginx!${NC}"
            sleep 2
            bash restart_services.sh
        }
        systemctl restart openvpn@server || {
            echo -e "${RED}Failed to restart OpenVPN!${NC}"
            sleep 2
            bash restart_services.sh
        }
        systemctl restart dropbear || {
            echo -e "${RED}Failed to restart Dropbear!${NC}"
            sleep 2
            bash restart_services.sh
        }
        systemctl restart haproxy || {
            echo -e "${RED}Failed to restart HAProxy!${NC}"
            sleep 2
            bash restart_services.sh
        }
        systemctl restart slowdns || {
            echo -e "${RED}Failed to restart SlowDNS!${NC}"
            sleep 2
            bash restart_services.sh
        }
        echo -e "${GREEN}All services restarted successfully!${NC}"
        sleep 2
        bash restart_services.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash restart_services.sh
        ;;
esac