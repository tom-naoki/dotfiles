#!/bin/zsh

# スクリプトの先頭に追加
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
brew install ghq

# install zprezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

# create .vim directory
mkdir -p ~/.vim/colors

# backup and symlink function
backup_and_symlink() {
  local source=$1
  local target=$2
  local backup_dir="$HOME/Desktop/setup-backup/dotfiles"
  
  if [ -e "$target" ]; then
    echo "既存のファイルが見つかりました: $target"
    read -p "バックアップを取って上書きしますか？ (y/n): " answer
    if [ "$answer" = "y" ]; then
      mkdir -p "$backup_dir"
      mv "$target" "$backup_dir/$(basename $target)"
      ln -sf "$source" "$target"
      echo "バックアップを作成し、シンボリックリンクを設定しました"
    else
      echo "スキップしました: $target"
    fi
  else
    ln -sf "$source" "$target"
    echo "シンボリックリンクを設定しました: $target"
  fi
}

symlink links with backup
backup_and_symlink "$SCRIPT_DIR/vim/.vimrc" ~/.vimrc
backup_and_symlink "$SCRIPT_DIR/vim/colors" ~/.vim/colors
backup_and_symlink "$SCRIPT_DIR/zsh/.zshrc" ~/.zshrc
backup_and_symlink "$SCRIPT_DIR/.aliasrc" ~/.aliasrc
backup_and_symlink "$SCRIPT_DIR/tig/.tigrc" ~/.tigrc
backup_and_symlink "$SCRIPT_DIR/git/.gitconfig" ~/.gitconfig
backup_and_symlink "$SCRIPT_DIR/git/.gitignore_global" ~/.gitignore_global

# install vim color
rm -rf ~/Desktop/vim_color
mkdir -p ~/Desktop/vim_color
git clone https://github.com/jacoborus/tender.vim.git ~/Desktop/vim_color/tender
git clone https://github.com/tomasr/molokai ~/Desktop/vim_color/molokai
git clone https://github.com/w0ng/vim-hybrid ~/Desktop/vim_color/vim-hybrid

# move vim colors
mv ~/Desktop/vim_color/tender/tender.vim ~/.vim/colors/
mv ~/Desktop/vim_color/molokai/colors/molokai.vim ~/.vim/colors/
mv ~/Desktop/vim_color/vim-hybrid/colors/hybrid.vim ~/.vim/colors/

# cleanup
rm -rf ~/Desktop/vim_color

# add .gitconfig files
mkdir -p ~/.git
touch ~/.git/.gitconfig.local

# set theme
echo "change theme to powerlevel10k : ~/.zpreztorc"
ln -sf ~/dotfiles/.p10k.zsh ~/.p10k.zsh

# change shell (最後に実行)
echo "シェルをzshに変更します..."
chsh -s $(which zsh)
echo "シェルの変更が完了しました。ターミナルを再起動してください。"
