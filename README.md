
### setup
```
brew install ghq
ghq get git@github.com:tom-naoki/dotfiles.git
cd ~/ghq/github.com/tom-naoki/dotfiles
./install.sh
```

setting oh-my-zsh
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

printf '\n[ -f ~/.zshrc.pre-oh-my-zsh ] && source ~/.zshrc.pre-oh-my-zsh\n' >> ~/.zshrc
```

### gitconfig設定
- `.gitconfig.local`を必要に応じて編集
