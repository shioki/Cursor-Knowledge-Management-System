#!/usr/bin/env node
import { readdir, readFile, access, stat } from 'node:fs/promises';
import path from 'node:path';
import { constants } from 'node:fs';

const SKILLS_DIR = path.join(process.cwd(), 'templates', '.claude', 'skills');

function parseFrontmatter(text) {
  const lines = text.split(/\r?\n/);
  if (lines.length === 0 || lines[0].trim() !== '---') {
    return { ok: false, error: 'SKILL.md must start with --- (YAML frontmatter)' };
  }

  const endIdx = lines.slice(1).findIndex((l) => l.trim() === '---');
  if (endIdx === -1) {
    return { ok: false, error: 'frontmatter is missing closing ---' };
  }

  const fmLines = lines.slice(1, 1 + endIdx);
  const map = new Map();

  for (const line of fmLines) {
    const t = line.trim();
    if (!t || t.startsWith('#')) continue;

    const m = /^([A-Za-z0-9_-]+)\s*:\s*(.*)$/.exec(line);
    if (!m) continue;

    const key = m[1];
    const rawValue = (m[2] ?? '').trim();
    map.set(key, rawValue);
  }

  return { ok: true, map };
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

  for (const skillName of skillDirs) {
    const skillDir = path.join(SKILLS_DIR, skillName);
    const skillFile = path.join(skillDir, 'SKILL.md');

    // Check SKILL.md exists
    try {
      await access(skillFile, constants.R_OK);
    } catch {
      problems.push(`${skillName}/: missing SKILL.md`);
      continue;
    }

    const text = await readFile(skillFile, 'utf8');

    // Check SKILL.md is not empty
    if (text.trim().length === 0) {
      problems.push(`${skillName}/SKILL.md: file is empty`);
      continue;
    }

    // Parse frontmatter
    const fm = parseFrontmatter(text);
    if (!fm.ok) {
      problems.push(`${skillName}/SKILL.md: ${fm.error}`);
      continue;
    }

    // Check required fields
    if (!fm.map.has('name')) {
      problems.push(`${skillName}/SKILL.md: frontmatter missing required key: name`);
    } else {
      const nameValue = fm.map.get('name');
      if (nameValue !== skillName) {
        problems.push(
          `${skillName}/SKILL.md: name "${nameValue}" does not match folder name "${skillName}"`
        );
      }
    }

    if (!fm.map.has('description')) {
      problems.push(`${skillName}/SKILL.md: frontmatter missing required key: description`);
    } else {
      const desc = fm.map.get('description');
      if (!desc || desc.length < 10) {
        problems.push(
          `${skillName}/SKILL.md: description is too short (should be at least 10 characters)`
        );
      }
    }

    // Check scripts/ have execute permission (Unix only)
    const scriptsDir = path.join(skillDir, 'scripts');
    try {
      const scriptEntries = await readdir(scriptsDir, { withFileTypes: true });
      for (const se of scriptEntries) {
        if (!se.isFile() || !se.name.endsWith('.sh')) continue;
        const scriptPath = path.join(scriptsDir, se.name);
        try {
          await access(scriptPath, constants.X_OK);
        } catch {
          problems.push(`${skillName}/scripts/${se.name}: missing execute permission`);
        }
      }
    } catch {
      // No scripts/ directory - that's fine
    }
  }

  if (problems.length > 0) {
    console.error('[skills-check] FAILED');
    for (const p of problems) console.error(`  - ${p}`);
    process.exit(1);
  }

  console.log(`[skills-check] OK (${skillDirs.length} skills)`);
}

main().catch((e) => {
  console.error('[skills-check] ERROR');
  console.error(e?.stack ?? e?.message ?? String(e));
  process.exit(1);
});
