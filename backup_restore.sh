#!/bin/bash

#=============[ Start Backup & Restore Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "BACKUP & RESTORE"
echo -e "${NC}"

# Backup & Restore Menu
echo -e "${BLUE}╔════════════ BACKUP & RESTORE ════════╗${NC}"
echo -e "${BLUE}║ [01] Create Backup                 ║${NC}"
echo -e "${BLUE}║ [02] Restore Backup                ║${NC}"
echo -e "${BLUE}║ [03] List Backups                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Create backup
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Create Backup              ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        BACKUP_DIR="/root/backups"
        BACKUP_FILE="vps_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
        mkdir -p "$BACKUP_DIR"
        
        # Backup important files
        tar -czf "$BACKUP_DIR/$BACKUP_FILE" /etc/xray /root/vps_script /var/log
        echo -e "${GREEN}Backup created successfully: $BACKUP_FILE${NC}"
        sleep 2
        bash backup_restore.sh
        ;;
    2)
        # Restore backup
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Restore Backup             ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        BACKUP_DIR="/root/backups"
        ls -lh "$BACKUP_DIR"
        read -p "Enter Backup File Name to Restore: " BACKUP_FILE
        
        # Restore backup
        if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
            tar -xzf "$BACKUP_DIR/$BACKUP_FILE" -C /
            systemctl restart xray
            echo -e "${GREEN}Backup restored successfully!${NC}"
        else
            echo -e "${RED}Backup file not found!${NC}"
        fi
        sleep 2
        bash backup_restore.sh
        ;;
    3)
        # List backups
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║            List Backups              ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        ls -lh /root/backups
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash backup_restore.sh
        fi
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash backup_restore.sh
        ;;
esac