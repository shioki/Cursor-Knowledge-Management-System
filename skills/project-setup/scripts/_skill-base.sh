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
  slug=$(printf '%s' "$input" \
    | tr '[:upper:]' '[:lower:]' \
    | tr ' _/\\' '-' \
    | sed -e 's/[^a-z0-9-]//g' -e 's/--*/-/g' -e 's/^-//' -e 's/-$//')
  if [ -z "$slug" ]; then
    printf '%s' "$fallback"
  else
    printf '%s' "$slug"
  fi
}

# 索引 README.md に 1 行追加する。README が無ければ見出しと表ごと作成する。
# 新しいエントリが上に来るよう、表ヘッダの直後に挿入する。
#
# Usage: ckms_index_upsert <索引ファイル> <見出し> <説明> <第1列> <タイトル> <ファイル名>
ckms_index_upsert() {
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
    awk -v row="$row" '
      { print }
      !inserted && /^\|------/ { print row; inserted = 1 }
    ' "$index" > "$tmp" && mv "$tmp" "$index"
  else
    printf '%s\n' "$row" >> "$index"
  fi
}
