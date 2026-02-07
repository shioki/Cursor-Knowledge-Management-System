#!/usr/bin/env node
import { readdir, readFile, access } from 'node:fs/promises';
import path from 'node:path';
import { constants } from 'node:fs';

const COMMANDS_DIR = path.join(process.cwd(), 'templates', '.cursor', 'commands');

function isKebabCase(name) {
  return /^[a-z0-9]+(-[a-z0-9]+)*$/.test(name);
}

async function main() {
  let entries;
  try {
    entries = await readdir(COMMANDS_DIR, { withFileTypes: true });
  } catch (e) {
    console.error(`[commands-check] ERROR: cannot read directory: ${COMMANDS_DIR}`);
    console.error(e?.message ?? String(e));
    process.exit(1);
  }

  const commandFiles = entries
    .filter((d) => d.isFile() && d.name.endsWith('.md'))
    .map((d) => d.name)
    .sort();

  if (commandFiles.length === 0) {
    console.error('[commands-check] ERROR: no command .md files found');
    process.exit(1);
  }

  const problems = [];

  for (const fileName of commandFiles) {
    const filePath = path.join(COMMANDS_DIR, fileName);
    const baseName = fileName.replace(/\.md$/, '');

    // Check kebab-case naming
    if (!isKebabCase(baseName)) {
      problems.push(`${fileName}: filename should be kebab-case (got: "${baseName}")`);
    }

    // Check file is not empty
    const text = await readFile(filePath, 'utf8');
    if (text.trim().length === 0) {
      problems.push(`${fileName}: file is empty`);
      continue;
    }

    // Check minimum content (should have at least a heading)
    if (!text.includes('#')) {
      problems.push(`${fileName}: no Markdown heading found`);
    }

    // Check for "## 手順" or "## Steps" section
    if (!text.includes('## 手順') && !text.includes('## Steps') && !text.includes('## 手順')) {
      // Warn but don't fail
      // problems.push(`${fileName}: missing "## 手順" section (recommended)`);
    }
  }

  if (problems.length > 0) {
    console.error('[commands-check] FAILED');
    for (const p of problems) console.error(`  - ${p}`);
    process.exit(1);
  }

  console.log(`[commands-check] OK (${commandFiles.length} commands)`);
}

main().catch((e) => {
  console.error('[commands-check] ERROR');
  console.error(e?.stack ?? e?.message ?? String(e));
  process.exit(1);
});
