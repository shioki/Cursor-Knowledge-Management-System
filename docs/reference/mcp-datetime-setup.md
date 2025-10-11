# MCPサーバ日時処理設定ガイド

このガイドでは、正確な日時処理のためのMCPサーバ設定手順を説明します。

## 1. 推奨MCPサーバ

### Time MCP Server by Anthropic（推奨）
公式Anthropic製で最も信頼性が高いサーバーです。

**特徴:**
- 高精度のタイムゾーン変換
- ローカライズされた時間データ処理
- 豊富な時間計算機能
- 346k以上のダウンロード実績

**設定方法:**
```json
{
  "mcpServers": {
    "time": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-time"]
    }
  }
}
```

### Date-time Tools MCP Server
多様な日時フォーマットに対応したサーバーです。

**特徴:**
- 豊富な日時フォーマット
- タイムゾーン変換機能
- 日時の算術操作（加減算）

**設定方法:**
```json
{
  "mcpServers": {
    "date-time-tools": {
      "command": "npx",
      "args": ["-y", "@abhi12299/date-time-tools"]
    }
  }
}
```

### mcp-datetime（日本語対応）
日本語環境に最適化されたサーバーです。

**特徴:**
- 日本語フォーマット対応
- ファイル名生成最適化
- 正確なタイムゾーン处理

**設定方法:**
```json
{
  "mcpServers": {
    "mcp-datetime": {
      "command": "uvx",
      "args": ["mcp-datetime"]
    }
  }
}
```

## 2. Claude Desktop設定手順

### Windows環境
1. 設定ファイルの場所:
   ```
   %APPDATA%\Claude\claude_desktop_config.json
   ```

2. 設定ファイルを開いて以下を追加:
   ```json
   {
     "mcpServers": {
       "time": {
         "command": "npx",
         "args": ["-y", "@modelcontextprotocol/server-time"]
       }
     }
   }
   ```

### macOS環境
1. 設定ファイルの場所:
   ```
   ~/Library/Application Support/Claude/claude_desktop_config.json
   ```

2. 同様の設定を追加

### Linux環境
1. 設定ファイルの場所:
   ```
   ~/.config/Claude/claude_desktop_config.json
   ```

2. 同様の設定を追加

## 3. Cursor IDE設定手順

### グローバル設定
1. `Settings > Cursor Settings > MCP` を開く
2. "Add new global MCP server" をクリック
3. 以下の設定を入力:

**Time MCP Server:**
```json
{
  "time": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-time"]
  }
}
```

### プロジェクト固有設定
プロジェクトルートに `.cursor/mcp.json` を作成:

```json
{
  "mcpServers": {
    "time": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-time"]
    },
    "date-time-tools": {
      "command": "npx",
      "args": ["-y", "@abhi12299/date-time-tools"]
    }
  }
}
```

## 4. 利用可能な日時フォーマット

### 標準フォーマット
- `date`: 2024-12-10
- `datetime`: 2024-12-10 00:54:01
- `iso`: 2024-12-10T00:54:01+0900

### 日本語フォーマット
- `date_jp`: 2024年12月10日
- `datetime_jp`: 2024年12月10日 00時54分01秒
- `time_jp`: 00時54分01秒

### ファイル名用フォーマット
- `compact`: 20241210005401
- `filename_md`: 20241210005401.md
- `filename_txt`: 20241210005401.txt
- `log_compact`: 20241210_005401

## 5. 使用例

### 現在時刻の取得
```
現在の時刻を教えてください
```

### タイムゾーン変換
```
東京時間の2024-12-10 15:00をニューヨーク時間に変換してください
```

### 日時計算
```
2024-12-10から30日後の日付を計算してください
```

### ファイル名生成
```
現在の日時をファイル名形式で生成してください
```

## 6. トラブルシューティング

### サーバが認識されない場合
1. Node.jsとnpmが最新版かチェック
2. インターネット接続を確認
3. Claude Desktop/Cursorを再起動

### タイムゾーンが正しくない場合
1. システムのタイムゾーン設定を確認
2. 環境変数 `TZ` の設定をチェック
3. MCPサーバの再起動

### パフォーマンスの問題
1. 複数のMCPサーバを同時使用しない
2. 最も適切なサーバー1つを選択
3. 定期的にMCPサーバを更新

## 7. セキュリティ注意事項

- MCPサーバはローカル実行のため、外部への時刻情報漏洩リスクは低い
- npxを使用する場合、信頼できるパッケージのみ使用
- 定期的にパッケージを更新してセキュリティを保持

## 8. パフォーマンス最適化

### 推奨設定順序
1. 最初に公式Time MCP Serverを試す
2. 日本語対応が必要な場合はmcp-datetimeを追加
3. 特殊フォーマットが必要な場合のみDate-time Tools MCPを使用

### リソース使用量を最小化
- 必要最小限のMCPサーバのみ有効化
- 未使用のサーバは無効化
- 定期的に設定を見直し

---

**注意**: MCPサーバの設定後は、Claude DesktopまたはCursorの再起動が必要です。 