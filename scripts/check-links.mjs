#!/usr/bin/env node
import { createRequire } from 'node:module';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const require = createRequire(import.meta.url);
const markdownLinkCheck = require('markdown-link-check');

async function runOne(filePath, configPath) {
  const markdown = await readFile(filePath, 'utf8');
  const configRaw = await readFile(configPath, 'utf8');
  const config = JSON.parse(configRaw);

  const fileName = path.relative(process.cwd(), filePath);

  // Bug 1 fix:
  // Do NOT construct baseUrl by string concatenation like:
  //   "file:///" + "/path" => "file:////path"  (Unix absolute paths already start with '/')
  // Use Node's URL utilities instead; this is correct on both Unix and Windows.
  const baseUrl = pathToFileURL(path.resolve(path.dirname(filePath)) + path.sep).href;

  await new Promise((resolve, reject) => {
    markdownLinkCheck(markdown, { ...config, baseUrl }, (err, results) => {
      if (err) {
        const e = new Error(`error while checking ${fileName}: ${err.message ?? String(err)}`);
        e.cause = err;
        return reject(e);
      }

      const dead = results.filter((r) => r.status !== 'alive');
      if (dead.length === 0) return resolve();

      const lines = dead.map((r) => `  [✖] ${r.link} → Status: ${r.status}`);
      return reject(new Error(`dead links found in ${fileName}\n${lines.join('\n')}`));
    });
  });
}

async function main() {
  const configPath = path.join(process.cwd(), '.mlc.config.json');

  const targets = [
    path.join(process.cwd(), 'README.md'),
    path.join(process.cwd(), 'CHANGELOG.md'),
  ];

  // Collect docs/**/*.md without relying on shell globs.
  const walk = async (dir) => {
    const { readdir } = await import('node:fs/promises');
    const entries = await readdir(dir, { withFileTypes: true });
    for (const e of entries) {
      const full = path.join(dir, e.name);
      if (e.isDirectory()) {
        await walk(full);
      } else if (e.isFile() && e.name.toLowerCase().endsWith('.md')) {
        targets.push(full);
      }
    }
  };

  await walk(path.join(process.cwd(), 'docs'));

  const uniq = Array.from(new Set(targets));

  const failures = [];
  for (const filePath of uniq) {
    try {
      await runOne(filePath, configPath);
    } catch (e) {
      failures.push(String(e?.message ?? e));
    }
  }

  if (failures.length > 0) {
    console.error('[link-check] FAILED');
    for (const msg of failures) console.error(`\n${msg}`);
    process.exit(1);
  }

  console.log(`[link-check] OK (${uniq.length} files)`);
}

main().catch((e) => {
  console.error('[link-check] ERROR');
  console.error(e?.stack ?? e?.message ?? String(e));
  process.exit(1);
});
