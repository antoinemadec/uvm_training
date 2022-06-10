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

install_bat() {
  mkdir -p ~/src
  curl -sSL https://github.com/sharkdp/bat/releases/download/v0.16.0/bat-v0.16.0-x86_64-unknown-linux-musl.tar.gz |
    tar -C "${HOME}/src" -xz -f -
}

cd ~
git clone http://github.com/antoinemadec/dotfiles
cd dotfiles
./deploy
sed -i '/coc-clangd/d' ~/.vim/plugins_config/coc.nvim.vim
cat << EOF > ~/.gitconfig
[color]
  ui = auto
EOF

install_latest_neovim
install_bat
pip3.8 install neovim --user

cat <<EOF > ~/.bashrc.local
pre_path ~/src/nvim-linux64/bin
pre_path ~/src/bat-v0.16.0-x86_64-unknown-linux-musl
EOF
