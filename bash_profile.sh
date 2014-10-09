#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/bash_prompt.sh"

# Homebrew paths
PATH="/usr/local/bin:${PATH}"
PATH="/usr/local/sbin:${PATH}"

export PATH
