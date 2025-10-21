# Phase 0-04: サービスアカウントとIAM設計

## 📖 学習目標

GCPのサービスアカウントとIAM（Identity and Access Management）の基礎を理解し、安全な権限設計ができるようになる。

### このセクションで学ぶこと

- サービスアカウントの概念
- 最小権限の原則
- BigQuery IAMロールの種類
- 実際のサービスアカウント作成と権限付与

## 📚 学習リソース

### 公式ドキュメント

- [サービスアカウントの概要](https://cloud.google.com/iam/docs/service-accounts)
- [BigQuery IAMロール](https://cloud.google.com/bigquery/docs/access-control)
- [IAM best practices](https://cloud.google.com/iam/docs/best-practices-service-accounts)

## 🎓 重要な概念

### サービスアカウントとは

アプリケーションやツールがGCPリソースにアクセスするための「機械用のユーザーアカウント」

### 主要なBigQuery IAMロール

| ロール | 権限 | 用途例 |
|--------|------|--------|
| `bigquery.dataViewer` | データの読み取りのみ | BIツール（Metabase） |
| `bigquery.dataEditor` | データの読み書き | データ取り込み（Databeat）、dbt |
| `bigquery.admin` | すべての操作 | 管理者のみ |
| `bigquery.jobUser` | ジョブの実行 | クエリ実行が必要な場合 |

### 最小権限の原則

各サービスアカウントには**必要最小限の権限のみ**を付与する。

**例（学習ロードマップより）**:

| サービスアカウント | 用途 | 権限 |
|-----------------|------|------|
| `databeat-ingestion` | データ取り込み | Raw Layerへの`dataEditor` |
| `dbt-transformation` | データ変換 | Rawは`dataViewer`、Staging/Martは`dataEditor` |
| `metabase-viewer` | BI接続 | Staging/Martへの`dataViewer` |

## 🚀 ハンズオン演習

### 演習1: サービスアカウントの作成

```bash
# 1. サービスアカウント作成
gcloud iam service-accounts create learning-test-sa \
  --display-name="学習用テストサービスアカウント" \
  --project=YOUR_PROJECT_ID

# 2. サービスアカウント一覧を確認
gcloud iam service-accounts list --project=YOUR_PROJECT_ID

# 3. サービスアカウントの詳細確認
gcloud iam service-accounts describe learning-test-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

### 演習2: データセットへの権限付与

```bash
# 1. 特定のデータセットへの閲覧権限付与
bq add-iam-policy-binding \
  --member=serviceAccount:learning-test-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/bigquery.dataViewer \
  YOUR_PROJECT_ID:DATASET_NAME

# 2. 権限確認
bq show --format=prettyjson YOUR_PROJECT_ID:DATASET_NAME | grep -A 5 "learning-test-sa"

# 3. 権限の削除
bq remove-iam-policy-binding \
  --member=serviceAccount:learning-test-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/bigquery.dataViewer \
  YOUR_PROJECT_ID:DATASET_NAME
```

### 演習3: サービスアカウントのクリーンアップ

```bash
# サービスアカウントの削除
gcloud iam service-accounts delete \
  learning-test-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --project=YOUR_PROJECT_ID
```

## 📝 演習課題

### 課題1: 権限設計の意図を説明

学習ロードマップの「IAM・セキュリティ設計」（917-966行目）を読み、以下を`learning-log/YYYY-MM-DD.md`に説明してください：

1. なぜDatabeatには「Raw Layerへの書き込み」のみを許可しているのか？
2. なぜdbtは「Rawの読み取り」と「Staging/Martの書き込み」が必要なのか？
3. なぜMetabaseは「読み取り」のみにしているのか？

### 課題2: 開発用サービスアカウントの作成

1. 自分の開発用サービスアカウントを作成
2. 開発用データセット（`learning_dev`）への`dataEditor`権限を付与
3. 権限が正しく付与されているか確認

### 課題3: セキュリティリスクの考察

もし`metabase-viewer`に`dataEditor`権限を付与してしまうと、どんな問題が起きるか考察してください。

**ヒント**: BIツールが侵害された場合、データの完全性にどのような影響があるか？

## ✅ 完了チェックリスト

- [ ] サービスアカウントの概念理解
- [ ] 最小権限の原則の理解
- [ ] サービスアカウント作成成功
- [ ] データセットへの権限付与成功
- [ ] 権限確認方法の理解
- [ ] サービスアカウント削除成功
- [ ] 課題1完了
- [ ] 課題2完了
- [ ] 課題3完了

## 🔗 次のステップ

完了したら、[Phase 0-05: Terraform基礎](../05-terraform/README.md)に進んでください。

## 📌 IAM設計のベストプラクティス

### 1. 最小権限の原則

- 必要な権限のみを付与
- 定期的に権限を見直し

### 2. サービスアカウントの命名規則

```
{purpose}-{action}@{project}.iam.gserviceaccount.com

例:
- databeat-ingestion@my-project.iam.gserviceaccount.com
- dbt-transformation@my-project.iam.gserviceaccount.com
```

### 3. プロジェクトレベルではなくデータセットレベルで権限付与

```bash
# ❌ 避けるべき: プロジェクト全体に権限付与
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:SA_EMAIL" \
  --role="roles/bigquery.dataEditor"

# ✅ 推奨: データセット単位で権限付与
bq add-iam-policy-binding \
  --member="serviceAccount:SA_EMAIL" \
  --role="roles/bigquery.dataEditor" \
  PROJECT_ID:DATASET_NAME
```

### 4. サービスアカウントキーの管理

- **サービスアカウントキー（JSON）は絶対にGitにコミットしない**
- `.gitignore`に追加
- Cloud Secret Managerでの管理を推奨

## ❓ トラブルシューティング

### 権限エラー: "Permission denied"

```bash
# 自分のアカウントに必要な権限があるか確認
gcloud projects get-iam-policy YOUR_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:YOUR_EMAIL"
```

### サービスアカウントが見つからない

```bash
# プロジェクト内のすべてのサービスアカウント確認
gcloud iam service-accounts list --project=YOUR_PROJECT_ID
```

### 権限が反映されない

- 権限の反映には数分かかる場合がある
- BigQueryのキャッシュをクリア（ブラウザを閉じて再度開く）
