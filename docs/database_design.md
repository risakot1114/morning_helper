# Morning Helper データベース設計書

## 1. データベース概要

### 1.1 基本情報
- **データベース**: PostgreSQL 14+
- **文字エンコーディング**: UTF-8
- **照合順序**: ja_JP.UTF-8
- **タイムゾーン**: Asia/Tokyo

### 1.2 設計方針
- **正規化**: 第3正規形まで適用
- **インデックス**: パフォーマンス重視で適切に配置
- **外部キー**: 参照整合性を保証
- **JSONB**: 柔軟なデータ構造に使用

## 2. テーブル設計

### 2.1 users（ユーザー情報）
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  birthday DATE,
  location VARCHAR(100),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  zodiac_sign VARCHAR(20),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- インデックス
CREATE INDEX idx_users_location ON users(location);
CREATE INDEX idx_users_zodiac_sign ON users(zodiac_sign);
CREATE INDEX idx_users_coordinates ON users(latitude, longitude);
```

#### カラム説明
| カラム名 | 型 | 制約 | 説明 |
|----------|----|----|------|
| id | SERIAL | PRIMARY KEY | ユーザーID |
| name | VARCHAR(100) | | ユーザー名 |
| birthday | DATE | | 誕生日（星座計算用） |
| location | VARCHAR(100) | | 居住地 |
| latitude | DECIMAL(10,8) | | 緯度 |
| longitude | DECIMAL(11,8) | | 経度 |
| zodiac_sign | VARCHAR(20) | | 星座 |
| created_at | TIMESTAMP | | 作成日時 |
| updated_at | TIMESTAMP | | 更新日時 |

### 2.2 clothing_items（服装アイテム）
```sql
CREATE TABLE clothing_items (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(50) NOT NULL,
  style VARCHAR(50) NOT NULL,
  gender VARCHAR(20) DEFAULT 'unisex',
  min_temp INTEGER,
  max_temp INTEGER,
  weather_condition VARCHAR(50),
  icon VARCHAR(10),
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- インデックス
CREATE INDEX idx_clothing_category ON clothing_items(category);
CREATE INDEX idx_clothing_style ON clothing_items(style);
CREATE INDEX idx_clothing_temp ON clothing_items(min_temp, max_temp);
CREATE INDEX idx_clothing_weather ON clothing_items(weather_condition);
```

#### カラム説明
| カラム名 | 型 | 制約 | 説明 |
|----------|----|----|------|
| id | SERIAL | PRIMARY KEY | アイテムID |
| name | VARCHAR(100) | NOT NULL | アイテム名 |
| category | VARCHAR(50) | NOT NULL | カテゴリ（top/bottom/outer/shoes/accessories） |
| style | VARCHAR(50) | NOT NULL | スタイル（business/casual/child） |
| gender | VARCHAR(20) | | 性別（male/female/unisex） |
| min_temp | INTEGER | | 最低気温 |
| max_temp | INTEGER | | 最高気温 |
| weather_condition | VARCHAR(50) | | 天気条件 |
| icon | VARCHAR(10) | | アイコン |
| description | TEXT | | 説明 |
| created_at | TIMESTAMP | | 作成日時 |
| updated_at | TIMESTAMP | | 更新日時 |

### 2.3 clothing_outfits（服装コーディネート）
```sql
CREATE TABLE clothing_outfits (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  style VARCHAR(50) NOT NULL,
  gender VARCHAR(20) DEFAULT 'unisex',
  min_temp INTEGER,
  max_temp INTEGER,
  weather_condition VARCHAR(50),
  top_item_id INTEGER REFERENCES clothing_items(id),
  bottom_item_id INTEGER REFERENCES clothing_items(id),
  outer_item_id INTEGER REFERENCES clothing_items(id),
  shoes_item_id INTEGER REFERENCES clothing_items(id),
  icon VARCHAR(10),
  advice TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- インデックス
CREATE INDEX idx_outfits_style ON clothing_outfits(style);
CREATE INDEX idx_outfits_temp ON clothing_outfits(min_temp, max_temp);
CREATE INDEX idx_outfits_weather ON clothing_outfits(weather_condition);
```

### 2.4 essential_items（持ち物アイテム）
```sql
CREATE TABLE essential_items (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(50) NOT NULL,
  icon VARCHAR(10),
  priority VARCHAR(20) DEFAULT 'medium',
  weather_condition VARCHAR(50),
  min_temp INTEGER,
  max_temp INTEGER,
  pollen_level VARCHAR(20),
  uv_index_min INTEGER,
  rain_probability_min INTEGER,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- インデックス
CREATE INDEX idx_items_category ON essential_items(category);
CREATE INDEX idx_items_priority ON essential_items(priority);
CREATE INDEX idx_items_weather ON essential_items(weather_condition);
CREATE INDEX idx_items_pollen ON essential_items(pollen_level);
```

### 2.5 pollen_data（花粉データ）
```sql
CREATE TABLE pollen_data (
  id SERIAL PRIMARY KEY,
  location VARCHAR(100) NOT NULL,
  date DATE NOT NULL,
  overall_level VARCHAR(20) NOT NULL,
  cedar_level VARCHAR(20),
  cypress_level VARCHAR(20),
  ragweed_level VARCHAR(20),
  wind_speed DECIMAL(4,2),
  humidity INTEGER,
  temperature DECIMAL(4,2),
  advice TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- インデックス
CREATE INDEX idx_pollen_location_date ON pollen_data(location, date);
CREATE INDEX idx_pollen_level ON pollen_data(overall_level);
CREATE UNIQUE INDEX idx_pollen_unique ON pollen_data(location, date);
```

### 2.6 zodiac_signs（星座情報）
```sql
CREATE TABLE zodiac_signs (
  id SERIAL PRIMARY KEY,
  name_en VARCHAR(20) NOT NULL UNIQUE,
  name_ja VARCHAR(20) NOT NULL,
  icon VARCHAR(10),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  element VARCHAR(20),
  quality VARCHAR(20),
  ruler VARCHAR(20),
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- インデックス
CREATE INDEX idx_zodiac_dates ON zodiac_signs(start_date, end_date);
```

### 2.7 fortune_data（占いデータ）
```sql
CREATE TABLE fortune_data (
  id SERIAL PRIMARY KEY,
  zodiac_sign_id INTEGER REFERENCES zodiac_signs(id),
  date DATE NOT NULL,
  overall INTEGER NOT NULL CHECK (overall >= 1 AND overall <= 5),
  love INTEGER NOT NULL CHECK (love >= 1 AND love <= 5),
  work INTEGER NOT NULL CHECK (work >= 1 AND work <= 5),
  health INTEGER NOT NULL CHECK (health >= 1 AND health <= 5),
  money INTEGER NOT NULL CHECK (money >= 1 AND money <= 5),
  lucky_color VARCHAR(50),
  lucky_color_hex VARCHAR(7),
  lucky_item VARCHAR(100),
  lucky_number INTEGER,
  lucky_direction VARCHAR(20),
  advice TEXT,
  message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- インデックス
CREATE INDEX idx_fortune_zodiac_date ON fortune_data(zodiac_sign_id, date);
CREATE UNIQUE INDEX idx_fortune_unique ON fortune_data(zodiac_sign_id, date);
```

### 2.8 suggestions（提案履歴）
```sql
CREATE TABLE suggestions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  date DATE NOT NULL,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  weather_data JSONB,
  clothing_suggestion JSONB,
  items_suggestion JSONB,
  pollen_data JSONB,
  fortune_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- インデックス
CREATE INDEX idx_suggestions_user_date ON suggestions(user_id, date);
CREATE INDEX idx_suggestions_coordinates ON suggestions(latitude, longitude);
CREATE INDEX idx_suggestions_weather ON suggestions USING GIN(weather_data);
CREATE INDEX idx_suggestions_clothing ON suggestions USING GIN(clothing_suggestion);
```

## 3. 初期データ

### 3.1 星座データ
```sql
INSERT INTO zodiac_signs (name_en, name_ja, icon, start_date, end_date, element, quality, ruler) VALUES
('aries', 'おひつじ座', '♈', '2024-03-21', '2024-04-19', '火', '活動宮', '火星'),
('taurus', 'おうし座', '♉', '2024-04-20', '2024-05-20', '土', '固定宮', '金星'),
('gemini', 'ふたご座', '♊', '2024-05-21', '2024-06-21', '風', '柔軟宮', '水星'),
('cancer', 'かに座', '♋', '2024-06-22', '2024-07-22', '水', '活動宮', '月'),
('leo', 'しし座', '♌', '2024-07-23', '2024-08-22', '火', '固定宮', '太陽'),
('virgo', 'おとめ座', '♍', '2024-08-23', '2024-09-22', '土', '柔軟宮', '水星'),
('libra', 'てんびん座', '♎', '2024-09-23', '2024-10-23', '風', '活動宮', '金星'),
('scorpio', 'さそり座', '♏', '2024-10-24', '2024-11-22', '水', '固定宮', '冥王星'),
('sagittarius', 'いて座', '♐', '2024-11-23', '2024-12-21', '火', '柔軟宮', '木星'),
('capricorn', 'やぎ座', '♑', '2024-12-22', '2024-01-19', '土', '活動宮', '土星'),
('aquarius', 'みずがめ座', '♒', '2024-01-20', '2024-02-18', '風', '固定宮', '天王星'),
('pisces', 'うお座', '♓', '2024-02-19', '2024-03-20', '水', '柔軟宮', '海王星');
```

### 3.2 服装アイテムデータ
```sql
-- ビジネス用アイテム
INSERT INTO clothing_items (name, category, style, gender, min_temp, max_temp, weather_condition, icon) VALUES
('薄手ワイシャツ', 'top', 'business', 'unisex', 20, 30, 'sunny', '👔'),
('スラックス', 'bottom', 'business', 'unisex', 15, 30, 'sunny', '👖'),
('ジャケット', 'outer', 'business', 'unisex', 10, 25, 'sunny', '🧥'),
('ネクタイ', 'accessories', 'business', 'male', 15, 30, 'sunny', '👔'),
('革靴', 'shoes', 'business', 'unisex', 5, 30, 'sunny', '👞'),

-- カジュアル用アイテム
('Tシャツ', 'top', 'casual', 'unisex', 20, 35, 'sunny', '👕'),
('ジーンズ', 'bottom', 'casual', 'unisex', 10, 30, 'sunny', '👖'),
('パーカー', 'outer', 'casual', 'unisex', 5, 20, 'sunny', '🧥'),
('スニーカー', 'shoes', 'casual', 'unisex', 5, 30, 'sunny', '👟'),

-- 雨用アイテム
('レインコート', 'outer', 'business', 'unisex', 5, 25, 'rainy', '🧥'),
('長靴', 'shoes', 'casual', 'unisex', 5, 20, 'rainy', '👢');
```

### 3.3 持ち物アイテムデータ
```sql
INSERT INTO essential_items (name, category, icon, priority, weather_condition, pollen_level, uv_index_min, rain_probability_min) VALUES
('雨傘', 'weather', '☔', 'high', 'rainy', NULL, NULL, 20),
('日傘', 'weather', '🌂', 'medium', 'sunny', NULL, 6, NULL),
('マスク', 'health', '😷', 'high', NULL, 'medium', NULL, NULL),
('サングラス', 'weather', '🕶️', 'medium', 'sunny', NULL, 5, NULL),
('手袋', 'weather', '🧤', 'low', NULL, NULL, NULL, NULL),
('マフラー', 'weather', '🧣', 'low', NULL, NULL, NULL, NULL),
('日焼け止め', 'health', '🧴', 'medium', 'sunny', NULL, 4, NULL),
('水筒', 'health', '💧', 'low', NULL, NULL, NULL, NULL);
```

## 4. ビュー定義

### 4.1 天気・服装提案ビュー
```sql
CREATE VIEW weather_clothing_suggestions AS
SELECT 
  w.temperature,
  w.condition,
  c.name as clothing_name,
  c.category,
  c.style,
  c.icon,
  c.min_temp,
  c.max_temp
FROM weather_data w
JOIN clothing_items c ON (
  w.temperature BETWEEN c.min_temp AND c.max_temp
  AND (c.weather_condition = w.condition OR c.weather_condition IS NULL)
);
```

### 4.2 今日の統合提案ビュー
```sql
CREATE VIEW daily_suggestions AS
SELECT 
  s.date,
  s.latitude,
  s.longitude,
  s.weather_data,
  s.clothing_suggestion,
  s.items_suggestion,
  s.pollen_data,
  s.fortune_data,
  u.name as user_name,
  u.zodiac_sign
FROM suggestions s
LEFT JOIN users u ON s.user_id = u.id
WHERE s.date = CURRENT_DATE;
```

## 5. ストアドプロシージャ

### 5.1 服装提案プロシージャ
```sql
CREATE OR REPLACE FUNCTION suggest_clothing(
  p_temperature INTEGER,
  p_weather VARCHAR(50),
  p_style VARCHAR(50) DEFAULT 'business',
  p_gender VARCHAR(20) DEFAULT 'unisex'
)
RETURNS TABLE (
  outfit_name VARCHAR(100),
  top_item VARCHAR(100),
  bottom_item VARCHAR(100),
  outer_item VARCHAR(100),
  shoes_item VARCHAR(100),
  advice TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    co.name,
    ci_top.name,
    ci_bottom.name,
    ci_outer.name,
    ci_shoes.name,
    co.advice
  FROM clothing_outfits co
  LEFT JOIN clothing_items ci_top ON co.top_item_id = ci_top.id
  LEFT JOIN clothing_items ci_bottom ON co.bottom_item_id = ci_bottom.id
  LEFT JOIN clothing_items ci_outer ON co.outer_item_id = ci_outer.id
  LEFT JOIN clothing_items ci_shoes ON co.shoes_item_id = ci_shoes.id
  WHERE co.style = p_style
    AND (co.gender = p_gender OR co.gender = 'unisex')
    AND p_temperature BETWEEN co.min_temp AND co.max_temp
    AND (co.weather_condition = p_weather OR co.weather_condition IS NULL)
  ORDER BY 
    CASE WHEN co.weather_condition = p_weather THEN 1 ELSE 2 END,
    ABS(p_temperature - (co.min_temp + co.max_temp) / 2)
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;
```

### 5.2 持ち物提案プロシージャ
```sql
CREATE OR REPLACE FUNCTION suggest_items(
  p_weather VARCHAR(50),
  p_temperature INTEGER,
  p_pollen_level VARCHAR(20) DEFAULT NULL,
  p_uv_index INTEGER DEFAULT NULL,
  p_rain_probability INTEGER DEFAULT NULL
)
RETURNS TABLE (
  item_name VARCHAR(100),
  item_icon VARCHAR(10),
  priority VARCHAR(20),
  reason TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ei.name,
    ei.icon,
    ei.priority,
    CASE 
      WHEN ei.weather_condition = p_weather THEN '天気に応じて必要'
      WHEN ei.pollen_level = p_pollen_level THEN '花粉対策として必要'
      WHEN ei.uv_index_min IS NOT NULL AND p_uv_index >= ei.uv_index_min THEN 'UV対策として必要'
      WHEN ei.rain_probability_min IS NOT NULL AND p_rain_probability >= ei.rain_probability_min THEN '雨対策として必要'
      ELSE 'その他の理由で必要'
    END as reason
  FROM essential_items ei
  WHERE (
    (ei.weather_condition = p_weather) OR
    (ei.pollen_level = p_pollen_level) OR
    (ei.uv_index_min IS NOT NULL AND p_uv_index >= ei.uv_index_min) OR
    (ei.rain_probability_min IS NOT NULL AND p_rain_probability >= ei.rain_probability_min)
  )
  ORDER BY 
    CASE ei.priority 
      WHEN 'high' THEN 1 
      WHEN 'medium' THEN 2 
      WHEN 'low' THEN 3 
    END;
END;
$$ LANGUAGE plpgsql;
```

## 6. パフォーマンス最適化

### 6.1 パーティショニング
```sql
-- 提案履歴テーブルの月別パーティショニング
CREATE TABLE suggestions_y2024m01 PARTITION OF suggestions
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE suggestions_y2024m02 PARTITION OF suggestions
FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
```

### 6.2 統計情報更新
```sql
-- 定期的な統計情報更新
ANALYZE users;
ANALYZE clothing_items;
ANALYZE suggestions;
ANALYZE pollen_data;
ANALYZE fortune_data;
```

### 6.3 クエリ最適化
```sql
-- よく使用されるクエリの最適化
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM clothing_items 
WHERE style = 'business' 
  AND min_temp <= 22 
  AND max_temp >= 22;
```

## 7. バックアップ・復旧

### 7.1 バックアップ戦略
```bash
# 日次フルバックアップ
pg_dump -h localhost -U postgres -d morning_helper > backup_$(date +%Y%m%d).sql

# 増分バックアップ（WAL）
pg_basebackup -h localhost -U postgres -D /backup/base -Ft -z -P
```

### 7.2 復旧手順
```bash
# データベース復旧
psql -h localhost -U postgres -d morning_helper < backup_20240101.sql
```

## 8. セキュリティ

### 8.1 アクセス制御
```sql
-- 読み取り専用ユーザー
CREATE USER readonly_user WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE morning_helper TO readonly_user;
GRANT USAGE ON SCHEMA public TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;

-- アプリケーション用ユーザー
CREATE USER app_user WITH PASSWORD 'app_password';
GRANT CONNECT ON DATABASE morning_helper TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO app_user;
```

### 8.2 データ暗号化
```sql
-- 機密データの暗号化（将来の拡張用）
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 例：ユーザー名の暗号化
ALTER TABLE users ADD COLUMN encrypted_name BYTEA;
```

このデータベース設計に従って、PostgreSQLデータベースを構築していきます！
