#!/usr/bin/env python
import os
import subprocess
import sys

#
# Settings
#

BREW_URL = 'https://raw.githubusercontent.com/Homebrew/install/master/install'
BREW_INSTALLER = '/tmp/homebrew_installer.rb'
BREW_PACKAGES = [
    'ag',
    'fish',
    'git',
    'homebrew/dupes/openssh',
    'neovim/neovim/neovim',
    'openssl',
    'python',
    'rbenv',
    'stow',
    'tmux',
    'tree',
    'vim',
]

CASK_PACKAGES = [
    '1password',
    'adium',
    'android-file-transfer',
    'arduino',
    'caskroom/versions/iterm2-beta',
    'dropbox',
    'firefox',
    'flux',
    'libreoffice',
    'macvim',
    'microsoft-office',
    'spectacle',
    'spotify',
    'the-unarchiver',
    'transmission',
    'virtualbox',
    'virtualbox-extension-pack',
    'vlc',
    'xquartz',
]

#
# Setup script
#

# print without a new line at the end
def printn(string):
    sys.stdout.write(string)
    sys.stdout.write(' ')
    sys.stdout.flush()

# execute a command and send its output to /dev/null
# print a message after command exits
def execute(*args):
    devnull = open(os.devnull, 'w')
    result = subprocess.call(args, stdout=devnull, stderr=devnull)

    if result == 0:
        print('success')
    else:
        print('error')

print('== Homebrew setup ==')

printn('Make sure xcode command line tools are installed...')
execute('xcode-select', '--install')

printn('Downloading Homebrew installer...')
execute('curl', '-o', BREW_INSTALLER, '-fsSL', BREW_URL)

printn('Instaling Homebrew...')
execute('ruby', BREW_INSTALLER)

printn('Removing Homebrew installer...')
execute('rm', BREW_INSTALLER)

printn('Turning off Homebrew analytics...')
execute('brew', 'analytics', 'off')

printn('Installing Homebrew cask...')
execute('brew', 'tap', 'caskroom/cask')

print('== Homebrew packages ==')

for pkg in BREW_PACKAGES:
    printn('Instaling %s...' % pkg)
    execute('brew', 'install', pkg)

print('== Homebrew casks ==')

for pkg in CASK_PACKAGES:
    printn('Instaling %s...' % pkg)
    execute('brew', 'cask', 'install', '--appdir=/Applications', pkg)

print('== Dotfiles setup ==')

printn('Changing shell to Fish...')
execute('sudo', 'chsh', '-s', '/usr/local/bin/fish', os.getlogin())

printn('Linking fish files...')
execute('stow', 'fish', '--no-folding')
