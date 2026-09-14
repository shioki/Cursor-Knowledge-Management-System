#!/usr/bin/env bash
# スキル・データディレクトリのパス検出と、知識ファイル生成の共通ヘルパー。
# プロジェクトルートから実行されることを想定している。
#
# 優先順: .agents/skills → .claude/skills → .cursor/skills
# SKILL_ROOT 環境変数を設定すると検出をバイパスできる。

if [ -n "${SKILL_ROOT:-}" ]; then
  SKILL_BASE="$SKILL_ROOT"
elif [ -d ".agents/skills" ]; then
  SKILL_BASE=".agents/skills"
elif [ -d ".claude/skills" ]; then
  SKILL_BASE=".claude/skills"
elif [ -d ".cursor/skills" ]; then
  SKILL_BASE=".cursor/skills"
else
  echo "エラー: .agents/skills / .claude/skills / .cursor/skills のいずれも見つかりません" >&2
  echo "プロジェクトルートから実行してください" >&2
  exit 1
fi

# データディレクトリ（debug-sessions 等）は必ず SKILL_BASE と同じ系統に置く。
# 独立に検出すると skills と data がずれる可能性があるため、親ディレクトリを使う。
DATA_BASE="$(dirname "$SKILL_BASE")"

# 文字列をファイル名用のスラッグへ変換する。
# 英数字とハイフン以外は除去する。日本語のみのタイトルなど結果が空になる場合は
# 引数で渡したフォールバックを使う（空ファイル名の生成を防ぐ）。
#
# Usage: ckms_slugify "タイトル" "フォールバック"
ckms_slugify() {
  local input="$1" fallback="${2:-entry}" slug
  # 改行は sed が行分割するため、先にスペースへ畳む（ファイル名への混入を防ぐ）
  slug=$(printf '%s' "$input" \
    | tr '\n\r' '  ' \
    | tr '[:upper:]' '[:lower:]' \
    | tr ' _/\\' '-' \
    | sed -e 's/[^a-z0-9-]//g' -e 's/--*/-/g' -e 's/^-//' -e 's/-$//')
  if [ -z "$slug" ]; then
    printf '%s' "$fallback"
  else
    printf '%s' "$slug"
  fi
}

# YAML frontmatter のスカラー用に、ダブルクォートで囲んでエスケープする。
# 改行はタイトルに不要なのでスペースへ畳む。呼び出し側は
#   title: $(ckms_yaml_escape "$TITLE")
# のように使う（本関数がクォートを付与する）。
#
# Usage: ckms_yaml_escape "文字列"
ckms_yaml_escape() {
  printf '%s' "$1" \
    | tr '\n\r' '  ' \
    | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/^/"/' -e 's/$/"/'
}

# Markdown 表セル用に、| と改行を無害化する。
#
# Usage: ckms_table_escape "文字列"
ckms_table_escape() {
  printf '%s' "$1" \
    | tr '\n\r' '  ' \
    | sed 's/|/\\|/g'
}

# ディレクトリ作成（mkdir はアトミック）でロックを取り、コマンドを実行する。
# Cursor と Claude Code を同一プロジェクトで並行利用すると、索引ファイルや
# ログファイルへの read-modify-write が競合しうるため、共有ファイルを書き
# 換える処理はこれで囲む。ロックが取れなくても記録そのものを諦めるよりは
# ましなので、一定時間待って取れなければ警告のうえ続行する（fail-open）。
#
# Usage: ckms_with_lock <対象ファイルパス> <コマンド...>
ckms_with_lock() {
  local target="$1" lockdir waited=0 max_wait=5
  shift
  lockdir="${target}.lock"
  while ! mkdir "$lockdir" 2>/dev/null; do
    if [ "$waited" -ge "$max_wait" ]; then
      echo "警告: ロック取得がタイムアウトしました（${lockdir}）。ロックせずに続行します" >&2
      "$@"
      return $?
    fi
    sleep 1
    waited=$((waited + 1))
  done
  "$@"
  local status=$?
  rmdir "$lockdir" 2>/dev/null || true
  return $status
}

# 索引 README.md に 1 行追加する。README が無ければ見出しと表ごと作成する。
# 新しいエントリが上に来るよう、表ヘッダの直後に挿入する。
# read-modify-write 全体を ckms_with_lock で囲み、並行実行時の lost update を防ぐ。
#
# Usage: ckms_index_upsert <索引ファイル> <見出し> <説明> <第1列> <タイトル> <ファイル名>
ckms_index_upsert() {
  local index="$1" heading="$2" intro="$3" col1="$4" title="$5" filename="$6"

  col1=$(ckms_table_escape "$col1")
  title=$(ckms_table_escape "$title")

  ckms_with_lock "$index" _ckms_index_upsert_body "$index" "$heading" "$intro" "$col1" "$title" "$filename"
}

_ckms_index_upsert_body() {
  local index="$1" heading="$2" intro="$3" col1="$4" title="$5" filename="$6"
  local row tmp

  if [ ! -f "$index" ]; then
    cat > "$index" << EOF
# ${heading}

${intro}

## 一覧

| 日付 | タイトル | ファイル |
|------|---------|---------|
EOF
  fi

  row="| ${col1} | ${title} | [${filename}](${filename}) |"

  if grep -q '^|------' "$index"; then
    tmp="${index}.tmp.$$"
    # awk -v はバックスラッシュを解釈するため、\| を保つには ENVIRON を使う
    CKMS_INDEX_ROW="$row" awk '
      { print }
      !inserted && /^\|------/ { print ENVIRON["CKMS_INDEX_ROW"]; inserted = 1 }
    ' "$index" > "$tmp" && mv "$tmp" "$index"
  else
    printf '%s\n' "$row" >> "$index"
  fi
}
