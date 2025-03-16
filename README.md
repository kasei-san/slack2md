# slack2md

Slackチャンネルの会話履歴をマークダウン形式でエクスポートするツールです。

## 機能

- 指定した日付のSlackメッセージを取得
- スレッドの返信も含めて取得
- メッセージをマークダウン形式に変換
- コードブロック、リンク、メンションの適切な変換
- 日本時間での表示
- 出力先ディレクトリの指定が可能

## 必要要件

- Ruby 2.7以上
- bundler

## セットアップ

1. 必要なgemをインストール:
```bash
bundle install
```

2. 環境変数の設定:
`.env.sample` を `.env` にコピーし、必要な情報を設定します：

```bash
cp .env.sample .env
```

`.env` ファイルを編集し、以下の情報を設定:
```bash
SLACK_BOT_TOKEN=xoxb-your-bot-token-here
SLACK_CHANNEL_ID=your-channel-id-here
```

- `SLACK_BOT_TOKEN`: SlackのBotトークン
  - [Slack API](https://api.slack.com/apps) から取得できます
  - 必要な権限: `channels:history`, `groups:history`, `users:read`
  - Botをチャンネルに招待する必要があります
- `SLACK_CHANNEL_ID`: エクスポートしたいチャンネルのID
  - チャンネルのURLから取得できます（例: `https://xxx.slack.com/archives/ABCDE1234`の `ABCDE1234` 部分）

## 使用方法

```bash
# 今日のログを取得する場合（カレントディレクトリに出力）
./slack_export.rb

# 特定日のログを取得する場合（YYYY-MM-DD形式）
./slack_export.rb 2024-03-20

# 特定日のログを指定したディレクトリに出力する場合
./slack_export.rb 2024-03-20 /path/to/output/dir
```

出力先ディレクトリを指定しない場合は、カレントディレクトリにファイルが作成されます。
指定したディレクトリが存在しない場合は自動的に作成されます。

## 出力形式

指定した日付の年月日（YYYYMMDD.md）でファイルが作成されます。
内容は以下のような形式になります：

```markdown
# 20240320

* [2024-03-20 10:00:00](https://slack.com/archives/CHANNEL_ID/p1234567890) @ユーザー名 : メッセージ本文
  * [2024-03-20 10:05:00](https://slack.com/archives/CHANNEL_ID/p1234567891) @ユーザー名 : スレッド返信
```

## エラーハンドリング

- 無効な日付形式が指定された場合はエラーメッセージを表示
- 環境変数が設定されていない場合はエラーメッセージを表示
- Slack APIのレート制限に対応（自動リトライ） 