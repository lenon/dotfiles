#!/usr/bin/env ruby

def info(str)
  STDERR.puts str
end

module OS
  module_function

  def mac?
    RUBY_PLATFORM.downcase.include? 'darwin'
  end
end

module Homebrew
  module_function

  def installed?
    system 'command -v brew >/dev/null 2>&1'
  end

  def install
    system 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
  end

  def pkg_installed?(pkg)
    system "brew list #{pkg} >/dev/null 2>&1"
  end

  def install_pkg(pkg)
    system "brew install #{pkg}"
  end

  def cleanup
    system 'brew cleanup >/dev/null 2>&1'
  end
end

module Cask
  module_function

  def pkg_installed?(pkg)
    system "brew cask list #{pkg} >/dev/null 2>&1"
  end

  def install_pkg(pkg)
    system "brew cask install --appdir=/Applications #{pkg}"
  end

  def cleanup
    system 'brew cask cleanup >/dev/null 2>&1'
  end
end

unless OS.mac?
  abort 'This script only works on Mac OS X'
end

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
