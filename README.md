# 🌅 Morning Helper - お天気Coordinate☀️

朝の忙しい時間に、天気・服装・持ち物・花粉・占いの情報を一括で提供するWebアプリケーションです。

## ✨ 主な機能

### 🌤️ **天気情報**
- 現在の天気と気温
- 体感温度
- 湿度・風速・UV指数
- 日の出・日の入り時刻
- 3日間の天気予報

### 👔 **服装提案**
- **ビジネス**: スーツ・ワイシャツ・ブレザーなど
- **カジュアル**: Tシャツ・ジーンズ・ジャケットなど  
- **キッズ**: 子供向けの服装提案
- 気温に応じた最適なコーディネート
- 詳細なアドバイス付き

### 🎒 **持ち物提案**
- 天気に応じた必須アイテム
- オプションアイテム
- 各アイテムの理由説明

### 🌸 **花粉情報**
- 現在の花粉レベル
- 花粉の種類（スギ・ヒノキ・ブタクサなど）
- 3日間の花粉予報
- 対策アドバイス

### 🔮 **占い機能**
- 12星座別の運勢
- 総合運・恋愛運・仕事運・健康運
- ラッキーカラー・ラッキーアイテム
- 日替わり・時間帯別の運勢変化

## 🚀 技術スタック

### **フロントエンド**
- **HTML5/CSS3** - レスポンシブデザイン
- **Tailwind CSS** - ユーティリティファーストCSS
- **JavaScript (ES6+)** - 動的コンテンツ更新
- **Google Fonts** - M PLUS Rounded 1c フォント

### **バックエンド**
- **Ruby on Rails 7.1** - Webフレームワーク
- **PostgreSQL** - データベース
- **Redis** - キャッシュストレージ
- **Puma** - Webサーバー

### **外部API**
- **OpenWeatherMap** - 天気情報
- **Geolocation API** - 位置情報取得

### **デプロイ**
- **Render** - クラウドプラットフォーム
- **GitHub** - バージョン管理

## 🎨 デザインコンセプト

### **ポップ&キュート**
- **Toy Story風**の雲の背景
- **パステルカラー**の配色
- **グラスモーフィズム**のカードデザイン
- **アニメーション**効果

### **モバイルファースト**
- スマートフォン最適化
- タッチフレンドリーなUI
- 朝の忙しい時間でも使いやすい

## 🛠️ セットアップ

### **前提条件**
- Ruby 3.2.0
- PostgreSQL
- Redis
- Node.js (アセット用)

### **インストール**

1. **リポジトリのクローン**
```bash
git clone https://github.com/yourusername/morning_helper.git
cd morning_helper
```

2. **依存関係のインストール**
```bash
bundle install
```

3. **データベースのセットアップ**
```bash
rails db:create
rails db:migrate
```

4. **環境変数の設定**
```bash
# .env ファイルを作成
echo "OPENWEATHER_API_KEY=your_api_key_here" > .env
```

5. **サーバーの起動**
```bash
rails server
```

6. **ブラウザでアクセス**
```
http://localhost:3000
```

## 🧪 テスト

### **テストの実行**
```bash
# 全テストの実行
bundle exec rspec

# 特定のテストの実行
bundle exec rspec spec/requests/api/v1/weather_spec.rb

# カバレッジレポート
bundle exec rspec --format documentation
```

### **テスト内容**
- **API エンドポイントテスト** (15テスト)
- **サービス層テスト** (10テスト)
- **エラーハンドリングテスト**
- **パラメータ検証テスト**

## 🚀 デプロイ

### **Render でのデプロイ**

1. **GitHubリポジトリの準備**
```bash
git add .
git commit -m "Deploy to Render"
git push origin main
```

2. **Render での設定**
   - Web Service を作成
   - PostgreSQL Database を追加
   - 環境変数を設定

詳細は [DEPLOY.md](DEPLOY.md) を参照してください。

## 📱 使用方法

### **基本操作**
1. **位置情報の許可** - GPSで現在地を取得
2. **天気情報の確認** - 現在の天気と気温
3. **服装スタイルの選択** - ビジネス/カジュアル/キッズ
4. **星座の選択** - 12星座から選択
5. **情報の確認** - 提案された服装・持ち物・運勢

### **API エンドポイント**

#### **天気情報**
```
GET /api/v1/weather?lat=35.6762&lon=139.6503
```

#### **服装提案**
```
GET /api/v1/clothing?temperature=20&weather=clear&style=business
```

#### **持ち物提案**
```
GET /api/v1/items?temperature=20&weather=clear&humidity=60&wind_speed=5
```

#### **花粉情報**
```
GET /api/v1/pollen?lat=35.6762&lon=139.6503
```

#### **占い**
```
GET /api/v1/fortune?lat=35.6762&lon=139.6503&zodiac=aries
```

## 🔧 開発

### **プロジェクト構造**
```
app/
├── controllers/
│   ├── api/v1/          # API コントローラー
│   └── home_controller.rb
├── services/            # ビジネスロジック
├── views/               # ERB テンプレート
└── assets/              # CSS/JS アセット

config/
├── routes.rb            # ルーティング設定
├── database.yml         # データベース設定
└── environments/        # 環境別設定

spec/                    # テストファイル
docs/                    # ドキュメント
```

### **コーディング規約**
- **Ruby**: RuboCop 準拠
- **JavaScript**: ESLint 準拠
- **CSS**: Tailwind CSS ユーティリティクラス使用

## 📊 パフォーマンス

### **最適化項目**
- **Redis キャッシュ** - API レスポンスのキャッシュ
- **アセット圧縮** - CSS/JS の最小化
- **画像最適化** - WebP フォーマット使用
- **CDN** - 静的ファイルの配信

### **レスポンス時間**
- **天気情報**: < 500ms (キャッシュ時 < 50ms)
- **服装提案**: < 200ms
- **占い**: < 100ms

## 🤝 コントリビューション

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 📞 サポート

問題や質問がある場合は、[Issues](https://github.com/yourusername/morning_helper/issues) で報告してください。

## 🙏 謝辞

- [OpenWeatherMap](https://openweathermap.org/) - 天気データAPI
- [Tailwind CSS](https://tailwindcss.com/) - CSS フレームワーク
- [Render](https://render.com/) - デプロイプラットフォーム

---

**🌅 朝の準備を楽しく、効率的に！ Morning Helper で素敵な一日を始めましょう！** ✨