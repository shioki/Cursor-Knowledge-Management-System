#!/usr/bin/env node
// .cursor-plugin/plugin.json を公式スキーマで検証する。
//
// スキーマは schemas/cursor-plugin.schema.json にベンダリングしている
// （https://github.com/cursor/plugins/blob/HEAD/schemas/plugin.schema.json）。
// additionalProperties: false のため、仕様外のキーは Cursor 側で拒否される。
// 自前の緩い検証ではそれを見逃すため、ajv で厳密に検証する。

import { readFile, access, readdir } from 'node:fs/promises';
import { constants } from 'node:fs';
import path from 'node:path';
import Ajv from 'ajv';
import addFormats from 'ajv-formats';

const ROOT = process.cwd();
const MANIFEST_PATH = path.join(ROOT, '.cursor-plugin', 'plugin.json');
const SCHEMA_PATH = path.join(ROOT, 'schemas', 'cursor-plugin.schema.json');

// plugin.json でコンポーネントを明示しない場合、Cursor はプラグインルート直下の
// これらのディレクトリ／ファイルを探索する。
const DEFAULT_COMPONENT_PATHS = {
  skills: 'skills',
  agents: 'agents',
  commands: 'commands',
  rules: 'rules',
  hooks: path.join('hooks', 'hooks.json'),
};

async function exists(target) {
  try {
    await access(target, constants.R_OK);
    return true;
  } catch {
    return false;
  }
}

async function main() {
  const problems = [];
  const warnings = [];

  if (!(await exists(MANIFEST_PATH))) {
    console.error(`[plugin-check] ERROR: manifest not found: ${MANIFEST_PATH}`);
    process.exit(1);
  }

  if (!(await exists(SCHEMA_PATH))) {
    console.error(`[plugin-check] ERROR: vendored schema not found: ${SCHEMA_PATH}`);
    console.error('  Fetch it from https://github.com/cursor/plugins/blob/HEAD/schemas/plugin.schema.json');
    process.exit(1);
  }

  let manifest;
  const rawManifest = await readFile(MANIFEST_PATH, 'utf8');
  try {
    manifest = JSON.parse(rawManifest);
  } catch (e) {
    console.error(`[plugin-check] ERROR: invalid JSON in ${MANIFEST_PATH}`);
    console.error(`  ${e.message}`);
    process.exit(1);
  }

  const schema = JSON.parse(await readFile(SCHEMA_PATH, 'utf8'));

  // $schema は manifest 側のメタキーであり、スキーマ本体には定義がない。
  // additionalProperties: false に引っかかるため検証対象から外す。
  const { $schema: declaredSchema, ...manifestForValidation } = manifest;

  const ajv = new Ajv({ allErrors: true, strict: false });
  addFormats(ajv);
  const validate = ajv.compile(schema);

  if (!validate(manifestForValidation)) {
    for (const err of validate.errors ?? []) {
      const where = err.instancePath || '(root)';
      let detail = `${where} ${err.message}`;
      if (err.keyword === 'additionalProperties') {
        detail = `${where}: unknown property "${err.params.additionalProperty}" (schema sets additionalProperties: false — Cursor will reject it)`;
      }
      problems.push(detail);
    }
  }

  if (declaredSchema && declaredSchema !== schema.$id) {
    warnings.push(`$schema is "${declaredSchema}" but the official $id is "${schema.$id}"`);
  }

  // バージョン整合性: plugin.json と apm.yml
  const apmPath = path.join(ROOT, 'apm.yml');
  if (manifest.version && (await exists(apmPath))) {
    const apmRaw = await readFile(apmPath, 'utf8');
    const apmVersion = /^version:\s*(.+)$/m.exec(apmRaw)?.[1]?.trim();
    if (apmVersion && apmVersion !== manifest.version) {
      problems.push(
        `version mismatch: plugin.json is "${manifest.version}" but apm.yml is "${apmVersion}"`
      );
    }
  }

  // コンポーネントが実際に見つかるかを確認する。
  // 明示指定が無い場合はデフォルト探索先の存在を確かめる。スキーマは通るのに
  // コンポーネント 0 件になる、という v5 で起きた事故を防ぐ。
  let foundComponents = 0;
  for (const [key, defaultPath] of Object.entries(DEFAULT_COMPONENT_PATHS)) {
    if (manifest[key] !== undefined) {
      // 明示指定された場合はグロブになりうるので存在確認までは行わない
      foundComponents += 1;
      continue;
    }
    if (await exists(path.join(ROOT, defaultPath))) {
      foundComponents += 1;
    }
  }

  if (foundComponents === 0) {
    problems.push(
      'no components found: the manifest declares none and no default directory ' +
        `(${Object.values(DEFAULT_COMPONENT_PATHS).join(', ')}) exists at the plugin root`
    );
  }

  // スキルはデフォルト探索されるため、隠しディレクトリに置くと見つからない
  if (manifest.skills === undefined) {
    const skillsRoot = path.join(ROOT, 'skills');
    if (await exists(skillsRoot)) {
      const entries = await readdir(skillsRoot, { withFileTypes: true });
      const skillDirs = entries.filter((e) => e.isDirectory());
      if (skillDirs.length === 0) {
        problems.push('skills/ exists but contains no skill directories');
      } else {
        console.log(`[plugin-check] discovered ${skillDirs.length} skills via default lookup`);
      }
    }
  }

  if (warnings.length > 0) {
    for (const w of warnings) console.warn(`[plugin-check] WARN: ${w}`);
  }

  if (problems.length > 0) {
    console.error('[plugin-check] FAILED');
    for (const p of problems) console.error(`  - ${p}`);
    process.exit(1);
  }

  console.log(`[plugin-check] OK (${manifest.name} v${manifest.version ?? 'unversioned'})`);
}

main().catch((e) => {
  console.error('[plugin-check] ERROR');
  console.error(e?.stack ?? e?.message ?? String(e));
  process.exit(1);
});
