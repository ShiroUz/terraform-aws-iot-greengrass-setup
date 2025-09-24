# AWS IoT Greengrass Setup Terraform Module

AWS IoT Core と AWS IoT Greengrass のセットアップを行うTerraformモジュールです。

## 機能

- AWS IoT Thing Group（親・子）の作成
- AWS IoT Thing の複数作成
- IoT 証明書の自動生成
- IAM Role と Role Alias の作成
- IoT ポリシーの設定
- AWS Systems Manager Parameter Store への証明書保存
- AWS IoT Greengrass 対応

## モジュール構成

```
terraform-aws-iot-greengrass-setup/
├── main.tf              # メインリソース（Thing Group）
├── variable.tf          # 入力変数定義
├── outputs.tf           # 出力値定義
└── things/              # Thingsサブモジュール
    ├── main.tf          # Thing、証明書、ポリシー、Role Alias
    ├── variables.tf     # サブモジュール変数
    └── outputs.tf       # サブモジュール出力
```

## 使用方法

### Git Repository参照

```hcl
module "iot_greengrass" {
  source = "git::https://github.com/your-org/terraform-aws-iot-greengrass-setup.git?ref=v1.0.0"

  # Thing Group設定
  thing_group_parent_name = "production-devices"
  thing_group_child_name  = "sensors"
  description             = "IoT sensor devices"
  thing_group_attributes = {
    Environment = "production"
    Team        = "iot-team"
    Project     = "sensor-monitoring"
  }

  # Things設定
  things_base_name = "sensor-device"
  things_amount    = 3

  # Greengrass設定
  enable_greengrass           = true
  role_alias_name             = "greengrass-role-alias"
  component_artifact_location = "arn:aws:s3:::my-greengrass-bucket"
  role_name                   = "greengrass-role"
  policy_name                 = "greengrass-policy"

  # 環境設定
  region       = "ap-northeast-1"
  env          = "prod"
  account_name = "123456789012"
}
```

### HCP Terraform Registry（予定）

```hcl
module "iot_greengrass" {
  source  = "your-org/iot-greengrass-setup/aws"
  version = "~> 1.0"

  # 上記と同じ設定
}
```

## 入力変数

### Thing Group関連
| 変数名 | 型 | デフォルト | 説明 |
|--------|----|-----------|----- |
| `thing_group_parent_name` | string | null | 親Thing Group名 |
| `thing_group_child_name` | string | null | 子Thing Group名 |
| `thing_group_attributes` | map(string) | {} | Thing Groupの属性 |
| `description` | string | null | Thing Groupの説明 |

### Things関連
| 変数名 | 型 | デフォルト | 説明 |
|--------|----|-----------|----- |
| `things_base_name` | string | "" | Thingのベース名 |
| `things_amount` | number | 0 | 作成するThing数 |
| `secret_version` | number | 1 | SSMパラメータのバージョン |

### Greengrass関連
| 変数名 | 型 | デフォルト | 説明 |
|--------|----|-----------|----- |
| `role_alias_name` | string | null | Role Alias名 |
| `credential_duration` | number | 3600 | 認証情報の有効期間（秒） |
| `component_artifact_location` | string | null | コンポーネントアーティファクトのS3 ARN |
| `role_name` | string | null | IAMロール名 |
| `policy_name` | string | null | IAMポリシー名 |
| `extra_policy_statement` | any | null | 追加のポリシーステートメント |

### 環境関連
| 変数名 | 型 | デフォルト | 説明 |
|--------|----|-----------|----- |
| `region` | string | "us-east-1" | AWSリージョン |
| `env` | string | "dev" | 環境名 |
| `account_name` | string | "123456789" | AWSアカウントID |

## 出力値

| 出力名 | 説明 |
|--------|------|
| `role_alias_arn` | Role AliasのARN |
| `iam_role_arn` | IAMロールのARN |
| `thing_group_parent_arn` | 親Thing GroupのARN |
| `thing_group_child_arn` | 子Thing GroupのARN |
| `things` | 作成されたThingsの情報 |

## 作成されるリソース

### メインモジュール
- `aws_iot_thing_group` (parent/child)

### Thingsサブモジュール（things_amount分作成）
- `aws_iot_thing`
- `aws_iot_certificate`
- `aws_iot_policy`
- `aws_iot_policy_attachment`
- `aws_iot_thing_principal_attachment`
- `aws_iot_thing_group_membership`
- `aws_ssm_parameter` (証明書保存用)
- `aws_iot_role_alias`
- `aws_iam_role`
- `aws_iam_policy`
- `aws_iam_role_policy_attachment`

## 前提条件

- Terraform >= 1.13
- AWS Provider >= 6.0
- 適切なAWS認証情報の設定

## バージョン管理

このモジュールは[Semantic Versioning](https://semver.org/)に従ってバージョン管理されています。

- メジャーバージョン: 破壊的変更
- マイナーバージョン: 新機能追加
- パッチバージョン: バグ修正

最新のリリース情報は[Releases](https://github.com/your-org/terraform-aws-iot-greengrass-setup/releases)で確認できます。

## 注意事項

- `./parent` ディレクトリは別途実行される想定です
- Role AliasとIAMロールは最初のThingインスタンス作成時に共有リソースとして作成されます
- 証明書はAWS Systems Manager Parameter Storeに暗号化して保存されます
- `things_amount`を0に設定すると、Thing関連のリソースは作成されません
- Git参照時は必ずタグまたはコミットハッシュを指定してください
- HCP Terraform Registry登録後は、バージョン制約を使用して予期しない変更を防いでください

## ライセンス

MIT License