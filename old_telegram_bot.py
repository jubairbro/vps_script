#!/usr/bin/env python3

#=============[ Start Telegram Bot ]================
import logging
import os
import subprocess
import json
from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes
from datetime import datetime, timedelta

# Logging setup
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO
)
logger = logging.getLogger(__name__)

# Telegram bot token
BOT_TOKEN = "your-bot-token-here"

# Owner UID for verification
OWNER_UID = "your-owner-uid-here"

# Start command
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user = update.effective_user
    if str(user.id) != OWNER_UID:
        await update.message.reply_text("You are not authorized to use this bot!")
        return
    await update.message.reply_text(
        f"Hello {user.first_name}! I am your VPS Management Bot.\n"
        "Type /help to see the command list."
    )

# Help command
async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if str(update.effective_user.id) != OWNER_UID:
        await update.message.reply_text("You are not authorized to use this bot!")
        return
    await update.message.reply_text(
        "Command List:\n"
        "/start - Start the bot\n"
        "/status - Check service status\n"
        "/create_user - Create a new SSH user\n"
        "/delete_user - Delete an SSH user\n"
        "/bandwidth - View bandwidth usage\n"
        "/reboot - Reboot the VPS\n"
        "/check_expiry - Check and notify expired users"
    )

# Status command
async def status(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if str(update.effective_user.id) != OWNER_UID:
        await update.message.reply_text("You are not authorized to use this bot!")
        return
    ssh_status = subprocess.getoutput("systemctl is-active ssh")
    openvpn_status = subprocess.getoutput("systemctl is-active openvpn@server")
    xray_status = subprocess.getoutput("systemctl is-active xray")
    nginx_status = subprocess.getoutput("systemctl is-active nginx")
    haproxy_status = subprocess.getoutput("systemctl is-active haproxy")
    slowdns_status = subprocess.getoutput("systemctl is-active slowdns")
    
    await update.message.reply_text(
        f"Service Status:\n"
        f"SSH: {ssh_status}\n"
        f"OpenVPN: {openvpn_status}\n"
        f"Xray: {xray_status}\n"
        f"NGINX: {nginx_status}\n"
        f"HAProxy: {haproxy_status}\n"
        f"SlowDNS: {slowdns_status}"
    )

# Create user command
async def create_user(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if str(update.effective_user.id) != OWNER_UID:
        await update.message.reply_text("You are not authorized to use this bot!")
        return
    username = f"user_{update.effective_user.id}_{int(datetime.now().timestamp())}"
    password = f"pass_{int(datetime.now().timestamp())}"
    expiry_days = 30
    expiry_date = (datetime.now() + timedelta(days=expiry_days)).strftime("%Y-%m-%d")
    
    # Create SSH user
    subprocess.run(["useradd", "-m", "-s", "/bin/bash", username])
    subprocess.run(["sh", "-c", f"echo '{username}:{password}' | chpasswd"])
    subprocess.run(["chage", "-E", expiry_date, username])
    
    await update.message.reply_text(
        f"User created!\n"
        f"Username: {username}\n"
        f"Password: {password}\n"
        f"Expiry: {expiry_date}"
    )

# Delete user command
async def delete_user(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if str(update.effective_user.id) != OWNER_UID:
        await update.message.reply_text("You are not authorized to use this bot!")
        return
    username = context.args[0] if context.args else None
    if not username:
        await update.message.reply_text("Please provide a username: /delete_user <username>")
        return
    
    # Check if user exists
    result = subprocess.run(["id", username], capture_output=True, text=True)
    if result.returncode == 0:
        subprocess.run(["userdel", "-r", username])
        await update.message.reply_text(f"User {username} deleted successfully!")
    else:
        await update.message.reply_text(f"User {username} does not exist!")

# Bandwidth usage command
async def bandwidth(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if str(update.effective_user.id) != OWNER_UID:
        await update.message.reply_text("You are not authorized to use this bot!")
        return
    bandwidth = subprocess.getoutput("vnstat --oneline | cut -d';' -f11")
    await update.message.reply_text(f"Bandwidth Usage: {bandwidth}")

# Reboot command
async def reboot(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if str(update.effective_user.id) != OWNER_UID:
        await update.message.reply_text("You are not authorized to use this bot!")
        return
    await update.message.reply_text("Rebooting VPS...")
    subprocess.run(["reboot"])

# Check expiry and notify
async def check_expiry(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if str(update.effective_user.id) != OWNER_UID:
        await update.message.reply_text("You are not authorized to use this bot!")
        return
    today = datetime.now().strftime("%Y-%m-%d")
    expired_users = []
    
    # Check SSH users
    with open("/etc/passwd", "r") as passwd_file:
        for line in passwd_file:
            if "/bin/bash" in line:
                username = line.split(":")[0]
                expiry = subprocess.getoutput(f"chage -l {username} | grep 'Account expires' | awk '{print $NF}'")
                if expiry != "never" and expiry < today:
                    expired_users.append(username)
    
    # Check Xray users (VMess, VLess, etc.)
    for service in ["vmess", "vless", "trojan", "shadowsocks"]:
        with open(f"/root/vps_script/{service}_users.txt", "r") as f:
            for line in f:
                username, _, expiry = line.strip().split(":")
                if expiry < today:
                    expired_users.append(f"{username} ({service})")
    
    if expired_users:
        await update.message.reply_text(f"Expired Users:\n" + "\n".join(expired_users))
    else:
        await update.message.reply_text("No expired users found.")

# Server down alert (background job)
async def server_down_alert(context: ContextTypes.DEFAULT_TYPE) -> None:
    ssh_status = subprocess.getoutput("systemctl is-active ssh")
    if ssh_status != "active":
        await context.bot.send_message(chat_id=OWNER_UID, text="Alert: SSH service is down!")

# Main function
def main() -> None:
    application = Application.builder().token(BOT_TOKEN).build()

    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("help", help_command))
    application.add_handler(CommandHandler("status", status))
    application.add_handler(CommandHandler("create_user", create_user))
    application.add_handler(CommandHandler("delete_user", delete_user))
    application.add_handler(CommandHandler("bandwidth", bandwidth))
    application.add_handler(CommandHandler("reboot", reboot))
    application.add_handler(CommandHandler("check_expiry", check_expiry))

    # Add job for server down alert (every 5 minutes)
    application.job_queue.run_repeating(server_down_alert, interval=300, first=10)

    application.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == "__main__":
    main()
