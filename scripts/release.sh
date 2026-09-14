#!/usr/bin/env bash
# GitHub Release 作成スクリプト（immutable release 対応）
#
# 用法: ./scripts/release.sh v6.0.0 [--dry-run] [--skip-skill-publish]
# 事前に gh auth login または GH_TOKEN の設定が必要です。
#
# 主な機能:
#   1. 作業ツリーがクリーンで、現在のブランチが upstream と一致していることの確認
#      （gh release create はタグ未作成時、既定で GitHub 上のデフォルトブランチの
#      最新状態からタグを作る。ローカルで検証した内容とズレないよう、対象コミットを
#      --target で明示する）
#   2. .cursor-plugin/plugin.json / apm.yml のバージョン一致検証
#   3. docs:check (skills/components/plugin/links) と gh skill publish --dry-run の実行
#   4. immutable release の推奨アナウンス
#   5. 実行前の確認プロンプト（対話環境のみ）のうえ gh release create --target 実行
#   6. 任意で `gh skill publish` 連携（--skip-skill-publish で無効化）

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

# --- Git 状態チェック ---
# gh release create はタグが未作成の場合、既定では GitHub 上のデフォルト
# ブランチの最新状態からタグを作成する（--target 未指定時の公式挙動）。
# このスクリプトが検証するのはローカルの作業ツリーなので、未コミット・
# 未 push の変更があると「検証した内容と実際にリリースされる内容が別物」
# になりうる。それを防ぐため、対象コミットを明示的に --target で渡し、
# 事前に作業ツリーの状態も確認する。
if [[ -n "$(git status --porcelain)" ]]; then
  echo "エラー: 作業ツリーに未コミットの変更があります。コミットしてから再実行してください。"
  git status --short
  exit 1
fi

TARGET_COMMIT="$(git rev-parse HEAD)"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if git rev-parse --symbolic-full-name '@{u}' &>/dev/null; then
  UPSTREAM_COMMIT="$(git rev-parse '@{u}')"
  if [[ "$TARGET_COMMIT" != "$UPSTREAM_COMMIT" ]]; then
    echo "エラー: ローカルの $CURRENT_BRANCH ($TARGET_COMMIT) が upstream ($UPSTREAM_COMMIT) と一致しません。"
    echo "  push し忘れた変更があると、ここで検証した内容とは別のコミットがリリースされる恐れがあります。"
    echo "  git push で揃えてから再実行してください。"
    exit 1
  fi
else
  echo "警告: 現在のブランチ ($CURRENT_BRANCH) に upstream が設定されていません。push 済みかどうか確認できません。"
fi

echo "[ok] リリース対象コミット: $TARGET_COMMIT ($CURRENT_BRANCH)"

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
# 検証を飛ばしてリリースできてしまうと検証の意味がないため、npm が無い場合は失敗させる。
if ! command -v npm &>/dev/null; then
  echo "エラー: npm が見つかりません。リリース前検証 (docs:check) を実行できません。"
  echo "  Node.js / npm をインストールしてから再実行してください。"
  exit 1
fi

echo ""
echo "==> docs:check を実行中 (skills / components / plugin / links)..."
npm run --silent docs:check

if gh skill --version &>/dev/null; then
  echo ""
  echo "==> gh skill publish --dry-run を実行中..."
  gh skill publish --dry-run
fi

# --- リリースノート ---
NOTES_FILE="RELEASE_NOTES_${VERSION}.md"
if [[ ! -f "$NOTES_FILE" ]]; then
  echo "エラー: リリースノートが見つかりません: $NOTES_FILE"
  echo "  ルートに $NOTES_FILE を作成するか、gh release create を --notes で直接実行してください。"
  exit 1
fi

# タイトルの副題はリリースノートの Codename から取る。ハードコードすると
# 版が上がるたびに前版の副題が残る。
CODENAME=$(sed -n 's/^\*\*Codename\*\*:[[:space:]]*//p' "$NOTES_FILE" | head -1)
if [[ -n "$CODENAME" ]]; then
  TITLE="${VERSION} - ${CODENAME}"
else
  TITLE="$VERSION"
fi
echo ""
echo "リリースを作成します: $VERSION"
echo "  タイトル: $TITLE"
echo "  ノート:   $NOTES_FILE"
echo ""

# --- immutable release の警告 ---
cat <<'EOF'
[INFO] immutable release の推奨
  GitHub リポジトリの Settings → General → Releases → Enable release immutability を有効化してください。
  これにより、公開後のタグ・アセットの改竄が防止され、`gh skill install --pin` および
  `apm install <repo>#<tag>` の供給網保全に寄与します。
EOF
echo ""

if [[ "$DRY_RUN" == true ]]; then
  echo "[DRY RUN] gh release create \"$VERSION\" --title \"$TITLE\" --notes-file \"$NOTES_FILE\" --target \"$TARGET_COMMIT\""
else
  if [[ -t 0 ]]; then
    read -r -p "  $VERSION を $TARGET_COMMIT ($CURRENT_BRANCH) からリリースします。よろしいですか？ (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
      echo "中止しました。"
      exit 1
    fi
  fi
  gh release create "$VERSION" \
    --title "$TITLE" \
    --notes-file "$NOTES_FILE" \
    --target "$TARGET_COMMIT"
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
