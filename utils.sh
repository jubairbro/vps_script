#!/bin/bash

# Common color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to display headers
display_header() {
    local title=$1
    echo -e "${BLUE}╔═════════════════════════════╗${NC}"
    echo -e "${BLUE}║           $title            ║${NC}"
    echo -e "${BLUE}╚═════════════════════════════╝${NC}"
}

# Function to check service status
check_service() {
    local service=$1
    systemctl is-active --quiet "$service"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}$service is running${NC}"
    else
        echo -e "${RED}$service is not running${NC}"
        return 1
    fi
    return 0
}

# Input validation functions
validate_domain() {
    local domain=$1
    if ! echo "$domain" | grep -qE '^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$'; then
        echo -e "${RED}Invalid domain: $domain${NC}"
        return 1
    fi
    return 0
}

validate_port() {
    local port=$1
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}Invalid port: $port (must be between 1 and 65535)${NC}"
        return 1
    fi
    return 0
}

validate_uuid() {
    local uuid=$1
    if ! echo "$uuid" | grep -qE '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'; then
        echo -e "${RED}Invalid UUID: $uuid${NC}"
        return 1
    fi
    return 0
}

# Function to display logo
display_logo() {
    echo -e "${GREEN}"
    toilet -f mono9 -F gay "VPS PANEL"
    echo -e "${YELLOW}Version: v2.1 Ultimate${NC}"
    echo -e "${YELLOW}Developer: Jubair | Telegram: @JubairFF${NC}"
    echo -e "${NC}"
}

# Display system and network info
display_system_info() {
    # System Info
    OS=$( [ -f /etc/os-release ] && . /etc/os-release && echo "$NAME $VERSION_ID" || echo "Unknown OS" )
    UPTIME=$(uptime -p | sed 's/up //')
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | awk '{printf "%.1f%%", $1}')
    MEM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
    MEM_USED=$(free -h | grep Mem | awk '{print $3}')
    DISK_TOTAL=$(df -h / | tail -1 | awk '{print $2}')
    DISK_USED=$(df -h / | tail -1 | awk '{print $3}')

    # Network Info
    PUBLIC_IP=$(curl -s ifconfig.me || echo "Unable to fetch")
    PRIVATE_IP=$(ip -4 addr show | grep inet | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -1 || echo "Unknown")
    GATEWAY=$(ip route | grep default | awk '{print $3}' || echo "Unknown")

    echo -e "${YELLOW}╔═════════════════════════════╗${NC}"
    echo -e "${YELLOW}║        System Info          ║${NC}"
    echo -e "${YELLOW}╠═════════════════════════════╣${NC}"
    echo -e "${YELLOW}║ OS: %-23s ║${NC}" "$OS"
    echo -e "${YELLOW}║ Uptime: %-19s ║${NC}" "$UPTIME"
    echo -e "${YELLOW}║ CPU Usage: %-16s ║${NC}" "$CPU_USAGE"
    echo -e "${YELLOW}║ Memory: %-10s / %-8s ║${NC}" "$MEM_USED" "$MEM_TOTAL"
    echo -e "${YELLOW}║ Disk: %-12s / %-8s ║${NC}" "$DISK_USED" "$DISK_TOTAL"
    echo -e "${YELLOW}╠═════════════════════════════╣${NC}"
    echo -e "${YELLOW}║        Network Info         ║${NC}"
    echo -e "${YELLOW}╠═════════════════════════════╣${NC}"
    echo -e "${YELLOW}║ Public IP: %-16s ║${NC}" "$PUBLIC_IP"
    echo -e "${YELLOW}║ Private IP: %-15s ║${NC}" "$PRIVATE_IP"
    echo -e "${YELLOW}║ Gateway: %-17s ║${NC}" "$GATEWAY"
    echo -e "${YELLOW}╚═════════════════════════════╝${NC}"
}