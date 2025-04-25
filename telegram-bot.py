import os
import subprocess
import logging
import json
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes, ConversationHandler

# Configure logging
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

# Paths
CONFIG_FILE = "/root/vps_script/.JubairVault/bot_config.json"
WHITELIST_FILE = "/root/vps_script/.JubairVault/whitelist.txt"
LOG_FILE = "/root/vps_script/telegram-bot.log"

# Conversation states
SET_TOKEN, SET_CHAT_ID = range(2)

# Load or initialize bot configuration
def load_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, "r") as f:
            return json.load(f)
    return {"bot_token": None, "chat_id": None}

# Save bot configuration
def save_config(config):
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=4)

# Check if user is authorized
def is_authorized(user_id: int) -> bool:
    try:
        with open(WHITELIST_FILE, "r") as f:
            authorized_ids = f.read().splitlines()
        return str(user_id) in authorized_ids
    except Exception as e:
        logger.error(f"Error reading whitelist: {e}")
        return False

# Start command
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return
    await update.message.reply_text(
        "Welcome to VPS Panel Bot!\n"
        "Available Commands:\n"
        "/setconfig - Set bot token and chat ID\n"
        "/status - Check service status\n"
        "/restart - Restart services\n"
        "/speedtest - Run a speedtest\n"
        "/users - Show active users\n"
        "/logs - View recent logs\n"
        "/cancel - Cancel current operation"
    )

# Start configuration conversation
async def set_config(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return ConversationHandler.END
    await update.message.reply_text("Please provide the bot token:")
    return SET_TOKEN

# Set bot token
async def set_token(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    config = load_config()
    config["bot_token"] = update.message.text.strip()
    save_config(config)
    await update.message.reply_text("Bot token set successfully! Now provide the chat ID:")
    return SET_CHAT_ID

# Set chat ID
async def set_chat_id(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    config = load_config()
    chat_id = update.message.text.strip()
    if not chat_id.isdigit():
        await update.message.reply_text("Chat ID must be a number! Please try again:")
        return SET_CHAT_ID
    config["chat_id"] = chat_id
    save_config(config)
    await update.message.reply_text("Chat ID set successfully! Configuration complete.")
    return ConversationHandler.END

# Cancel configuration
async def cancel(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    await update.message.reply_text("Operation cancelled.")
    return ConversationHandler.END

# Status command
async def status(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return
    try:
        services = ["xray", "nginx", "openvpn@server", "dropbear", "haproxy", "slowdns"]
        response = "Service Status:\n"
        for service in services:
            status = subprocess.run(["systemctl", "is-active", service], capture_output=True, text=True).stdout.strip()
            response += f"{service}: {'Running' if status == 'active' else 'Not Running'}\n"
        await update.message.reply_text(response)
    except Exception as e:
        logger.error(f"Error checking status: {e}")
        await update.message.reply_text(f"Error checking status: {str(e)}")

# Restart command
async def restart(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return
    try:
        services = ["xray", "nginx", "openvpn@server", "dropbear", "haproxy", "slowdns"]
        response = "Restarting Services:\n"
        for service in services:
            subprocess.run(["systemctl", "restart", service], check=True)
            response += f"{service}: Restarted\n"
        await update.message.reply_text(response)
    except Exception as e:
        logger.error(f"Error restarting services: {e}")
        await update.message.reply_text(f"Error restarting services: {str(e)}")

# Speedtest command
async def speedtest(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return
    try:
        await update.message.reply_text("Running speedtest... Please wait.")
        result = subprocess.run(["speedtest-cli", "--simple"], capture_output=True, text=True).stdout.strip()
        await update.message.reply_text(f"Speedtest Result:\n{result}")
    except Exception as e:
        logger.error(f"Error running speedtest: {e}")
        await update.message.reply_text(f"Error running speedtest: {str(e)}")

# Users command
async def users(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return
    try:
        result = subprocess.run(["who"], capture_output=True, text=True).stdout.strip()
        if not result:
            await update.message.reply_text("No active users found.")
        else:
            await update.message.reply_text(f"Active Users:\n{result}")
    except Exception as e:
        logger.error(f"Error fetching users: {e}")
        await update.message.reply_text(f"Error fetching users: {str(e)}")

# Logs command
async def logs(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id
    if not is_authorized(user_id):
        await update.message.reply_text("You are not authorized to use this bot! Contact @JubairFF to get access.")
        return
    try:
        log_file = "/var/log/xray/error.log"
        if os.path.exists(log_file):
            with open(log_file, "r") as f:
                log_lines = f.readlines()[-10:]  # Last 10 lines
            logs = "".join(log_lines)
            await update.message.reply_text(f"Recent Xray Error Logs:\n{logs}")
        else:
            await update.message.reply_text("No Xray error logs found.")
    except Exception as e:
        logger.error(f"Error fetching logs: {e}")
        await update.message.reply_text(f"Error fetching logs: {str(e)}")

# Main function to run the bot
def main() -> None:
    config = load_config()
    bot_token = config.get("bot_token")
    if not bot_token:
        logger.error("Bot token not set! Please set it using /setconfig command.")
        return

    # Create the Application and pass it your bot's token
    application = Application.builder().token(bot_token).build()

    # Add command handlers
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("status", status))
    application.add_handler(CommandHandler("restart", restart))
    application.add_handler(CommandHandler("speedtest", speedtest))
    application.add_handler(CommandHandler("users", users))
    application.add_handler(CommandHandler("logs", logs))

    # Add conversation handler for setting config
    conv_handler = ConversationHandler(
        entry_points=[CommandHandler("setconfig", set_config)],
        states={
            SET_TOKEN: [MessageHandler(filters.TEXT & ~filters.COMMAND, set_token)],
            SET_CHAT_ID: [MessageHandler(filters.TEXT & ~filters.COMMAND, set_chat_id)],
        },
        fallbacks=[CommandHandler("cancel", cancel)],
    )
    application.add_handler(conv_handler)

    # Start the bot
    logger.info("Bot is running...")
    application.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == "__main__":
    main()