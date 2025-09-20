#!/bin/bash

# Папка и имя
folder="$HOME/screenshots"
mkdir -p "$folder"
filename="screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
filepath="$folder/$filename"

# Скриншот области
grim -g "$(slurp)" "$filepath"

# Звук (после скрина)
canberra-gtk-play -i camera-shutter -d "screenshot"

# Копировать в буфер обмена
wl-copy < "$filepath"

# Уведомление с действием "Открыть папку"
notify-send -a "Screenshot" "✅ Скриншот сохранён" "$filename" \
    -i "$filepath" \
    -h string:x-canonical-private-synchronous:screenshot \
    -A "Открыть папку:dolphin \"$folder\""