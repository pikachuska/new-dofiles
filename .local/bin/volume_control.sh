#!/bin/bash

# Регулировка громкости
if [ "$1" == "up" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    dunstify -h int:value:"$(pamixer --get-volume)" -i ~/.config/dunst/assets/volume.svg -t 500 -r 2593 "Volume: $(pamixer --get-volume) %"
elif [ "$1" == "down" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    dunstify -h int:value:"$(pamixer --get-volume)" -i ~/.config/dunst/assets/volume.svg -t 500 -r 2593 "Volume: $(pamixer --get-volume) %"
elif [ "$1" == "mute" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    if [ "$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')" == "yes" ]; then
        dunstify -h int:value:"$(pamixer --get-volume)" -i ~/.config/dunst/assets/volume-mute.svg -t 500 -r 2593 "Volume: $(pamixer --get-volume) %"
    else
        dunstify -h int:value:"$(pamixer --get-volume)" -i ~/.config/dunst/assets/volume.svg -t 500 -r 2593 "Volume: $(pamixer --get-volume) %"
    fi
fi
