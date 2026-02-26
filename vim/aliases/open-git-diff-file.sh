# git status + fzf + vim
#
# git status の変更ファイルを fzf で選択して vim で開く
# staged / not staged / untracked をセクション分けして色付き表示する
gvi() {
  local green=$'\033[32m' red=$'\033[31m' reset=$'\033[0m' white=$'\033[37m'
  local list=""
  local staged="" unstaged="" untracked=""

  while IFS= read -r line; do
    local x="${line:0:1}"
    local y="${line:1:1}"
    local file="${line:3}"

    local label=""
    case "$x" in
      A) label="new file:" ;; M) label="modified:" ;; D) label="deleted:" ;;
      R) label="renamed:" ;; C) label="copied:" ;;
    esac

    if [[ "$x" != " " && "$x" != "?" ]]; then
      staged+="${green}    ${label}	${file}${reset}"$'\n'
    fi

    if [[ "$y" != " " && "$x" != "?" ]]; then
      local wt_label=""
      case "$y" in M) wt_label="modified:" ;; D) wt_label="deleted:" ;; esac
      unstaged+="${red}    ${wt_label}	${file}${reset}"$'\n'
    fi

    if [[ "$x" == "?" ]]; then
      untracked+="${red}    	${file}${reset}"$'\n'
    fi
  done < <(git status --porcelain)

  if [ -n "$staged" ]; then
    list+="${white}====[staged]====${reset}"$'\n'"${staged}"
  fi
  if [ -n "$unstaged" ]; then
    list+="${white}====[not staged]====${reset}"$'\n'"${unstaged}"
  fi
  if [ -n "$untracked" ]; then
    list+="${white}====[Untracked files]====${reset}"$'\n'"${untracked}"
  fi

  if [ -z "$list" ]; then
    echo "No changes."
    return 0
  fi

  local selected
  selected=$(echo "${list%$'\n'}" | fzf --ansi --prompt "EDIT FILE > " --no-sort --reverse)

  if [ -z "$selected" ] || [[ "$selected" == *====* ]]; then
    return 0
  fi

  # タブ区切りの最後のフィールドがファイルパス
  local file
  file=$(echo "$selected" | awk -F'\t' '{print $NF}')

  if [[ "$file" == *" -> "* ]]; then
    file="${file##* -> }"
  fi

  vim "$file"
}
