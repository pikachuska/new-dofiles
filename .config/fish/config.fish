set fish_greeting

alias n='nvim'
alias p='sudo pacman -S'
alias pr='sudo pacman -R'
alias cdd='cd /mnt/downloads/downloads'
alias y='yay -S'
alias yr='yay -R'
alias ureboot='systemctl reboot --firmware-setup'

if status is-interactive
    fastfetch
end

# Подключаем pywal цвета
if test -e ~/.cache/wal/colors.fish
    source ~/.cache/wal/colors.fish
end


# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/user/.lmstudio/bin
# End of LM Studio CLI section

