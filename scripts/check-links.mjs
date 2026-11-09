#!/usr/bin/env node
import { createRequire } from 'node:module';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const require = createRequire(import.meta.url);
const markdownLinkCheck = require('markdown-link-check');

// retryOn429 は 429 しか再試行しないため、タイムアウトや 5xx による一時的な dead をここで再確認する
const EXTERNAL_RETRY_COUNT = 2;
const EXTERNAL_RETRY_DELAY_MS = 5000;

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

function check(markdown, options) {
  return new Promise((resolve, reject) => {
    markdownLinkCheck(markdown, options, (err, results) => (err ? reject(err) : resolve(results)));
  });
}

// ignored は .mlc.config.json の ignorePatterns で意図して外したもの
const isDead = (r) => r.status !== 'alive' && r.status !== 'ignored';

async function recheckExternal(result, options) {
  let latest = result;
  for (let i = 0; i < EXTERNAL_RETRY_COUNT; i++) {
    await sleep(EXTERNAL_RETRY_DELAY_MS);
    const [r] = await check(`<${result.link}>`, options);
    if (r) latest = r;
    if (!isDead(latest)) break;
  }
  return latest;
}

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
  const options = { ...config, baseUrl };

  let results;
  try {
    results = await check(markdown, options);
  } catch (err) {
    const e = new Error(`error while checking ${fileName}: ${err.message ?? String(err)}`);
    e.cause = err;
    throw e;
  }

  const dead = [];
  for (const r of results.filter(isDead)) {
    const final = /^https?:\/\//i.test(r.link) ? await recheckExternal(r, options) : r;
    if (isDead(final)) dead.push(final);
  }
  if (dead.length === 0) return;

  const lines = dead.map((r) => {
    const detail = [r.statusCode ? `HTTP ${r.statusCode}` : null, r.err ? String(r.err.message ?? r.err) : null]
      .filter(Boolean)
      .join(', ');
    return `  [✖] ${r.link} → Status: ${r.status}${detail ? ` (${detail})` : ''}`;
  });
  throw new Error(`dead links found in ${fileName}\n${lines.join('\n')}`);
}

async function main() {
  const configPath = path.join(process.cwd(), '.mlc.config.json');

  const targets = [
    path.join(process.cwd(), 'README.md'),
    path.join(process.cwd(), 'README.en.md'),
    path.join(process.cwd(), 'CHANGELOG.md'),
    path.join(process.cwd(), 'CONTRIBUTING.md'),
  ];

  // Collect docs/**/*.md without relying on shell globs.
  const walk = async (dir) => {
    const { readdir } = await import('node:fs/promises');
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
      } else if (e.isFile() && e.name.toLowerCase().endsWith('.md')) {
        targets.push(full);
      }
    }
  };

  for (const dir of ['docs', 'skills', 'agents', 'hooks', 'templates']) {
    await walk(path.join(process.cwd(), dir));
  }

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
