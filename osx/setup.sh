#!/usr/bin/env bash
set -e

if [ "$(uname)" != "Darwin" ]; then
  echo "This script only works on Mac OS X"
  exit 1
fi

source ./lib/utils.sh

BREW_INSTALLER="https://raw.githubusercontent.com/Homebrew/install/master/install"
BREW_PACKAGES="
  ag
  bash
  bash-completion
  caskroom/cask/brew-cask
  coreutils
  encfs
  git
  gpg
  openssl
  python
  rename
  tree
  vim
"
CASK_PACKAGES="
  adium
  alfred
  dropbox
  flux
  iterm2
  macvim
  onepassword
  spectacle
  spotify
  the-unarchiver
  transmission
"

e_header "Installing homebrew..."

if command -v brew >/dev/null 2>&1; then
  e_success "Homebrew already installed"
else
  if ruby -e "$(curl -fsSL "${BREW_INSTALLER}")" >/dev/null; then
    e_success "Homebrew installed"
  fi
fi

e_header "Installing homebrew packages..."

for package in $BREW_PACKAGES ; do
  if brew list "$package" >/dev/null 2>&1; then
    e_success "$package already installed"
  else
    e_header "Installing $package..."
    if brew install "$package" >/dev/null; then
      e_success "$package installed"
    fi
  fi
done

e_header "Installing cask packages..."

for package in $CASK_PACKAGES ; do
  if brew cask list "$package" >/dev/null 2>&1; then
    e_success "$package already installed"
  else
    e_header "Installing $package..."
    if brew cask install --appdir=/Applications "$package" >/dev/null; then
      e_success "$package installed"
    fi
  fi
done

e_header "Cleaning up..."

brew cleanup >/dev/null
brew cask alfred link >/dev/null
brew cask cleanup >/dev/null

e_success "Done!"

exit 0
