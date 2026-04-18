#!/usr/bin/env bash
# GitHub Release 作成スクリプト（v5.0.0 以降 immutable release 対応）
#
# 用法: ./scripts/release.sh v5.0.0 [--dry-run] [--skip-skill-publish]
# 事前に gh auth login または GH_TOKEN の設定が必要です。
#
# 主な機能:
#   1. .cursor-plugin/plugin.json / apm.yml のバージョン一致検証
#   2. docs:check (skills/commands/plugin/links) の実行
#   3. immutable release の推奨アナウンス
#   4. gh release create 実行
#   5. 任意で `gh skill publish` 連携（--skip-skill-publish で無効化）

set -euo pipefail

VERSION="${1:-}"
DRY_RUN=false
SKIP_SKILL_PUBLISH=false
shift || true

for arg in "$@"; do
  case "$arg" in
    --dry-run)             DRY_RUN=true ;;
    --skip-skill-publish)  SKIP_SKILL_PUBLISH=true ;;
  esac
done

if [[ -z "$VERSION" ]]; then
  echo "用法: $0 <バージョンタグ> [--dry-run] [--skip-skill-publish]"
  echo "例:   $0 v5.0.0"
  exit 1
fi

if ! command -v gh &>/dev/null; then
  echo "エラー: GitHub CLI (gh) がインストールされていません。"
  echo "  https://docs.github.com/ja/get-started/using-github/github-cli を参照してインストールしてください。"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "エラー: GitHub CLI (gh) が認証されていません。"
  echo ""
  echo "次のいずれかを実行してください:"
  echo "  (1) 対話ログイン:  gh auth login"
  echo "  (2) トークン利用:  export GH_TOKEN=\"ghp_xxxx...\" のうえ、再度このスクリプトを実行"
  echo ""
  echo "詳しくは: docs/reference/github-release.md"
  exit 1
fi

# --- バージョン整合性チェック ---
VERSION_NUM="${VERSION#v}"
PLUGIN_MANIFEST=".cursor-plugin/plugin.json"
APM_MANIFEST="apm.yml"

if [[ -f "$PLUGIN_MANIFEST" ]]; then
  PLUGIN_VER=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$PLUGIN_MANIFEST" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  if [[ "$PLUGIN_VER" != "$VERSION_NUM" ]]; then
    echo "エラー: $PLUGIN_MANIFEST の version ($PLUGIN_VER) がリリースタグ ($VERSION_NUM) と一致しません"
    echo "  $PLUGIN_MANIFEST の version を $VERSION_NUM に更新してください"
    exit 1
  fi
  echo "[ok] $PLUGIN_MANIFEST version=$PLUGIN_VER"
fi

if [[ -f "$APM_MANIFEST" ]]; then
  APM_VER=$(grep -E '^version:' "$APM_MANIFEST" | head -1 | awk '{print $2}')
  if [[ "$APM_VER" != "$VERSION_NUM" ]]; then
    echo "エラー: $APM_MANIFEST の version ($APM_VER) がリリースタグ ($VERSION_NUM) と一致しません"
    echo "  $APM_MANIFEST の version を $VERSION_NUM に更新してください"
    exit 1
  fi
  echo "[ok] $APM_MANIFEST version=$APM_VER"
fi

# --- 事前検証 ---
echo ""
echo "==> docs:check を実行中 (skills / commands / plugin / links)..."
if command -v npm &>/dev/null; then
  npm run --silent docs:check
else
  echo "警告: npm が見つかりません。docs:check をスキップします。"
fi

# --- リリースノート ---
NOTES_FILE="RELEASE_NOTES_${VERSION}.md"
if [[ ! -f "$NOTES_FILE" ]]; then
  echo "エラー: リリースノートが見つかりません: $NOTES_FILE"
  echo "  ルートに $NOTES_FILE を作成するか、gh release create を --notes で直接実行してください。"
  exit 1
fi

TITLE="${VERSION} - Knowledge Management Plugin"
echo ""
echo "リリースを作成します: $VERSION"
echo "  タイトル: $TITLE"
echo "  ノート:   $NOTES_FILE"
echo ""

# --- immutable release の警告 ---
cat <<'EOF'
[INFO] immutable release の推奨
  GitHub リポジトリの Settings → Rules → Releases → Require immutable を有効化してください。
  これにより、公開後のタグ・アセットの改竄が防止され、`gh skill install --pin` および
  `apm install <repo>#<tag>` の供給網保全に寄与します。
EOF
echo ""

if [[ "$DRY_RUN" == true ]]; then
  echo "[DRY RUN] gh release create \"$VERSION\" --title \"$TITLE\" --notes-file \"$NOTES_FILE\""
else
  gh release create "$VERSION" \
    --title "$TITLE" \
    --notes-file "$NOTES_FILE"
  echo "完了: $VERSION をリリースしました。"
fi

# --- gh skill publish 連携 ---
if [[ "$SKIP_SKILL_PUBLISH" == false ]]; then
  echo ""
  echo "==> gh skill publish を試行中..."
  if gh skill --version &>/dev/null; then
    if [[ "$DRY_RUN" == true ]]; then
      echo "[DRY RUN] gh skill publish"
    else
      gh skill publish || {
        echo "警告: gh skill publish に失敗しました。frontmatter を確認してください。"
        echo "      修正の自動化は \`gh skill publish --fix\` で試せます。"
      }
    fi
  else
    echo "情報: gh skill サブコマンドが利用できません（GitHub CLI のバージョンを確認してください）。"
    echo "      スキルを Marketplace / gh skill で公開する場合は、gh v2.90.0 以上にアップグレードしてください。"
  fi
fi
