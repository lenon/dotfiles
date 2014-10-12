#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/bash_prompt.sh"

# Executable scripts
PATH="${HOME}/dotfiles/bin:${PATH}"

# Homebrew paths
PATH="/usr/local/bin:${PATH}"
PATH="/usr/local/sbin:${PATH}"
export PATH

eval "$(rbenv init -)"
source "$(brew --prefix)/etc/bash_completion"
