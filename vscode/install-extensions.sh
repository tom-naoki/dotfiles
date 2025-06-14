#!/usr/bin/env bash
set -euo pipefail

LIST_FILE="$(dirname "$0")/extensions.txt"

#####################################################################
# 0. いま入っている拡張をバックアップしておく（任意）
#####################################################################
code --list-extensions > "${LIST_FILE%.txt}-backup-$(date +%Y%m%d%H%M).txt"

#####################################################################
# 1. 既存拡張をすべてアンインストール
#####################################################################
echo "🗑  uninstalling existing extensions..."
code --list-extensions | while read -r ext; do
  echo "  - $ext"
  code --uninstall-extension "$ext" --force
done

#####################################################################
# 2. リストから再インストール
#####################################################################
echo "⬇  installing from ${LIST_FILE}..."
grep -v '^\s*#' "$LIST_FILE" | while read -r ext; do
  [[ -z "$ext" ]] && continue   # 空行スキップ
  echo "  + $ext"
  code --install-extension "$ext" --force
done

echo "✅  done!"