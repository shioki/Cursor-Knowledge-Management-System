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

- 新しいコンポーネント追加時は、`pattern-library` スキルの `@add-pattern` コマンドで実装パターンも登録する
- 既存コンポーネントの大規模改修時は、`knowledge-management` スキルで判断を記録する

## 禁止事項

- 直接の DOM 操作（`document.*`）は使わない
- `any` 型の利用は `// eslint-disable-next-line` とセットで理由を明記

---

> 参考: [ネストされた AGENTS.md の公式サポート](https://cursor.com/ja/docs/rules#agentsmd)
