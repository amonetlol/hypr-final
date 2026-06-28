#!/usr/bin/env python3

import json
import requests
from datetime import datetime

WEATHER_CODES = {
    '113': '☀️ ',
    '116': '⛅ ',
    '119': '☁️ ',
    '122': '☁️ ',
    '143': '☁️ ',
    '176': '🌧️',
    '179': '🌧️',
    '182': '🌧️',
    '185': '🌧️',
    '200': '⛈️ ',
    '227': '🌨️',
    '230': '🌨️',
    '248': '☁️ ',
    '260': '☁️ ',
    '263': '🌧️',
    '266': '🌧️',
    '281': '🌧️',
    '284': '🌧️',
    '293': '🌧️',
    '296': '🌧️',
    '299': '🌧️',
    '302': '🌧️',
    '305': '🌧️',
    '308': '🌧️',
    '311': '🌧️',
    '314': '🌧️',
    '317': '🌧️',
    '320': '🌨️',
    '323': '🌨️',
    '326': '🌨️',
    '329': '❄️ ',
    '332': '❄️ ',
    '335': '❄️ ',
    '338': '❄️ ',
    '350': '🌧️',
    '353': '🌧️',
    '356': '🌧️',
    '359': '🌧️',
    '362': '🌧️',
    '365': '🌧️',
    '368': '🌧️',
    '371': '❄️',
    '374': '🌨️',
    '377': '🌨️',
    '386': '🌨️',
    '389': '🌨️',
    '392': '🌧️',
    '395': '❄️ '
}

data = {}

city = "Ubatuba"

# EN
#weather = requests.get(f"https://wttr.in/{city}?format=j1").json()
# PT-BR
weather = requests.get(f"https://wttr.in/{city}?format=j1&lang=pt-br").json()

def format_time(time):
    return time.replace("00", "").zfill(2)

def format_temp(temp):
    return (hour['FeelsLikeC']+"°").ljust(3)


def format_chances(hour):
    # EN
    # chances = {
    #     "chanceoffog": "Fog",
    #     "chanceoffrost": "Frost",
    #     "chanceofovercast": "Overcast",
    #     "chanceofrain": "Rain",
    #     "chanceofsnow": "Snow",
    #     "chanceofsunshine": "Sunshine",
    #     "chanceofthunder": "Thunder",
    #     "chanceofwindy": "Wind"
    # }
    chances = {
        "chanceoffog": "🌫️ Neblina",
        "chanceoffrost": "❄️ Geada",
        "chanceofovercast": "☁️ Encoberto",
        "chanceofrain": "🌧️ Chuva",
        "chanceofsnow": "❄️ Neve",
        "chanceofsunshine": "☀️ Sol",
        "chanceofthunder": "⛈️ Trovoada",
        "chanceofwindy": "🌬️ Vento"
    }

    conditions = []
    for event in chances.keys():
        if int(hour[event]) > 0:
            conditions.append(chances[event]+" "+hour[event]+"%")
    return ", ".join(conditions)

# Sensação (Feels) - descomenta aqui
#tempint = int(weather['current_condition'][0]['FeelsLikeC'])

# Temperatura (Mist)
tempint = int(weather['current_condition'][0]['temp_C'])
extrachar = ''
if tempint > 0 and tempint < 10:
    extrachar = '+'

# PT-BR - para EN, só comentar a linha abaixo
desc_pt = weather['current_condition'][0]['lang_pt-br'][0]['value']
# FIM_PT-BR

# Sensação (Feels)
#data['text'] = ' '+WEATHER_CODES[weather['current_condition'][0]['weatherCode']] + \
#    " "+extrachar+weather['current_condition'][0]['FeelsLikeC']+"°C"

# Temperatura (Mist)
data['text'] = ' ' + WEATHER_CODES[weather['current_condition'][0]['weatherCode']] + \
    ' ' + extrachar + weather['current_condition'][0]['temp_C'] + '°C'

