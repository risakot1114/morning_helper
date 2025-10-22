# Morning Helper 技術仕様書

## 1. アーキテクチャ概要

### 1.1 システム構成
```
Frontend (React) ←→ Backend (Rails API) ←→ External APIs
     ↓                    ↓                    ↓
  TailwindCSS         PostgreSQL          OpenWeatherMap
  React Icons         Redis Cache         Pollen API
                      Fortune Logic
```

### 1.2 技術スタック詳細

#### Frontend
- **React 18.x** - UIライブラリ
- **TailwindCSS 3.x** - CSSフレームワーク
- **React Icons** - アイコンライブラリ
- **Axios** - HTTPクライアント
- **React Router** - ルーティング（必要に応じて）

#### Backend
- **Ruby on Rails 7.x** - Webフレームワーク
- **PostgreSQL 14+** - データベース
- **Redis 6+** - キャッシュ・セッション管理
- **Rack CORS** - CORS対応
- **JWT** - 認証（将来の拡張用）

#### External APIs
- **OpenWeatherMap API** - 天気情報
- **WeatherAPI** - 天気情報（バックアップ）
- **花粉飛散情報API** - 花粉情報
- **自作占いロジック** - 運勢計算

## 2. フロントエンド仕様

### 2.1 プロジェクト構成
```
frontend/
├── src/
│   ├── components/
│   │   ├── WeatherCard.jsx
│   │   ├── ClothingCard.jsx
│   │   ├── ItemsCard.jsx
│   │   ├── PollenCard.jsx
│   │   ├── FortuneCard.jsx
│   │   └── Layout.jsx
│   ├── hooks/
│   │   ├── useWeather.js
│   │   ├── useClothing.js
│   │   └── useFortune.js
│   ├── services/
│   │   └── api.js
│   ├── utils/
│   │   ├── weatherUtils.js
│   │   └── clothingUtils.js
│   └── App.jsx
├── public/
│   └── images/
└── package.json
```

### 2.2 主要コンポーネント

#### WeatherCard.jsx
```jsx
// 天気情報を表示するカードコンポーネント
- 現在の天気・気温
- 今日の最高・最低気温
- 降水確率
- 天気アイコン（☀️🌤🌧☔）
- パステルカラーの背景
```

#### ClothingCard.jsx
```jsx
// 服装提案を表示するカードコンポーネント
- 気温に応じた服装提案
- ビジネス/カジュアル切替
- 服装アイコン（👔👕🧥👗🩳）
- 服装の詳細説明
```

#### ItemsCard.jsx
```jsx
// 持ち物提案を表示するカードコンポーネント
- 雨傘☔、日傘🌂、マスク😷等
- 天気・花粉に応じたアイテム
- アイコン表示
```

#### PollenCard.jsx
```jsx
// 花粉情報を表示するカードコンポーネント
- 花粉飛散量（少/中/多）
- 色分け表示
- 花粉アイコン（🌸💨）
- 対策アドバイス
```

#### FortuneCard.jsx
```jsx
// 占い結果を表示するカードコンポーネント
- 星座選択
- 運勢（総合、恋愛、仕事、健康、金運）
- ラッキーカラー
- 星座アイコン
```

### 2.3 スタイリング仕様

#### TailwindCSS設定
```javascript
// tailwind.config.js
module.exports = {
  content: ['./src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        // パステルカラーパレット
        'pastel-blue': '#B8E6FF',
        'pastel-pink': '#FFB8E6',
        'pastel-green': '#B8FFB8',
        'pastel-yellow': '#FFFFB8',
        'pastel-purple': '#E6B8FF',
      },
      borderRadius: {
        'card': '16px',
      },
      boxShadow: {
        'card': '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
      }
    }
  },
  plugins: []
}
```

#### カードスタイル
```css
.card-base {
  @apply bg-white rounded-card shadow-card p-6 mb-4;
}

.weather-card {
  @apply card-base bg-gradient-to-br from-pastel-blue to-pastel-purple;
}

.clothing-card {
  @apply card-base bg-gradient-to-br from-pastel-pink to-pastel-yellow;
}

.items-card {
  @apply card-base bg-gradient-to-br from-pastel-green to-pastel-blue;
}

.pollen-card {
  @apply card-base bg-gradient-to-br from-pastel-yellow to-pastel-pink;
}

.fortune-card {
  @apply card-base bg-gradient-to-br from-pastel-purple to-pastel-green;
}
```

