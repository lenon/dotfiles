# dotfiles

These are my dotfiles. This project includes my development environment and the
setup that I'm using on macOS and Ubuntu.

## Requirements

* macOS or Ubuntu
* A terminal emulator

## Usage

This project uses a bare Git repository to manage dotfiles. You can read more
about it [here][1].

Execute the following commands to clone this repo:

    cd ~
    git clone --bare git@github.com:lenon/dotfiles.git .dotfiles.git
    git --git-dir .dotfiles.git --work-tree . checkout

If you are On macOS:

    .dotfiles/install.sh

It will install Command Line tools, Homebrew, Ansible and then will run the
setup playbook.

[1]: https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/
