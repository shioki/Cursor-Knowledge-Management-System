#!/usr/bin/env bash
# CKMS hooks 共通ライブラリ
#
# フックスクリプトは Cursor から起動され、stdin で JSON を受け取り stdout に JSON を返す。
# jq / python / node のいずれにも依存しないよう、必要最小限の処理だけを提供する。

# 知識ベースのベースディレクトリを検出する。
# skills/ を持つディレクトリを .agents → .claude → .cursor の順に探す。
# 見つからない場合は空文字を返す（呼び出し側で握りつぶす）。
ckms_detect_base() {
  local dir
  for dir in .agents .claude .cursor; do
    if [ -d "$dir/skills" ]; then
      printf '%s' "$dir"
      return 0
    fi
  done
  printf ''
}

# stdin のテキストを JSON 文字列の中身へエスケープして stdout に出す（前後の " は付けない）。
# バックスラッシュ・ダブルクォート・タブ・改行を処理する。Markdown の索引を通す用途では十分。
ckms_json_escape() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' -e 's/\r$//' \
    | awk 'BEGIN { ORS = "" } { if (NR > 1) printf "\\n"; print }'
}

# Markdown のタイトルを取り出す。frontmatter の title を優先し、無ければ最初の H1。
# デバッグセッションのように frontmatter を持たない形式にも対応する。
ckms_read_title() {
  local file="$1"
  [ -f "$file" ] || return 0
  awk '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { in_fm = 0; next }
    in_fm && /^title:[[:space:]]*/ {
      sub(/^title:[[:space:]]*/, "")
      gsub(/^["'"'"']|["'"'"']$/, "")
      # ダブルクォート YAML の \" と \\ を元に戻す（順序: \" を先に）
      gsub(/\\"/, "\"")
      gsub(/\\\\/, "\\")
      if (length($0) > 0) { print; exit }
    }
    !in_fm && /^# / {
      sub(/^# /, "")
      print
      exit
    }
  ' "$file"
}

# フックの設定値を読む。設定ファイルは <base>/knowledge-hooks.conf（key=value 形式）。
# Usage: ckms_conf <base> <key> <default>
ckms_conf() {
  local base="$1" key="$2" fallback="$3" conf value
  conf="${base}/knowledge-hooks.conf"
  [ -f "$conf" ] || { printf '%s' "$fallback"; return 0; }
  value=$(sed -n "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*//p" "$conf" | tail -n 1 | tr -d '[:space:]')
  [ -n "$value" ] && printf '%s' "$value" || printf '%s' "$fallback"
}

# 何もしないで正常終了する。フックは失敗しても本体を止めないのが原則。
ckms_noop_exit() {
  printf '{}'
  exit 0
}
