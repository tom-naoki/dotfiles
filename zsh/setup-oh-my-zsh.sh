#!/bin/bash

# 既存の.zshrcのバックアップを作成
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup
    echo "既存の.zshrcをバックアップしました: ~/.zshrc.backup"
fi

# oh-my-zshのインストール（既にインストールされている場合はスキップ）
if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "oh-my-zshをインストールしました"
else
    echo "oh-my-zshは既にインストールされています"
fi

# oh-my-zshの設定ディレクトリを作成
mkdir -p zsh/oh-my-zsh

# oh-my-zshにより生成された.zshrcを移動
if [ -f ~/.zshrc ]; then
    mv ~/.zshrc zsh/oh-my-zsh/.zshrc
    echo "oh-my-zshの.zshrcを移動しました"
fi

# シンボリックリンクを作成
ln -sf "$(pwd)/zsh/oh-my-zsh/.zshrc" ~/.zshrc
echo "シンボリックリンクを作成しました"

# 既存の設定を読み込むように.zshrcを修正
if [ -f ~/.zshrc.pre-oh-my-zsh ]; then
    echo "\n" >> zsh/oh-my-zsh/.zshrc
    echo "# ====================" >> zsh/oh-my-zsh/.zshrc
    echo "# 元々作成している .zshrc (~/.zshrc.pre-oh-my-zsh) の読み込み" >> zsh/oh-my-zsh/.zshrc
    echo "# ====================" >> zsh/oh-my-zsh/.zshrc
    echo "source ~/.zshrc.pre-oh-my-zsh" >> zsh/oh-my-zsh/.zshrc
    echo "既存の設定を読み込むように修正しました"
fi

# 上書きする設定ファイルのシンボリックリンクを作成
if [ -f ~/.zshrc.oh-my-zsh ]; then
    ln -sf "$(pwd)/zsh/oh-my-zsh/.zshrc.oh-my-zsh" ~/.zshrc.oh-my-zsh
    echo "上書きする設定ファイルのシンボリックリンクを作成しました"
    echo "\n" >> zsh/oh-my-zsh/.zshrc
    echo "# ====================" >> zsh/oh-my-zsh/.zshrc
    echo "# 上書きする設定ファイル (zsh/oh-my-zsh/.zshrc.oh-my-zsh) の読み込み" >> zsh/oh-my-zsh/.zshrc
    echo "# ====================" >> zsh/oh-my-zsh/.zshrc
    echo "source ~/.zshrc.oh-my-zsh" >> zsh/oh-my-zsh/.zshrc
    echo "上書きする設定ファイルの読み込みを追加しました"
fi

# 設定が正しく行われたか確認
if [ ! -L ~/.zshrc ] || [ ! -f zsh/oh-my-zsh/.zshrc ]; then
    echo "エラー: 設定が正しく行われませんでした"
    exit 1
fi

echo "セットアップが完了しました。ターミナルを再起動してください。"
