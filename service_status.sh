#!/bin/bash

#=============[ Start Service Status Check ]================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Service Status             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"

# SSH status
SSH_STATUS=$(systemctl is-active ssh)
if [ "$SSH_STATUS" = "active" ]; then
    echo -e "${YELLOW}SSH        : ${GREEN}ON${NC}"
else
    echo -e "${YELLOW}SSH        : ${RED}OFF${NC}"
fi

# OpenVPN status
OPENVPN_STATUS=$(systemctl is-active openvpn@server)
if [ "$OPENVPN_STATUS" = "active" ]; then
    echo -e "${YELLOW}OpenVPN    : ${GREEN}ON${NC}"
else
    echo -e "${YELLOW}OpenVPN    : ${RED}OFF${NC}"
fi

# VMess status
VMESS_STATUS=$(netstat -tuln | grep -q ":10000" && echo "active" || echo "inactive")
if [ "$VMESS_STATUS" = "active" ]; then
    echo -e "${YELLOW}VMess      : ${GREEN}ON${NC}"
else
    echo -e "${YELLOW}VMess      : ${RED}OFF${NC}"
fi

# VLess status
VLESS_STATUS=$(netstat -tuln | grep -q ":10001" && echo "active" || echo "inactive")
if [ "$VLESS_STATUS" = "active" ]; then
    echo -e "${YELLOW}VLess      : ${GREEN}ON${NC}"
else
    echo -e "${YELLOW}VLess      : ${RED}OFF${NC}"
fi

# Trojan status
TROJAN_STATUS=$(netstat -tuln | grep -q ":10002" && echo "active" || echo "inactive")
if [ "$TROJAN_STATUS" = "active" ]; then
    echo -e "${YELLOW}Trojan     : ${GREEN}ON${NC}"
else
    echo -e "${YELLOW}Trojan     : ${RED}OFF${NC}"
fi

# Shadowsocks status
SHADOWSOCKS_STATUS=$(netstat -tuln | grep -q ":10003" && echo "active" || echo "inactive")
if [ "$SHADOWSOCKS_STATUS" = "active" ]; then
    echo -e "${YELLOW}Shadowsocks: ${GREEN}ON${NC}"
else
    echo -e "${YELLOW}Shadowsocks: ${RED}OFF${NC}"
fi

# NGINX status
NGINX_STATUS=$(systemctl is-active nginx)
if [ "$NGINX_STATUS" = "active" ]; then
    echo -e "${YELLOW}NGINX      : ${GREEN}ON${NC}"
else
    echo -e "${YELLOW}NGINX      : ${RED}OFF${NC}"
fi

# HAProxy status
HAPROXY_STATUS=$(systemctl is-active haproxy)
if [ "$HAPROXY_STATUS" = "active" ]; then
    echo -e "${YELLOW}HAProxy    : ${GREEN}ON${NC}"
else
    echo -e "${YELLOW}HAProxy    : ${RED}OFF${NC}"
fi

# SlowDNS status
SLOWDNS_STATUS=$(systemctl is-active slowdns)
if [ "$SLOWDNS_STATUS" = "active" ]; then
    echo -e "${YELLOW}SlowDNS    : ${GREEN}ON${NC}"
else
    echo -e "${YELLOW}SlowDNS    : ${RED}OFF${NC}"
fi

echo -e "${RED}Press 0 to return${NC}"
read -p "Option: " OPTION
if [ "$OPTION" = "0" ]; then
    bash main.sh
fi