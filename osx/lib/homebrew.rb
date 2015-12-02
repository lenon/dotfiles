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
