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

# Display Bot Panel menu
display_header "Bot Panel Menu"
echo -e "${BLUE}║ [1] Start Telegram Bot      ║${NC}"
echo -e "${BLUE}║ [2] Stop Telegram Bot       ║${NC}"
echo -e "${BLUE}║ [3] Check Bot Status        ║${NC}"
echo -e "${BLUE}║ [4] Add User to Whitelist   ║${NC}"
echo -e "${BLUE}║ [5] View Whitelist          ║${NC}"
echo -e "${BLUE}║ [6] Set Bot Token           ║${NC}"
echo -e "${BLUE}║ [7] Set Chat ID             ║${NC}"
echo -e "${BLUE}║ [8] View Bot Logs           ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash telegram_bot.sh
fi

# Paths
WHITELIST_FILE="/root/vps_script/.JubairVault/whitelist.txt"
CONFIG_FILE="/root/vps_script/.JubairVault/bot_config.json"
LOG_FILE="/root/vps_script/telegram-bot.log"

# Ensure whitelist file exists
if [ ! -f "$WHITELIST_FILE" ]; then
    echo "your_owner_id_here" > "$WHITELIST_FILE"
    chmod 600 "$WHITELIST_FILE" || {
        echo -e "${RED}Failed to set permissions for whitelist file!${NC}"
        sleep 2
        bash telegram_bot.sh
    }
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Start Telegram Bot"
        if pgrep -f "telegram-bot.py" >/dev/null; then
            echo -e "${RED}Telegram bot is already running!${NC}"
            sleep 2
            bash telegram_bot.sh
        fi
        # Check if bot token and chat ID are set
        if ! jq -e '.bot_token and .chat_id' "$CONFIG_FILE" >/dev/null 2>&1; then
            echo -e "${RED}Bot token or chat ID not set! Please set them first using options 6 and 7.${NC}"
            sleep 2
            bash telegram_bot.sh
        fi
        nohup python3 /root/vps_script/telegram-bot.py &>>"$LOG_FILE" &
        sleep 1
        if pgrep -f "telegram-bot.py" >/dev/null; then
            echo -e "${GREEN}Telegram bot started successfully!${NC}"
        else
            echo -e "${RED}Failed to start Telegram bot! Check $LOG_FILE for details.${NC}"
        fi
        sleep 2
        bash telegram_bot.sh
        ;;
    2)
        clear
        display_header "Stop Telegram Bot"
        if ! pgrep -f "telegram-bot.py" >/dev/null; then
            echo -e "${RED}Telegram bot is not running!${NC}"
            sleep 2
            bash telegram_bot.sh
        fi
        pkill -f "telegram-bot.py" || {
            echo -e "${RED}Failed to stop Telegram bot!${NC}"
            sleep 2
            bash telegram_bot.sh
        }
        echo -e "${GREEN}Telegram bot stopped successfully!${NC}"
        sleep 2
        bash telegram_bot.sh
        ;;
    3)
        clear
        display_header "Check Bot Status"
        if pgrep -f "telegram-bot.py" >/dev/null; then
            echo -e "${GREEN}Telegram bot is running.${NC}"
        else
            echo -e "${RED}Telegram bot is not running.${NC}"
        fi
        read -p "Press Enter to continue..."
        bash telegram_bot.sh
        ;;
    4)
        clear
        display_header "Add User to Whitelist"
        read -p "Enter Telegram User ID to whitelist: " USER_ID
        if [ -z "$USER_ID" ]; then
            echo -e "${RED}User ID cannot be empty!${NC}"
            sleep 2
            bash telegram_bot.sh
        fi
        if ! [[ "$USER_ID" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Invalid User ID! Please enter a numeric ID.${NC}"
            sleep 2
            bash telegram_bot.sh
        fi
        if grep -q "$USER_ID" "$WHITELIST_FILE"; then
            echo -e "${RED}User ID $USER_ID is already in the whitelist!${NC}"
            sleep 2
            bash telegram_bot.sh
        fi
        echo "$USER_ID" >> "$WHITELIST_FILE" || {
            echo -e "${RED}Failed to add user to whitelist!${NC}"
            sleep 2
            bash telegram_bot.sh
        }
        echo -e "${GREEN}User ID $USER_ID added to whitelist successfully!${NC}"
        sleep 2
        bash telegram_bot.sh
        ;;
    5)
        clear
        display_header "View Whitelist"
        if [ ! -s "$WHITELIST_FILE" ]; then
            echo -e "${RED}Whitelist is empty!${NC}"
        else
            echo -e "${YELLOW}Whitelisted User IDs:${NC}"
            cat "$WHITELIST_FILE" | while read -r user_id; do
                echo -e "${GREEN}$user_id${NC}"
            done
        fi
        read -p "Press Enter to continue..."
        bash telegram_bot.sh
        ;;
    6)
        clear
        display_header "Set Bot Token"
        read -p "Enter Bot Token: " BOT_TOKEN
        if [ -z "$BOT_TOKEN" ]; then
            echo -e "${RED}Bot token cannot be empty!${NC}"
            sleep 2
            bash telegram_bot.sh
        fi
        # Update bot_config.json
        if [ ! -f "$CONFIG_FILE" ]; then
            echo '{"bot_token": "", "chat_id": ""}' > "$CONFIG_FILE"
            chmod 600 "$CONFIG_FILE" || {
                echo -e "${RED}Failed to set permissions for config file!${NC}"
                sleep 2
                bash telegram_bot.sh
            }
        fi
        jq ".bot_token = \"$BOT_TOKEN\"" "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE" || {
            echo -e "${RED}Failed to set bot token!${NC}"
            sleep 2
            bash telegram_bot.sh
        }
        echo -e "${GREEN}Bot token set successfully!${NC}"
        sleep 2
        bash telegram_bot.sh
        ;;
    7)
        clear
        display_header "Set Chat ID"
        read -p "Enter Chat ID: " CHAT_ID
        if [ -z "$CHAT_ID" ]; then
            echo -e "${RED}Chat ID cannot be empty!${NC}"
            sleep 2
            bash telegram_bot.sh
        fi
        if ! [[ "$CHAT_ID" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Invalid Chat ID! Please enter a numeric ID.${NC}"
            sleep 2
            bash telegram_bot.sh
        fi
        # Update bot_config.json
        if [ ! -f "$CONFIG_FILE" ]; then
            echo '{"bot_token": "", "chat_id": ""}' > "$CONFIG_FILE"
            chmod 600 "$CONFIG_FILE" || {
                echo -e "${RED}Failed to set permissions for config file!${NC}"
                sleep 2
                bash telegram_bot.sh
            }
        fi
        jq ".chat_id = \"$CHAT_ID\"" "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE" || {
            echo -e "${RED}Failed to set chat ID!${NC}"
            sleep 2
            bash telegram_bot.sh
        }
        echo -e "${GREEN}Chat ID set successfully!${NC}"
        sleep 2
        bash telegram_bot.sh
        ;;
    8)
        clear
        display_header "View Bot Logs"
        if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
            echo -e "${YELLOW}Last 20 lines of bot logs:${NC}"
            tail -n 20 "$LOG_FILE" || {
                echo -e "${RED}Failed to read bot logs!${NC}"
                sleep 2
                bash telegram_bot.sh
            }
        else
            echo -e "${RED}No bot logs found!${NC}"
        fi
        read -p "Press Enter to continue..."
        bash telegram_bot.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 8.${NC}"
        sleep 2
        bash telegram_bot.sh
        ;;
esac