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
    'irssi',
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
# Helper methods
#

# Print without a new line at the end.
def write(string):
    sys.stdout.write(string)
    sys.stdout.flush()

# Executes a command and returns True if it exits with 0.
def cmd(command):
    devnull = open(os.devnull, 'w')
    return subprocess.call(command, stdout=devnull, stderr=devnull) == 0

# Executes a command and returns its output.
def cmd_output(command):
    try:
        return subprocess.check_output(command, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError:
        return False

# Executes a command and prints a nice line about its execution status.
def execute(description, command, skip_if=None, wait_until=None):
    write('%s... ' % description)

    if skip_if and skip_if():
        print('skipped')
        return

    if cmd(command):
        if wait_until:
            write('(waiting) ')
            wait_until()
        print('success')
    else:
        print('error')

# Wait for a command to return success.
def wait_cmd(args):
    while not cmd(args):
        time.sleep(1)

# Writes a OS X setting using 'defaults' helper.
def write_setting(*args):
    args = ('defaults', 'write') + args
    execute(description=' '.join(args),
            command=args)

# Returns True if fish shell is already user's shell.
def fish_is_default_shell():
    output = cmd_output(['dscacheutil', '-q', 'user', '-a', 'name', os.getlogin()])
    expected_str = 'shell: /usr/local/bin/fish'
    return expected_str in output

# Returns True if local Time-Machine backups are disabled.
def tm_local_backup_disabled():
    plist = '/Library/Preferences/com.apple.TimeMachine.plist'
    output = cmd_output(['defaults', 'read', plist, 'MobileBackups'])
    return output.strip() == '0'

# Returns True if brew is installed.
def brew_installed():
    return cmd(['command', '-v', 'brew'])

# Returns True if a brew package is installed.
def brew_pkg_installed(name):
    return cmd(['brew', 'list', name])

# Returns True if a brew cask package is installed.
def cask_pkg_installed(name):
    return cmd(['brew', 'cask', 'list', name])

# Returns True if command line utils is installed.
def xcode_installed():
    return cmd(['xcode-select', '-p'])

# Waits for command line utils installation.
def wait_xcode_prompt():
    return wait_cmd(['xcode-select', '-p'])

#
# Setup
#

print('== Homebrew setup ==')

execute(description='Installing command line tools',
        command=['xcode-select', '--install'],
        skip_if=xcode_installed,
        wait_until=wait_xcode_prompt)

execute(description='Downloading Homebrew installer',
        command=['curl', '-o', BREW_INSTALLER, '-fsSL', BREW_URL],
        skip_if=brew_installed)

execute(description='Installing Homebrew',
        command=['ruby', BREW_INSTALLER],
        skip_if=brew_installed)

execute(description='Removing Homebrew installer',
        command=['rm', BREW_INSTALLER],
        skip_if=brew_installed)

execute(description='Turning off Homebrew analytics',
        command=['brew', 'analytics', 'off'])

execute(description='Installing Homebrew cask',
        command=['brew', 'tap', 'caskroom/cask'])

print('== Homebrew packages ==')

for pkg in BREW_PACKAGES:
    execute(description='Installing %s' % pkg,
            command=['brew', 'install', pkg],
            skip_if=lambda: brew_pkg_installed(pkg))

print('== Homebrew casks ==')

for pkg in CASK_PACKAGES:
    execute(description='Installing %s' % pkg,
            command=['brew', 'cask', 'install', '--appdir=/Applications', pkg],
            skip_if=lambda: cask_pkg_installed(pkg))

print('== Dotfiles setup ==')

execute(description='Changing shell to fish',
        command=['sudo', 'chsh', '-s', '/usr/local/bin/fish', os.getlogin()],
        skip_if=fish_is_default_shell)

execute(description='Linking fish files',
        command=['stow', 'fish', '--no-folding'])

print('== OS X settings ==')

# use dark menus
write_setting('-g', 'AppleInterfaceStyle', 'Dark')
# keyboard key repeat rate
write_setting('-g', 'InitialKeyRepeat', '-int', '10')
write_setting('-g', 'KeyRepeat', '-int', '1')
# enable full keyboard access for all controls
write_setting('-g', 'AppleKeyboardUIMode', '-int', '3')
# disable shadow in screenshots
write_setting('com.apple.screencapture', 'disable-shadow', '-bool', 'true')
# disable auto-correct
write_setting('-g', 'NSAutomaticSpellingCorrectionEnabled', '-bool', 'false')
# disable smart quotes and smart dashes
write_setting('-g', 'NSAutomaticQuoteSubstitutionEnabled', '-bool', 'false')
write_setting('-g', 'NSAutomaticDashSubstitutionEnabled', '-bool', 'false')

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
write_setting('-g', 'AppleShowAllExtensions', '-bool', 'true')
# display full path as finder window title
write_setting('com.apple.finder', '_FXShowPosixPathInTitle', '-bool', 'true')
# search the current folder by default
write_setting('com.apple.finder', 'FXDefaultSearchScope', '-string', '"SCcf"')
# disable the warning when changing a file extension
write_setting('com.apple.finder', 'FXEnableExtensionChangeWarning', '-bool', 'false')
# use column view in all finder windows by default
write_setting('com.apple.finder', 'FXPreferredViewStyle', 'Clmv')
# avoid creation of .DS_Store files on network volumes
write_setting('com.apple.desktopservices', 'DSDontWriteNetworkStores', '-bool', 'true')

for app in ['Dock', 'Finder', 'SystemUIServer', 'cfprefsd']:
    execute(description='Restarting %s' % app,
            command=['killall', app])

print('== Extra settings ==')

execute(description='Disabling local time machine backups',
        command=['sudo', 'tmutil', 'disablelocal'],
        skip_if=tm_local_backup_disabled)

execute(description='Setting up brew crontab',
        command=['crontab', 'crontab/brew'])

print('== Cleaning up space ==')

execute(description='Cleaning up brew space',
        command=['brew', 'cleanup'])

execute(description='Cleaning up brew cask space',
        command=['brew', 'cask', 'cleanup'])
