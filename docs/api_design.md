# Morning Helper API設計書

## 1. API概要

### 1.1 基本情報
- **ベースURL**: `https://api.morning-helper.com/api/v1`
- **認証方式**: なし（ログイン不要）
- **データ形式**: JSON
- **文字エンコーディング**: UTF-8
- **HTTPメソッド**: GET（読み取り専用）

### 1.2 共通レスポンス形式
```json
{
  "status": "success",
  "data": { ... },
  "message": "Success",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### 1.3 エラーレスポンス形式
```json
{
  "status": "error",
  "error": {
    "code": "WEATHER_API_ERROR",
    "message": "天気情報の取得に失敗しました",
    "details": "API rate limit exceeded"
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## 2. エンドポイント一覧

### 2.1 天気情報API
```
GET /api/v1/weather
```

#### パラメータ
| パラメータ | 型 | 必須 | 説明 |
|------------|----|----|------|
| lat | float | Yes | 緯度 |
| lon | float | Yes | 経度 |
| units | string | No | 単位系 (metric/imperial) |

#### レスポンス例
```json
{
  "status": "success",
  "data": {
    "current": {
      "temperature": 22,
      "feels_like": 24,
      "condition": "sunny",
      "description": "晴れ",
      "icon": "☀️",
      "humidity": 65,
      "wind_speed": 3.2,
      "uv_index": 6
    },
    "today": {
      "max_temp": 25,
      "min_temp": 18,
      "rain_probability": 20,
      "sunrise": "06:30",
      "sunset": "18:45"
    },
    "hourly": [
      {
        "time": "09:00",
        "temperature": 20,
        "condition": "sunny",
        "icon": "☀️",
        "rain_probability": 10
      },
      {
        "time": "12:00",
        "temperature": 24,
        "condition": "partly_cloudy",
        "icon": "⛅",
        "rain_probability": 15
      }
    ]
  },
  "message": "Success",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### 2.2 服装提案API
```
GET /api/v1/clothing
```

#### パラメータ
| パラメータ | 型 | 必須 | 説明 |
|------------|----|----|------|
| temperature | integer | Yes | 気温 |
| weather | string | Yes | 天気条件 (sunny/cloudy/rainy) |
| style | string | No | スタイル (business/casual/child) |
| gender | string | No | 性別 (male/female/unisex) |

#### レスポンス例
```json
{
  "status": "success",
  "data": {
    "outfit": {
      "top": "薄手ワイシャツ",
      "bottom": "スラックス",
      "outer": "ジャケット",
      "shoes": "革靴",
      "accessories": ["ネクタイ", "ベルト"],
      "icon": "👔",
      "style": "business"
    },
    "advice": "朝晩の気温差があるので羽織ものをお忘れなく",
    "comfort_level": "comfortable",
    "temperature_range": {
      "min": 18,
      "max": 25
    }
  },
  "message": "Success",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### 2.3 持ち物提案API
```
GET /api/v1/items
```

#### パラメータ
| パラメータ | 型 | 必須 | 説明 |
|------------|----|----|------|
| weather | string | Yes | 天気条件 |
| temperature | integer | Yes | 気温 |
| pollen_level | string | No | 花粉レベル (low/medium/high) |
| uv_index | integer | No | UV指数 |
| rain_probability | integer | No | 降水確率 |

#### レスポンス例
```json
{
  "status": "success",
  "data": {
    "essential_items": [
      {
        "name": "雨傘",
        "icon": "☔",
        "reason": "降水確率20%",
        "priority": "medium"
      },
      {
        "name": "マスク",
        "icon": "😷",
        "reason": "花粉飛散量が多い",
        "priority": "high"
      }
    ],
    "optional_items": [
      {
        "name": "日傘",
        "icon": "🌂",
        "reason": "UV指数が高い",
        "priority": "low"
      }
    ],
    "advice": "花粉対策を忘れずに！"
  },
  "message": "Success",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### 2.4 花粉情報API
```
GET /api/v1/pollen
```

#### パラメータ
| パラメータ | 型 | 必須 | 説明 |
|------------|----|----|------|
| location | string | Yes | 地域名 |
| date | string | No | 日付 (YYYY-MM-DD) |

#### レスポンス例
```json
{
  "status": "success",
  "data": {
    "location": "東京",
    "date": "2024-01-01",
    "overall_level": "high",
    "level_text": "多い",
    "color": "red",
    "icon": "🌸",
    "pollen_types": [
      {
        "name": "スギ",
        "level": "high",
        "level_text": "多い",
        "icon": "🌲"
      },
      {
        "name": "ヒノキ",
        "level": "medium",
        "level_text": "やや多い",
        "icon": "🌲"
      }
    ],
    "advice": "今日は花粉多め、マスク必須です",
    "forecast": [
      {
        "time": "09:00",
        "level": "high",
        "wind_speed": 3.2
      },
      {
        "time": "15:00",
        "level": "medium",
        "wind_speed": 2.1
      }
    ]
  },
  "message": "Success",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### 2.5 占いAPI
```
GET /api/v1/fortune
```

#### パラメータ
| パラメータ | 型 | 必須 | 説明 |
|------------|----|----|------|
| zodiac_sign | string | Yes | 星座 (aries/taurus/gemini/...) |
| date | string | No | 日付 (YYYY-MM-DD) |

#### レスポンス例
```json
{
  "status": "success",
  "data": {
    "zodiac_sign": "aries",
    "zodiac_name": "おひつじ座",
    "zodiac_icon": "♈",
    "date": "2024-01-01",
    "fortune": {
      "overall": 4,
      "love": 3,
      "work": 5,
      "health": 4,
      "money": 3
    },
    "lucky": {
      "color": "ブルー",
      "color_hex": "#339AF0",
      "item": "ペン",
      "number": 7,
      "direction": "東"
    },
    "advice": "今日は仕事運が最高！新しいアイデアが浮かびそうです",
    "message": "積極的に行動することで良い結果が得られそうです"
  },
  "message": "Success",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### 2.6 統合提案API
```
GET /api/v1/suggestions
```

#### パラメータ
| パラメータ | 型 | 必須 | 説明 |
|------------|----|----|------|
| lat | float | Yes | 緯度 |
| lon | float | Yes | 経度 |
| zodiac_sign | string | No | 星座 |
| style | string | No | 服装スタイル |

#### レスポンス例
```json
{
  "status": "success",
  "data": {
    "weather": {
      "current": {
        "temperature": 22,
        "condition": "sunny",
        "icon": "☀️"
      },
      "today": {
        "max_temp": 25,
        "min_temp": 18,
        "rain_probability": 20
      }
    },
    "clothing": {
      "outfit": {
        "top": "薄手ワイシャツ",
        "bottom": "スラックス",
        "outer": "ジャケット",
        "icon": "👔"
      },
      "advice": "朝晩の気温差があるので羽織ものをお忘れなく"
    },
    "items": {
      "essential_items": [
        {
          "name": "マスク",
          "icon": "😷",
          "reason": "花粉飛散量が多い"
        }
      ]
    },
    "pollen": {
      "level": "high",
      "level_text": "多い",
      "icon": "🌸",
      "advice": "今日は花粉多め、マスク必須です"
    },
    "fortune": {
      "overall": 4,
      "lucky_color": "ブルー",
      "advice": "今日は仕事運が最高！"
    }
  },
  "message": "Success",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## 3. エラーコード

### 3.1 HTTPステータスコード
| コード | 説明 |
|--------|------|
| 200 | 成功 |
| 400 | リクエストエラー |
| 404 | リソースが見つからない |
| 429 | レート制限超過 |
| 500 | サーバーエラー |
| 503 | サービス利用不可 |

### 3.2 エラーコード一覧
| コード | 説明 |
|--------|------|
| INVALID_PARAMETERS | パラメータが無効 |
| WEATHER_API_ERROR | 天気APIエラー |
| POLLEN_API_ERROR | 花粉APIエラー |
| FORTUNE_CALCULATION_ERROR | 占い計算エラー |
| LOCATION_NOT_FOUND | 地域が見つからない |
| RATE_LIMIT_EXCEEDED | レート制限超過 |
| EXTERNAL_API_ERROR | 外部APIエラー |

## 4. レート制限

### 4.1 制限値
- **IPアドレスあたり**: 100リクエスト/時間
- **統合API**: 50リクエスト/時間
- **個別API**: 200リクエスト/時間

### 4.2 レート制限ヘッダー
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

## 5. キャッシュ戦略

### 5.1 キャッシュ時間
| データ | キャッシュ時間 |
|--------|----------------|
| 天気情報 | 30分 |
| 服装提案 | 1時間 |
| 花粉情報 | 6時間 |
| 占い結果 | 24時間 |

### 5.2 キャッシュヘッダー
```http
Cache-Control: public, max-age=1800
ETag: "weather-20240101-120000"
Last-Modified: Mon, 01 Jan 2024 12:00:00 GMT
```

## 6. バージョニング

### 6.1 バージョン管理
- **現在のバージョン**: v1
- **バージョン指定**: URLパス (`/api/v1/`)
- **後方互換性**: 6ヶ月間保証

### 6.2 バージョン情報
```json
{
  "api_version": "v1",
  "min_version": "v1",
  "deprecated": false,
  "sunset_date": null
}
```

## 7. セキュリティ

### 7.1 HTTPS必須
- すべてのAPI通信はHTTPSを使用
- HTTPリクエストは301リダイレクト

### 7.2 CORS設定
```http
Access-Control-Allow-Origin: https://morning-helper.com
Access-Control-Allow-Methods: GET, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

### 7.3 入力検証
- パラメータの型チェック
- 範囲チェック（緯度: -90〜90, 経度: -180〜180）
- SQLインジェクション対策

## 8. モニタリング

### 8.1 ログ出力
```json
{
  "timestamp": "2024-01-01T00:00:00Z",
  "method": "GET",
  "path": "/api/v1/weather",
  "status": 200,
  "response_time": 150,
  "ip_address": "192.168.1.1",
  "user_agent": "Mozilla/5.0...",
  "parameters": {
    "lat": 35.6762,
    "lon": 139.6503
  }
}
```

### 8.2 メトリクス
- リクエスト数
- レスポンス時間
- エラー率
- 外部API呼び出し数

## 9. テスト

### 9.1 テスト環境
- **URL**: `https://api-test.morning-helper.com/api/v1`
- **データ**: モックデータを使用
- **制限**: レート制限なし

### 9.2 テストケース
```bash
# 正常系テスト
curl "https://api-test.morning-helper.com/api/v1/weather?lat=35.6762&lon=139.6503"

# エラー系テスト
curl "https://api-test.morning-helper.com/api/v1/weather?lat=999&lon=999"

# パラメータ不足テスト
curl "https://api-test.morning-helper.com/api/v1/weather"
```

## 10. 実装例

### 10.1 JavaScript (Axios)
```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://api.morning-helper.com/api/v1',
  timeout: 5000,
  headers: {
    'Content-Type': 'application/json',
  }
});

// 天気情報取得
const getWeather = async (lat, lon) => {
  try {
    const response = await api.get('/weather', {
      params: { lat, lon }
    });
    return response.data;
  } catch (error) {
    console.error('Weather API Error:', error.response?.data);
    throw error;
  }
};

// 統合提案取得
const getSuggestions = async (lat, lon, zodiacSign, style) => {
  try {
    const response = await api.get('/suggestions', {
      params: { lat, lon, zodiac_sign: zodiacSign, style }
    });
    return response.data;
  } catch (error) {
    console.error('Suggestions API Error:', error.response?.data);
    throw error;
  }
};
```

### 10.2 Ruby (Net::HTTP)
```ruby
require 'net/http'
require 'json'
require 'uri'

class MorningHelperAPI
  BASE_URL = 'https://api.morning-helper.com/api/v1'
  
  def initialize
    @uri = URI(BASE_URL)
  end
  
  def get_weather(lat:, lon:)
    params = { lat: lat, lon: lon }
    make_request('/weather', params)
  end
  
  def get_suggestions(lat:, lon:, zodiac_sign: nil, style: nil)
    params = { lat: lat, lon: lon, zodiac_sign: zodiac_sign, style: style }.compact
    make_request('/suggestions', params)
  end
  
  private
  
  def make_request(endpoint, params)
    uri = URI("#{BASE_URL}#{endpoint}")
    uri.query = URI.encode_www_form(params)
    
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  rescue => e
    { status: 'error', error: { message: e.message } }
  end
end
```

このAPI設計書に従って、Rails APIを実装していきます！
