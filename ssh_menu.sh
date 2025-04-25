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

# Display SSH menu
display_header "SSH Menu"
echo -e "${BLUE}║ [1] Create SSH User         ║${NC}"
echo -e "${BLUE}║ [2] Delete SSH User         ║${NC}"
echo -e "${BLUE}║ [3] List SSH Users          ║${NC}"
echo -e "${BLUE}║ [0] Back to Main Menu       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash ssh_menu.sh
fi

case $OPTION in
    0)
        bash main.sh
        ;;
    1)
        clear
        display_header "Create SSH User"
        read -p "Enter username: " USERNAME
        if [ -z "$USERNAME" ]; then
            echo -e "${RED}Username cannot be empty!${NC}"
            sleep 2
            bash ssh_menu.sh
        fi
        if id "$USERNAME" >/dev/null 2>&1; then
            echo -e "${RED}User $USERNAME already exists!${NC}"
            sleep 2
            bash ssh_menu.sh
        fi
        read -p "Enter password: " PASSWORD
        if [ -z "$PASSWORD" ]; then
            echo -e "${RED}Password cannot be empty!${NC}"
            sleep 2
            bash ssh_menu.sh
        fi
        useradd -m -s /bin/bash "$USERNAME" || {
            echo -e "${RED}Failed to create user $USERNAME!${NC}"
            sleep 2
            bash ssh_menu.sh
        }
        echo "$USERNAME:$PASSWORD" | chpasswd || {
            echo -e "${RED}Failed to set password for user $USERNAME!${NC}"
            sleep 2
            bash ssh_menu.sh
        }
        echo -e "${GREEN}User $USERNAME created successfully!${NC}"
        sleep 2
        bash ssh_menu.sh
        ;;
    2)
        clear
        display_header "Delete SSH User"
        read -p "Enter username to delete: " USERNAME
        if [ -z "$USERNAME" ]; then
            echo -e "${RED}Username cannot be empty!${NC}"
            sleep 2
            bash ssh_menu.sh
        fi
        if ! id "$USERNAME" >/dev/null 2>&1; then
            echo -e "${RED}User $USERNAME does not exist!${NC}"
            sleep 2
            bash ssh_menu.sh
        fi
        userdel -r "$USERNAME" || {
            echo -e "${RED}Failed to delete user $USERNAME!${NC}"
            sleep 2
            bash ssh_menu.sh
        }
        echo -e "${GREEN}User $USERNAME deleted successfully!${NC}"
        sleep 2
        bash ssh_menu.sh
        ;;
    3)
        clear
        display_header "List SSH Users"
        getent passwd | grep '/bin/bash' | cut -d: -f1 | while read -r user; do
            echo -e "${GREEN}$user${NC}"
        done
        read -p "Press Enter to continue..."
        bash ssh_menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 3.${NC}"
        sleep 2
        bash ssh_menu.sh
        ;;
esac