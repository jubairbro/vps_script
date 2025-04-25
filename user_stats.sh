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

# Display User Stats menu
display_header "User Stats Menu"
echo -e "${BLUE}║ [1] Show Active Users       ║${NC}"
echo -e "${BLUE}║ [2] Show Total Users        ║${NC}"
echo -e "${BLUE}║ [3] Show Resource Usage     ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash user_stats.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Show Active Users"
        echo -e "${YELLOW}Active users:${NC}"
        who | awk '{print $1 " (Logged in at " $3 " " $4 ")"}' | while read -r user; do
            echo -e "${GREEN}$user${NC}"
        done
        if [ -z "$(who)" ]; then
            echo -e "${RED}No active users found!${NC}"
        fi
        read -p "Press Enter to continue..."
        bash user_stats.sh
        ;;
    2)
        clear
        display_header "Show Total Users"
        TOTAL_USERS=$(getent passwd | grep '/bin/bash' | wc -l)
        echo -e "${YELLOW}Total users with bash shell:${NC}"
        echo -e "${GREEN}$TOTAL_USERS${NC}"
        echo -e "${YELLOW}List of users:${NC}"
        getent passwd | grep '/bin/bash' | cut -d: -f1 | while read -r user; do
            echo -e "${GREEN}$user${NC}"
        done
        read -p "Press Enter to continue..."
        bash user_stats.sh
        ;;
    3)
        clear
        display_header "Show Resource Usage"
        echo -e "${YELLOW}CPU Usage:${NC}"
        top -bn1 | head -n 3 || {
            echo -e "${RED}Failed to fetch CPU usage!${NC}"
            sleep 2
            bash user_stats.sh
        }
        echo -e "${YELLOW}Memory Usage:${NC}"
        free -h || {
            echo -e "${RED}Failed to fetch memory usage!${NC}"
            sleep 2
            bash user_stats.sh
        }
        echo -e "${YELLOW}Disk Usage:${NC}"
        df -h / || {
            echo -e "${RED}Failed to fetch disk usage!${NC}"
            sleep 2
            bash user_stats.sh
        }
        read -p "Press Enter to continue..."
        bash user_stats.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash user_stats.sh
        ;;
esac