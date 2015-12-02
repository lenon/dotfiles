#!/usr/bin/env ruby
require_relative 'lib/os'
require_relative 'lib/homebrew'
require_relative 'lib/cask'

def info(str)
  STDERR.puts str
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

packages = File.readlines(File.join(__dir__, 'config/packages')).map(&:strip)
packages.each do |pkg|
  install_pkg(
    pkg,
    ->(p) { Homebrew.pkg_installed?(p) },
    ->(p) { Homebrew.install_pkg(p) }
  )
end

info 'Installing cask packages...'

casks = File.readlines(File.join(__dir__, 'config/casks')).map(&:strip)
casks.each do |pkg|
  install_pkg(
    pkg,
    ->(p) { Cask.pkg_installed?(p) },
    ->(p) { Cask.install_pkg(p) }
  )
end

info 'Cleaning old packages...'

Homebrew.cleanup
Cask.cleanup

info 'Done!'
