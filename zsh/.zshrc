# ====================
# 基本環境設定
# ====================
# エディタ設定
export EDITOR=code
export BUNDLER_EDITOR='code'

# 自動補完を有効
autoload -U compinit; compinit
# ディレクトリ名だけでcd
setopt auto_cd
# .aliasrc の読み込み
source ~/.aliasrc

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
# peco関連設定
# ====================

# ----- cdrの設定 (peco-cdr用) -----
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
    zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/chpwd-recent-dirs"
fi

# ====================
# ナビゲーション関連機能
# ====================

# ----- コマンド履歴検索 (Ctrl + H) -----
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N peco-history-selection
bindkey '^H' peco-history-selection

# ----- 最近使用したディレクトリに移動 (Ctrl + P) -----
function peco-cdr () {
    local selected_dir="$(cdr -l | sed 's/^[0-9]* *//' | peco --prompt "cdr ❯" --query "$LBUFFER")"
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
}
zle -N peco-cdr
bindkey '^P' peco-cdr

# ----- ghqリポジトリに移動 (Ctrl + G) -----
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

# ----- ブランチ切り替え -----
function peco-git-switch {
    git branch --sort=-authordate | peco | xargs git switch
}
zle -N peco-git-switch
alias g-switch="peco-git-switch"

# ----- ブランチ切り替え(差分表示付き) -----
function peco-git-switch-with-diff {
    git branch --sort=-authordate | peco | xargs git sw-with-diff
}
zle -N peco-git-switch-with-diff
alias g-switch-with-diff="peco-git-switch-with-diff"

# ----- Gitエイリアスコマンド実行 -----
function peco-git-config-aliases() {
  git $(git config --list | grep alias | sed -e "s/^alias\.\([^=]*\).*/\1/g" | grep - | peco)
}
alias g-aliases="peco-git-config-aliases"

# ----- Gitリベース対話モード -----
function peco-git-rebase() {
  git rebase -i $(git logn $1 | peco | awk '{print $1}')
}
alias g-rebasei="peco-git-rebase"

# ----- 変更ファイルをVS Codeで開く -----
function peco-code-open-file-from-git-status() {
  # MMではじまる場合はM&Mに変換、選択なしの場合は何もしない
  local selected_file=$(git status -s | peco | awk '{print $2}' | sed -e "s/^M/&&/g")
  if [ -n "$selected_file" ]; then
    code $selected_file
  fi
}
alias code-gs="peco-code-open-file-from-git-status"

# ----- 変更ファイルをステージング -----
function peco-git-add-from-git-status() {
  # すでにaddされているファイル(M )は除外し、変更のあるファイルのみ表示
  local selected_file=$(git status -s | grep -v "^M " | peco | awk '{print $2}' | sed -e "s/^M/&&/g")
  if [ -n "$selected_file" ]; then
    git add -p $selected_file; git status
  fi
}
alias g-add="peco-git-add-from-git-status"

# ====================
# クラウド・インフラ関連機能
# ====================

# ----- GCP設定切り替え -----
function peco-gcp-config() {
  gcloud config configurations activate $(gcloud config configurations list | peco | awk '{print $1}' | grep -v NAME )
}
alias gcpconfig="peco-gcp-config"

# ----- Dockerコンテナログ表示 -----
function peco-docker-logs() {
  local selected_container=$(docker ps | peco | awk '{print $1}')
  if [ -n "$selected_container" ]; then
    docker logs -f $selected_container
  fi
}
alias docker-logs="peco-docker-logs"
