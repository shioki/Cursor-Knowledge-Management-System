#!/usr/bin/env bash
# 導入先で hooks を実際に動かし、出力と作業ログを確かめる（CI 用）。
#
# 先に対象へ init.sh で導入しておくこと（.cursor/hooks と .claude/hooks が要る）。
# JSON の検証に node を使う。配布する hooks 自体は node に依存しない。
#
# Usage: bash scripts/smoke-hooks.sh <target>
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: bash scripts/smoke-hooks.sh <target>" >&2
  exit 1
fi
cd "$1"

fail() {
  echo "error: $*" >&2
  exit 1
}

# 出力が JSON として読めることを確かめ、指定したパスの値を出す（無ければ空）
json_get() {
  node -e '
    let s = "";
    process.stdin.on("data", (d) => (s += d)).on("end", () => {
      let v;
      try { v = JSON.parse(s); } catch (e) { console.error("invalid JSON: " + s.slice(0, 200)); process.exit(1); }
      for (const k of process.argv[1].split(".").filter(Boolean)) v = v == null ? undefined : v[k];
      if (v !== undefined) process.stdout.write(typeof v === "string" ? v : JSON.stringify(v));
    });
  ' "${1:-}"
}

[ -d .cursor/hooks ] || fail ".cursor/hooks is not installed"
[ -d .claude/hooks/claude-code ] || fail ".claude/hooks/claude-code is not installed"

BASE=.agents
LOG="$BASE/knowledge-activity.log"
DECISIONS="$BASE/skills/knowledge-management/references/decisions"
rm -f "$LOG"

# 索引に出るよう、特殊な文字を含む判断記録を 1 件作る。
# 同じ導入先で繰り返し流せるよう、タイトルは実行ごとに変える。
RUN_ID="$$-$(date +%H%M%S)"
TITLE="Hook smoke ${RUN_ID} | \"quoted\" \\ back \$(x)"
bash "$BASE/skills/knowledge-management/scripts/add-entry.sh" "$TITLE" >/dev/null

# --- sessionStart: 索引を JSON で返す ---
context="$(printf '{}' | bash .cursor/hooks/inject-knowledge-index.sh | json_get additional_context)"
printf '%s' "$context" | grep -qF "$TITLE" || fail "Cursor sessionStart index is missing the record title"
context="$(printf '{}' | bash .claude/hooks/claude-code/session-start.sh | json_get hookSpecificOutput.additionalContext)"
printf '%s' "$context" | grep -qF "$TITLE" || fail "Claude Code SessionStart index is missing the record title"

# --- afterFileEdit / PostToolUse: 作業ログ ---
log_has() {
  [ -f "$LOG" ] && cut -f2- "$LOG" | grep -qxF -- "$1"
}

out="$(printf '{"file_path":"%s/src/a \\"b\\".ts","edits":[]}' "$PWD" | bash .cursor/hooks/log-activity.sh)"
[ "$(printf '%s' "$out" | json_get)" = "{}" ] || fail "afterFileEdit did not return {}"
log_has 'src/a "b".ts' || fail "a path containing \" was not logged intact"

printf '{"tool_name":"Write","tool_response":{"file_path":"/wrong"},"tool_input":{"content":"say \\"file_path\\": 1","file_path":"%s/docs/x|y.md"}}' "$PWD" \
  | bash .claude/hooks/claude-code/post-tool-use-log-activity.sh >/dev/null
log_has 'docs/x|y.md' || fail "PostToolUse did not log tool_input.file_path"
log_has '/wrong' && fail "PostToolUse logged tool_response.file_path"

printf '{"tool_name":"Edit","tool_input":{"file_path":"%s/docs/q \\"z\\".md"}}' "$PWD" \
  | bash .claude/hooks/claude-code/post-tool-use-log-activity.sh >/dev/null
log_has 'docs/q "z".md' || fail "PostToolUse did not log a path containing \" intact"

printf '{"file_path":"%s/%s/skills/x.md"}' "$PWD" "$BASE" | bash .cursor/hooks/log-activity.sh >/dev/null
grep -qF "$BASE/skills/x.md" "$LOG" && fail "an edit inside the knowledge base was logged"

printf 'not json' | bash .cursor/hooks/log-activity.sh >/dev/null || fail "afterFileEdit failed on invalid input"
printf '' | bash .claude/hooks/claude-code/post-tool-use-log-activity.sh >/dev/null || fail "PostToolUse failed on empty input"

# Windows ネイティブのパス。Git Bash の $PWD（/c/...）から C:\... を組み立てる。
case "$PWD" in
  /[a-zA-Z]/*)
    drive="$(printf '%s' "${PWD:1:1}" | tr '[:lower:]' '[:upper:]')"
    win_root="${drive}:$(printf '%s' "${PWD:2}" | sed 's|/|\\\\|g')"
    printf '{"file_path":"%s\\\\src\\\\win.ts"}' "$win_root" | bash .cursor/hooks/log-activity.sh >/dev/null
    log_has 'src/win.ts' || fail "a Windows path (${win_root}\\src\\win.ts) was not made project-relative: $(tail -n 1 "$LOG")"
    printf '{"tool_input":{"file_path":"%s\\\\%s\\\\skills\\\\y.md"}}' "$win_root" "$BASE" \
      | bash .claude/hooks/claude-code/post-tool-use-log-activity.sh >/dev/null
    grep -qF "skills/y.md" "$LOG" && fail "a Windows path inside the knowledge base was logged"
    echo "info: checked Windows paths under ${win_root}"
    ;;
  *)
    echo "info: \$PWD is not a Git Bash drive path; skipping the Windows path check"
    ;;
esac

# ログは 1 行 1 件（タブ区切り 2 列）のまま
awk -F '\t' 'NF != 2 { bad = 1 } END { exit bad }' "$LOG" || fail "activity log has a malformed line"

# --- stop / Stop: 既定は無効で {} を返す。有効にしても JSON を返す ---
for hook in .cursor/hooks/suggest-record.sh .claude/hooks/claude-code/stop-suggest-record.sh; do
  [ "$(printf '{"status":"completed","loop_count":0}' | bash "$hook" | json_get)" = "{}" ] \
    || fail "$hook should return {} while disabled"
done
printf 'suggest_record = true\n' > "$BASE/knowledge-hooks.conf"
for hook in .cursor/hooks/suggest-record.sh .claude/hooks/claude-code/stop-suggest-record.sh; do
  printf '{"status":"completed","loop_count":0}' | bash "$hook" | json_get >/dev/null \
    || fail "$hook returned invalid JSON while enabled"
done
rm -f "$BASE/knowledge-hooks.conf"

# --- search-sessions.sh: キーワードは文字列として探す ---
bash "$BASE/skills/debug-workflow/scripts/create-session.sh" "regex [1] literal ${RUN_ID}" >/dev/null
search() { bash "$BASE/skills/debug-workflow/scripts/search-sessions.sh" "$1" | grep -c '^--- ' || true; }
# 閉じていない [ は正規表現ではエラーになり、0 件になる
[ "$(search 'regex [1')" -ge 1 ] || fail "search-sessions did not find a literal 'regex [1'"
# . を任意の 1 文字として扱うと "regex" に当たる
[ "$(search 'r.gex')" -eq 0 ] || fail "search-sessions treated . as a regex wildcard"

echo "ok: hooks and session search behaved as expected in $PWD"
