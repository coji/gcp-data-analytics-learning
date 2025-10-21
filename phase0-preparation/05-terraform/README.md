# Phase 0-05: Terraform基礎（インフラのコード管理）

## 📖 学習目標

Terraformを使って、インフラストラクチャをコードで管理する方法を習得する。

### このセクションで学ぶこと

- Infrastructure as Code（IaC）の概念
- Terraformの基本構成（provider, resource, variable）
- BigQueryデータセットのTerraformコード作成
- terraform init/plan/apply/destroyの実行

## 📚 学習リソース

### 公式チュートリアル

- [Terraform - Get Started with Google Cloud](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started)
- [Google Cloud - Terraformを使用したリソース管理](https://cloud.google.com/docs/terraform)

### 入門書籍

- 「Terraform実践ガイド」（技術評論社）

### 動画

- [HashiCorp Learn - Terraform Introduction](https://www.youtube.com/watch?v=h970ZBgKINg)

## 🎓 重要な概念

### Infrastructure as Code（IaC）とは

- インフラをコードで定義 → 手作業のミスを防ぐ
- Git管理 → 誰がいつ何を変更したか追跡可能
- 再現性 → 同じコードから同じ環境を再構築可能

### Terraformの基本構成

```hcl
# 1. プロバイダー定義（どのクラウドを使うか）
provider "google" {
  project = "my-project-prd"
  region  = "asia-northeast1"
}

# 2. リソース定義（何を作るか）
resource "google_bigquery_dataset" "dataset" {
  dataset_id  = "raw_marketing_ads"
  location    = "asia-northeast1"
  description = "広告生データ"
}

# 3. 変数定義（再利用可能な値）
variable "project_id" {
  default = "my-project-prd"
}
```

## 🚀 ハンズオン演習

### 前提条件

```bash
# Terraformのインストール（macOS）
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# インストール確認
terraform --version
```

### 演習1: 初めてのTerraformプロジェクト

```bash
# 1. 学習用ディレクトリに移動
cd phase0-preparation/05-terraform/learning

# 2. main.tfを作成（エディタで編集）
# （下記の「基本的なmain.tf」を参照）

# 3. Terraform初期化
terraform init

# 4. 実行計画の確認（何が作成されるか）
terraform plan

# 5. 適用（実際に作成）
terraform apply
# "yes"と入力

# 6. BigQueryで確認
bq show YOUR_PROJECT_ID:terraform_learning_test

# 7. 削除
terraform destroy
# "yes"と入力
```

### 基本的なmain.tf

```hcl
# main.tf
provider "google" {
  project = "YOUR_PROJECT_ID"
  region  = "asia-northeast1"
}

resource "google_bigquery_dataset" "learning" {
  dataset_id  = "terraform_learning_test"
  location    = "asia-northeast1"
  description = "Terraform学習用テストデータセット"

  labels = {
    environment = "learning"
    managed_by  = "terraform"
  }
}
```

### 演習2: 変数を使ったTerraform

`variables.tf`を作成して、値を再利用可能にします。

```hcl
# variables.tf
variable "project_id" {
  description = "GCPプロジェクトID"
  type        = string
  default     = "YOUR_PROJECT_ID"
}

variable "location" {
  description = "BigQueryのロケーション"
  type        = string
  default     = "asia-northeast1"
}

variable "dataset_id" {
  description = "データセットID"
  type        = string
}
```

```hcl
# main.tf（変数を使用）
provider "google" {
  project = var.project_id
  region  = var.location
}

resource "google_bigquery_dataset" "learning" {
  dataset_id  = var.dataset_id
  location    = var.location
  description = "Terraform学習用テストデータセット"
}
```

```hcl
# terraform.tfvars（実際の値を設定）
project_id = "YOUR_PROJECT_ID"
dataset_id = "terraform_learning_test"
```

### 演習3: サービスアカウントの作成

```hcl
# service-account.tf
resource "google_service_account" "learning_sa" {
  account_id   = "terraform-learning-sa"
  display_name = "Terraform学習用サービスアカウント"
  description  = "Terraformで作成したテスト用サービスアカウント"
}

# データセットへの権限付与
resource "google_bigquery_dataset_iam_member" "sa_viewer" {
  dataset_id = google_bigquery_dataset.learning.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.learning_sa.email}"
}
```

## 📝 演習課題

### 課題1: Terraformのメリットを3つ挙げる

学習ロードマップの「Terraformによるインフラ管理」（967-1117行目）を読み、`learning-log/YYYY-MM-DD.md`にメリットを3つ挙げてください。

### 課題2: terraform planの理解

`terraform plan`を実行し、出力内容を理解してください。

- 何が作成されるか（`+`）
- 何が変更されるか（`~`）
- 何が削除されるか（`-`）

### 課題3: 複数リソースの管理

以下を含むTerraformコードを作成してください：

1. データセットを2つ作成（`raw_xxx`, `staging_xxx`）
2. サービスアカウントを1つ作成
3. サービスアカウントに適切な権限を付与

## ✅ 完了チェックリスト

- [ ] Terraformのインストール
- [ ] Infrastructure as Code（IaC）の概念理解
- [ ] Terraformの基本構成理解
- [ ] `terraform init`の実行
- [ ] `terraform plan`の理解
- [ ] `terraform apply`でリソース作成
- [ ] `terraform destroy`でクリーンアップ
- [ ] 変数の使い方理解
- [ ] 課題1完了
- [ ] 課題2完了
- [ ] 課題3完了

## 🔗 次のステップ

Phase 0完了おめでとうございます！

次は[Phase 1-06: dbt](../../phase1-integration/06-dbt/README.md)に進んでください。

## 📌 Terraformのベストプラクティス

### 1. ステートファイルの管理

```hcl
# backend.tf
terraform {
  backend "gcs" {
    bucket = "terraform-state-bucket"
    prefix = "learning/state"
  }
}
```

**注意**: 学習段階ではローカルでOK。本番ではGCSなどのリモートバックエンドを使用。

### 2. .gitignoreの設定

```.gitignore
# Terraform
*.tfstate
*.tfstate.*
*.tfvars
!*.tfvars.example
.terraform/
```

### 3. ファイル構成

```
learning/
├── main.tf           # メインのリソース定義
├── variables.tf      # 変数定義
├── outputs.tf        # 出力値定義
├── terraform.tfvars.example  # 変数値のテンプレート
└── terraform.tfvars  # 実際の変数値（.gitignore）
```

## ❓ よくある質問

### Q: terraform applyを実行したらエラーが出た

A: よくあるエラー:

1. **認証エラー**: `gcloud auth application-default login`を実行
2. **APIが有効化されていない**: 必要なAPIを有効化
3. **権限不足**: プロジェクトオーナーまたは適切なロールが必要

### Q: terraform destroyは安全か？

A:

- テスト環境: 安全に削除可能
- 本番環境: **絶対に実行しない**（すべてのリソースが削除される）
- `terraform plan -destroy`で事前確認推奨

### Q: tfstateファイルをGitにコミットしてしまった

A:

- **即座にコミットを削除**（機密情報を含む可能性）
- Git履歴からも削除（`git filter-branch`など）
- リモートバックエンドの使用を検討

## 🔗 参考リンク

- [Terraform Registry - Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
