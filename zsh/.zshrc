# zsh の共通設定
# .zshrc.oh-my-zsh の読み込み前に読み込む
#
# 基本環境設定
# ====================
#
# エディタ設定
export EDITOR=code
export BUNDLER_EDITOR='code'

# 自動補完を有効
autoload -U compinit; compinit
# ディレクトリ名だけでcd
setopt auto_cd
# .aliasrc の読み込み
source ~/.aliasrc

# ターミナルパネルタイトルを変更
function update_terminal_title() {
  # Git リポジトリ名（末尾ディレクトリ）
  local git_repo
  git_repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)") || git_repo=""

  # カレントディレクトリ名
  local cwd_name="${PWD##*/}"

  # タイトル組み立て
  local title
  if [[ -n "$git_repo" ]]; then
    title="[$git_repo] $cwd_name"
  else
    title="$cwd_name"
  fi

  # VS Code / Cursor にタイトルを送る（OSC 0）
  print -Pn "\e]0;$title\a"
}

# プロンプト実行のたびに呼ぶ
autoload -Uz add-zsh-hook
add-zsh-hook precmd update_terminal_title

# ====================
# version
# ====================
# asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
. "$(brew --prefix asdf)/libexec/asdf.sh"
export ASDF_LEGACY_VERSION_FILE="yes"

# ====================
# PATH環境変数設定
# ====================
# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin:$HOME"

# Java
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# diff-highlight
export PATH="$PATH:/opt/homebrew/share/git-core/contrib/diff-highlight"

# local/bin
export PATH="$HOME/.local/bin:$PATH"


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
# peco/navigation設定
# ====================

# ----- コマンド履歴検索 (Ctrl + H) -----
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N peco-history-selection
bindkey '^H' peco-history-selection

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
