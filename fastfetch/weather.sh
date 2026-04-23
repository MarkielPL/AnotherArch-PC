#!/usr/bin/env bash

# =========================
# AUTO LOKALIZACJA (IP)
# =========================
LOC_JSON=$(curl -s ipinfo.io/json)

LAT=$(echo "$LOC_JSON" | jq -r '.loc' | cut -d ',' -f1)
LON=$(echo "$LOC_JSON" | jq -r '.loc' | cut -d ',' -f2)
CITY=$(echo "$LOC_JSON" | jq -r '.city')

# fallback gdyby API padło
[ -z "$LAT" ] && LAT="50.982996"
[ -z "$LON" ] && LON="23.1697933"
[ -z "$CITY" ] && CITY="Siennica Nadolna"

# =========================
# POGODA (OpenWeather)
# =========================
APIKEY="<YOUR_API_KEY>" # https://openweathermap.org/api

QUERY="https://api.openweathermap.org/data/2.5/weather?lat=${LAT}&lon=${LON}&appid=${APIKEY}&units=metric"

WEATHER_JSON=$(curl -s "$QUERY")

# jeśli brak odpowiedzi → wyjdź
[ -z "$WEATHER_JSON" ] && exit 0

# =========================
# PARSOWANIE
# =========================
DESC=$(echo "$WEATHER_JSON" | jq -r '.weather[0].description // empty')
ICON=$(echo "$WEATHER_JSON" | jq -r '.weather[0].icon // empty')
TEMP=$(echo "$WEATHER_JSON" | jq -r '.main.temp // empty' | cut -d '.' -f1)

if ! [[ "$TEMP" =~ ^-?[0-9]+$ ]]; then
  TEMP=0
fi

[ -z "$DESC" ] && DESC="brak danych"
[ -z "$ICON" ] && ICON="na"
# =========================
# IKONY
# =========================
case "$ICON" in
  01d) SYMBOL="☀";;
  01n) SYMBOL="🌙";;
  02d) SYMBOL="⛅";;
  02n) SYMBOL="☁";;
  03*|04*) SYMBOL="☁";;
  09*|10*) SYMBOL="🌧";;
  11*) SYMBOL="⚡";;
  13*) SYMBOL="❄";;
  50*) SYMBOL="🌫";;
  *) SYMBOL="$DESC";;
esac

# =========================
# "KOLORY" POD FASTFETCH
# =========================
# zamiast ANSI → emoji (działa wszędzie)

if [ "$TEMP" -lt 5 ]; then
  TEMP_STR="🥶 ${TEMP}°C"
elif [ "$TEMP" -lt 18 ]; then
  TEMP_STR="🙂 ${TEMP}°C"
elif [ "$TEMP" -lt 26 ]; then
  TEMP_STR="😎 ${TEMP}°C"
else
  TEMP_STR="🔥 ${TEMP}°C"
fi

# =========================
# OUTPUT (bez ANSI!)
# =========================
echo "$SYMBOL $TEMP_STR  $DESC ($CITY)"