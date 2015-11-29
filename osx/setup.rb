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

# Installs a package. "check" is a lambda used to check if the package is
# installed and "install" is a lambda that performs the installation.
def install_pkg(pkg, check, install)
  if check.call(pkg)
    info "#{pkg} is already installed, skipping"
  else
    info "Installing #{pkg}"

    if install.call(pkg) && check.call(pkg)
      info "#{pkg} installed"
    else
      abort "#{pkg} was not installed due to a problem"
    end
  end
end

info 'Installing Homebrew packages...'

packages = File.readlines('packages').map(&:strip)
packages.each do |pkg|
  perform_install(
    pkg,
    ->(p) { Homebrew.pkg_installed?(p) },
    ->(p) { Homebrew.install_pkg(p) }
  )
end

info 'Installing cask packages...'

casks = File.readlines('casks').map(&:strip)
casks.each do |pkg|
  perform_install(
    pkg,
    ->(p) { Cask.pkg_installed?(p) },
    ->(p) { Cask.install_pkg(p) }
  )
end

info 'Cleaning old packages...'

Homebrew.cleanup
Cask.cleanup

info 'Done!'
