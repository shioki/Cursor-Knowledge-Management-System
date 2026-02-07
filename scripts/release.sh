#!/usr/bin/env bash
# GitHub Release 作成スクリプト
# 用法: ./scripts/release.sh v3.0.0
# 事前に gh auth login または GH_TOKEN の設定が必要です。

set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "用法: $0 <バージョンタグ>"
  echo "例:   $0 v3.0.0"
  exit 1
fi

# gh の存在確認
if ! command -v gh &>/dev/null; then
  echo "エラー: GitHub CLI (gh) がインストールされていません。"
  echo "  https://docs.github.com/ja/get-started/using-github/github-cli を参照してインストールしてください。"
  exit 1
fi

# 認証確認（gh auth status の終了コードと出力の両方で判定）
AUTH_OUTPUT="$(gh auth status 2>&1)" || true
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

NOTES_FILE="RELEASE_NOTES_${VERSION}.md"
if [[ ! -f "$NOTES_FILE" ]]; then
  echo "エラー: リリースノートが見つかりません: $NOTES_FILE"
  echo "  ルートに $NOTES_FILE を作成するか、gh release create を --notes で直接実行してください。"
  exit 1
fi

TITLE="${VERSION} - Agent Skills + Commands Migration"
echo "リリースを作成します: $VERSION"
echo "  タイトル: $TITLE"
echo "  ノート:   $NOTES_FILE"
gh release create "$VERSION" \
  --title "$TITLE" \
  --notes-file "$NOTES_FILE"
echo "完了: $VERSION をリリースしました。"
