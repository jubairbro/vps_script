#!/bin/bash

#=============[ Start Telegram Bot Menu Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "TELEGRAM BOT"
echo -e "${NC}"

# Telegram Bot Menu
echo -e "${BLUE}╔════════════ TELEGRAM BOT ════════════╗${NC}"
echo -e "${BLUE}║ [01] Start Telegram Bot             ║${NC}"
echo -e "${BLUE}║ [02] Stop Telegram Bot              ║${NC}"
echo -e "${BLUE}║ [03] Check Bot Status               ║${NC}"
echo -e "${BLUE}║ [04] Edit Bot Token & UID           ║${NC}"
echo -e "${BLUE}╚═════════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Start Telegram bot
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Starting Telegram Bot        ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        if ! pgrep -f "telegram_bot.py" > /dev/null; then
            nohup python3 /root/vps_script/telegram_bot.py > /root/vps_script/telegram_bot.log 2>&1 &
            echo -e "${GREEN}Telegram bot started!${NC}"
        else
            echo -e "${YELLOW}Telegram bot is already running!${NC}"
        fi
        sleep 2
        bash telegram_bot.sh
        ;;
    2)
        # Stop Telegram bot
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Stopping Telegram Bot        ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        pkill -f "telegram_bot.py"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Telegram bot stopped!${NC}"
        else
            echo -e "${YELLOW}Telegram bot is not running!${NC}"
        fi
        sleep 2
        bash telegram_bot.sh
        ;;
    3)
        # Check bot status
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Check Bot Status             ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        if pgrep -f "telegram_bot.py" > /dev/null; then
            echo -e "${GREEN}Telegram bot is running!${NC}"
            echo -e "${YELLOW}Log Output:${NC}"
            tail -n 10 /root/vps_script/telegram_bot.log
        else
            echo -e "${RED}Telegram bot is not running!${NC}"
        fi
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash telegram_bot.sh
        fi
        ;;
    4)
        # Edit bot token & UID
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Edit Bot Token & UID          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Telegram Bot Token: " BOT_TOKEN
        read -p "Enter Owner UID: " OWNER_UID
        
        # Update telegram_bot.py with new token and UID
        sed -i "s/BOT_TOKEN = \".*\"/BOT_TOKEN = \"$BOT_TOKEN\"/" /root/vps_script/telegram_bot.py
        sed -i "s/OWNER_UID = \".*\"/OWNER_UID = \"$OWNER_UID\"/" /root/vps_script/telegram_bot.py
        echo -e "${GREEN}Bot Token and UID updated successfully!${NC}"
        sleep 2
        bash telegram_bot.sh
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash telegram_bot.sh
        ;;
esac