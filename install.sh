#!/bin/zsh

# install packges
brew install nodenv
brew install pyenv
brew install rbenv
brew install direnv
brew install tig
brew install bat
brew install peco
brew install go
brew install jq

# install zprezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

# symlink links
ln -sf ~/dotfiles/vim/.vimrc ~/.vimrc
ln -sf ~/dotfiles/vim/colors ~/.vim/colors
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.aliasrc ~/.aliasrc
ln -sf ~/dotfiles/.tigrc ~/.tigrc
ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.gitignore_global ~/.gitignore_global
# install vim color
mkdir ~/Desktop/vim_color
git clone https://github.com/jacoborus/tender.vim.git ~/Desktop/vim_color
git clone https://github.com/tomasr/molokai ~/Desktop/vim_color
git clone https://github.com/w0ng/vim-hybrid ~/Desktop/vim_color
mv ~/Desktop/vim_color/tender/tender.vim ~/.vim/colors
mv ~/Desktop/vim_color/molokai/colors/molokai.vi ~/.vim/colors
mv ~/Desktop/vim_color/vim-hybrid/colors/hybrid.vim ~/.vim/colors

# add .gitconfig files
mkdir ~/.git
touch ~/.git/.gitconfig.local

# change shell
chsh -s $(which zsh)
source ~/.zshrc

# set theme
echo "change theme to powerlevel10k : ~/.zpreztorc";
ln -sf ~/.p10k.zsh ~/dotfiles/.p10k.zsh
