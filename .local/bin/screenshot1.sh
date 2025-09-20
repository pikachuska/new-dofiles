#!/bin/bash

folder="$HOME/screenshots"
mkdir -p "$folder"
filename="freeze_$(date +%Y-%m-%d_%H-%M-%S).png"
filepath="$folder/$filename"

# Скрин всего экрана
grim "$filepath"

# Звук
canberra-gtk-play -i camera-shutter -d "screenshot"

# Копируем в буфер
wl-copy < "$filepath"

# Уведомление
notify-send -a "Screenshot" "✅ Скриншот сохранён" "$filename" -i "$filepath"
