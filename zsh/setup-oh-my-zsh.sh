#!/bin/bash

# スクリプトの実行ディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "================================================"
echo "Oh My Zsh セットアップスクリプト"
echo "================================================"

# oh-my-zshのインストール（既にインストールされている場合はスキップ）
if [ ! -d ~/.oh-my-zsh ]; then
    echo "oh-my-zshをインストールしています..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ oh-my-zshをインストールしました"
else
    echo "✓ oh-my-zshは既にインストールされています"
fi

# oh-my-zshの設定ディレクトリを作成
mkdir -p "$DOTFILES_DIR/zsh/oh-my-zsh"
echo "✓ oh-my-zsh設定ディレクトリを作成しました"

# 1. 既存の ~/.zshrc を ~/.zshrc.pre-oh-my-zsh として保存
if [ -f ~/.zshrc ] && [ ! -L ~/.zshrc.pre-oh-my-zsh ]; then
    # ~/.zshrc が既にシンボリックリンクの場合はそのまま .pre-oh-my-zsh にリネーム
    if [ -L ~/.zshrc ]; then
        mv ~/.zshrc ~/.zshrc.pre-oh-my-zsh
        echo "✓ 既存の~/.zshrc（シンボリックリンク）を~/.zshrc.pre-oh-my-zshに移動しました"
    else
        # 通常のファイルの場合はバックアップを作成してからシンボリックリンクを作成
        cp ~/.zshrc ~/.zshrc.backup
        rm ~/.zshrc
        ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc.pre-oh-my-zsh
        echo "✓ 既存の~/.zshrcをバックアップし、~/.zshrc.pre-oh-my-zshにシンボリックリンクを作成しました"
    fi
else
    # .pre-oh-my-zsh がまだ存在しない場合は作成
    if [ ! -L ~/.zshrc.pre-oh-my-zsh ]; then
        ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc.pre-oh-my-zsh
        echo "✓ ~/.zshrc.pre-oh-my-zshにシンボリックリンクを作成しました"
    else
        echo "✓ ~/.zshrc.pre-oh-my-zshは既に存在します"
    fi
fi

# 2. oh-my-zshが作成した.zshrcをdotfiles配下に移動（初回のみ）
if [ ! -f "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc" ]; then
    if [ -f ~/.oh-my-zsh/templates/zshrc.zsh-template ]; then
        # テンプレートをコピー
        cp ~/.oh-my-zsh/templates/zshrc.zsh-template "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "✓ oh-my-zshの.zshrcテンプレートをdotfiles配下にコピーしました"
    fi
fi

# 3. oh-my-zsh用の.zshrcに必要な設定を追加
if [ -f "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc" ]; then
    # 既存の設定を読み込む行を追加（まだ追加されていない場合）
    if ! grep -q "source ~/.zshrc.pre-oh-my-zsh" "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"; then
        echo "" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "# ====================" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "# 元々作成している .zshrc (~/.zshrc.pre-oh-my-zsh) の読み込み" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "# ====================" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "if [ -f ~/.zshrc.pre-oh-my-zsh ]; then" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "  source ~/.zshrc.pre-oh-my-zsh" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "fi" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "✓ 既存の設定を読み込む行を追加しました"
    fi

    # company-specific の読み込み行を追加（まだ追加されていない場合）
    if ! grep -q "source ~/.zshrc.company-specific" "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"; then
        echo "" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "# ====================" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "# 所属組織固有の設定ファイルの読み込み" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "# ====================" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "if [ -f ~/.zshrc.company-specific ]; then" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "  source ~/.zshrc.company-specific" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "fi" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "✓ company-specific設定を読み込む行を追加しました"
    fi

    # oh-my-zsh上書き設定の読み込み行を追加（まだ追加されていない場合）
    if ! grep -q "source ~/.zshrc.oh-my-zsh" "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"; then
        echo "" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "# ====================" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "# 上書きする設定ファイル (zsh/oh-my-zsh/.zshrc.oh-my-zsh) の読み込み" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "# ====================" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "if [ -f ~/.zshrc.oh-my-zsh ]; then" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "  source ~/.zshrc.oh-my-zsh" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "fi" >> "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
        echo "✓ 上書き設定を読み込む行を追加しました"
    fi
fi

# 4. ~/.zshrc.oh-my-zsh のシンボリックリンクを作成
if [ ! -L ~/.zshrc.oh-my-zsh ]; then
    ln -sf "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc.oh-my-zsh" ~/.zshrc.oh-my-zsh
    echo "✓ ~/.zshrc.oh-my-zshにシンボリックリンクを作成しました"
else
    echo "✓ ~/.zshrc.oh-my-zshは既に存在します"
fi

# 5. ~/.zshrc.company-specific ファイルを作成（存在しない場合のみ）
if [ ! -f ~/.zshrc.company-specific ]; then
    echo "# 所属組織固有の設定を追加する" > ~/.zshrc.company-specific
    echo "✓ ~/.zshrc.company-specificを作成しました"
else
    echo "✓ ~/.zshrc.company-specificは既に存在します"
fi

# 6. メインの ~/.zshrc をoh-my-zsh用の設定ファイルにリンク
if [ -L ~/.zshrc ]; then
    # 既にシンボリックリンクの場合は削除
    rm ~/.zshrc
fi
ln -sf "$DOTFILES_DIR/zsh/oh-my-zsh/.zshrc" ~/.zshrc
echo "✓ ~/.zshrcをoh-my-zsh用の設定ファイルにリンクしました"

echo ""
echo "================================================"
echo "セットアップが完了しました！"
echo "================================================"
echo ""
echo "【設定ファイルの構成】"
echo "  ~/.zshrc"
echo "    → $DOTFILES_DIR/zsh/oh-my-zsh/.zshrc"
echo ""
echo "  ~/.zshrc.pre-oh-my-zsh"
echo "    → $DOTFILES_DIR/zsh/.zshrc"
echo ""
echo "  ~/.zshrc.oh-my-zsh"
echo "    → $DOTFILES_DIR/zsh/oh-my-zsh/.zshrc.oh-my-zsh"
echo ""
echo "  ~/.zshrc.company-specific"
echo "    （組織固有の設定を記述してください）"
echo ""
echo "ターミナルを再起動するか、'source ~/.zshrc' を実行してください。"
