#!/usr/bin/env ruby

def info(str)
  STDERR.puts str
end

# OS helpers.
module OS
  module_function

  # Returns false if the current OS is not Mac OS X.
  def mac?
    RUBY_PLATFORM.downcase.include? 'darwin'
  end
end

# Homebrew is a package manager for OS X. This module provides some functions
# to check if it is installed, to install it and to install its packages.
module Homebrew
  module_function

  # Returns true if Homebrew is installed.
  def installed?
    system 'command -v brew >/dev/null 2>&1'
  end

  # Installs Homebrew.
  def install
    system 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
  end

  # Returns true if a Homebrew package is installed.
  def pkg_installed?(pkg)
    system "brew list #{pkg} >/dev/null 2>&1"
  end

  # Installs a Homebrew package.
  def install_pkg(pkg)
    system "brew install #{pkg}"
  end

  # Clean up old Homebrew packages.
  def cleanup
    system 'brew cleanup >/dev/null 2>&1'
  end
end

# Cask is a package manager for GUI apps on OS X. It is an extension for
# Homebrew.
module Cask
  module_function

  # Returns true if a Cask package is installed.
  def pkg_installed?(pkg)
    system "brew cask list #{pkg} >/dev/null 2>&1"
  end

  # Installs a Cask package.
  def install_pkg(pkg)
    system "brew cask install --appdir=/Applications #{pkg}"
  end

  # Clean up old Cask packages.
  def cleanup
    system 'brew cask cleanup >/dev/null 2>&1'
  end
end

abort 'This script only works on Mac OS X' unless OS.mac?

if Homebrew.installed?
  info 'Homebrew is already installed, skipping'
else
  info 'Installing Homebrew...'

  if Homebrew.install
    info 'Homebrew installed'
  else
    abort 'Homebrew was not installed due to a problem'
  end
end

packages = File.readlines('packages').map(&:strip)
casks = File.readlines('casks').map(&:strip)

info 'Installing Homebrew packages...'

packages.each do |pkg|
  if Homebrew.pkg_installed?(pkg)
    info "#{pkg} is already installed, skipping"
  else
    info "Installing #{pkg}"

    if Homebrew.install_pkg(pkg) && Homebrew.pkg_installed?(pkg)
      info "#{pkg} installed"
    else
      abort "#{pkg} was not installed due to a problem"
    end
  end
end

info 'Installing cask packages...'

casks.each do |pkg|
  if Cask.pkg_installed?(pkg)
    info "#{pkg} is already installed, skipping"
  else
    info "Installing #{pkg}"

    if Cask.install_pkg(pkg) && Cask.pkg_installed?(pkg)
      info "#{pkg} installed"
    else
      abort "#{pkg} was not installed due to a problem"
    end
  end
end

info 'Cleaning old packages...'

Homebrew.cleanup
Cask.cleanup

info 'Done!'
