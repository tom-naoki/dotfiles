#!/bin/bash
set -euo pipefail

# 呼び出し元の作業ディレクトリに依存せず、リポジトリの場所を取得する
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 必要なツールをインストールする
brew install --cask ghostty
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
for plugin in ruby nodejs; do
  if ! asdf plugin list | grep -qx "$plugin"; then
    asdf plugin add "$plugin"
  fi
done

# set fixed versions
RUBY_VERSION="3.4.6"
NODE_VERSION="24.22.1"

echo "Rubyバージョン: $RUBY_VERSION"
echo "Node.jsバージョン: $NODE_VERSION"

# install fixed versions
echo "指定バージョンをインストールしています..."
asdf install ruby "$RUBY_VERSION"
asdf install nodejs "$NODE_VERSION"

# create .tool-versions file
echo ".tool-versionsファイルを作成しています..."
cat > "$SCRIPT_DIR/.tool-versions" << EOF
ruby $RUBY_VERSION
nodejs $NODE_VERSION
EOF

# set global versions
echo "グローバルバージョンを設定しています..."
asdf set -u ruby "$RUBY_VERSION"
asdf set -u nodejs "$NODE_VERSION"

echo "asdfの設定が完了しました"

# create directories
mkdir -p ~/.vim
mkdir -p ~/.config/peco

# backup and symlink function
backup_and_symlink() {
  local source="$1"
  local target="$2"
  local backup_dir="$HOME/Desktop/setup-backup/dotfiles"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "設定済みです: $target"
    return
  fi

  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "既存のファイルが見つかりました: $target"
    read -p "バックアップを取って上書きしますか？ (y/n): " answer
    if [ "$answer" = "y" ]; then
      mkdir -p "$backup_dir"
      local backup_path
      backup_path="$(mktemp -d "$backup_dir/$(basename "$target").XXXXXX")"
      mv "$target" "$backup_path/"
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
backup_and_symlink "$SCRIPT_DIR/zsh/.zshrc.prompt-terminal" ~/.zshrc.prompt-terminal
backup_and_symlink "$SCRIPT_DIR/.aliasrc" ~/.aliasrc
backup_and_symlink "$SCRIPT_DIR/tig/.tigrc" ~/.tigrc
backup_and_symlink "$SCRIPT_DIR/git/.gitconfig" ~/.gitconfig
backup_and_symlink "$SCRIPT_DIR/git/.gitignore_global" ~/.gitignore_global
backup_and_symlink "$SCRIPT_DIR/git/.worktreerc" ~/.worktreerc
backup_and_symlink "$SCRIPT_DIR/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
backup_and_symlink "$SCRIPT_DIR/peco/config.json" "$HOME/.config/peco/config.json"

# Vimのカラースキームはリポジトリ内のvim/colorsを利用する。

# add .gitconfig files
mkdir -p ~/.git
touch ~/.git/.gitconfig.local

# change shell (最後に実行)
echo "シェルをzshに変更します..."
chsh -s "$(command -v zsh)"
echo "シェルの変更が完了しました。ターミナルを再起動してください。"
