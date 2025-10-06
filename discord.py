import asyncio
import websockets
import websockets.exceptions
import json
import random

from src.logger.logger import setup_logger
from config import (DISCORD_WS_URL, DISCORD_TOKEN, MONEY_THRESHOLD,
                    IGNORE_UNKNOWN, PLAYER_TRESHOLD, BYPASS_10M,
                    FILTER_BY_NAME, IGNORE_LIST, READ_CHANNELS)
from src.roblox import server
from src.utils import check_channel, extract_server_info, set_console_title

logger = setup_logger()

async def identify(ws):
    identify_payload = {
        "op": 2,
        "d": {
            "token": DISCORD_TOKEN,
            "properties": {
                "os": "Windows", "browser": "Chrome", "device": "", "system_locale": "en-US",
                "browser_user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36",
                "referrer": "https://discord.com/", "referring_domain": "discord.com"
            }
        }
    }

    await ws.send(json.dumps(identify_payload))
    logger.info("Sent client identification")

    payload = {
        "op": 37,
        "d": {
            "subscriptions": {
                "1385491616013221990": {"typing": True, "threads": True, "activities": True, "members": [], "member_updates": False, "channels": {}, "thread_member_lists": []},
                "1401550662335991908": {"typing": True, "threads": True, "activities": True, "members": [], "member_updates": False, "channels": {}, "thread_member_lists": []}
            }
        }
    }
    await ws.send(json.dumps(payload))
    logger.info("Sent client subscriptions")
    logger.info("You must be on the chilli hub discord server and notasnek github (see repo)")

async def message_check(event):
    channel_id = event['d']['channel_id']
    result, category = check_channel(channel_id)
    if result:
        try:
            parsed = extract_server_info(event)
            if not parsed: return

            if parsed['money'] < MONEY_THRESHOLD[0] or parsed['money'] > MONEY_THRESHOLD[1]:
                return

            if category not in READ_CHANNELS:
                # logger.warning(f"Skipped brainrot channel {category} not in READ_CHANNELS")
                return

            if parsed['name'] == "Unknown" and IGNORE_UNKNOWN:
                logger.warning("Skipped unknown brainrot")
                return

            if int(parsed['players']) >= PLAYER_TRESHOLD:
                logger.warning(f"Skipped server {parsed['players']} >= {PLAYER_TRESHOLD} players")
                return

            if FILTER_BY_NAME[0]:
                if parsed['name'] not in FILTER_BY_NAME[1]:
                    logger.warning(f"Skip brainrot {parsed['name']} not in filter by name list")
                    return

            if parsed['name'] in IGNORE_LIST:
                logger.warning(f"Skip brainrot {parsed['name']} in ignore list")
                return


            if parsed['money'] >= 10.0:
                if not BYPASS_10M:
                    logger.warning("Skip 10m+ server because bypass turned off")
                    return

                await server.broadcast(parsed['job_id'])
            else:
                await server.broadcast(parsed['script'])
            logger.info(f"Sent {parsed['name']} in category {category}: {parsed['money']} M/s")

            if random.randint(0, 6) == 1:
                logger.info(f"You are using FREE AutoJoiner from notasnek: github.com/notasnek/roblox-autojoiner")
        except Exception as e:
            logger.debug(f"Failed to check message: {e}")

async def message_listener(ws):
    logger.info("Listening new messages...")
    while True:
        event = json.loads(await ws.recv())
        #logger.info(f"Получил ивент: {str(event)[:2000]}")
        op_code = event.get("op", None)

        if op_code == 10: # Hello
            pass # пока не нужно

        elif op_code == 0: # Dispatch
            #last_sequence = event.get("s", None)
            event_type = event.get("t")

            if event_type == "MESSAGE_CREATE" and not server.paused:
                await message_check(event) # nоtasnek

        elif op_code == 9: # Invalid Session
            logger.warning("The session has ended, creating a new one..")
            await identify(ws)


async def listener():
    set_console_title(f"AutoJoiner | Status: Enabled")
    while True:
        try:
            async with websockets.connect(DISCORD_WS_URL, max_size=None) as ws:
                await identify(ws)
                await message_listener(ws)

        except websockets.exceptions.ConnectionClosed as e:
            logger.error(f" - WebSocket closed with error: {e}. Trying to reconnect... (if not mistake: check your discord token)")
            await asyncio.sleep(3)
            continue

# https://github.com/notasnek/roblox-autojoiner