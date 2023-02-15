typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
# prezto set prompt thme "powerlevel10k" at ~/.p10k.zsh
# and fix ~/.p10k.zsh with reference to https://github.com/romkatv/powerlevel10k/issues/2019

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# direnv hook
_direnv_hook() {
  trap -- '' SIGINT;
  eval "$("/opt/homebrew/bin/direnv" export zsh)";
  trap - SIGINT;
}

typeset -ag precmd_functions;
if [[ -z "${precmd_functions[(r)_direnv_hook]+1}" ]]; then
  precmd_functions=( _direnv_hook ${precmd_functions[@]} )
fi
typeset -ag chpwd_functions;
if [[ -z "${chpwd_functions[(r)_direnv_hook]+1}" ]]; then
  chpwd_functions=( _direnv_hook ${chpwd_functions[@]} )
fi

# prezto 設定
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# path
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
export PATH="$HOME/.rbenv/shims:$PATH"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin:$HOME"

# 自動補完を有効
autoload -U compinit; compinit
# ディレクトリ名だけでcd
setopt auto_cd
# Tab で候補からパス名を選択できるようになる
zstyle ':completion:*:default' menu select=1

# [peco] コマンド履歴
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N peco-history-selection
bindkey '^H' peco-history-selection

# [peco] brahch移動
function peco-git-checkout {
    git branch --sort=-authordate | peco | xargs git checkout
}
zle -N peco-git-checkout
bindkey '^B' peco-git-checkout

# [peco] ディレクトリ移動
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
    zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/chpwd-recent-dirs"
fi
function peco-cdr () {
    local selected_dir="$(cdr -l | sed 's/^[0-9]* *//' | peco --prompt "cdr ❯" --query "$LBUFFER")"
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
}
zle -N peco-cdr
bindkey '^P' peco-cdr

# [peco] git command from git config
function peco-git-config-aliases() {
  git $(git config --list | grep alias | sed -e "s/^alias\.\([^=]*\).*/\1/g" | grep - | peco)
}
alias gp="peco-git-config-aliases"

# [peco] move directory from ghq list
function peco-ghq-cd() {
  local selected_dir=$(ghq list | sed -r 's/(.*)\/(.*)\/(.*)/\1 | \2 | \3/' | peco --query "$LBUFFER" | sed 's/ | /\//g')
  # local selected_dir=$(ghq list | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    cd "$HOME/ghq/$selected_dir"
    BUFFER="cd $HOME/ghq/$selected_dir"
    zle accept-line
  fi
}
zle -N peco-ghq-cd
bindkey '^G' peco-ghq-cd

# [peco] GCP configulation
function peco-gcp-config() {
  gcloud config configurations activate $(gcloud config configurations list | peco | awk '{print $1}' | grep -v NAME )
}
alias gcpp="peco-gcp-config"

# zplug
if [[ ! -d ~/.zplug ]];then
    git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

# plugins
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "b4b4r07/enhancd", use:"init.sh"

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load –verbose

# diff-highlight
export PATH="$PATH:/opt/homebrew/share/git-core/contrib/diff-highlight"

# tab color
tab-color() {
    echo -ne "\033]6;1;bg;red;brightness;$1\a"
    echo -ne "\033]6;1;bg;green;brightness;$2\a"
    echo -ne "\033]6;1;bg;blue;brightness;$3\a"
}

tab-reset() {
    echo -ne "\033]6;1;bg;*;default\a"
}

chpwd_tab_color() {
  case $PWD/ in
    */Users/kuratomi/Desktop/hogehoge/*) tab-color 60 179 113;; # green
    */Users/kuratomi/Desktop/hogehoge.txt) tab-color 240 128 128;; # yellow
    *) tab-reset;;
  esac
}

# setting tab name (iTerm2使用時に使用)
# vscode intergrated tab title からも参照される
# function chpwd() { ls; echo -ne "\033]0;$(pwd | rev | awk -F \/ '{print $1}'| rev)\007"}
function chpwd() { ls; echo -ne "\033]0;$(pwd | sed -e "s/.*\/\(.*\)\/\(.*\)$/\1\/\2/g" | sed -e "s/\(^.\)\(.*\)\/\(.*\)/\1\/\3/g")\007"}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd chpwd_tab_color

# .aliasrc の読み込み
source ~/.aliasrc

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export EDITOR=code
