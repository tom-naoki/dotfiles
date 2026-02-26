#!/bin/zsh

# スクリプトの先頭に追加
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# install packges
brew install asdf
brew install direnv
brew install tig
brew install bat
brew install peco
brew install go
brew install jq
brew install ghq

# setup asdf
echo "asdfのプラグインを追加しています..."
asdf plugin add ruby
asdf plugin add nodejs

# set fixed versions
RUBY_VERSION="3.4.6"
NODE_VERSION="24.9.0"

echo "Rubyバージョン: $RUBY_VERSION"
echo "Node.jsバージョン: $NODE_VERSION"

# install fixed versions
echo "指定バージョンをインストールしています..."
asdf install ruby $RUBY_VERSION
asdf install nodejs $NODE_VERSION

# create .tool-versions file
echo ".tool-versionsファイルを作成しています..."
cat > "$SCRIPT_DIR/.tool-versions" << EOF
ruby $RUBY_VERSION
nodejs $NODE_VERSION
EOF

# set global versions
echo "グローバルバージョンを設定しています..."
asdf global ruby $RUBY_VERSION
asdf global nodejs $NODE_VERSION

echo "asdfの設定が完了しました"

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

# symlink links with backup
backup_and_symlink "$SCRIPT_DIR/vim/.vimrc" ~/.vimrc
backup_and_symlink "$SCRIPT_DIR/vim/colors" ~/.vim/colors
backup_and_symlink "$SCRIPT_DIR/zsh/.zshrc" ~/.zshrc
backup_and_symlink "$SCRIPT_DIR/zsh/.zshrc.ghostty-worktree" ~/.zshrc.ghostty-worktree
backup_and_symlink "$SCRIPT_DIR/.aliasrc" ~/.aliasrc
backup_and_symlink "$SCRIPT_DIR/tig/.tigrc" ~/.tigrc
backup_and_symlink "$SCRIPT_DIR/git/.gitconfig" ~/.gitconfig
backup_and_symlink "$SCRIPT_DIR/git/.gitignore_global" ~/.gitignore_global
backup_and_symlink "$SCRIPT_DIR/git/.worktreerc" ~/.worktreerc

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

# change shell (最後に実行)
echo "シェルをzshに変更します..."
chsh -s $(which zsh)
echo "シェルの変更が完了しました。ターミナルを再起動してください。"
