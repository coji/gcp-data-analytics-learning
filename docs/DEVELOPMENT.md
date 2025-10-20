# 開発ガイド / Development Guide

このドキュメントは、このリポジトリに貢献する開発者向けのガイドです。

## 🛠️ 開発環境のセットアップ

### 必要なツール

- **Node.js** (v18以上推奨) - markdownlintツールの実行に必要
- **pnpm** - パッケージマネージャー
- **Git** - バージョン管理

### セットアップ手順

```bash
# 1. リポジトリをクローン
git clone https://github.com/coji/gcp-data-analytics-learning.git
cd gcp-data-analytics-learning

# 2. 依存パッケージをインストール
pnpm install
```

## 📝 Markdownlintの使い方

このリポジトリでは、Markdownファイルの品質を保つために [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) を使用しています。

### ローカルでlintを実行

#### すべてのMarkdownファイルをチェック

```bash
pnpm run lint
```

#### エラーを自動修正

```bash
pnpm run lint:fix
```

多くの空行や書式の問題は自動修正されます。

#### 特定のディレクトリのみチェック

```bash
# docs/ ディレクトリのみ
pnpm run lint:docs

# ルートのMarkdownファイルのみ
pnpm run lint:root
```

### Lintルールの設定

設定は `.markdownlint.json` で管理されています：

```json
{
  "default": true,              // すべてのルールをデフォルトで有効
  "MD013": false,               // 行の長さ制限を無効
  "MD033": false,               // HTML使用を許可
  "MD024": {                    // 重複見出しは兄弟要素のみチェック
    "siblings_only": true
  },
  "MD036": false,               // 強調を見出しとして誤認しない（絵文字対策）
  "MD003": {                    // 見出しスタイルはATX (#) を推奨
    "style": "atx"
  }
}
```

### よくあるlintエラーと修正方法

#### MD032: リストの前後に空行が必要

❌ **エラー**:

```markdown
以下のポイントに注意：
- ポイント1
- ポイント2
次のセクション
```

✅ **修正**:

```markdown
以下のポイントに注意：

- ポイント1
- ポイント2

次のセクション
```

#### MD031: コードブロックの前後に空行が必要

❌ **エラー**:

```markdown
実行方法：
\`\`\`bash
npm run lint
\`\`\`
結果が表示されます
```

✅ **修正**:

```markdown
実行方法：

\`\`\`bash
npm run lint
\`\`\`

結果が表示されます
```

#### MD022: 見出しの前後に空行が必要

❌ **エラー**:

```markdown
## セクション1
内容
## セクション2
```

✅ **修正**:

```markdown
## セクション1

内容

## セクション2
```

### CIでのlint

GitHub Actionsで自動的にlintが実行されます。PRを作成する前に、必ずローカルで実行してください：

```bash
# 自動修正を実行
pnpm run lint:fix

# エラーが残っていないか確認
pnpm run lint
```

## 🔄 コミット前のチェックリスト

1. **Markdownlintを実行**

   ```bash
   pnpm run lint:fix
   pnpm run lint
   ```

2. **変更内容を確認**

   ```bash
   git status
   git diff
   ```

3. **適切なコミットメッセージを書く**

   ```bash
   git commit -m "docs: Update GETTING-STARTED.md with new examples"
   ```

   コミットメッセージのプレフィックス：
   - `docs:` - ドキュメントの変更
   - `feat:` - 新機能
   - `fix:` - バグ修正
   - `refactor:` - リファクタリング
   - `chore:` - ビルド・設定の変更

## 🧪 テストスクリプト

スクリプトを修正した場合は、動作確認を行ってください：

```bash
# 学習用設定に切り替え
./scripts/switch-to-learning.sh

# サンプルデータクエリを実行
./scripts/quickstart-sample-data.sh

# データセットセットアップ（注意：実際にBigQueryにデータセットを作成）
# ./scripts/setup-learning-data.sh
```

## 📦 package.jsonのスクリプト一覧

| コマンド | 説明 |
|---------|------|
| `pnpm run lint` | すべてのMarkdownファイルをチェック |
| `pnpm run lint:fix` | 自動修正可能なエラーを修正 |
| `pnpm run lint:docs` | docs/ ディレクトリのみチェック |
| `pnpm run lint:root` | ルートのMarkdownファイルのみチェック |

## 🔧 トラブルシューティング

### pnpmがインストールされていない

```bash
# npmを使ってpnpmをインストール
npm install -g pnpm

# または、Homebrewを使用（macOS）
brew install pnpm
```

### markdownlintのエラーが多すぎる

まず自動修正を実行：

```bash
pnpm run lint:fix
```

それでも残るエラーは、多くの場合：

- 重複する見出し（演習テンプレートなど、意図的な場合がある）
- 見出しレベルのスキップ（h2からh4など）
- リンクフラグメントの問題

これらは `.markdownlint.json` で調整するか、手動で修正してください。

### CIでエラーが出るがローカルでは出ない

`.markdownlint.json` がGitに追跡されているか確認：

```bash
git ls-files | grep markdownlint
# .markdownlint.json が表示されるはず
```

表示されない場合：

```bash
git add .markdownlint.json
git commit -m "chore: Add markdownlint configuration"
git push
```

## 🔗 関連リンク

- [markdownlint Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md) - すべてのルールの説明
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) - CLIツールのドキュメント
- [CONTRIBUTING.md](../CONTRIBUTING.md) - 貢献ガイドライン
