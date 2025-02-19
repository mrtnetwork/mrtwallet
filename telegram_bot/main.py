import logging
from telegram import InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler
from dotenv import load_dotenv
import os

# Enable logging
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s',
                    level=logging.INFO)
logger = logging.getLogger()

# Load environment variables from .env file
load_dotenv()

# Get the bot token from the environment variable
BOT_TOKEN = "7993027595:AAGsUgbchSCh6qRXkBT159EmPTWMYijB4XE"
WEB_APP_URL = "https://67b2-5-181-23-67.ngrok-free.app"

async def start(update, context):
    keyboard = [[InlineKeyboardButton("Open Wallet", web_app={"url": WEB_APP_URL})]]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text("Click the button below to open your wallet:", reply_markup=reply_markup)

def main():
    # Initialize the application with the bot token
    application = Application.builder().token(BOT_TOKEN).build()

    # Add the /start command handler
    application.add_handler(CommandHandler("start", start))

    # Log when the bot starts
    logger.info("Bot started")

    # Start polling and log any exceptions
    try:
        application.run_polling()
    except Exception as e:
        logger.error(f"Bot encountered an error: {e}")

if __name__ == "__main__":
    main()
