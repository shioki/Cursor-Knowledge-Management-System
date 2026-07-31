# AGENTS.md (サブディレクトリ用ネスト例)

> このファイルは、特定のサブディレクトリにだけ適用したい指示を書く例です。
> 例えば `frontend/AGENTS.md`, `backend/AGENTS.md`, `packages/api/AGENTS.md` に配置します。
> 親ディレクトリの AGENTS.md と **マージ** され、こちらの方が優先されます。

## このディレクトリの責務

<!-- 例: "フロントエンド UI 層。React コンポーネントと画面遷移を管理。" -->

## コーディング規約（このディレクトリ専用）

- 言語: TypeScript (strict mode)
- フレームワーク: React 19 + TanStack Router
- スタイリング: Tailwind CSS v4
- テスト: Vitest + @testing-library/react

## ファイル命名規則

- コンポーネント: `PascalCase.tsx`
- hooks: `use-*.ts`
- utilities: `kebab-case.ts`

## エージェント向け補足

- 新しいコンポーネントを追加したら、`/add-pattern` で実装パターンも登録する
- 既存コンポーネントを大きく改修するときは、`/record-decision` で判断を記録する
- このディレクトリ固有の規約と、プロジェクト全体の `team-standards` スキルの規約が食い違う場合は、こちらを優先する

## 禁止事項

- 直接の DOM 操作（`document.*`）は使わない
- `any` 型の利用は `// eslint-disable-next-line` とセットで理由を明記

---

> 参考: [ネストされた AGENTS.md の公式サポート](https://cursor.com/ja/docs/rules#agentsmd)
