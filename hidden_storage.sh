#!/bin/bash

#=============[ Start Hidden Storage Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "HIDDEN STORAGE"
echo -e "${NC}"

# Hidden Storage Menu
echo -e "${BLUE}╔════════════ HIDDEN STORAGE ════════════╗${NC}"
echo -e "${BLUE}║ [01] Setup Hidden Storage             ║${NC}"
echo -e "${BLUE}║ [02] View Hidden Storage Content      ║${NC}"
echo -e "${BLUE}║ [03] Clear Hidden Storage             ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Setup Hidden Storage
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Setup Hidden Storage         ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        HIDDEN_DIR="/root/vps_script/.JubairVault"
        mkdir -p "$HIDDEN_DIR"
        chmod 700 "$HIDDEN_DIR"
        
        # Move existing logs and backups to hidden storage
        mv /root/vps_script/*.log "$HIDDEN_DIR/" 2>/dev/null
        mv /root/backups/* "$HIDDEN_DIR/" 2>/dev/null
        echo -e "${GREEN}Hidden storage setup at $HIDDEN_DIR!${NC}"
        
        # Update script paths to use hidden storage
        sed -i "s#/root/vps_script/telegram_bot.log#$HIDDEN_DIR/telegram_bot.log#" /root/vps_script/telegram_bot.sh
        sed -i "s#/root/vps_script/speedtest_result.txt#$HIDDEN_DIR/speedtest_result.txt#" /root/vps_script/speedtest.sh
        sed -i "s#/root/backups#$HIDDEN_DIR#" /root/vps_script/backup_restore.sh
        echo -e "${GREEN}Scripts updated to use hidden storage!${NC}"
        sleep 2
        bash hidden_storage.sh
        ;;
    2)
        # View Hidden Storage Content
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║      View Hidden Storage Content     ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        HIDDEN_DIR="/root/vps_script/.JubairVault"
        if [ -d "$HIDDEN_DIR" ]; then
            ls -lh "$HIDDEN_DIR"
        else
            echo -e "${YELLOW}Hidden storage not set up!${NC}"
        fi
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash hidden_storage.sh
        fi
        ;;
    3)
        # Clear Hidden Storage
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Clear Hidden Storage          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        HIDDEN_DIR="/root/vps_script/.JubairVault"
        if [ -d "$HIDDEN_DIR" ]; then
            rm -rf "$HIDDEN_DIR"/*
            echo -e "${GREEN}Hidden storage cleared!${NC}"
        else
            echo -e "${YELLOW}Hidden storage not set up!${NC}"
        fi
        sleep 2
        bash hidden_storage.sh
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash hidden_storage.sh
        ;;
esac