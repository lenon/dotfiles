#!/usr/bin/env bash
set -e

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
fi

while ! xcode-select -p >/dev/null 2>&1; do
  sleep 5
done

if ! command -v brew > /dev/null; then
  /usr/bin/ruby -e "$(curl -fsSL \
    https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if ! command -v ansible-playbook > /dev/null; then
  brew install ansible
fi

ansible-playbook -i localhost, --ask-sudo-pass playbooks/dotfiles.yml
