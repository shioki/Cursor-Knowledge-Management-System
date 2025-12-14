#!/usr/bin/env node
import { readdir, readFile } from 'node:fs/promises';
import path from 'node:path';

const REQUIRED_KEYS = ['description', 'globs', 'alwaysApply'];

function stripQuotes(s) {
  const t = s.trim();
  if ((t.startsWith('"') && t.endsWith('"')) || (t.startsWith("'") && t.endsWith("'"))) {
    return t.slice(1, -1);
  }
  return t;
}

function parseFrontmatter(text) {
  const lines = text.split(/\r?\n/);
  if (lines.length === 0 || lines[0].trim() !== '---') {
    return { ok: false, error: 'frontmatter must start at line 1 with ---' };
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

    const m = /^([A-Za-z0-9_]+)\s*:\s*(.*)$/.exec(line);
    if (!m) continue;

    const key = m[1];
    const rawValue = m[2] ?? '';
    map.set(key, rawValue);
  }

  return { ok: true, map };
}

function countFences(text) {
  // Count lines that start a fenced code block.
  // This is a heuristic to catch obviously broken Markdown.
  const lines = text.split(/\r?\n/);
  let n = 0;
  for (const line of lines) {
    if (line.startsWith('```')) n++;
  }
  return n;
}

async function main() {
  const rulesDir = path.join(process.cwd(), 'templates', '.cursor', 'rules');

  let entries;
  try {
    entries = await readdir(rulesDir, { withFileTypes: true });
  } catch (e) {
    console.error(`[mdc-check] ERROR: cannot read directory: ${rulesDir}`);
    console.error(e?.message ?? String(e));
    process.exit(1);
  }

  const files = entries
    .filter((d) => d.isFile() && d.name.endsWith('.mdc'))
    .map((d) => path.join(rulesDir, d.name))
    .sort();

  if (files.length === 0) {
    console.error('[mdc-check] ERROR: no .mdc files found under templates/.cursor/rules');
    process.exit(1);
  }

  const problems = [];

  for (const file of files) {
    const rel = path.relative(process.cwd(), file);
    const text = await readFile(file, 'utf8');

    const fm = parseFrontmatter(text);
    if (!fm.ok) {
      problems.push(`${rel}: ${fm.error}`);
      continue;
    }

    for (const key of REQUIRED_KEYS) {
      if (!fm.map.has(key)) {
        problems.push(`${rel}: frontmatter missing required key: ${key}`);
      }
    }

    if (fm.map.has('alwaysApply')) {
      const v = stripQuotes(String(fm.map.get('alwaysApply') ?? '')).trim();
      if (!(v === 'true' || v === 'false')) {
        problems.push(`${rel}: alwaysApply must be true/false (got: ${v || '(empty)'})`);
      }
    }

    const fenceCount = countFences(text);
    if (fenceCount % 2 === 1) {
      problems.push(`${rel}: odd number of fenced code block markers (\\\`\\\`\\\`), likely unclosed fence`);
    }
  }

  if (problems.length > 0) {
    console.error('[mdc-check] FAILED');
    for (const p of problems) console.error(`- ${p}`);
    process.exit(1);
  }

  console.log(`[mdc-check] OK (${files.length} files)`);
}

main().catch((e) => {
  console.error('[mdc-check] ERROR');
  console.error(e?.stack ?? e?.message ?? String(e));
  process.exit(1);
});
