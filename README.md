
### セットアップ実行
```
brew install ghq
ghq get git@github.com:tom-naoki/dotfiles.git
cd ~/ghq/github.com/tom-naoki/dotfiles
./install.sh
```

### zsh設定
```
vi ~/.zpreztorc
# add zstyle pmodule `git`, `syntax-highlighting`, `autosuggestions`
# fix zstyle theme `powerlevel10k`

# install Powerline Fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh

# install Python
pyenv install --list
pyenv install x.x.x
pyenv versions
pyenv global x.x.x
python --version

# apply Powerline Shell
git clone https://github.com/b-ryan/powerline-shell
cd powerline-shell
python setup.py install
```

### gitconfig設定
- `.gitconfig.local`を必要に応じて編集
