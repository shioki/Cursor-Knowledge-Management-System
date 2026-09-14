#!/usr/bin/env node
// hooks/ と agents/ を検証する。
//
// v6 でコマンドはアクションスキルへ統合されたため、旧 check-command-structure.mjs を
// このスクリプトに置き換えた。skills の検証は check-skill-structure.mjs が担当する。

import { readdir, readFile, access } from 'node:fs/promises';
import { constants } from 'node:fs';
import path from 'node:path';
import { parse as parseYaml } from 'yaml';

const ROOT = process.cwd();
const HOOKS_DIR = path.join(ROOT, 'hooks');
const CLAUDE_HOOKS_DIR = path.join(HOOKS_DIR, 'claude-code');
const AGENTS_DIR = path.join(ROOT, 'agents');
const CLAUDE_SETTINGS_TEMPLATE = path.join(ROOT, 'templates', '.claude', 'settings.json.template');

// Claude Code の hooks で本プロジェクトが使用するイベント名
// （settings.json.template で実際に使われているものだけを検証する。
//   Claude Code の全イベント一覧は公式ドキュメント参照）
const CLAUDE_CODE_EVENTS = new Set(['SessionStart', 'PreToolUse', 'PostToolUse', 'Stop', 'UserPromptSubmit']);

// Cursor が受け付ける hook イベント名
const VALID_EVENTS = new Set([
  'sessionStart',
  'sessionEnd',
  'preToolUse',
  'postToolUse',
  'postToolUseFailure',
  'subagentStart',
  'subagentStop',
  'beforeShellExecution',
  'afterShellExecution',
  'beforeMCPExecution',
  'afterMCPExecution',
  'beforeReadFile',
  'afterFileEdit',
  'beforeSubmitPrompt',
  'preCompact',
  'stop',
  'afterAgentResponse',
  'afterAgentThought',
  'beforeTabFileRead',
  'afterTabFileEdit',
  'workspaceOpen',
]);

// loop_limit を必ず設定すべきイベント（未設定だと既定 5 回まで繰り返す）
const LOOPING_EVENTS = new Set(['stop', 'subagentStop']);

async function exists(target, mode = constants.R_OK) {
  try {
    await access(target, mode);
    return true;
  } catch {
    return false;
  }
}

async function checkHooks(problems, warnings) {
  const configPath = path.join(HOOKS_DIR, 'hooks.json');
  if (!(await exists(configPath))) {
    warnings.push('hooks/hooks.json not found — the plugin ships no hooks');
    return 0;
  }

  let config;
  try {
    config = JSON.parse(await readFile(configPath, 'utf8'));
  } catch (e) {
    problems.push(`hooks/hooks.json: invalid JSON — ${e.message}`);
    return 0;
  }

  if (config.version !== 1) {
    problems.push(`hooks/hooks.json: "version" must be 1 (got ${JSON.stringify(config.version)})`);
  }

  if (!config.hooks || typeof config.hooks !== 'object') {
    problems.push('hooks/hooks.json: missing "hooks" object');
    return 0;
  }

  let count = 0;

  for (const [event, definitions] of Object.entries(config.hooks)) {
    if (!VALID_EVENTS.has(event)) {
      problems.push(`hooks/hooks.json: unknown hook event "${event}"`);
      continue;
    }
    if (!Array.isArray(definitions)) {
      problems.push(`hooks/hooks.json: "${event}" must be an array`);
      continue;
    }

    for (const def of definitions) {
      count += 1;

      if (typeof def.command !== 'string' || def.command.length === 0) {
        problems.push(`hooks/hooks.json: "${event}" entry is missing "command"`);
        continue;
      }

      // "./hooks/foo.sh" 形式のみ実体を確認する（任意のシェルコマンドも許容されるため）
      if (def.command.startsWith('./')) {
        const scriptPath = path.join(ROOT, def.command.slice(2));
        if (!(await exists(scriptPath))) {
          problems.push(`hooks/hooks.json: "${event}" command not found: ${def.command}`);
        } else if (!(await exists(scriptPath, constants.X_OK))) {
          problems.push(`${def.command}: missing execute permission`);
        }
      }

      if (LOOPING_EVENTS.has(event) && def.loop_limit === undefined) {
        warnings.push(
          `hooks/hooks.json: "${event}" has no loop_limit — it defaults to 5, which can consume several turns`
        );
      }
    }
  }

  // hooks.json から参照されていないスクリプトの検出
  const referenced = new Set(
    Object.values(config.hooks)
      .flat()
      .map((d) => d?.command)
      .filter((c) => typeof c === 'string' && c.startsWith('./'))
      .map((c) => path.basename(c))
  );

  const hookEntries = await readdir(HOOKS_DIR, { withFileTypes: true });
  for (const e of hookEntries) {
    if (!e.isFile() || !e.name.endsWith('.sh')) continue;
    if (e.name.startsWith('_')) continue; // 共通ライブラリは直接参照されない
    if (!referenced.has(e.name)) {
      warnings.push(`hooks/${e.name}: not referenced from hooks.json`);
    }
    if (!(await exists(path.join(HOOKS_DIR, e.name), constants.X_OK))) {
      problems.push(`hooks/${e.name}: missing execute permission`);
    }
  }

  return count;
}

