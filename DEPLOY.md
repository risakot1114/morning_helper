# 🌅 Morning Helper - Render デプロイガイド

## 🚀 Render へのデプロイ手順

### 1. 準備
1. [Render](https://render.com) にアカウントを作成
2. GitHubリポジトリを準備
3. OpenWeatherMap APIキーを取得

### 2. Render での設定

#### 2.1 Web Service の作成
1. Render ダッシュボードで「New +」→「Web Service」を選択
2. GitHubリポジトリを接続
3. 以下の設定を入力：

**基本設定:**
- **Name**: `morning-helper`
- **Environment**: `Ruby`
- **Region**: `Oregon (US West)`
- **Branch**: `main`
- **Root Directory**: `/` (空のまま)

**ビルド設定:**
- **Build Command**: `bundle install && bundle exec rails assets:precompile && bundle exec rails db:migrate`
- **Start Command**: `bundle exec rails server -p $PORT -e production`

#### 2.2 PostgreSQL Database の作成
1. 「New +」→「PostgreSQL」を選択
2. 以下の設定を入力：
- **Name**: `morning-helper-db`
- **Database**: `morning_helper_production`
- **User**: `morning_helper_user`
- **Plan**: `Free`

#### 2.3 環境変数の設定
Web Service の「Environment」タブで以下を設定：

**必須:**
```
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
OPENWEATHER_API_KEY=your_api_key_here
```

**自動設定（Renderが提供）:**
```
DATABASE_URL=postgresql://...
```

**オプション:**
```
REDIS_URL=redis://localhost:6379/0
```

### 3. デプロイ
1. 「Create Web Service」をクリック
2. ビルドが完了するまで待機（5-10分）
3. デプロイ完了後、URLでアクセス

### 4. 動作確認
- 天気情報の表示
- 服装提案機能
- アイテム提案機能
- 花粉情報
- 占い機能

## 🔧 トラブルシューティング

### ビルドエラー
- `bundle install` でエラーが出る場合：Gemfileの依存関係を確認
- アセットプリコンパイルエラー：`config.assets.compile = true` に一時変更

### データベースエラー
- マイグレーションエラー：`bundle exec rails db:create db:migrate` を実行
- 接続エラー：`DATABASE_URL` の設定を確認

### APIエラー
- OpenWeatherMap APIキーが正しく設定されているか確認
- API制限に達していないか確認

## 📱 アクセス方法
デプロイ完了後、Renderが提供するURL（例：`https://morning-helper.onrender.com`）でアクセスできます。

## 🔄 更新方法
GitHubにプッシュすると自動的に再デプロイされます。
