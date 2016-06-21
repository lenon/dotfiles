#!/usr/bin/env python
import os
import tempfile
from utils import cmd, osx

BREW_PACKAGES = [
    'ag',
    'fish',
    'git',
    'go',
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
    'caskroom/fonts/font-hack',
    'caskroom/versions/iterm2-beta',
    'chromium',
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

STOW_DIRS = [
    'fish',
    'launchd'
]

LAUNCHD_FILES = [
    'brew_update.plist'
]

print('== Homebrew setup ==')

cmd.execute(desc='Installing command line tools',
            args='xcode-select --install',
            skip_if=lambda: cmd.run('xcode-select -p'),
            wait_for=lambda: cmd.wait('xcode-select -p'))

BREW_URL = 'https://raw.githubusercontent.com/Homebrew/install/master/install'
BREW_INSTALLED = lambda: cmd.run('command -v brew')

with tempfile.NamedTemporaryFile() as tmp:
    cmd.execute(desc='Downloading Homebrew installer',
                args=['curl', '-o', tmp.name, '-fsSL', BREW_URL],
                skip_if=BREW_INSTALLED)

    cmd.execute(desc='Installing Homebrew',
                args=['ruby', tmp.name],
                skip_if=BREW_INSTALLED)

cmd.execute(desc='Turning off Homebrew analytics',
            args='brew analytics off')

cmd.execute(desc='Installing Homebrew cask',
            args='brew tap caskroom/cask')

print('== Installing brew packages ==')

for pkg in BREW_PACKAGES:
    cmd.execute(desc='Installing %s' % pkg,
                args=['brew', 'install', pkg],
                skip_if=lambda: cmd.run(['brew', 'list', pkg]))

for pkg in CASK_PACKAGES:
    cmd.execute(desc='Installing %s' % pkg,
                args=['brew', 'cask', 'install', pkg],
                skip_if=lambda: cmd.run(['brew', 'cask', 'list', pkg]))

cmd.execute(desc='Cleaning up brew space',
            args='brew cleanup')

cmd.execute(desc='Cleaning up brew cask space',
            args='brew cask cleanup')

print('== Dotfiles setup ==')

cmd.execute(desc='Changing shell to fish',
            args=['sudo', 'chsh', '-s', '/usr/local/bin/fish', os.getlogin()],
            skip_if=lambda: osx.get_user_shell() == 'fish')

for _dir in STOW_DIRS:
    # 'no-folding' makes stow create a link for each file and not just a single
    # link for the root directory
    cmd.execute(desc='Linking %s files' % _dir,
                args=['stow', _dir, '--no-folding'])

for plist in LAUNCHD_FILES:
    file = os.path.join(os.path.expanduser('~'), 'Library', 'LaunchAgents', plist)

    cmd.execute(desc='Unloading %s' % plist,
                args=['launchctl', 'unload', file])

    cmd.execute(desc='Reloading %s' % plist,
                args=['launchctl', 'load', file])

print('== OS X settings ==')

# use dark menus
osx.write('-g AppleInterfaceStyle Dark')
# disable press-and-hold for keys in favor of key repeat
osx.write('-g ApplePressAndHoldEnabled -bool false')
# keyboard key repeat rate
osx.write('-g InitialKeyRepeat -int 15')
osx.write('-g KeyRepeat -int 2')
# enable full keyboard access for all controls
osx.write('-g AppleKeyboardUIMode -int 3')
# disable shadow in screenshots
osx.write('com.apple.screencapture disable-shadow -bool true')
# disable auto-correct
osx.write('-g NSAutomaticSpellingCorrectionEnabled -bool false')
# disable smart quotes and smart dashes
osx.write('-g NSAutomaticQuoteSubstitutionEnabled -bool false')
osx.write('-g NSAutomaticDashSubstitutionEnabled -bool false')
# enable a hover effect for stack folders in grid view
osx.write('com.apple.dock mouse-over-hilite-stack -bool true')
# set the icon size of dock items to 36 pixels
osx.write('com.apple.dock tilesize -int 36')
# change minimize/maximize window effect
osx.write('com.apple.dock mineffect -string scale')
# minimize windows into their application's icon
osx.write('com.apple.dock minimize-to-application -bool true')
# enable spring loading for all dock items
osx.write('com.apple.dock enable-spring-load-actions-on-all-items -bool true')
# show indicator lights for open applications in the dock
osx.write('com.apple.dock show-process-indicators -bool true')
# automatically hide and show the dock
osx.write('com.apple.dock autohide -bool true')
# make dock icons of hidden applications translucent
osx.write('com.apple.dock showhidden -bool true')
# show status bar
osx.write('com.apple.finder ShowStatusBar -bool true')
# show path bar
osx.write('com.apple.finder ShowPathbar -bool true')
# show icons for hard drives, servers and removable media on the desktop
osx.write('com.apple.finder ShowExternalHardDrivesOnDesktop -bool true')
osx.write('com.apple.finder ShowHardDrivesOnDesktop -bool true')
osx.write('com.apple.finder ShowMountedServersOnDesktop -bool true')
osx.write('com.apple.finder ShowRemovableMediaOnDesktop -bool true')
# show file extensions
osx.write('-g AppleShowAllExtensions -bool true')
# display full path as finder window title
osx.write('com.apple.finder _FXShowPosixPathInTitle -bool true')
# search the current folder by default
osx.write('com.apple.finder FXDefaultSearchScope -string "SCcf"')
# disable the warning when changing a file extension
osx.write('com.apple.finder FXEnableExtensionChangeWarning -bool false')
# use column view in all finder windows by default
osx.write('com.apple.finder FXPreferredViewStyle Clmv')
# avoid creation of .DS_Store files on network volumes
osx.write('com.apple.desktopservices DSDontWriteNetworkStores -bool true')

for app in ['Dock', 'Finder', 'SystemUIServer', 'cfprefsd']:
    cmd.execute(desc='Restarting %s' % app,
                args=['killall', app])

print('== Extra settings ==')

cmd.execute(desc='Disabling local time machine backups',
            args='sudo tmutil disablelocal',
            skip_if=osx.tm_local_backup_disabled)
