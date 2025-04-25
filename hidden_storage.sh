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

# Display Hidden Storage menu
display_header "Hidden Storage Menu"
echo -e "${BLUE}║ [1] Create Hidden File      ║${NC}"
echo -e "${BLUE}║ [2] View Hidden File        ║${NC}"
echo -e "${BLUE}║ [3] Delete Hidden File      ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash hidden_storage.sh
fi

# Hidden storage directory
HIDDEN_DIR="/root/vps_script/.JubairVault/hidden"

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Create Hidden File"
        mkdir -p "$HIDDEN_DIR" || {
            echo -e "${RED}Failed to create hidden directory!${NC}"
            sleep 2
            bash hidden_storage.sh
        }
        chmod 700 "$HIDDEN_DIR" || {
            echo -e "${RED}Failed to set permissions for hidden directory!${NC}"
            sleep 2
            bash hidden_storage.sh
        }
        read -p "Enter file name: " FILENAME
        if [ -z "$FILENAME" ]; then
            echo -e "${RED}File name cannot be empty!${NC}"
            sleep 2
            bash hidden_storage.sh
        fi
        read -p "Enter content to store: " CONTENT
        if [ -z "$CONTENT" ]; then
            echo -e "${RED}Content cannot be empty!${NC}"
            sleep 2
            bash hidden_storage.sh
        fi
        echo "$CONTENT" > "$HIDDEN_DIR/$FILENAME" || {
            echo -e "${RED}Failed to create hidden file!${NC}"
            sleep 2
            bash hidden_storage.sh
        }
        echo -e "${GREEN}Hidden file $FILENAME created successfully!${NC}"
        sleep 2
        bash hidden_storage.sh
        ;;
    2)
        clear
        display_header "View Hidden File"
        if [ ! -d "$HIDDEN_DIR" ] || [ -z "$(ls -A $HIDDEN_DIR)" ]; then
            echo -e "${RED}No hidden files found!${NC}"
            sleep 2
            bash hidden_storage.sh
        fi
        echo -e "${YELLOW}Available hidden files:${NC}"
        ls -1 "$HIDDEN_DIR" | while read -r file; do
            echo -e "${GREEN}$file${NC}"
        done
        read -p "Enter file name to view: " FILENAME
        if [ ! -f "$HIDDEN_DIR/$FILENAME" ]; then
            echo -e "${RED}File $FILENAME not found!${NC}"
            sleep 2
            bash hidden_storage.sh
        fi
        echo -e "${YELLOW}Content of $FILENAME:${NC}"
        cat "$HIDDEN_DIR/$FILENAME" || {
            echo -e "${RED}Failed to read hidden file!${NC}"
            sleep 2
            bash hidden_storage.sh
        }
        read -p "Press Enter to continue..."
        bash hidden_storage.sh
        ;;
    3)
        clear
        display_header "Delete Hidden File"
        if [ ! -d "$HIDDEN_DIR" ] || [ -z "$(ls -A $HIDDEN_DIR)" ]; then
            echo -e "${RED}No hidden files found!${NC}"
            sleep 2
            bash hidden_storage.sh
        fi
        echo -e "${YELLOW}Available hidden files:${NC}"
        ls -1 "$HIDDEN_DIR" | while read -r file; do
            echo -e "${GREEN}$file${NC}"
        done
        read -p "Enter file name to delete: " FILENAME
        if [ ! -f "$HIDDEN_DIR/$FILENAME" ]; then
            echo -e "${RED}File $FILENAME not found!${NC}"
            sleep 2
            bash hidden_storage.sh
        fi
        rm "$HIDDEN_DIR/$FILENAME" || {
            echo -e "${RED}Failed to delete hidden file!${NC}"
            sleep 2
            bash hidden_storage.sh
        }
        echo -e "${GREEN}Hidden file $FILENAME deleted successfully!${NC}"
        sleep 2
        bash hidden_storage.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash hidden_storage.sh
        ;;
esac