## 3. バックエンド仕様

### 3.1 Rails API構成
```
app/
├── controllers/
│   ├── api/
│   │   ├── v1/
│   │   │   ├── weather_controller.rb
│   │   │   ├── clothing_controller.rb
│   │   │   ├── items_controller.rb
│   │   │   ├── pollen_controller.rb
│   │   │   └── fortune_controller.rb
│   │   └── application_controller.rb
├── models/
│   ├── user.rb
│   ├── clothing.rb
│   ├── suggestion.rb
│   └── weather_data.rb
├── services/
│   ├── weather_service.rb
│   ├── clothing_service.rb
│   ├── pollen_service.rb
│   └── fortune_service.rb
└── serializers/
    ├── weather_serializer.rb
    ├── clothing_serializer.rb
    └── suggestion_serializer.rb
```

### 3.2 API エンドポイント

#### Weather API
```
GET /api/v1/weather
- 現在の天気情報を取得
- パラメータ: lat, lon (緯度経度)

Response:
{
  "current": {
    "temperature": 22,
    "condition": "sunny",
    "icon": "☀️",
    "humidity": 65
  },
  "today": {
    "max_temp": 25,
    "min_temp": 18,
    "rain_probability": 20
  }
}
```

#### Clothing API
```
GET /api/v1/clothing
- 服装提案を取得
- パラメータ: temperature, weather, style (business/casual)

Response:
{
  "outfit": {
    "top": "薄手ワイシャツ",
    "bottom": "スラックス",
    "outer": "ジャケット",
    "accessories": ["ネクタイ"],
    "icon": "👔"
  },
  "advice": "朝晩の気温差があるので羽織ものをお忘れなく"
}
```

#### Items API
```
GET /api/v1/items
- 持ち物提案を取得
- パラメータ: weather, pollen_level, uv_index

Response:
{
  "items": [
    {
      "name": "雨傘",
      "icon": "☔",
      "reason": "降水確率20%"
    },
    {
      "name": "マスク",
      "icon": "😷",
      "reason": "花粉飛散量が多い"
    }
  ]
}
```

#### Pollen API
```
GET /api/v1/pollen
- 花粉情報を取得
- パラメータ: location

Response:
{
  "level": "high",
  "level_text": "多い",
  "color": "red",
  "icon": "🌸",
  "advice": "今日は花粉多め、マスク必須です"
}
```

#### Fortune API
```
GET /api/v1/fortune
- 占い結果を取得
- パラメータ: zodiac_sign

Response:
{
  "overall": 4,
  "love": 3,
  "work": 5,
  "health": 4,
  "money": 3,
  "lucky_color": "ブルー",
  "lucky_item": "ペン",
  "advice": "今日は仕事運が最高！新しいアイデアが浮かびそうです"
}
```

### 3.3 サービス層

#### WeatherService
```ruby
class WeatherService
  def initialize(lat:, lon:)
    @lat = lat
    @lon = lon
  end

  def current_weather
    # OpenWeatherMap API呼び出し
    # データの整形・変換
  end

  def today_forecast
    # 今日の天気予報取得
  end
end
```

#### ClothingService
```ruby
class ClothingService
  def initialize(temperature:, weather:, style: 'business')
    @temperature = temperature
    @weather = weather
    @style = style
  end

  def suggest_outfit
    # 気温・天気に基づく服装提案ロジック
    # ビジネス/カジュアル別の提案
  end
end
```

## 4. データベース設計

### 4.1 テーブル構成

#### users
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  birthday DATE,
  location VARCHAR(100),
  zodiac_sign VARCHAR(20),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

