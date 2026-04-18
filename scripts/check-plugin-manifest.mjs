#!/usr/bin/env node
// .cursor-plugin/plugin.json と apm.yml のスキーマ検証

import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';

const ROOT = process.cwd();
const PLUGIN_MANIFEST = path.join(ROOT, '.cursor-plugin', 'plugin.json');
const APM_MANIFEST = path.join(ROOT, 'apm.yml');

const problems = [];
const warnings = [];

async function fileExists(p) {
  try {
    await stat(p);
    return true;
  } catch {
    return false;
  }
}

async function checkPluginManifest() {
  if (!(await fileExists(PLUGIN_MANIFEST))) {
    problems.push('.cursor-plugin/plugin.json not found');
    return;
  }

  let text;
  try {
    text = await readFile(PLUGIN_MANIFEST, 'utf8');
  } catch (e) {
    problems.push(`.cursor-plugin/plugin.json read error: ${e.message}`);
    return;
  }

  let data;
  try {
    data = JSON.parse(text);
  } catch (e) {
    problems.push(`.cursor-plugin/plugin.json is not valid JSON: ${e.message}`);
    return;
  }

  const requiredFields = ['name', 'version', 'description'];
  for (const f of requiredFields) {
    if (!data[f] || typeof data[f] !== 'string') {
      problems.push(`.cursor-plugin/plugin.json: missing or invalid required field "${f}"`);
    }
  }

  if (!data.author || typeof data.author !== 'object' || !data.author.name) {
    warnings.push('.cursor-plugin/plugin.json: recommended field "author.name" missing');
  }

  if (!data.license) {
    warnings.push('.cursor-plugin/plugin.json: recommended field "license" missing');
  }

  // Validate version format (semver-ish)
  if (data.version && !/^\d+\.\d+\.\d+/.test(data.version)) {
    problems.push(
      `.cursor-plugin/plugin.json: version "${data.version}" is not in X.Y.Z format`
    );
  }

  // Validate paths
  if (!data.paths || typeof data.paths !== 'object') {
    warnings.push(
      '.cursor-plugin/plugin.json: "paths" object recommended (paths.skills / paths.commands)'
    );
  } else {
    for (const key of ['skills', 'commands']) {
      const rel = data.paths[key];
      if (!rel) {
        warnings.push(`.cursor-plugin/plugin.json: paths.${key} missing`);
        continue;
      }
      const abs = path.join(ROOT, rel);
      if (!(await fileExists(abs))) {
        problems.push(
          `.cursor-plugin/plugin.json: paths.${key} "${rel}" does not exist on disk`
        );
      }
    }
  }
}

async function checkApmManifest() {
  if (!(await fileExists(APM_MANIFEST))) {
    warnings.push('apm.yml not found (optional, required only if publishing via APM)');
    return;
  }

  const text = await readFile(APM_MANIFEST, 'utf8');

  const required = ['name', 'version', 'description'];
  for (const key of required) {
    const re = new RegExp(`^${key}\\s*:\\s*\\S`, 'm');
    if (!re.test(text)) {
      problems.push(`apm.yml: missing required top-level key "${key}"`);
    }
  }

  const versionMatch = /^version\s*:\s*(\S+)/m.exec(text);
  if (versionMatch && !/^\d+\.\d+\.\d+/.test(versionMatch[1])) {
    problems.push(`apm.yml: version "${versionMatch[1]}" is not in X.Y.Z format`);
  }

  if (!/^license\s*:/m.test(text)) {
    warnings.push('apm.yml: recommended field "license" missing');
  }

  if (!/^paths\s*:/m.test(text)) {
    warnings.push('apm.yml: recommended "paths:" section missing');
  }
}

async function checkVersionConsistency() {
  let pluginVersion = null;
  let apmVersion = null;

  try {
    const p = JSON.parse(await readFile(PLUGIN_MANIFEST, 'utf8'));
    pluginVersion = p.version;
  } catch {
    /* handled above */
  }

  try {
    const text = await readFile(APM_MANIFEST, 'utf8');
    const m = /^version\s*:\s*(\S+)/m.exec(text);
    if (m) apmVersion = m[1];
  } catch {
    /* optional */
  }

  if (pluginVersion && apmVersion && pluginVersion !== apmVersion) {
    problems.push(
      `version mismatch: .cursor-plugin/plugin.json=${pluginVersion} vs apm.yml=${apmVersion}`
    );
  }
}

async function main() {
  await checkPluginManifest();
  await checkApmManifest();
  await checkVersionConsistency();

  for (const w of warnings) {
    console.warn(`[plugin-check] WARN: ${w}`);
  }

  if (problems.length > 0) {
    console.error('[plugin-check] FAILED');
    for (const p of problems) console.error(`  - ${p}`);
    process.exit(1);
  }

  console.log(
    `[plugin-check] OK (${warnings.length} warning${warnings.length === 1 ? '' : 's'})`
  );
}

main().catch((e) => {
  console.error('[plugin-check] ERROR');
  console.error(e?.stack ?? e?.message ?? String(e));
  process.exit(1);
});
