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

# Display Shadowsocks menu
display_header "Shadowsocks Menu"
echo -e "${BLUE}║ [1] Create Shadowsocks User ║${NC}"
echo -e "${BLUE}║ [2] Delete Shadowsocks User ║${NC}"
echo -e "${BLUE}║ [3] List Shadowsocks Users  ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash shadow_menu.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Create Shadowsocks User"
        read -p "Enter password (or press Enter to generate): " PASSWORD
        if [ -z "$PASSWORD" ]; then
            PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
            echo -e "${GREEN}Generated Password: $PASSWORD${NC}"
        fi
        read -p "Enter port (default 10003): " PORT
        if [ -z "$PORT" ]; then
            PORT=10003
        else
            validate_port "$PORT" || {
                sleep 2
                bash shadow_menu.sh
            }
        }

        # Add user to Xray config
        CONFIG_FILE="/etc/xray/config.json"
        jq --arg password "$PASSWORD" '.inbounds[3].settings.clients += [{"password": $password}]' "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE" || {
            echo -e "${RED}Failed to add Shadowsocks user to config!${NC}"
            sleep 2
            bash shadow_menu.sh
        }
        systemctl restart xray || {
            echo -e "${RED}Failed to restart Xray service!${NC}"
            sleep 2
            bash shadow_menu.sh
        }
        echo -e "${GREEN}Shadowsocks user created successfully! Password: $PASSWORD, Port: $PORT${NC}"
        sleep 2
        bash shadow_menu.sh
        ;;
    2)
        clear
        display_header "Delete Shadowsocks User"
        read -p "Enter password to delete: " PASSWORD
        if [ -z "$PASSWORD" ]; then
            echo -e "${RED}Password cannot be empty!${NC}"
            sleep 2
            bash shadow_menu.sh
        fi
        CONFIG_FILE="/etc/xray/config.json"
        jq --arg password "$PASSWORD" '.inbounds[3].settings.clients |= map(select(.password != $password))' "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE" || {
            echo -e "${RED}Failed to delete Shadowsocks user from config!${NC}"
            sleep 2
            bash shadow_menu.sh
        }
        systemctl restart xray || {
            echo -e "${RED}Failed to restart Xray service!${NC}"
            sleep 2
            bash shadow_menu.sh
        }
        echo -e "${GREEN}Shadowsocks user with password $PASSWORD deleted successfully!${NC}"
        sleep 2
        bash shadow_menu.sh
        ;;
    3)
        clear
        display_header "List Shadowsocks Users"
        CONFIG_FILE="/etc/xray/config.json"
        jq -r '.inbounds[3].settings.clients[].password' "$CONFIG_FILE" | while read -r password; do
            echo -e "${GREEN}$password${NC}"
        done
        read -p "Press Enter to continue..."
        bash shadow_menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash shadow_menu.sh
        ;;
esac