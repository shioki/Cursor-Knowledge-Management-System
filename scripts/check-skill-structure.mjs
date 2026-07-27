#!/usr/bin/env node
// skills/ 配下の SKILL.md を Agent Skills 仕様に沿って検証する。
//
// frontmatter は yaml パーサで読む。自前の正規表現ではネストした構造
// （metadata.tags や paths のリスト）を取りこぼすため。

import { readdir, readFile, access } from 'node:fs/promises';
import { constants } from 'node:fs';
import path from 'node:path';
import { parse as parseYaml } from 'yaml';

const ROOT = process.cwd();
const SKILLS_DIR = path.join(ROOT, 'skills');

// Agent Skills 仕様で定義されている最上位キー。これ以外は警告する。
const KNOWN_KEYS = new Set([
  'name',
  'description',
  'license',
  'compatibility',
  'metadata',
  'paths',
  'disable-model-invocation',
  'allowed-tools',
  'model',
  'version',
]);

const NAME_MAX = 64;
const DESCRIPTION_MAX = 1024;
const NAME_PATTERN = /^[a-z0-9]+(-[a-z0-9]+)*$/;

function splitFrontmatter(text) {
  const lines = text.split(/\r?\n/);
  if (lines[0]?.trim() !== '---') {
    return { ok: false, error: 'must start with --- (YAML frontmatter)' };
  }
  const endIdx = lines.slice(1).findIndex((l) => l.trim() === '---');
  if (endIdx === -1) {
    return { ok: false, error: 'frontmatter is missing closing ---' };
  }
  return {
    ok: true,
    raw: lines.slice(1, 1 + endIdx).join('\n'),
    body: lines.slice(endIdx + 2).join('\n'),
  };
}

async function isExecutable(target) {
  try {
    await access(target, constants.X_OK);
    return true;
  } catch {
    return false;
  }
}

async function checkSkill(skillName, problems, warnings) {
  const skillDir = path.join(SKILLS_DIR, skillName);
  const skillFile = path.join(skillDir, 'SKILL.md');

  try {
    await access(skillFile, constants.R_OK);
  } catch {
    problems.push(`${skillName}/: missing SKILL.md`);
    return null;
  }

  const text = await readFile(skillFile, 'utf8');
  if (text.trim().length === 0) {
    problems.push(`${skillName}/SKILL.md: file is empty`);
    return null;
  }

  const split = splitFrontmatter(text);
  if (!split.ok) {
    problems.push(`${skillName}/SKILL.md: ${split.error}`);
    return null;
  }

  let fm;
  try {
    fm = parseYaml(split.raw);
  } catch (e) {
    problems.push(`${skillName}/SKILL.md: invalid YAML frontmatter — ${e.message}`);
    return null;
  }

  if (fm === null || typeof fm !== 'object' || Array.isArray(fm)) {
    problems.push(`${skillName}/SKILL.md: frontmatter must be a YAML mapping`);
    return null;
  }

  // name
  if (typeof fm.name !== 'string' || fm.name.length === 0) {
    problems.push(`${skillName}/SKILL.md: missing required key "name"`);
  } else {
    if (fm.name !== skillName) {
      problems.push(
        `${skillName}/SKILL.md: name "${fm.name}" does not match folder name "${skillName}"`
      );
    }
    if (fm.name.length > NAME_MAX) {
      problems.push(`${skillName}/SKILL.md: name exceeds ${NAME_MAX} characters`);
    }
    if (!NAME_PATTERN.test(fm.name)) {
      problems.push(`${skillName}/SKILL.md: name "${fm.name}" is not kebab-case`);
    }
  }

  // description
  if (typeof fm.description !== 'string' || fm.description.trim().length === 0) {
    problems.push(`${skillName}/SKILL.md: missing required key "description"`);
  } else {
    if (fm.description.length > DESCRIPTION_MAX) {
      problems.push(
        `${skillName}/SKILL.md: description is ${fm.description.length} characters (max ${DESCRIPTION_MAX})`
      );
    }
    if (fm.description.length < 20) {
      warnings.push(
        `${skillName}/SKILL.md: description is very short — the agent uses it to decide when to load the skill`
      );
    }
  }

  // paths
  if (fm.paths !== undefined) {
    const list = Array.isArray(fm.paths) ? fm.paths : [fm.paths];
    if (!list.every((p) => typeof p === 'string')) {
      problems.push(`${skillName}/SKILL.md: "paths" must be a string or an array of strings`);
    }
  }

  // disable-model-invocation
  const explicitOnly = fm['disable-model-invocation'];
  if (explicitOnly !== undefined && typeof explicitOnly !== 'boolean') {
    problems.push(`${skillName}/SKILL.md: "disable-model-invocation" must be a boolean`);
  }

  // 仕様外キー
  for (const key of Object.keys(fm)) {
    if (!KNOWN_KEYS.has(key)) {
      warnings.push(
        `${skillName}/SKILL.md: unknown frontmatter key "${key}" (not in the Agent Skills spec — it will be ignored)`
      );
    }
  }

  // 配布時に推奨されるキー
  if (fm.license === undefined) {
    warnings.push(`${skillName}/SKILL.md: missing "license" (recommended for gh skill publish)`);
  }
  if (fm.metadata === undefined) {
    warnings.push(`${skillName}/SKILL.md: missing "metadata" (metadata.tags aids discoverability)`);
  }

  // 本文が空でないこと
  if (split.body.trim().length === 0) {
    problems.push(`${skillName}/SKILL.md: body is empty (frontmatter alone is not a skill)`);
  }

  // scripts/ の実行権限
  const scriptsDir = path.join(skillDir, 'scripts');
  try {
    const scriptEntries = await readdir(scriptsDir, { withFileTypes: true });
    for (const se of scriptEntries) {
      if (!se.isFile() || !se.name.endsWith('.sh')) continue;
      if (!(await isExecutable(path.join(scriptsDir, se.name)))) {
        problems.push(`${skillName}/scripts/${se.name}: missing execute permission`);
      }
    }
  } catch {
    // scripts/ が無いのは正常
  }

  return { name: fm.name, explicitOnly: explicitOnly === true };
}

