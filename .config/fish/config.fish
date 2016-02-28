set --export EDITOR vim
set --export PATH /usr/local/bin $PATH

set fish_color_command white
set fish_color_autosuggestion yellow
set fish_pager_color_description yellow
set fish_color_param white

status --is-interactive; and . (rbenv init -|psub)
