# Weight Report App スペック

## 目的

Weight Report App は、Android 向けに体重を日次で記録し、履歴・平均・目標達成状況を確認できる体重管理アプリです。

## 対象プラットフォーム

- Flutter stable channel
- Android

## 現在の主要機能

1. 今日の体重を入力できる。
2. 体重履歴を一覧で確認できる。
3. 直近 7 日平均を表示できる。
4. 目標体重 75kg までの進捗を表示できる。
5. Material 3 に準拠した UI を利用する。
6. Riverpod による状態管理を利用する。
7. Isar によるローカル永続化を利用する。

## 画面仕様

### ホーム画面

- アプリ起動時は、`screen-animations/weight-entry-start-screen-reference.png` を基準にした体重入力画面を表示する。
- 今日の体重入力欄を表示する。
- 入力前は、入力エリアを指差すキャラクター画像で入力位置を案内する。
- 起動時の入力画面は、淡いピンク基調の背景、雲・星・ハートなどの装飾、入力エリアを指差すキャラクター、下部の大きな角丸カード型体重表示で構成する。
- 未入力時の体重表示は `00.0 kg` とし、数値を大きく、単位 `kg` を右側に小さく表示する。
- 体重表示カードは白〜淡色の背景、ピンクの枠線、角丸、軽い影を付け、入力可能な領域であることが分かる見た目にする。
- 入力した体重を保存できる。
- 保存後は、ハイタッチを求めるキャラクター画像と「ハイタッチ！」操作を表示する。
- ハイタッチ後は、記録完了を祝うキャラクター画像と完了メッセージを表示する。
- 保存済みの体重履歴を表示する。
- 直近 7 日平均を表示する。
- 目標 75kg までの進捗を表示する。

## データ仕様

### 体重記録

- 記録日
- 体重

## 受け入れ条件

- ユーザーは今日の体重を入力し、ローカルに保存できる。
- 保存した体重はアプリ再起動後も確認できる。
- 体重履歴は記録日と体重が分かる形で表示される。
- 直近 7 日分の記録がある場合、平均体重が表示される。
- 目標体重 75kg に対する進捗が表示される。

## 画面イメージ/アニメーション

画面イメージ、画面遷移、操作アニメーションは `screen-animations/` に格納します。ファイル名は、対象画面や操作が分かる名前にします。

例:

- `home-screen.png`
- `weight-entry-flow.gif`
- `history-scroll.mp4`

現在の登録済み素材:

- `screen-animations/weight-entry-start-screen-reference.png`: アプリ起動時に表示する体重入力画面の参考画像。
- `../screenshots/startup-weight-entry-screen.png`: 実装後にキャプチャしたアプリ起動時の体重入力画面。
- `screen-animations/weight-entry-high-touch-flow.png`: 体重入力後にハイタッチを求め、タップ後に記録完了演出を表示する画面フロー案。
- `screen-animations/characters/character-pointing-input.png`: 入力前に入力エリアを案内するキャラクター画像。
- `screen-animations/characters/character-high-touch.png`: 入力後にハイタッチを求めるキャラクター画像。
- `screen-animations/characters/character-celebration.png`: 記録完了後にお祝いするキャラクター画像。
