# Phase 0-05 演習メモ

## 演習1: 初めてのTerraformプロジェクト

### 実行日時

YYYY-MM-DD HH:MM

### terraform init の実行

```bash
# 実行コマンド
terraform init
```

**出力結果**:

```
# ここに出力を記録
```

### terraform plan の実行

**実行結果サマリー**:

- 作成されるリソース数:
- 変更されるリソース数:
- 削除されるリソース数:

**詳細**:

```
# plan の出力結果
```

### terraform apply の実行

**作成されたリソース**

- （記入してください）

**BigQueryでの確認結果**:

```bash
bq show PROJECT:DATASET
```

### terraform destroy の実行

**削除されたリソース**

- （記入してください）

---

## 演習2: 変数を使ったTerraform

### 作成したファイル

#### variables.tf

```hcl
# ここにコードを記録
```

#### terraform.tfvars

```hcl
# ここに設定を記録（機密情報は除く）
```

### 実行結果

### 変数を使うメリット

---

## 演習3: サービスアカウントの作成

### 作成したサービスアカウント名

### 付与した権限

### Terraformコード

```hcl
# service-account.tf
```

### 実行結果

```bash
# apply の結果
```

### GCPコンソールでの確認

---

## 課題1: Terraformのメリットを3つ挙げる

### メリット1

### メリット2

### メリット3

---

## 課題2: terraform planの理解

### 作成されるリソース（+）

-
-

### 変更されるリソース（~）

-
-

### 削除されるリソース（-）

-
-

### plan出力の読み方について学んだこと

---

## 課題3: 複数リソースの管理

### 作成したTerraformコード

#### main.tf

```hcl
# データセット2つの定義
```

#### service-account.tf

```hcl
# サービスアカウントと権限の定義
```

### リソース構成

```
Project
├── Dataset: raw_xxx
├── Dataset: staging_xxx
└── ServiceAccount: xxx
    ├── raw_xxx へのアクセス権
    └── staging_xxx へのアクセス権
```

### terraform planの結果

**作成されるリソース数**: X個

### terraform applyの結果

**作成完了したリソース**:
1.
2.
3.

### 確認

```bash
# データセット確認
bq ls

# サービスアカウント確認
gcloud iam service-accounts list
```

---

## Terraformを通しての学び

### Infrastructure as Codeのメリット

### 実際に使ってみての感想

### 注意すべきポイント（tfstate管理など）

### 本番環境での利用時の考慮事項

### まだ理解が不十分なこと
