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
