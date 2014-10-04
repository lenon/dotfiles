#!/usr/bin/env bash
set -e

if [ "$(uname)" != "Darwin" ]; then
  echo "This script only works on Mac OS X"
  exit 0
fi

BREW_INSTALLER="https://raw.githubusercontent.com/Homebrew/install/master/install"
BREW_PACKAGES="
  ag
  bash
  bash-completion
  caskroom/cask/brew-cask
  git
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
  onepassword
  spotify
"

if command -v brew >/dev/null 2>&1; then
  echo "Homebrew already installed"
else
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL "${BREW_INSTALLER}")"
fi

echo "Installing homebrew packages..."

for package in $BREW_PACKAGES ; do
  if brew list "$package" >/dev/null 2>&1; then
    echo "$package already installed"
  else
    brew install "$package"
  fi
done

echo "Installing cask packages..."

for package in $CASK_PACKAGES ; do
  if brew cask list "$package" >/dev/null 2>&1; then
    echo "$package already installed"
  else
    brew cask install --appdir=/Applications "$package"
  fi
done

brew cleanup
brew cask alfred link

echo "Done!"
exit 1