// templates/ に SKILL.md が再び現れていないか（v5 の二重管理 drift の再発防止）
async function checkNoDuplicateTree(problems) {
  const templatesDir = path.join(ROOT, 'templates');
  const found = [];

  const walk = async (dir) => {
    let entries;
    try {
      entries = await readdir(dir, { withFileTypes: true });
    } catch {
      return;
    }
    for (const e of entries) {
      const full = path.join(dir, e.name);
      if (e.isDirectory()) {
        await walk(full);
      } else if (e.name === 'SKILL.md') {
        found.push(path.relative(ROOT, full));
      }
    }
  };

  await walk(templatesDir);

  for (const f of found) {
    problems.push(
      `${f}: skills must live only in skills/ — a copy under templates/ will drift (this caused the v5 duplication)`
    );
  }
}

async function main() {
  let entries;
  try {
    entries = await readdir(SKILLS_DIR, { withFileTypes: true });
  } catch (e) {
    console.error(`[skills-check] ERROR: cannot read directory: ${SKILLS_DIR}`);
    console.error(e?.message ?? String(e));
    process.exit(1);
  }

  const skillDirs = entries
    .filter((d) => d.isDirectory())
    .map((d) => d.name)
    .sort();

  if (skillDirs.length === 0) {
    console.error('[skills-check] ERROR: no skill directories found');
    process.exit(1);
  }

  const problems = [];
  const warnings = [];
  const results = [];

  for (const skillName of skillDirs) {
    const result = await checkSkill(skillName, problems, warnings);
    if (result) results.push(result);
  }

  await checkNoDuplicateTree(problems);

  for (const w of warnings) console.warn(`[skills-check] WARN: ${w}`);

  if (problems.length > 0) {
    console.error('[skills-check] FAILED');
    for (const p of problems) console.error(`  - ${p}`);
    process.exit(1);
  }

  const actionCount = results.filter((r) => r.explicitOnly).length;
  const domainCount = results.length - actionCount;
  console.log(
    `[skills-check] OK (${results.length} skills: ${domainCount} auto-invoked, ${actionCount} explicit-only)`
  );
}

main().catch((e) => {
  console.error('[skills-check] ERROR');
  console.error(e?.stack ?? e?.message ?? String(e));
  process.exit(1);
});