#### clothing_items
```sql
CREATE TABLE clothing_items (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(50) NOT NULL, -- 'top', 'bottom', 'outer', 'accessories'
  style VARCHAR(50) NOT NULL,    -- 'business', 'casual', 'child'
  min_temp INTEGER,
  max_temp INTEGER,
  weather_condition VARCHAR(50),
  icon VARCHAR(10),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

#### suggestions
```sql
CREATE TABLE suggestions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  date DATE NOT NULL,
  weather_data JSONB,
  clothing_suggestion JSONB,
  items_suggestion JSONB,
  pollen_data JSONB,
  fortune_data JSONB,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### 4.2 インデックス
```sql
-- パフォーマンス向上のためのインデックス
CREATE INDEX idx_suggestions_user_date ON suggestions(user_id, date);
CREATE INDEX idx_clothing_temp ON clothing_items(min_temp, max_temp);
CREATE INDEX idx_clothing_style ON clothing_items(style, category);
```

## 5. キャッシュ戦略

### 5.1 Redis設定
```ruby
# config/redis.yml
development:
  host: localhost
  port: 6379
  db: 0

production:
  host: <%= ENV['REDIS_URL'] %>
  port: 6379
  db: 0
```

### 5.2 キャッシュ戦略
```ruby
# 天気データ: 30分キャッシュ
Rails.cache.fetch("weather_#{lat}_#{lon}", expires_in: 30.minutes) do
  WeatherService.new(lat: lat, lon: lon).current_weather
end

# 服装提案: 1時間キャッシュ
Rails.cache.fetch("clothing_#{temp}_#{weather}_#{style}", expires_in: 1.hour) do
  ClothingService.new(temperature: temp, weather: weather, style: style).suggest_outfit
end

# 花粉データ: 6時間キャッシュ
Rails.cache.fetch("pollen_#{location}", expires_in: 6.hours) do
  PollenService.new(location: location).current_level
end
```

## 6. エラーハンドリング

### 6.1 フロントエンド
```javascript
// エラー境界コンポーネント
class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <div className="error-card">データの取得に失敗しました</div>;
    }
    return this.props.children;
  }
}
```

### 6.2 バックエンド
```ruby
# 例外処理
class Api::V1::WeatherController < ApplicationController
  rescue_from WeatherService::ApiError, with: :handle_weather_error
  rescue_from StandardError, with: :handle_generic_error

  private

  def handle_weather_error(error)
    render json: { error: '天気情報の取得に失敗しました' }, status: 503
  end

  def handle_generic_error(error)
    Rails.logger.error "Unexpected error: #{error.message}"
    render json: { error: 'サーバーエラーが発生しました' }, status: 500
  end
end
```

## 7. セキュリティ

### 7.1 CORS設定
```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:3000', 'https://yourdomain.com'
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

### 7.2 API レート制限
```ruby
# Gemfile
gem 'rack-attack'

# config/initializers/rack_attack.rb
Rack::Attack.throttle('api/ip', limit: 100, period: 1.hour) do |req|
  req.ip if req.path.start_with?('/api/')
end
```

## 8. デプロイメント

### 8.1 Docker設定
```dockerfile
# Dockerfile
FROM ruby:3.1.0
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
```

### 8.2 Heroku設定
```yaml
# app.json
{
  "name": "morning-helper-api",
  "description": "Morning Helper API",
  "repository": "https://github.com/yourusername/morning-helper",
  "stack": "heroku-22",
  "addons": [
    "heroku-postgresql:mini",
    "heroku-redis:mini"
  ],
  "env": {
    "RAILS_ENV": "production"
  }
}
```

## 9. 監視・ログ

### 9.1 ログ設定
```ruby
# config/environments/production.rb
config.log_level = :info
config.log_formatter = ::Logger::Formatter.new

# 構造化ログ
Rails.logger = ActiveSupport::Logger.new(STDOUT)
Rails.logger.formatter = proc do |severity, datetime, progname, msg|
  {
    timestamp: datetime.iso8601,
    level: severity,
    message: msg
  }.to_json + "\n"
end
```

### 9.2 ヘルスチェック
```ruby
# config/routes.rb
get '/health', to: 'health#check'

# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def check
    render json: {
      status: 'ok',
      timestamp: Time.current.iso8601,
      version: Rails.application.config.version
    }
  end
end
```