async function checkClaudeCodeHooks(problems, warnings) {
  let entries;
  try {
    entries = await readdir(CLAUDE_HOOKS_DIR, { withFileTypes: true });
  } catch {
    warnings.push('hooks/claude-code/ not found — no native Claude Code hooks shipped');
    return 0;
  }

  // claude-code/*.sh は ../_hook-lib.sh（hooks/_hook-lib.sh）を参照する。symlink は
  // 使わない方針（Windows で symlink checkout が無効だと壊れるため）なので、
  // hooks/_hook-lib.sh 自体の存在は checkHooks 側で保証される。
  if (!(await exists(path.join(HOOKS_DIR, '_hook-lib.sh')))) {
    problems.push('hooks/_hook-lib.sh: not found (required by hooks/claude-code/*.sh)');
  }

  const scripts = entries.filter((e) => e.isFile() && e.name.endsWith('.sh') && !e.name.startsWith('_'));
  if (scripts.length === 0) {
    warnings.push('hooks/claude-code/ contains no .sh files');
  }

  for (const script of scripts) {
    const scriptPath = path.join(CLAUDE_HOOKS_DIR, script.name);
    if (!(await exists(scriptPath, constants.X_OK))) {
      problems.push(`hooks/claude-code/${script.name}: missing execute permission`);
    }
  }

  if (!(await exists(CLAUDE_SETTINGS_TEMPLATE))) {
    problems.push('templates/.claude/settings.json.template: not found');
    return scripts.length;
  }

  let settings;
  try {
    settings = JSON.parse(await readFile(CLAUDE_SETTINGS_TEMPLATE, 'utf8'));
  } catch (e) {
    problems.push(`templates/.claude/settings.json.template: invalid JSON — ${e.message}`);
    return scripts.length;
  }

  if (!settings.hooks || typeof settings.hooks !== 'object') {
    problems.push('templates/.claude/settings.json.template: missing "hooks" object');
  } else {
    for (const [event, definitions] of Object.entries(settings.hooks)) {
      if (!CLAUDE_CODE_EVENTS.has(event)) {
        warnings.push(`templates/.claude/settings.json.template: unexpected hook event "${event}"`);
      }
      if (!Array.isArray(definitions)) {
        problems.push(`templates/.claude/settings.json.template: "${event}" must be an array`);
        continue;
      }
      for (const group of definitions) {
        for (const hook of group?.hooks ?? []) {
          const command = hook?.command;
          if (typeof command !== 'string' || command.length === 0) {
            problems.push(`templates/.claude/settings.json.template: "${event}" entry is missing "command"`);
            continue;
          }
          const scriptName = path.basename(command);
          if (!scripts.some((s) => s.name === scriptName)) {
            problems.push(
              `templates/.claude/settings.json.template: "${event}" references missing script hooks/claude-code/${scriptName}`
            );
          }
        }
      }
    }
  }

  if (!settings.permissions || typeof settings.permissions !== 'object') {
    warnings.push('templates/.claude/settings.json.template: missing "permissions" object');
  }

  return scripts.length;
}

async function checkAgents(problems, warnings) {
  let entries;
  try {
    entries = await readdir(AGENTS_DIR, { withFileTypes: true });
  } catch {
    warnings.push('agents/ not found — the plugin ships no subagents');
    return 0;
  }

  const files = entries.filter((e) => e.isFile() && e.name.endsWith('.md'));
  if (files.length === 0) {
    warnings.push('agents/ contains no .md files');
    return 0;
  }

  if (files.length > 3) {
    warnings.push(
      `agents/ defines ${files.length} subagents — Cursor documents heavy subagent use as an anti-pattern`
    );
  }

  for (const file of files) {
    const baseName = file.name.replace(/\.md$/, '');
    const text = await readFile(path.join(AGENTS_DIR, file.name), 'utf8');
    const lines = text.split(/\r?\n/);

    if (lines[0]?.trim() !== '---') {
      problems.push(`agents/${file.name}: must start with --- (YAML frontmatter)`);
      continue;
    }
    const endIdx = lines.slice(1).findIndex((l) => l.trim() === '---');
    if (endIdx === -1) {
      problems.push(`agents/${file.name}: frontmatter is missing closing ---`);
      continue;
    }

    let fm;
    try {
      fm = parseYaml(lines.slice(1, 1 + endIdx).join('\n'));
    } catch (e) {
      problems.push(`agents/${file.name}: invalid YAML frontmatter — ${e.message}`);
      continue;
    }

    if (typeof fm?.name !== 'string' || fm.name.length === 0) {
      problems.push(`agents/${file.name}: missing required key "name"`);
    } else if (fm.name !== baseName) {
      problems.push(`agents/${file.name}: name "${fm.name}" does not match file name "${baseName}"`);
    }

    if (typeof fm?.description !== 'string' || fm.description.trim().length === 0) {
      problems.push(`agents/${file.name}: missing required key "description"`);
    }

    if (fm?.readonly !== undefined && typeof fm.readonly !== 'boolean') {
      problems.push(`agents/${file.name}: "readonly" must be a boolean`);
    }

    if (lines.slice(endIdx + 2).join('\n').trim().length === 0) {
      problems.push(`agents/${file.name}: body is empty (no system prompt)`);
    }
  }

  return files.length;
}

async function main() {
  const problems = [];
  const warnings = [];

  const hookCount = await checkHooks(problems, warnings);
  const claudeHookCount = await checkClaudeCodeHooks(problems, warnings);
  const agentCount = await checkAgents(problems, warnings);

  for (const w of warnings) console.warn(`[components-check] WARN: ${w}`);

  if (problems.length > 0) {
    console.error('[components-check] FAILED');
    for (const p of problems) console.error(`  - ${p}`);
    process.exit(1);
  }

  console.log(
    `[components-check] OK (${hookCount} cursor hooks, ${claudeHookCount} claude-code hooks, ${agentCount} subagents)`
  );
}

main().catch((e) => {
  console.error('[components-check] ERROR');
  console.error(e?.stack ?? e?.message ?? String(e));
  process.exit(1);
});