# EN
#data['tooltip'] = f"<b>{weather['current_condition'][0]['weatherDesc'][0]['value']} {weather['current_condition'][0]['temp_C']}°</b>\n"

# PT-BR - 2 linhas abaixo:
desc_pt = weather['current_condition'][0]['lang_pt-br'][0]['value']
data['tooltip'] = f"<b>{desc_pt}</b> {weather['current_condition'][0]['temp_C']}°C\n"
# FIM_PT-BR

# EN
# data['tooltip'] += f"Feels like: {weather['current_condition'][0]['FeelsLikeC']}°\n"
# data['tooltip'] += f"Wind: {weather['current_condition'][0]['windspeedKmph']}Km/h\n"
# data['tooltip'] += f"Humidity: {weather['current_condition'][0]['humidity']}%\n"

# PT-BR
data['tooltip'] += f"🌡️ Sensação: {weather['current_condition'][0]['FeelsLikeC']}°C\n"
data['tooltip'] += f"🌬️ Vento: {weather['current_condition'][0]['windspeedKmph']} km/h\n"
data['tooltip'] += f"💧 Umidade: {weather['current_condition'][0]['humidity']}%\n"
for i, day in enumerate(weather['weather']):
    # EN
    # data['tooltip'] += f"\n<b>"
    # if i == 0:
    #     data['tooltip'] += "Hoje, "
    # if i == 1:
    #     data['tooltip'] += "Amanhã, "
    # data['tooltip'] += f"{day['date']}</b>\n"

    # PT-BR
    date_obj = datetime.strptime(day['date'], "%Y-%m-%d")
    data_formatada = date_obj.strftime("%d/%m/%Y")

    if i == 0:
        prefix = "Hoje"
    elif i == 1:
        prefix = "Amanhã"
    else:
        prefix = data_formatada

    data['tooltip'] += f"\n{prefix}, <b>{data_formatada}</b>\n"
    data['tooltip'] += f"⬆️ {day['maxtempC']}° ⬇️ {day['mintempC']}° "
    data['tooltip'] += f"🌅 {day['astronomy'][0]['sunrise']} 🌇 {day['astronomy'][0]['sunset']}\n"
    # EN e PT-BR 12h
    # for hour in day['hourly']:
    #     if i == 0:
    #         if int(format_time(hour['time'])) < datetime.now().hour-2:
    #             continue
    #     # EN
    #     #data['tooltip'] += f"{format_time(hour['time'])} {WEATHER_CODES[hour['weatherCode']]} {format_temp(hour['FeelsLikeC'])} {hour['weatherDesc'][0]['value']}, {format_chances(hour)}\n"
    #     # PT-BR
    #     desc_pt = hour['lang_pt-br'][0]['value']
    #     # data['tooltip'] += f"{format_time(hour['time'])} {WEATHER_CODES[hour['weatherCode']]} {desc_pt} {format_temp(hour['FeelsLikeC'])} {hour['weatherDesc'][0]['value']}, {format_chances(hour)}\n"
    #     # PT-BR - versão short
    #     data['tooltip'] += f"{format_time(hour['time'])} • {desc_pt} • {hour['tempC']}°C • 💧{hour['chanceofrain']}%\n"

    # PT-BR com 24h
    for hour in day['hourly']:
        if i == 0:  # só filtra horas passadas no dia de hoje
            if int(format_time(hour['time'])) < datetime.now().hour - 2:
                continue

        desc_pt = hour['lang_pt-br'][0]['value']

        # Versão curta e limpa (recomendada)
        data['tooltip'] += (
            f"{format_time(hour['time'])} • "
            f"{WEATHER_CODES[hour['weatherCode']]} "
            f"{desc_pt} • "
            f"{hour['tempC']}°C • "
            f"💧 {hour['chanceofrain']}%\n"
        )


print(json.dumps(data))
