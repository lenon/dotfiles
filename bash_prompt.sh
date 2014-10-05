#!/usr/bin/env bash

DOTFILES_ROOT=$(dirname "${BASH_SOURCE[0]}")
source "${DOTFILES_ROOT}/lib/colors.sh"
source "${DOTFILES_ROOT}/lib/git.sh"

git_info_for_ps1() {
  local prompt=""

  if is_a_git_repo; then
    if ! is_dot_git; then
      update_git_index
      has_uncommitted_changes && prompt+="U"
      has_unstaged_files && prompt+="M"
      has_untracked_files && prompt+="?"
      has_stashed_files && prompt+="S"
    fi

    [ -n "${prompt}" ] && prompt=" [${prompt}]"

    printf " ${COLOR_BLUE}%s${COLOR_YELLOW}%s${COLOR_RESET}" "$(git_branch_name)" "${prompt}"
  fi
}

set_exitcode_color() {
  if [ "$?" = 0 ]; then
    printf "${COLOR_WHITE}"
  else
    printf "${COLOR_RED}"
  fi
}

PROMPT_COMMAND=set_exitcode_color

PS1="\[\033]0;\$(basename "\\w")\007\]" # show basename of the current directory as window title
PS1+="\w" # current working directory
PS1+="\$(git_info_for_ps1)" # git repository information
PS1+="\[${COLOR_WHITE}\] \$ "
PS1+="\[${COLOR_RESET}\]"

PS2="\[${COLOR_YELLOW}\]> \[${COLOR_RESET}\]"

export PROMPT_COMMAND
export PS1
export PS2
