#!/bin/bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-smoke.XXXXXX")"
test_root="$(cd "$test_root" && pwd)"
trap 'rm -rf "$test_root"' EXIT
fixture="$test_root/repo with spaces"
test_home="$test_root/home"
fake_bin="$test_root/bin"
mkdir -p "$fixture" "$test_home" "$fake_bin" "$test_root/elsewhere"
for path in install.sh vim zsh .aliasrc tig git ghostty peco; do
  cp -R "$repo_dir/$path" "$fixture/$path"
done

# 外部ツールはすべてスタブにし、設定ファイルの操作だけを一時HOMEで検証する。
cat > "$fake_bin/asdf" <<'STUB'
#!/bin/bash
set -euo pipefail
printf '%s\n' "$*" >> "$HOME/asdf-calls"
case "$1 $2" in
  'plugin list') cat "$HOME/plugins" ;;
  'plugin add') printf '%s\n' "$3" >> "$HOME/plugins" ;;
  'install ruby'|'install nodejs') test -n "$3" ;;
  'set -u')
    awk -v tool="$3" '$1 != tool' "$HOME/.tool-versions" > "$HOME/tool-versions.next"
    printf '%s %s\n' "$3" "$4" >> "$HOME/tool-versions.next"
    mv "$HOME/tool-versions.next" "$HOME/.tool-versions"
    ;;
  *) echo "未対応のasdfコマンド: $*" >&2; exit 1 ;;
esac
STUB
for name in brew chsh zsh; do
  printf '#!/bin/bash\nexit 0\n' > "$fake_bin/$name"
done
chmod +x "$fake_bin/"*
printf 'ruby\n' > "$test_home/plugins"
printf 'python 3.12.15\n' > "$test_home/.tool-versions"

run_install() {
  (cd "$test_root/elsewhere" && env -i HOME="$test_home" PATH="$fake_bin:/usr/bin:/bin" \
    /bin/bash "$fixture/install.sh") > "$test_root/install.log"
}

run_install
test "$(readlink "$test_home/.vimrc")" = "$fixture/vim/.vimrc"
test "$(readlink "$test_home/.vim/colors")" = "$fixture/vim/colors"
test "$(readlink "$test_home/Library/Application Support/com.mitchellh.ghostty/config")" = "$fixture/ghostty/config"
grep -qx 'python 3.12.15' "$test_home/.tool-versions"
grep -qx 'ruby 3.4.6' "$test_home/.tool-versions"
grep -qx 'nodejs 24.22.1' "$test_home/.tool-versions"
grep -qx 'plugin add nodejs' "$test_home/asdf-calls"
if grep -q '^plugin add ruby$' "$test_home/asdf-calls"; then
  echo '既存プラグインを追加し直しています' >&2
  exit 1
fi
test -f "$fixture/.tool-versions"
test ! -e "$test_root/elsewhere/.tool-versions"

# 再実行では同じリンクのバックアップや入力要求が発生しない。
run_install < /dev/null
test ! -e "$test_home/Desktop/setup-backup"

# 上書きを断ると既存ファイルを保持する。
rm "$test_home/.vimrc"
printf 'existing vim config\n' > "$test_home/.vimrc"
printf 'n\n' | run_install
test ! -L "$test_home/.vimrc"
grep -qx 'existing vim config' "$test_home/.vimrc"

# 承認した通常ファイルと切れたリンクは、衝突しない場所へ退避する。
rm "$test_home/.tigrc"
ln -s "$test_home/missing-tig" "$test_home/.tigrc"
printf 'y\ny\n' | run_install
test "$(readlink "$test_home/.vimrc")" = "$fixture/vim/.vimrc"
test "$(readlink "$test_home/.tigrc")" = "$fixture/tig/.tigrc"
backup_count="$(find "$test_home/Desktop/setup-backup/dotfiles" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
test "$backup_count" = 2
backup_file="$(find "$test_home/Desktop/setup-backup/dotfiles" -name .vimrc -type f)"
test -n "$backup_file"
grep -qx 'existing vim config' "$backup_file"
backup_link="$(find "$test_home/Desktop/setup-backup/dotfiles" -name .tigrc -type l)"
test "$(readlink "$backup_link")" = "$test_home/missing-tig"
echo 'PASS: 別ディレクトリ・空白パス・asdf移行・再実行・上書き拒否・バックアップ'
