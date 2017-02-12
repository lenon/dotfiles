set --local color_blue 005b96
set --local color_green a2d27b
set --local color_purple a0a0ff
set --local color_red feb3b3
set --local color_white ffffff
set --local color_yellow fdf498

# prompt colors
set --global fish_color_autosuggestion $color_green
set --global fish_color_command $color_white
set --global fish_color_comment $color_purple
set --global fish_color_cwd $color_white
set --global fish_color_end $color_purple
set --global fish_color_error $color_red
set --global fish_color_escape $color_purple
set --global fish_color_match $color_yellow
set --global fish_color_normal $color_white
set --global fish_color_operator $color_yellow
set --global fish_color_param $color_white
set --global fish_color_redirection $color_purple
set --global fish_color_search_match --background=$color_blue

# pager colors
set --global fish_pager_color_completion $color_white
set --global fish_pager_color_prefix $color_green
set --global fish_pager_color_progress $color_yellow

# git prompt settings
set --global __fish_git_prompt_char_cleanstate '✓'
set --global __fish_git_prompt_char_dirtystate "*"
set --global __fish_git_prompt_char_stagedstate '±'
set --global __fish_git_prompt_char_stateseparator ' '
set --global __fish_git_prompt_show_informative_status 1
set --global __fish_git_prompt_showcolorhints 1
set --global __fish_git_prompt_color $fish_color_cwd

# set vim as default editor
set --export EDITOR nvim

# add brew packages on PATH
set --export PATH /usr/local/bin $PATH
set --export PATH /usr/local/sbin $PATH

# rbenv initialization
status --is-interactive; and . (rbenv init -|psub)

# golang workspace location
set --export GOPATH "$HOME/dev/go"

# load aliases
source ~/.config/fish/aliases.fish
