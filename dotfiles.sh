#!/usr/bin/env bash
set -e

if ! command -v brew > /dev/null; then
  /usr/bin/ruby -e "$(curl -fsSL \
    https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if ! command -v ansible-playbook > /dev/null; then
  brew install ansible
fi

ansible-playbook -i hosts.ini --ask-sudo-pass playbooks/dotfiles.yml
