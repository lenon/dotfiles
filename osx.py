#!/usr/bin/env python
import os
import subprocess
import sys
import time

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
    'python3',
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

# Print without a new line at the end.
def printn(string):
    sys.stdout.write(string)
    sys.stdout.flush()

# Executes a command and send its output to /dev/null.
# Returns True if the command exits with 0.
def cmd(args):
    devnull = open(os.devnull, 'w')
    return subprocess.call(args, stdout=devnull, stderr=devnull) == 0

# Wait for a command to return 0.
def wait_cmd(args):
    while not cmd(args):
        time.sleep(1)

# Executes a command and prints a nice line about its execution status.
def execute(description, command, skip_if=None, wait_until=None):
    printn('%s... ' % description)

    # do not execute a command if 'skip_if' command returns success
    if skip_if and cmd(skip_if):
        print('skipped')
        return

    if cmd(command):
        if wait_until:
            printn('(waiting) ')
            wait_cmd(wait_until)
        print('success')
    else:
        print('error')

# Writes a OS X setting using 'defaults' helper.
def write_setting(*args):
    args = ('defaults', 'write') + args
    execute(description=' '.join(args),
            command=args)

print('== Homebrew setup ==')

execute(description='Installing command line tools',
        command=['xcode-select', '--install'],
        skip_if=['xcode-select', '-p'],
        wait_until=['xcode-select', '-p'])

execute(description='Downloading Homebrew installer',
        command=['curl', '-o', BREW_INSTALLER, '-fsSL', BREW_URL],
        skip_if=['command', '-v', 'brew'])

execute(description='Installing Homebrew',
        command=['ruby', BREW_INSTALLER],
        skip_if=['command', '-v', 'brew'])

execute(description='Removing Homebrew installer',
        command=['rm', BREW_INSTALLER],
        skip_if=['command', '-v', 'brew'])

execute(description='Turning off Homebrew analytics',
        command=['brew', 'analytics', 'off'])

execute(description='Installing Homebrew cask',
        command=['brew', 'tap', 'caskroom/cask'])

print('== Homebrew packages ==')

for pkg in BREW_PACKAGES:
    execute(description='Installing %s' % pkg,
            command=['brew', 'install', pkg])

print('== Homebrew casks ==')

for pkg in CASK_PACKAGES:
    execute(description='Installing %s' % pkg,
            command=['brew', 'cask', 'install', '--appdir=/Applications', pkg])

print('== Dotfiles setup ==')

execute(description='Changing shell to fish',
        command=['sudo', 'chsh', '-s', '/usr/local/bin/fish', os.getlogin()])

execute(description='Linking fish files',
        command=['stow', 'fish', '--no-folding'])

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

print('== Finder settings ==')
# show status bar
write_setting('com.apple.finder', 'ShowStatusBar', '-bool', 'true')
# show path bar
write_setting('com.apple.finder', 'ShowPathbar', '-bool', 'true')
# show icons for hard drives, servers and removable media on the desktop
write_setting('com.apple.finder', 'ShowExternalHardDrivesOnDesktop', '-bool', 'true')
write_setting('com.apple.finder', 'ShowHardDrivesOnDesktop', '-bool', 'true')
write_setting('com.apple.finder', 'ShowMountedServersOnDesktop', '-bool', 'true')
write_setting('com.apple.finder', 'ShowRemovableMediaOnDesktop', '-bool', 'true')
# show file extensions
write_setting('NSGlobalDomain', 'AppleShowAllExtensions', '-bool', 'true')
# display full path as finder window title
write_setting('com.apple.finder', '_FXShowPosixPathInTitle', '-bool', 'true')
# search the current folder by default
write_setting('com.apple.finder', 'FXDefaultSearchScope', '-string', '"SCcf"')
# disable the warning when changing a file extension
write_setting('com.apple.finder', 'FXEnableExtensionChangeWarning', '-bool', 'false')

for app in ['Dock', 'Finder']:
    execute(description='Restarting %s' % app,
            command=['killall', app])

execute(description='Disabling local time machine backups',
        command=['sudo', 'tmutil', 'disablelocal'])
