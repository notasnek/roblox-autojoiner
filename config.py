
# https://github.com/notasnek/roblox-autojoiner



DISCORD_TOKEN = "your discord token"
# discord token / дискорд токен
# гайд/guide: https://www.youtube.com/results?search_query=how+to+get+discord+token


MONEY_THRESHOLD = (1.0, 1999.0) # in millions from, to / в миллионах от, до (example: 1.5 = 1.5m, 0.5 = 500k)
# if the brainrot earnings per second are less than the first number or higher than the second number, it will be skipped
# если заработок в секунду у брейнрота меньше первого числа или выше второго числа, то он будет скипнут
# Example / Пример: (3.0, 10.0) - от 3м до 10м / from 3m to 10m


PLAYER_TRESHOLD = 8 # число / number
# if there are more PLAYER_TRESHOLD players on the server - it will not try to enter the server
# если на сервере больше PLAYER_TRESHOLD игроков - не будет пытаться зайти на сервер


IGNORE_UNKNOWN = True # True / False
# ignore "Unknown" brainrots
# игнорировать "Unknown" брейнротов


IGNORE_LIST = [""] # ignore list, список игнора
# Добавьте имена брейнротов в данный список которых надо скипать
# Add the names of the brainrots to this list of those that need to be skipped
# Example 1 / Пример 1: ["Graipuss Medussi"]
# Example 2 / Пример 2: ["Graipuss Medussi", "La Grande Combinasion"]


FILTER_BY_NAME = False, ["Graipuss Medussi", "La Grande Combinasion"] # filter by name, фильтр по имени
# Что-бы он работал, поменяйте False на True, а также в список добавьте\уберите\измените название необходимых брейнротов
# To make it work, change False to True, and add/remove/change the names of the necessary brainroots to the list
# Если включено: будет заходить на сервера где название брейнрота соответствует списку
# If enabled: will connect to servers where the brainrot name matches the list
# Example/пример: True, ["Graipuss Medussi"]


BYPASS_10M = True # True / False
# bypass jobid for 10m+ servers, FOR WORKING BYPASS YOU MUST HAVE INJECTED CHILLI HUB
# байпасить вход для 10м+ серваков, ДЛЯ РАБОЧЕГО БУПАССА У ВАС ДОЛЖЕН БЫТЬ ЗАИНЖЕКЧЕН ЧИЛЛИ ХАБ


READ_CHANNELS = ['notasnek_1m-10m', "10m_plus"] # channels / каналы
# список каналов логов какие читать (айдишники снизу)
# list of log channels to read (IDs at the bottom)
# Don't change it if you don't know what you're doing.
# не меняйте если не понимаете что делаете





# DON'T TOUCH ! / НЕ ТРОГАЙ !
# don't touch it if you don't understand what it is / не трогай если не понимаешь что это
WEBSOCKET_PORT = 51948 # websocket port for data transfer in roblox

DISCORD_WS_URL = "wss://gateway.discord.gg/?encoding=json&v=9" # discord ws

CHILLI_HUB_CHANNELS_ID = {
    "under_500k": ["1401774723246854204", "1401774863974268959"], # under 500k channels
    "500k_1m": ["1401774956404277378", "1401775012083404931"], # 500k - 1M channels
    "1m-10m": ["1401775061706346536", "1401775125765947442"], # 1m - 10m channels
    "10m_plus": ["1401775181025775738"], # 10m+ channels

    "notasnek_1m-10m": ["1404759535293431849"], # 1m - 10m notasnek discord channel
    "notasnek_10m_plus": ["1404759584450678865"] # 10m+ notasnek discord channel
}



# https://github.com/notasnek/roblox-autojoiner