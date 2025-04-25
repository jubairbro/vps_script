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
#=============[ Setup Domain and Nameserver ]================
setup_domain_and_ns() {
    clear
    display_header "Setting Up Domain and Nameserver"

    # Check if domain is already set
    if [ -f /etc/vps_script/domain ]; then
        CURRENT_DOMAIN=$(cat /etc/vps_script/domain)
        echo -e "${YELLOW}Current domain: $CURRENT_DOMAIN${NC}"
        echo -e "${YELLOW}Do you want to change the domain? (y/n):${NC}"
        read -p "Choice: " CHANGE_DOMAIN
        if [ "$CHANGE_DOMAIN" != "y" ]; then
            echo -e "${GREEN}Keeping current domain: $CURRENT_DOMAIN${NC}"
            export DOMAIN=$CURRENT_DOMAIN
        else
            # Prompt user for domain name
            echo -e "${YELLOW}Please enter your domain name (e.g., example.com):${NC}"
            read -p "Domain: " DOMAIN
            if [ -z "$DOMAIN" ]; then
                echo -e "${RED}Domain name cannot be empty!${NC}"
                sleep 2
                bash main.sh
                return 1
            fi

            # Advanced domain format validation
            if ! echo "$DOMAIN" | grep -qE '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; then
                echo -e "${RED}Invalid domain format! Please enter a valid domain (e.g., example.com).${NC}"
                sleep 2
                bash main.sh
                return 1
            fi
            echo -e "${GREEN}Domain set to: $DOMAIN${NC}"

            # Save domain to a file
            mkdir -p /etc/vps_script
            echo "$DOMAIN" > /etc/vps_script/domain
        fi
    else
        # Prompt user for domain name
        echo -e "${YELLOW}Please enter your domain name (e.g., example.com):${NC}"
        read -p "Domain: " DOMAIN
        if [ -z "$DOMAIN" ]; then
            echo -e "${RED}Domain name cannot be empty!${NC}"
            sleep 2
            bash main.sh
            return 1
        fi

        # Advanced domain format validation
        if ! echo "$DOMAIN" | grep -qE '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; then
            echo -e "${RED}Invalid domain format! Please enter a valid domain (e.g., example.com).${NC}"
            sleep 2
            bash main.sh
            return 1
        fi
        echo -e "${GREEN}Domain set to: $DOMAIN${NC}"

        # Save domain to a file
        mkdir -p /etc/vps_script
        echo "$DOMAIN" > /etc/vps_script/domain
    fi

    # Get the VPS public IP
    PUBLIC_IP=$(curl -s ifconfig.me)
    if [ -z "$PUBLIC_IP" ]; then
        echo -e "${RED}Failed to detect VPS public IP!${NC}"
        sleep 2
        bash main.sh
        return 1
    fi
    echo -e "${GREEN}VPS Public IP: $PUBLIC_IP${NC}"

    # Check if domain resolves to the VPS IP (requires 'dnsutils')
    if command -v dig &> /dev/null; then
        RESOLVED_IP=$(dig +short "$DOMAIN" | tail -1)
        if [ -z "$RESOLVED_IP" ]; then
            echo -e "${YELLOW}Warning: Could not resolve domain $DOMAIN. Ensure DNS is configured correctly.${NC}"
        elif [ "$RESOLVED_IP" != "$PUBLIC_IP" ]; then
            echo -e "${YELLOW}Warning: Domain $DOMAIN resolves to $RESOLVED_IP, but VPS IP is $PUBLIC_IP.${NC}"
            echo -e "${YELLOW}Please update your domain's A record to point to $PUBLIC_IP.${NC}"
        else
            echo -e "${GREEN}Domain $DOMAIN resolves to $PUBLIC_IP - OK${NC}"
        fi
    else
        echo -e "${YELLOW}dig command not found. Installing dnsutils for domain resolution check...${NC}"
        apt install -y dnsutils || {
            echo -e "${RED}Failed to install dnsutils! Skipping domain resolution check.${NC}"
        }
        if command -v dig &> /dev/null; then
            RESOLVED_IP=$(dig +short "$DOMAIN" | tail -1)
            if [ -z "$RESOLVED_IP" ]; then
                echo -e "${YELLOW}Warning: Could not resolve domain $DOMAIN. Ensure DNS is configured correctly.${NC}"
            elif [ "$RESOLVED_IP" != "$PUBLIC_IP" ]; then
                echo -e "${YELLOW}Warning: Domain $DOMAIN resolves to $RESOLVED_IP, but VPS IP is $PUBLIC_IP.${NC}"
                echo -e "${YELLOW}Please update your domain's A record to point to $PUBLIC_IP.${NC}"
            else
                echo -e "${GREEN}Domain $DOMAIN resolves to $PUBLIC_IP - OK${NC}"
            fi
        else
            echo -e "${YELLOW}Unable to install dig. Skipping domain resolution check...${NC}"
            echo -e "${YELLOW}Please ensure your domain's A record points to $PUBLIC_IP.${NC}"
        fi
    fi

    # Setup nameservers
    echo -e "${YELLOW}Current nameservers in /etc/resolv.conf:${NC}"
    cat /etc/resolv.conf || echo -e "${RED}Failed to read /etc/resolv.conf!${NC}"
    echo -e "${YELLOW}Do you want to change the nameservers? (y/n):${NC}"
    read -p "Choice: " CHANGE_NS
    if [ "$CHANGE_NS" = "y" ]; then
        echo -e "${YELLOW}Enter the first nameserver (e.g., 8.8.8.8 for Google DNS, or kenneth.ns.cloudflare.com):${NC}"
        read -p "Nameserver 1: " NS1
        if [ -z "$NS1" ]; then
            echo -e "${RED}Nameserver cannot be empty! Using default Google DNS (8.8.8.8).${NC}"
            NS1="8.8.8.8"
        fi
        echo -e "${YELLOW}Enter the second nameserver (e.g., 8.8.4.4 for Google DNS, press Enter to skip):${NC}"
        read -p "Nameserver 2: " NS2

        # Validate nameservers (basic check for IP or domain format)
        if ! echo "$NS1" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$|^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; then
            echo -e "${RED}Invalid nameserver format for NS1! Using default Google DNS (8.8.8.8).${NC}"
            NS1="8.8.8.8"
        fi
        if [ ! -z "$NS2" ] && ! echo "$NS2" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$|^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; then
            echo -e "${RED}Invalid nameserver format for NS2! Skipping NS2.${NC}"
            NS2=""
        fi

        # Update /etc/resolv.conf
        echo "nameserver $NS1" > /etc/resolv.conf
        if [ ! -z "$NS2" ]; then
            echo "nameserver $NS2" >> /etc/resolv.conf
        fi
        echo -e "${GREEN}Nameservers updated:${NC}"
        cat /etc/resolv.conf
    else
        echo -e "${GREEN}Keeping current nameservers.${NC}"
    fi

    # Update NGINX configuration if exists
    if [ -f /etc/nginx/conf.d/vps.conf ]; then
        cat > /etc/nginx/conf.d/vps.conf << EOL
server {
    listen 80;
    server_name $DOMAIN;
    location /vmess {
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
    location /vless {
        proxy_pass http://127.0.0.1:10001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
    location /trojan {
        proxy_pass http://127.0.0.1:10002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOL

        # Setup SSL with Let's Encrypt (optional)
        echo -e "${YELLOW}Do you want to setup SSL with Let's Encrypt? (y/n):${NC}"
        read -p "Choice: " SETUP_SSL
        if [ "$SETUP_SSL" = "y" ]; then
            echo -e "${YELLOW}Installing certbot for Let's Encrypt...${NC}"
            apt install -y certbot python3-certbot-nginx || {
                echo -e "${RED}Failed to install certbot! SSL setup skipped.${NC}"
            }
            if command -v certbot &> /dev/null; then
                echo -e "${YELLOW}Setting up SSL for $DOMAIN...${NC}"
                certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email admin@$DOMAIN || {
                    echo -e "${RED}Failed to setup SSL with Let's Encrypt! Proceeding without SSL.${NC}"
                }
                if [ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]; then
                    echo -e "${GREEN}SSL setup successful! HTTPS enabled for $DOMAIN.${NC}"
                else
                    echo -e "${YELLOW}SSL setup failed. Proceeding with HTTP only.${NC}"
                fi
            else
                echo -e "${YELLOW}certbot not found. Skipping SSL setup...${NC}"
            fi
        else
            echo -e "${GREEN}Skipping SSL setup. Proceeding with HTTP only.${NC}"
        fi

        # Restart NGINX
        if command -v systemctl &> /dev/null; then
            systemctl restart nginx || echo -e "${RED}Failed to restart NGINX!${NC}"
        elif command -v service &> /dev/null; then
            service nginx restart || echo -e "${RED}Failed to restart NGINX!${NC}"
        fi
        echo -e "${GREEN}NGINX configuration updated with domain $DOMAIN.${NC}"
    fi

    # Update HAProxy configuration if exists
    if [ -f /etc/haproxy/haproxy.cfg ]; then
        SSL_CERT=""
        if [ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]; then
            SSL_CERT="/etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/letsencrypt/live/$DOMAIN/privkey.pem"
            echo -e "${GREEN}SSL certificate found for $DOMAIN. Configuring HAProxy with HTTPS...${NC}"
        else
            echo -e "${YELLOW}No SSL certificate found. Configuring HAProxy with HTTP only...${NC}"
        fi

        cat > /etc/haproxy/haproxy.cfg << EOL
global
    log /dev/log local0
    maxconn 4096
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode tcp
    option tcplog
    timeout connect 5000
    timeout client 50000
    timeout server 50000

frontend http_front
    bind *:80
    mode http
    $([ -z "$SSL_CERT" ] || echo "redirect scheme https code 301 if !{ ssl_fc }")
    default_backend http_back

frontend https_front
    $([ -z "$SSL_CERT" ] || echo "bind *:443 ssl crt $SSL_CERT")
    mode tcp
    default_backend ws_back

backend http_back
    mode http
    balance roundrobin
    server backend1 127.0.0.1:10000 check

backend ws_back
    mode tcp
    balance roundrobin
    server ws1 127.0.0.1:10000 check
EOL

        # Restart HAProxy
        if command -v systemctl &> /dev/null; then
            systemctl restart haproxy || echo -e "${RED}Failed to restart HAProxy!${NC}"
        elif command -v service &> /dev/null; then
            service haproxy restart || echo -e "${RED}Failed to restart HAProxy!${NC}"
        fi
        echo -e "${GREEN}HAProxy configuration updated with domain $DOMAIN.${NC}"
    fi

    sleep 2
    bash main.sh
}
