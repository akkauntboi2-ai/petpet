#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import logging
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup, KeyboardButton, ReplyKeyboardMarkup
from telegram.ext import Application, CommandHandler, MessageHandler, CallbackQueryHandler, filters, ContextTypes

BOT_TOKEN = "8024293449:AAEfyTzZerNUxxo-f13yO4ikZR45yUuh-1U"
users_db = {}

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    args = context.args
    if args and args[0] == 'auth':
        keyboard = [[KeyboardButton("Otpravit nomer telefona", request_contact=True)]]
        reply_markup = ReplyKeyboardMarkup(keyboard, resize_keyboard=True, one_time_keyboard=True)
        await update.message.reply_text(f"Privet, {user.first_name}!\n\nDobro pozhalovat v PetShop!\n\nDlya avtorizacii nazhmite knopku i otpravte nomer:", reply_markup=reply_markup)
    else:
        keyboard = [
            [InlineKeyboardButton("Koshki", callback_data="cat_cats"), InlineKeyboardButton("Sobaki", callback_data="cat_dogs")],
            [InlineKeyboardButton("Pticy", callback_data="cat_birds"), InlineKeyboardButton("Loshadi", callback_data="cat_horses")],
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)
        await update.message.reply_text(f"Privet, {user.first_name}!\n\nPetShop - ploshchadka dlya pokupki i prodazhi zhivotnyh\n\nVyberite kategoriyu:", reply_markup=reply_markup)

async def handle_contact(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    contact = update.message.contact
    if contact.user_id == user.id:
        users_db[user.id] = {'id': user.id, 'name': user.first_name, 'username': user.username, 'phone': contact.phone_number, 'authorized': True}
        auth_code = f"PETSHOP-{user.id}"
        await update.message.reply_text(f"Avtorizaciya uspeshna!\n\nImya: {user.first_name}\nTelefon: {contact.phone_number}\nTelegram: @{user.username if user.username else 'ne ukazan'}\n\nKod: {auth_code}\n\nVernites v prilozhenie PetShop!")
        logger.info(f"User {user.id} authorized with phone {contact.phone_number}")

async def handle_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    categories = {'cat_cats': 'Koshki', 'cat_dogs': 'Sobaki', 'cat_birds': 'Pticy', 'cat_horses': 'Loshadi'}
    if query.data in categories:
        keyboard = [[InlineKeyboardButton("Nazad", callback_data="back_main")]]
        await query.edit_message_text(f"{categories[query.data]}\n\nDlya prosmotra skachajte prilozhenie!", reply_markup=InlineKeyboardMarkup(keyboard))
    elif query.data == 'back_main':
        keyboard = [
            [InlineKeyboardButton("Koshki", callback_data="cat_cats"), InlineKeyboardButton("Sobaki", callback_data="cat_dogs")],
            [InlineKeyboardButton("Pticy", callback_data="cat_birds"), InlineKeyboardButton("Loshadi", callback_data="cat_horses")],
        ]
        await query.edit_message_text("PetShop\n\nVyberite kategoriyu:", reply_markup=InlineKeyboardMarkup(keyboard))

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("PetShop Help\n\n/start - Nachat\n/help - Pomoshch")

def main():
    print("PetShop Bot starting...")
    app = Application.builder().token(BOT_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("help", help_command))
    app.add_handler(MessageHandler(filters.CONTACT, handle_contact))
    app.add_handler(CallbackQueryHandler(handle_callback))
    print("Bot started!")
    app.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == '__main__':
    main()
