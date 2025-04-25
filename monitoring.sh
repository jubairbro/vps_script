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

# Display Monitoring menu
display_header "Monitoring Menu"
echo -e "${BLUE}║ [1] Monitor CPU Usage       ║${NC}"
echo -e "${BLUE}║ [2] Monitor Memory Usage    ║${NC}"
echo -e "${BLUE}║ [3] Monitor Network Traffic ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash monitoring.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Monitor CPU Usage"
        echo -e "${YELLOW}Press Ctrl+C to stop monitoring...${NC}"
        while true; do
            top -bn1 | head -n 3 || {
                echo -e "${RED}Failed to monitor CPU usage!${NC}"
                sleep 2
                bash monitoring.sh
            }
            sleep 2
            clear
            display_header "Monitor CPU Usage"
            echo -e "${YELLOW}Press Ctrl+C to stop monitoring...${NC}"
        done
        ;;
    2)
        clear
        display_header "Monitor Memory Usage"
        echo -e "${YELLOW}Press Ctrl+C to stop monitoring...${NC}"
        while true; do
            free -h || {
                echo -e "${RED}Failed to monitor memory usage!${NC}"
                sleep 2
                bash monitoring.sh
            }
            sleep 2
            clear
            display_header "Monitor Memory Usage"
            echo -e "${YELLOW}Press Ctrl+C to stop monitoring...${NC}"
        done
        ;;
    3)
        clear
        display_header "Monitor Network Traffic"
        if ! command -v vnstat >/dev/null 2>&1; then
            echo -e "${RED}vnstat not found! Please ensure it is installed.${NC}"
            sleep 2
            bash monitoring.sh
        fi
        echo -e "${YELLOW}Press Ctrl+C to stop monitoring...${NC}"
        while true; do
            vnstat -l || {
                echo -e "${RED}Failed to monitor network traffic!${NC}"
                sleep 2
                bash monitoring.sh
            }
            sleep 2
            clear
            display_header "Monitor Network Traffic"
            echo -e "${YELLOW}Press Ctrl+C to stop monitoring...${NC}"
        done
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash monitoring.sh
        ;;
esac