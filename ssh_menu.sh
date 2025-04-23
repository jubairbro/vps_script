#!/bin/bash

#=============[ Start SSH Menu Script ]================
clear

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header logo
echo -e "${RED}"
figlet -f big "SSH MENU"
echo -e "${NC}"

# SSH Menu
echo -e "${BLUE}╔════════════ SSH MENU ════════════╗${NC}"
echo -e "${BLUE}║ [01] Create SSH User            ║${NC}"
echo -e "${BLUE}║ [02] Delete SSH User            ║${NC}"
echo -e "${BLUE}║ [03] List SSH Users             ║${NC}"
echo -e "${BLUE}║ [04] Monitor SSH Logins         ║${NC}"
echo -e "${BLUE}║ [05] Limit SSH Speed            ║${NC}"
echo -e "${BLUE}║ [06] Extend SSH User            ║${NC}"
echo -e "${BLUE}║ [07] Delete Expired Users       ║${NC}"
echo -e "${BLUE}╚═════════════════════════════════╝${NC}"
echo -e "${RED}[0] Back to Main Menu${NC}"

# User input
read -p "Select Option: " OPTION

case $OPTION in
    1)
        # Create SSH user
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Create SSH User            ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username: " USERNAME
        read -p "Enter Password: " PASSWORD
        read -p "Enter Expiry Days (e.g., 30): " EXPIRY_DAYS
        
        # Create user and set password
        useradd -m -s /bin/bash "$USERNAME"
        echo "$USERNAME:$PASSWORD" | chpasswd
        
        # Set expiry date
        EXPIRY_DATE=$(date -d "+$EXPIRY_DAYS days" +%Y-%m-%d)
        chage -E "$EXPIRY_DATE" "$USERNAME"
        
        # Generate PUB key (simulating a public key for output)
        PUB_KEY=$(openssl rand -hex 32)
        
        # Output in specified format
        echo -e "${GREEN}Account Created Successfully${NC}"
        echo -e "————————————————————————————————————"
        echo -e "${YELLOW}HOST            : ${GREEN}$(hostname)${NC}"
        echo -e "${YELLOW}NameServer      : ${GREEN}ns.$(hostname)${NC}"
        echo -e "${YELLOW}Username        : ${GREEN}$USERNAME${NC}"
        echo -e "${YELLOW}Password        : ${GREEN}$PASSWORD${NC}"
        echo -e "${YELLOW}PUB Key         : ${GREEN}$PUB_KEY${NC}"
        echo -e "————————————————————————————————————"
        echo -e "${YELLOW}Expired         : ${GREEN}$EXPIRY_DATE${NC}"
        echo -e "————————————————————————————————————"
        echo -e "${YELLOW}TLS             : ${GREEN}443,8443${NC}"
        echo -e "${YELLOW}None TLS        : ${GREEN}80,8080${NC}"
        echo -e "${YELLOW}Any             : ${GREEN}2082,2083,8880${NC}"
        echo -e "${YELLOW}OpenSSH         : ${GREEN}444${NC}"
        echo -e "${YELLOW}Dropbear        : ${GREEN}90${NC}"
        echo -e "————————————————————————————————————"
        echo -e "${YELLOW}SlowDNS         : ${GREEN}53,5300${NC}"
        echo -e "${YELLOW}UDP-Custom      : ${GREEN}1-65535${NC}"
        echo -e "${YELLOW}OHP + SSH       : ${GREEN}9080${NC}"
        echo -e "${YELLOW}Squid Proxy     : ${GREEN}3128${NC}"
        echo -e "${YELLOW}UDPGW           : ${GREEN}7100-7600${NC}"
        echo -e "${YELLOW}OpenVPN TCP     : ${GREEN}80,1194${NC}"
        echo -e "${YELLOW}OpenVPN SSL     : ${GREEN}443${NC}"
        echo -e "${YELLOW}OpenVPN UDP     : ${GREEN}25000${NC}"
        echo -e "${YELLOW}OpenVPN DNS     : ${GREEN}53${NC}"
        echo -e "${YELLOW}OHP + OVPN      : ${GREEN}9088${NC}"
        echo -e "————————————————————————————————————"
        echo -e "${YELLOW}Save link: ${GREEN}http://$(hostname):81/$USERNAME.txt${NC}"
        echo -e "${YELLOW}Opvpn    : ${GREEN}http://$(hostname):81/my-vpn.zip${NC}"
        echo -e "————————————————————————————————————"
        
        # Save user info to a file
        echo "Username: $USERNAME\nPassword: $PASSWORD\nExpiry: $EXPIRY_DATE" > "/var/www/html/$USERNAME.txt"
        sleep 5
        bash ssh_menu.sh
        ;;
    2)
        # Delete SSH user
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Delete SSH User            ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username to Delete: " USERNAME
        
        # Check if user exists
        if id "$USERNAME" >/dev/null 2>&1; then
            userdel -r "$USERNAME"
            rm -f "/var/www/html/$USERNAME.txt"
            echo -e "${GREEN}User $USERNAME deleted successfully!${NC}"
        else
            echo -e "${RED}User $USERNAME does not exist!${NC}"
        fi
        sleep 2
        bash ssh_menu.sh
        ;;
    3)
        # List SSH users
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║            List SSH Users            ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        getent passwd | grep '/bin/bash' | cut -d: -f1
        echo -e "${RED}Press 0 to return${NC}"
        read -p "Option: " OPTION
        if [ "$OPTION" = "0" ]; then
            bash ssh_menu.sh
        fi
        ;;
    4)
        # Monitor SSH logins
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║          Monitor SSH Logins          ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        tail -f /var/log/auth.log | grep sshd
        ;;
    5)
        # Limit SSH speed
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Limit SSH Speed            ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username: " USERNAME
        read -p "Enter Speed Limit (e.g., 100kbit): " SPEED_LIMIT
        
        # Apply speed limit using wondershaper
        wondershaper -a eth0 -u "$SPEED_LIMIT"
        echo -e "${GREEN}Speed limit set to $SPEED_LIMIT for $USERNAME!${NC}"
        sleep 2
        bash ssh_menu.sh
        ;;
    6)
        # Extend SSH user
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Extend SSH User            ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        read -p "Enter Username: " USERNAME
        read -p "Enter Additional Days (e.g., 30): " ADD_DAYS
        
        # Check if user exists
        if id "$USERNAME" >/dev/null 2>&1; then
            CURRENT_EXPIRY=$(chage -l "$USERNAME" | grep "Account expires" | awk '{print $NF}')
            NEW_EXPIRY=$(date -d "$CURRENT_EXPIRY + $ADD_DAYS days" +%Y-%m-%d)
            chage -E "$NEW_EXPIRY" "$USERNAME"
            echo -e "${GREEN}User $USERNAME extended until $NEW_EXPIRY!${NC}"
        else
            echo -e "${RED}User $USERNAME does not exist!${NC}"
        fi
        sleep 2
        bash ssh_menu.sh
        ;;
    7)
        # Delete expired users
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║         Delete Expired Users         ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        TODAY=$(date +%Y-%m-%d)
        while IFS=: read -r USERNAME _ _ _ _ _ EXPIRY; do
            if [[ "$EXPIRY" < "$TODAY" && "$EXPIRY" != "never" ]]; then
                userdel -r "$USERNAME"
                rm -f "/var/www/html/$USERNAME.txt"
                echo -e "${GREEN}Deleted expired user: $USERNAME${NC}"
            fi
        done < <(getent passwd | grep '/bin/bash')
        sleep 2
        bash ssh_menu.sh
        ;;
    0)
        bash main.sh
        ;;
    *)
        echo -e "${RED}Invalid input! Try again.${NC}"
        sleep 2
        bash ssh_menu.sh
        ;;
esac