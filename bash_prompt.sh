#!/usr/bin/env bash

DOTFILES_ROOT=$(dirname "${BASH_SOURCE[0]}")
source "${DOTFILES_ROOT}/lib/colors.sh"
source "${DOTFILES_ROOT}/lib/git.sh"

git_info_for_ps1() {
  local prompt=""

  if git::repo?; then
    if ! git::dot_dir?; then
      git::uncommitted_changes? && prompt+="U"
      git::unstaged_files? && prompt+="M"
      git::untracked_files? && prompt+="?"
      git::stashed_files? && prompt+="S"
    fi

    [ -n "${prompt}" ] && prompt=" [${prompt}]"

    # http://superuser.com/a/301355
    printf " \001%s\002%s\001%s\002%s\001%s\002" \
      "${COLOR_BLUE}" \
      "$(git::branch_name)" \
      "${COLOR_YELLOW}" \
      "${prompt}" \
      "${COLOR_RESET}"
  fi
}

set_exitcode_color() {
  if [ "$?" = 0 ]; then
    printf "\001%s\002" "${COLOR_WHITE}"
  else
    printf "\001%s\002" "${COLOR_RED}"
  fi
}

PROMPT_COMMAND=set_exitcode_color

TITLE_BAR="\e]0;\$(basename "\\w")\a"

PS1="\[${TITLE_BAR}\]" # show basename of the current directory as window title
PS1+="\w" # current working directory
PS1+="\$(git_info_for_ps1)" # git repository information
PS1+="\[${COLOR_WHITE}\] \$ "
PS1+="\[${COLOR_RESET}\]"

PS2="\[${COLOR_YELLOW}\]> \[${COLOR_RESET}\]"

export PROMPT_COMMAND
export PS1
export PS2
