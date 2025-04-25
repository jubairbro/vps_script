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

# Display system and network info
display_system_info

# Display Main Menu
display_header "Main Menu"
echo -e "${BLUE}║ [1] Service Status          ║${NC}"
echo -e "${BLUE}║ [2] SSH Menu                ║${NC}"
echo -e "${BLUE}║ [3] VMess Menu              ║${NC}"
echo -e "${BLUE}║ [4] VLess Menu              ║${NC}"
echo -e "${BLUE}║ [5] Trojan Menu             ║${NC}"
echo -e "${BLUE}║ [6] Shadowsocks Menu        ║${NC}"
echo -e "${BLUE}║ [7] Auto Reboot             ║${NC}"
echo -e "${BLUE}║ [8] Speedtest               ║${NC}"
echo -e "${BLUE}║ [9] Backup & Restore        ║${NC}"
echo -e "${BLUE}║ [10] Update Script          ║${NC}"
echo -e "${BLUE}║ [11] Bot Panel Menu         ║${NC}"
echo -e "${BLUE}║ [12] Log Manager            ║${NC}"
echo -e "${BLUE}║ [13] Change Theme           ║${NC}"
echo -e "${BLUE}║ [14] Telegram Join          ║${NC}"
echo -e "${BLUE}║ [15] Hidden Storage         ║${NC}"
echo -e "${BLUE}║ [16] User Stats             ║${NC}"
echo -e "${BLUE}║ [17] Cleanup                ║${NC}"
echo -e "${BLUE}║ [18] Firewall               ║${NC}"
echo -e "${BLUE}║ [19] Monitoring             ║${NC}"
echo -e "${BLUE}║ [20] Restart Services       ║${NC}"
echo -e "${BLUE}║ [21] Set Domain & Nameservers ║${NC}"  
echo -e "${BLUE}║ [0] Exit                    ║${NC}"
echo -e "${BLUE}╚═════════════════════════════╝${NC}"

# User input
read -p "Select Option: " OPTION

# Input validation
if ! [[ "$OPTION" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input! Please enter a number.${NC}"
    sleep 2
    bash main.sh
fi

case $OPTION in
    0)
        clear
        echo -e "${GREEN}Exiting VPS Panel...${NC}"
        exit 0
        ;;
    1)
        bash service_status.sh
        ;;
    2)
        bash ssh_menu.sh
        ;;
    3)
        bash vmess_menu.sh
        ;;
    4)
        bash vless_menu.sh
        ;;
    5)
        bash trojan_menu.sh
        ;;
    6)
        bash shadow_menu.sh
        ;;
    7)
        bash auto_reboot.sh
        ;;
    8)
        bash speedtest.sh
        ;;
    9)
        bash backup_restore.sh
        ;;
    10)
        bash update_script.sh
        ;;
    11)
        bash telegram_bot.sh
        ;;
    12)
        bash log_manager.sh
        ;;
    13)
        bash change_theme.sh
        ;;
    14)
        bash telegram_join.sh
        ;;
    15)
        bash hidden_storage.sh
        ;;
    16)
        bash user_stats.sh
        ;;
    17)
        bash cleanup.sh
        ;;
    18)
        bash firewall.sh
        ;;
    19)
        bash monitoring.sh
        ;;
    20)
        bash restart_services.sh
        ;;
    21)  # New Option Handler
        setup_domain_and_ns
        ;;
    *)
        echo -e "${RED}Invalid option! Please select a number between 0 and 21.${NC}"
        sleep 2
        bash main.sh
        ;;
esac
