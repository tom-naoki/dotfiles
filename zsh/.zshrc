# ====================
# Powerlevel10k設定
# ====================
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
# prezto set prompt thme "powerlevel10k" at ~/.p10k.zsh
# and fix ~/.p10k.zsh with reference to https://github.com/romkatv/powerlevel10k/issues/2019

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ====================
# 基本環境設定
# ====================
# prezto 設定
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# エディタ設定
export EDITOR=code
export BUNDLER_EDITOR='code'

# 自動補完を有効
autoload -U compinit; compinit
# ディレクトリ名だけでcd
setopt auto_cd
# Tab で候補からパス名を選択できるようになる
zstyle ':completion:*:default' menu select=1

# .aliasrc の読み込み
source ~/.aliasrc

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ====================
# PATH環境変数設定
# ====================
# Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Ruby
export PATH="$HOME/.rbenv/shims:$PATH"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin:$HOME"

# asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# Node.js環境(nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# diff-highlight
export PATH="$PATH:/opt/homebrew/share/git-core/contrib/diff-highlight"

# ====================
# direnv設定
# ====================
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

# 追加のdirenv hook
eval "$(direnv hook zsh)"

# ====================
# zplug設定とプラグイン
# ====================
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

zplug load --verbose

# ====================
# peco関連の便利機能
# ====================
# [peco] コマンド履歴
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N peco-history-selection
bindkey '^H' peco-history-selection

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

# [peco] move directory from ghq list
function peco-ghq-cd() {
  local selected_dir=$(ghq list | sed -r 's/(.*)\/(.*)\/(.*)/\1 | \2 | \3/' | peco --query "$LBUFFER" | sed 's/ | /\//g')
  if [ -n "$selected_dir" ]; then
    cd "$HOME/ghq/$selected_dir"
    BUFFER="cd $HOME/ghq/$selected_dir"
    zle accept-line
  fi
}
zle -N peco-ghq-cd
bindkey '^G' peco-ghq-cd

# ====================
# Git関連の便利機能
# ====================
# [peco] branch移動
function peco-git-switch {
    git branch --sort=-authordate | peco | xargs git switch
}
zle -N peco-git-switch
alias g-switch="peco-git-switch"

function peco-git-switch-with-diff {
    git branch --sort=-authordate | peco | xargs git sw-with-diff
}
zle -N peco-git-switch-with-diff
alias g-switch-with-diff="peco-git-switch-with-diff"

# [peco] git command from git config
function peco-git-config-aliases() {
  git $(git config --list | grep alias | sed -e "s/^alias\.\([^=]*\).*/\1/g" | grep - | peco)
}
alias g-aliases="peco-git-config-aliases"

# [peco] git rebase from git log
function peco-git-rebase() {
  git rebase -i $(git logn $1 | peco | awk '{print $1}')
}
alias g-rebasei="peco-git-rebase"

# [peco] select code command first argument from git status files
function peco-code-open-file-from-git-status() {
  # MM ではじまる場合は、M&M に変換する
  # なにも選択されなかった場合は　、code command を実行しない
  local selected_file=$(git status -s | peco | awk '{print $2}' | sed -e "s/^M/&&/g")
  if [ -n "$selected_file" ]; then
    code $selected_file
  fi
}
alias code-gs="peco-code-open-file-from-git-status"

# [peco] git add first argument from git status files
function peco-git-add-from-git-status() {
  # 'M ' ではじまるファイルはすでにaddされているので、対象から除外する
  # 'MM', 'M ' , ' M' で始まる場合は、その部分を削除する
  local selected_file=$(git status -s | grep -v "^M " | peco | awk '{print $2}' | sed -e "s/^M/&&/g")
  if [ -n "$selected_file" ]; then
    git add -p $selected_file; git status
  fi
}
alias g-add="peco-git-add-from-git-status"

# ====================
# その他の便利機能
# ====================
# [peco] GCP configulation
function peco-gcp-config() {
  gcloud config configurations activate $(gcloud config configurations list | peco | awk '{print $1}' | grep -v NAME )
}
alias gcpconfig="peco-gcp-config"

# [peco] docker logs
function peco-docker-logs() {
  local selected_container=$(docker ps | peco | awk '{print $1}')
  if [ -n "$selected_container" ]; then
    docker logs -f $selected_container
  fi
}
alias docker-logs="peco-docker-logs"
