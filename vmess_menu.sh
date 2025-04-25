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

# Display VMess menu
display_header "VMess Menu"
echo -e "${BLUE}║ [1] Create VMess User       ║${NC}"
echo -e "${BLUE}║ [2] Delete VMess User       ║${NC}"
echo -e "${BLUE}║ [3] List VMess Users        ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash vmess_menu.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Create VMess User"
        read -p "Enter UUID (or press Enter to generate): " UUID
        if [ -z "$UUID" ]; then
            UUID=$(uuidgen)
            echo -e "${GREEN}Generated UUID: $UUID${NC}"
        else
            validate_uuid "$UUID" || {
                sleep 2
                bash vmess_menu.sh
            }
        fi
        read -p "Enter port (default 10000): " PORT
        if [ -z "$PORT" ]; then
            PORT=10000
        else
            validate_port "$PORT" || {
                sleep 2
                bash vmess_menu.sh
            }
        fi

        # Add user to Xray config
        CONFIG_FILE="/etc/xray/config.json"
        jq --arg uuid "$UUID" '.inbounds[0].settings.clients += [{"id": $uuid}]' "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE" || {
            echo -e "${RED}Failed to add VMess user to config!${NC}"
            sleep 2
            bash vmess_menu.sh
        }
        systemctl restart xray || {
            echo -e "${RED}Failed to restart Xray service!${NC}"
            sleep 2
            bash vmess_menu.sh
        }
        echo -e "${GREEN}VMess user created successfully! UUID: $UUID, Port: $PORT${NC}"
        sleep 2
        bash vmess_menu.sh
        ;;
    2)
        clear
        display_header "Delete VMess User"
        read -p "Enter UUID to delete: " UUID
        validate_uuid "$UUID" || {
            sleep 2
            bash vmess_menu.sh
        }
        CONFIG_FILE="/etc/xray/config.json"
        jq --arg uuid "$UUID" '.inbounds[0].settings.clients |= map(select(.id != $uuid))' "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE" || {
            echo -e "${RED}Failed to delete VMess user from config!${NC}"
            sleep 2
            bash vmess_menu.sh
        }
        systemctl restart xray || {
            echo -e "${RED}Failed to restart Xray service!${NC}"
            sleep 2
            bash vmess_menu.sh
        }
        echo -e "${GREEN}VMess user with UUID $UUID deleted successfully!${NC}"
        sleep 2
        bash vmess_menu.sh
        ;;
    3)
        clear
        display_header "List VMess Users"
        CONFIG_FILE="/etc/xray/config.json"
        jq -r '.inbounds[0].settings.clients[].id' "$CONFIG_FILE" | while read -r uuid; do
            echo -e "${GREEN}$uuid${NC}"
        done
        read -p "Press Enter to continue..."
        bash vmess_menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash vmess_menu.sh
        ;;
esac