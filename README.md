
### setup
```
brew install ghq
ghq get git@github.com:tom-naoki/dotfiles.git
cd ~/ghq/github.com/tom-naoki/dotfiles
bash ./install.sh
bash ./zsh/setup-oh-my-zsh.sh
```

### gitconfig設定
- `.gitconfig.local`を必要に応じて編集

### 初期設定の注意点

- `install.sh`と`zsh/setup-oh-my-zsh.sh`はBashで実行してください。
- 現行のasdf（0.16以降）を使用し、`asdf set -u`でホームのRuby／Node.jsの既定バージョンを設定します。他のツールの指定は保持します。
- `install.sh`はツールのインストール、設定ファイルのリンク作成、既定シェルの変更を行います。実行前に内容を確認してください。
- 同じリンクが設定済みならスキップします。既存ファイルや切れたリンクを置き換える場合は確認し、承認時に`~/Desktop/setup-backup/dotfiles/`配下の別々のフォルダへ退避します。
- Vimのカラースキームは`vim/colors/`内のファイルを使います。

### セットアップスクリプトの検証

```bash
bash -n install.sh
bash -n zsh/setup-oh-my-zsh.sh
bash tests/install-smoke.sh
```

スモークテストは一時HOMEとbrew・asdf・chshのスタブを使います。実際のツールのインストールや、ホームの設定・既定シェルの変更は行いません。
