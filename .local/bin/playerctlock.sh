#!/bin/bash

# Папка для обложки
folder="$HOME/Изображения/hl"
mkdir -p "$folder"
artfile="$folder/img.jpg"

if [ $# -eq 0 ]; then
    echo "Usage: $0 --title | --artist | --album | --length | --status | --position | --source | --arturl"
    exit 1
fi

# Получаем metadata
get_metadata() {
    playerctl metadata "$1" 2>/dev/null
}

# Источник плеера
get_source_info() {
    trackid=$(playerctl metadata mpris:trackid 2>/dev/null)
    if [[ "$trackid" == *"firefox"* ]]; then
        echo "Firefox 󰈹"
    elif [[ "$trackid" == *"spotify"* ]]; then
        echo "Spotify "
    elif [[ "$trackid" == *"chromium"* ]]; then
        echo "Chrome "
    elif [[ "$trackid" == *"mpv"* ]]; then
        echo "MPV 󰐊"
    elif [[ "$trackid" == *"vlc"* ]]; then
        echo "VLC 󰕼"
    elif [[ "$trackid" == *"amberol"* ]]; then
        echo "Amberol "
    else
        echo ""
    fi
}

# Форматируем время
format_time() {
    local sec=$(( $1 / 1000000 ))
    printf "%d:%02d" $((sec/60)) $((sec%60))
}

# Получаем обложку
get_art() {
    url=$(playerctl metadata mpris:artUrl 2>/dev/null)

    if [[ -z "$url" ]]; then
        echo "/usr/share/icons/default_music.jpg"
        return
    fi

    if [[ "$url" == file://* ]]; then
        echo "${url#file://}"
        return
    fi

    if [[ "$url" == https://* ]]; then
        curl -sfL "$url" -o "$artfile"
        if [[ -s "$artfile" ]]; then
            echo "$artfile"
        else
            echo "/usr/share/icons/default_music.jpg"
        fi
        return
    fi

    echo "/usr/share/icons/default_music.jpg"
}

# Обработка аргументов
case "$1" in
--title)
    title=$(get_metadata xesam:title)
    [ -n "$title" ] && echo "${title:0:28}" || echo ""
    ;;

--artist)
    artist=$(get_metadata xesam:artist)
    [ -n "$artist" ] && echo "${artist:0:30}" || echo ""
    ;;

--album)
    album=$(get_metadata xesam:album)
    [ -n "$album" ] && echo "$album" || echo "Not album"
    ;;

--length)
    length=$(get_metadata mpris:length)
    [ -n "$length" ] && format_time "$length" || echo ""
    ;;

--position)
    pos=$(playerctl position 2>/dev/null)
    [[ -n "$pos" ]] && printf "%d:%02d\n" $((pos/60)) $((pos%60)) || echo ""
    ;;

--status)
    st=$(playerctl status 2>/dev/null)
    [[ "$st" == "Playing" ]] && echo "󰎆" || ([[ "$st" == "Paused" ]] && echo "󱑽" || echo "")
    ;;

--source)
    get_source_info
    ;;

--arturl)
    get_art
    ;;

*)
    echo "Invalid option: $1"
    exit 1
    ;;
esac
