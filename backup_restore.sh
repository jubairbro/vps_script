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

# Display Backup & Restore menu
display_header "Backup & Restore Menu"
echo -e "${BLUE}║ [1] Create Backup           ║${NC}"
echo -e "${BLUE}║ [2] Restore Backup          ║${NC}"
echo -e "${BLUE}║ [3] List Backups            ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash backup_restore.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Create Backup"
        BACKUP_DIR="/root/backups"
        BACKUP_FILE="$BACKUP_DIR/backup_$(date +%F_%H-%M-%S).tar.gz"
        tar -czf "$BACKUP_FILE" /etc/xray /root/vps_script || {
            echo -e "${RED}Failed to create backup!${NC}"
            sleep 2
            bash backup_restore.sh
        }
        echo -e "${GREEN}Backup created successfully: $BACKUP_FILE${NC}"
        sleep 2
        bash backup_restore.sh
        ;;
    2)
        clear
        display_header "Restore Backup"
        BACKUP_DIR="/root/backups"
        echo -e "${YELLOW}Available backups:${NC}"
        ls -1 "$BACKUP_DIR" | grep ".tar.gz" | while read -r backup; do
            echo -e "${GREEN}$backup${NC}"
        done
        read -p "Enter backup file name to restore: " BACKUP_FILE
        if [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
            echo -e "${RED}Backup file $BACKUP_FILE not found!${NC}"
            sleep 2
            bash backup_restore.sh
        fi
        tar -xzf "$BACKUP_DIR/$BACKUP_FILE" -C / || {
            echo -e "${RED}Failed to restore backup!${NC}"
            sleep 2
            bash backup_restore.sh
        }
        systemctl restart xray || {
            echo -e "${RED}Failed to restart Xray service after restore!${NC}"
            sleep 2
            bash backup_restore.sh
        }
        echo -e "${GREEN}Backup $BACKUP_FILE restored successfully!${NC}"
        sleep 2
        bash backup_restore.sh
        ;;
    3)
        clear
        display_header "List Backups"
        BACKUP_DIR="/root/backups"
        echo -e "${YELLOW}Available backups:${NC}"
        ls -1 "$BACKUP_DIR" | grep ".tar.gz" | while read -r backup; do
            echo -e "${GREEN}$backup${NC}"
        done
        read -p "Press Enter to continue..."
        bash backup_restore.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash backup_restore.sh
        ;;
esac