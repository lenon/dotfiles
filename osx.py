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

def write_setting(*args):
    args = ('defaults', 'write') + args
    printn(' '.join(args))
    execute(*args)

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

print('== OS X settings ==')
print('== Dock settings ==')

# enable a hover effect for stack folders in grid view
write_setting('com.apple.dock', 'mouse-over-hilite-stack', '-bool', 'true')
# set the icon size of dock items to 36 pixels
write_setting('com.apple.dock', 'tilesize', '-int', '36')
# change minimize/maximize window effect
write_setting('com.apple.dock', 'mineffect', '-string', 'scale')
# minimize windows into their application's icon
write_setting('com.apple.dock', 'minimize-to-application', '-bool', 'true')
# enable spring loading for all dock items
write_setting('com.apple.dock', 'enable-spring-load-actions-on-all-items', '-bool', 'true')
# show indicator lights for open applications in the dock
write_setting('com.apple.dock', 'show-process-indicators', '-bool', 'true')
# automatically hide and show the dock
write_setting('com.apple.dock', 'autohide', '-bool', 'true')
# make dock icons of hidden applications translucent
write_setting('com.apple.dock', 'showhidden', '-bool', 'true')

printn('Restarting dock... ')
execute('killall', 'Dock')
