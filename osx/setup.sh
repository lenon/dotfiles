#!/usr/bin/env bash
set -e

if [ "$(uname)" != "Darwin" ]; then
  echo "This script only works on Mac OS X"
  exit 1
fi

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

BREW_INSTALLER="https://raw.githubusercontent.com/Homebrew/install/master/install"

e_header "Installing homebrew..."

if command -v brew >/dev/null 2>&1; then
  e_success "Homebrew already installed"
else
  if ruby -e "$(curl -fsSL "${BREW_INSTALLER}")" >/dev/null; then
    e_success "Homebrew installed"
  fi
fi

e_header "Installing homebrew packages..."

while read package; do
  if brew list "$package" >/dev/null 2>&1; then
    e_success "$package already installed"
  else
    e_header "Installing $package..."
    if brew install "$package" >/dev/null; then
      e_success "$package installed"
    fi
  fi
done < config/brew_packages

e_header "Installing cask packages..."

while read package; do
  if brew cask list "$package" >/dev/null 2>&1; then
    e_success "$package already installed"
  else
    e_header "Installing $package..."
    if brew cask install --appdir=/Applications "$package" >/dev/null; then
      e_success "$package installed"
    fi
  fi
done < config/cask_packages

e_header "Cleaning up..."

brew cleanup >/dev/null
brew cask alfred link >/dev/null
brew cask cleanup >/dev/null

e_success "Done!"

exit 0
