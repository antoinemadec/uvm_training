#!/usr/bin/env bash

set -e

install_latest_neovim() {
  local url
  local filename
  url=https://github.com/neovim/neovim/releases/download/stable
  filename=nvim-linux64.tar.gz
  mkdir -p ~/src
  curl -sSL "${url}/${filename}" | tar -C "${HOME}/src" -xz -f -
}

cd ~
git clone http://github.com/antoinemadec/dotfiles
cat << EOF > ~/.gitconfig
[color]
  ui = auto
EOF

install_latest_neovim
pip3.8 install neovim --user

echo "pre_path ~/src/nvim-linux64/bin" > ~/.bashrc.local
