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

# 蓄積済み知識（技術判断・パターン・改善記録・デバッグセッション）の索引を
# Markdown テキストとして組み立てる。中身は読み込まず、ファイル名とタイトルの
# 一覧だけを返す。エージェント間で共通のロジックなので、sessionStart 系の
# hook（Cursor の inject-knowledge-index.sh、Claude Code の session-start.sh）
# の両方から呼ぶ。
#
# 該当する記録が 1 件もない場合は空文字を返す（呼び出し側で noop に分岐する）。
#
# Usage: ckms_build_knowledge_index <base>
ckms_build_knowledge_index() {
  local base="$1" max_entries body

  max_entries="$(ckms_conf "$base" index_max_entries 30)"
  case "$max_entries" in
    ''|*[!0-9]*) max_entries=30 ;;
  esac

  # カテゴリ内のファイルを「- ファイル名 — title」の形式で列挙する。
  # Usage: _ckms_list_category <ディレクトリ> <見出し>
  _ckms_list_category() {
    local dir="$1" heading="$2" count=0 total=0 file title
    [ -d "$dir" ] || return 0

    total=$(find "$dir" -maxdepth 1 -name '*.md' ! -name 'README.md' 2>/dev/null | wc -l | tr -d ' ')
    [ "$total" -gt 0 ] || return 0

    printf '\n### %s（%s 件）\n' "$heading" "$total"
    while IFS= read -r file; do
      [ "$count" -lt "$max_entries" ] || break
      title="$(ckms_read_title "$file")"
      if [ -n "$title" ]; then
        printf -- '- `%s` — %s\n' "$(basename "$file")" "$title"
      else
        printf -- '- `%s`\n' "$(basename "$file")"
      fi
      count=$((count + 1))
    done <<< "$(find "$dir" -maxdepth 1 -name '*.md' ! -name 'README.md' 2>/dev/null | sort -r)"

    if [ "$total" -gt "$count" ]; then
      printf -- '- （ほか %s 件。ディレクトリを一覧して確認してください）\n' "$((total - count))"
    fi
  }

  body="$(
    _ckms_list_category "${base}/skills/knowledge-management/references/decisions" "技術判断"
    _ckms_list_category "${base}/skills/pattern-library/references/patterns" "実装パターン"
    _ckms_list_category "${base}/skills/improvement-tracking/references/improvements" "改善記録"
    _ckms_list_category "${base}/debug-sessions" "デバッグセッション"
  )"

  [ -n "$body" ] || return 0

  printf '## このプロジェクトに蓄積済みの知識（索引）\n'
  printf '\n'
  printf 'ベースディレクトリ: `%s/`\n' "$base"
  printf '%s\n' "$body"
  printf '\n'
  printf 'これは索引です。内容が必要になった時点で該当ファイルだけを読んでください。\n'
  printf '関連する判断やパターンが既にある作業では、まずここを参照してから提案してください。\n'
}
