# Terraform リポジトリ

wip

## 構成

- VPC
- Subnet

## 環境構築

### aws-cli のセッティング

terraform を利用する場合は、aws-cli のセッティングが必要です。

下記を参考に設定を行ってください。

https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-chap-configure.html

### tfenv のインストール

mac を利用する前提の手順書です。

`tfenv`は、terraform のバージョンマネージャーになります。

異なるバージョンを容易に扱えるため、`tfenv`をベースで mac で作業します。

```
brew install tfenv

tfenv --version
```

`tfenv --version`で結果が表示されれば OK です。

### terraform のインストール

インストールできる terraform のバージョンを確認します。

version が`0.12.0`以上の terraform をインストールしてください。

```
tfenv install
```

### config.tfvars の用意

terraform を利用する場合は、**AdministratorAccess**の権限があるユーザで作業することを推奨します。

```
touch config.tfvars

vim config.tfvars

region  = "ap-northeast-1"
profile = "AWS-CLIでセッティングしたprofile名"
```

## 設計方針

設計方針としては、`shared/modules/`配下に作成するリソースのファイルを配置します。
