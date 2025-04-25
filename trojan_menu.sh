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

# Display Trojan menu
display_header "Trojan Menu"
echo -e "${BLUE}║ [1] Create Trojan User      ║${NC}"
echo -e "${BLUE}║ [2] Delete Trojan User      ║${NC}"
echo -e "${BLUE}║ [3] List Trojan Users       ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash trojan_menu.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Create Trojan User"
        read -p "Enter UUID (or press Enter to generate): " UUID
        if [ -z "$UUID" ]; then
            UUID=$(uuidgen)
            echo -e "${GREEN}Generated UUID: $UUID${NC}"
        else
            validate_uuid "$UUID" || {
                sleep 2
                bash trojan_menu.sh
            }
        fi
        read -p "Enter port (default 10002): " PORT
        if [ -z "$PORT" ]; then
            PORT=10002
        else
            validate_port "$PORT" || {
                sleep 2
                bash trojan_menu.sh
            }
        }

        # Add user to Xray config
        CONFIG_FILE="/etc/xray/config.json"
        jq --arg uuid "$UUID" '.inbounds[2].settings.clients += [{"password": $uuid}]' "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE" || {
            echo -e "${RED}Failed to add Trojan user to config!${NC}"
            sleep 2
            bash trojan_menu.sh
        }
        systemctl restart xray || {
            echo -e "${RED}Failed to restart Xray service!${NC}"
            sleep 2
            bash trojan_menu.sh
        }
        echo -e "${GREEN}Trojan user created successfully! UUID: $UUID, Port: $PORT${NC}"
        sleep 2
        bash trojan_menu.sh
        ;;
    2)
        clear
        display_header "Delete Trojan User"
        read -p "Enter UUID to delete: " UUID
        validate_uuid "$UUID" || {
            sleep 2
            bash trojan_menu.sh
        }
        CONFIG_FILE="/etc/xray/config.json"
        jq --arg uuid "$UUID" '.inbounds[2].settings.clients |= map(select(.password != $uuid))' "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE" || {
            echo -e "${RED}Failed to delete Trojan user from config!${NC}"
            sleep 2
            bash trojan_menu.sh
        }
        systemctl restart xray || {
            echo -e "${RED}Failed to restart Xray service!${NC}"
            sleep 2
            bash trojan_menu.sh
        }
        echo -e "${GREEN}Trojan user with UUID $UUID deleted successfully!${NC}"
        sleep 2
        bash trojan_menu.sh
        ;;
    3)
        clear
        display_header "List Trojan Users"
        CONFIG_FILE="/etc/xray/config.json"
        jq -r '.inbounds[2].settings.clients[].password' "$CONFIG_FILE" | while read -r uuid; do
            echo -e "${GREEN}$uuid${NC}"
        done
        read -p "Press Enter to continue..."
        bash trojan_menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash trojan_menu.sh
        ;;
esac