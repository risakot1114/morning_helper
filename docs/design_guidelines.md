# Morning Helper UI/UXデザインガイドライン

## 1. デザインコンセプト

### 1.1 基本コンセプト
- **「朝の準備を楽しく、簡単に」**
- **可愛くて直感的なUI**
- **パッと見てわかる情報表示**
- **カード型で情報を整理**

### 1.2 デザインキーワード
- 可愛い（Cute）
- 直感的（Intuitive）
- 親しみやすい（Friendly）
- 明るい（Bright）
- 清潔感（Clean）

## 2. カラーパレット

### 2.1 メインカラー
```css
/* パステルカラーパレット */
:root {
  /* 天気カード */
  --weather-blue: #B8E6FF;      /* パステルブルー */
  --weather-purple: #E6B8FF;    /* パステルパープル */
  
  /* 服装カード */
  --clothing-pink: #FFB8E6;     /* パステルピンク */
  --clothing-yellow: #FFFFB8;   /* パステルイエロー */
  
  /* 持ち物カード */
  --items-green: #B8FFB8;       /* パステルグリーン */
  --items-blue: #B8E6FF;        /* パステルブルー */
  
  /* 花粉カード */
  --pollen-yellow: #FFFFB8;     /* パステルイエロー */
  --pollen-pink: #FFB8E6;       /* パステルピンク */
  
  /* 占いカード */
  --fortune-purple: #E6B8FF;    /* パステルパープル */
  --fortune-green: #B8FFB8;     /* パステルグリーン */
  
  /* ベースカラー */
  --white: #FFFFFF;
  --gray-50: #F9FAFB;
  --gray-100: #F3F4F6;
  --gray-200: #E5E7EB;
  --gray-300: #D1D5DB;
  --gray-400: #9CA3AF;
  --gray-500: #6B7280;
  --gray-600: #4B5563;
  --gray-700: #374151;
  --gray-800: #1F2937;
  --gray-900: #111827;
  
  /* アクセントカラー */
  --accent-orange: #FFB84D;     /* オレンジ */
  --accent-red: #FF6B6B;        /* レッド */
  --accent-green: #51CF66;      /* グリーン */
  --accent-blue: #339AF0;       /* ブルー */
}
```

### 2.2 カラー使用ルール
- **背景**: パステルカラーのグラデーション
- **テキスト**: グレー系（gray-700, gray-800）
- **アクセント**: 鮮やかな色で重要な情報を強調
- **エラー**: レッド系で注意を促す
- **成功**: グリーン系で安心感を与える

## 3. タイポグラフィ

### 3.1 フォント設定
```css
/* Google Fonts */
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@300;400;500;700&display=swap');

:root {
  --font-family: 'Noto Sans JP', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}
```

### 3.2 フォントサイズ
```css
/* TailwindCSS カスタムサイズ */
.text-xs { font-size: 0.75rem; }      /* 12px */
.text-sm { font-size: 0.875rem; }     /* 14px */
.text-base { font-size: 1rem; }        /* 16px */
.text-lg { font-size: 1.125rem; }      /* 18px */
.text-xl { font-size: 1.25rem; }       /* 20px */
.text-2xl { font-size: 1.5rem; }      /* 24px */
.text-3xl { font-size: 1.875rem; }    /* 30px */
.text-4xl { font-size: 2.25rem; }      /* 36px */
```

### 3.3 フォントウェイト
- **Light (300)**: サブテキスト
- **Regular (400)**: 本文
- **Medium (500)**: 強調テキスト
- **Bold (700)**: 見出し

## 4. レイアウト・スペーシング

### 4.1 グリッドシステム
```css
/* カードレイアウト */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  padding: 1rem;
}

/* モバイルファースト */
@media (max-width: 768px) {
  .card-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
    padding: 0.5rem;
  }
}
```

### 4.2 スペーシング
```css
/* 統一されたスペーシング */
:root {
  --spacing-xs: 0.25rem;   /* 4px */
  --spacing-sm: 0.5rem;    /* 8px */
  --spacing-md: 1rem;      /* 16px */
  --spacing-lg: 1.5rem;    /* 24px */
  --spacing-xl: 2rem;      /* 32px */
  --spacing-2xl: 3rem;     /* 48px */
}
```

## 5. カードデザイン

### 5.1 カード基本スタイル
```css
.card-base {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  padding: 1.5rem;
  margin-bottom: 1rem;
  transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
}

.card-base:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}
```

### 5.2 カード別スタイル

#### 天気カード
```css
.weather-card {
  background: linear-gradient(135deg, var(--weather-blue), var(--weather-purple));
  color: var(--gray-800);
}

.weather-card .icon {
  font-size: 3rem;
  margin-bottom: 0.5rem;
}
```

#### 服装カード
```css
.clothing-card {
  background: linear-gradient(135deg, var(--clothing-pink), var(--clothing-yellow));
  color: var(--gray-800);
}

.clothing-card .outfit-icon {
  font-size: 2.5rem;
  margin-right: 1rem;
}
```

#### 持ち物カード
```css
.items-card {
  background: linear-gradient(135deg, var(--items-green), var(--items-blue));
  color: var(--gray-800);
}

.items-card .item-icon {
  font-size: 1.5rem;
  margin-right: 0.5rem;
}
```

#### 花粉カード
```css
.pollen-card {
  background: linear-gradient(135deg, var(--pollen-yellow), var(--pollen-pink));
  color: var(--gray-800);
}

.pollen-card .level-high {
  color: var(--accent-red);
}

.pollen-card .level-medium {
  color: var(--accent-orange);
}

.pollen-card .level-low {
  color: var(--accent-green);
}
```

#### 占いカード
```css
.fortune-card {
  background: linear-gradient(135deg, var(--fortune-purple), var(--fortune-green));
  color: var(--gray-800);
}

.fortune-card .zodiac-icon {
  font-size: 2rem;
  margin-bottom: 0.5rem;
}

.fortune-card .fortune-star {
  color: var(--accent-orange);
  font-size: 1.2rem;
}
```

## 6. アイコン・イラスト

### 6.1 天気アイコン
```jsx
const WeatherIcons = {
  sunny: '☀️',
  partly_cloudy: '⛅',
  cloudy: '☁️',
  rainy: '🌧️',
  stormy: '⛈️',
  snowy: '❄️',
  foggy: '🌫️'
};
```

### 6.2 服装アイコン
```jsx
const ClothingIcons = {
  business: '👔',
  casual: '👕',
  jacket: '🧥',
  dress: '👗',
  pants: '👖',
  shorts: '🩳',
  shoes: '👟',
  hat: '🧢',
  scarf: '🧣'
};
```

### 6.3 持ち物アイコン
```jsx
const ItemIcons = {
  umbrella: '☔',
  sunshade: '🌂',
  mask: '😷',
  sunglasses: '🕶️',
  gloves: '🧤',
  bag: '👜',
  water: '💧',
  sunscreen: '🧴'
};
```

### 6.4 花粉・占いアイコン
```jsx
const PollenIcons = {
  low: '🌸',
  medium: '🌺',
  high: '🌻',
  wind: '💨'
};

const FortuneIcons = {
  aries: '♈',
  taurus: '♉',
  gemini: '♊',
  cancer: '♋',
  leo: '♌',
  virgo: '♍',
  libra: '♎',
  scorpio: '♏',
  sagittarius: '♐',
  capricorn: '♑',
  aquarius: '♒',
  pisces: '♓'
};
```

## 7. ボタン・インタラクション

### 7.1 ボタンスタイル
```css
.btn-primary {
  background: linear-gradient(135deg, var(--accent-blue), var(--accent-green));
  color: white;
  border: none;
  border-radius: 12px;
  padding: 0.75rem 1.5rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease-in-out;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.btn-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.btn-secondary {
  background: white;
  color: var(--gray-700);
  border: 2px solid var(--gray-200);
  border-radius: 12px;
  padding: 0.75rem 1.5rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease-in-out;
}

.btn-secondary:hover {
  border-color: var(--accent-blue);
  color: var(--accent-blue);
}
```

### 7.2 トグルボタン
```css
.toggle-button {
  background: var(--gray-200);
  border: none;
  border-radius: 20px;
  padding: 0.25rem;
  cursor: pointer;
  transition: all 0.2s ease-in-out;
  position: relative;
}

.toggle-button.active {
  background: var(--accent-blue);
}

.toggle-slider {
  background: white;
  border-radius: 50%;
  width: 1.5rem;
  height: 1.5rem;
  transition: transform 0.2s ease-in-out;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.toggle-button.active .toggle-slider {
  transform: translateX(1.5rem);
}
```

## 8. レスポンシブデザイン

### 8.1 ブレークポイント
```css
/* モバイルファースト */
@media (min-width: 640px) { /* sm */ }
@media (min-width: 768px) { /* md */ }
@media (min-width: 1024px) { /* lg */ }
@media (min-width: 1280px) { /* xl */ }
@media (min-width: 1536px) { /* 2xl */ }
```

### 8.2 モバイル対応
```css
/* モバイル用レイアウト */
@media (max-width: 768px) {
  .card-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
    padding: 1rem;
  }
  
  .card-base {
    padding: 1rem;
    margin-bottom: 0.75rem;
  }
  
  .weather-card .icon {
    font-size: 2.5rem;
  }
  
  .clothing-card .outfit-icon {
    font-size: 2rem;
  }
}
```

## 9. アニメーション・トランジション

### 9.1 基本アニメーション
```css
/* フェードイン */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.fade-in {
  animation: fadeIn 0.5s ease-out;
}

/* バウンス */
@keyframes bounce {
  0%, 20%, 53%, 80%, 100% { transform: translate3d(0,0,0); }
  40%, 43% { transform: translate3d(0,-10px,0); }
  70% { transform: translate3d(0,-5px,0); }
  90% { transform: translate3d(0,-2px,0); }
}

.bounce {
  animation: bounce 1s ease-in-out;
}
```

### 9.2 ホバーエフェクト
```css
.hover-lift {
  transition: transform 0.2s ease-in-out;
}

.hover-lift:hover {
  transform: translateY(-2px);
}

.hover-scale {
  transition: transform 0.2s ease-in-out;
}

.hover-scale:hover {
  transform: scale(1.05);
}
```

## 10. アクセシビリティ

### 10.1 カラーコントラスト
- **通常テキスト**: 4.5:1以上のコントラスト比
- **大きなテキスト**: 3:1以上のコントラスト比
- **UI要素**: 3:1以上のコントラスト比

### 10.2 フォーカス表示
```css
.focus-visible {
  outline: 2px solid var(--accent-blue);
  outline-offset: 2px;
}

button:focus-visible,
input:focus-visible,
select:focus-visible {
  outline: 2px solid var(--accent-blue);
  outline-offset: 2px;
}
```

### 10.3 セマンティックHTML
```html
<!-- 適切な見出し構造 -->
<h1>Morning Helper</h1>
<h2>今日の天気</h2>
<h3>服装提案</h3>

<!-- 適切なラベル -->
<label for="zodiac-select">星座を選択</label>
<select id="zodiac-select" name="zodiac">
  <option value="aries">おひつじ座</option>
  <!-- ... -->
</select>

<!-- 適切なalt属性 -->
<img src="weather-icon.png" alt="晴れの天気アイコン" />
```

## 11. デザインシステム

### 11.1 コンポーネント一覧
- **Card**: 基本カードコンポーネント
- **WeatherCard**: 天気情報カード
- **ClothingCard**: 服装提案カード
- **ItemsCard**: 持ち物提案カード
- **PollenCard**: 花粉情報カード
- **FortuneCard**: 占い結果カード
- **Button**: ボタンコンポーネント
- **Toggle**: トグルスイッチ
- **Icon**: アイコンコンポーネント

### 11.2 デザイントークン
```css
:root {
  /* スペーシング */
  --space-xs: 0.25rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;
  --space-lg: 1.5rem;
  --space-xl: 2rem;
  
  /* ボーダー半径 */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  
  /* シャドウ */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  
  /* トランジション */
  --transition-fast: 0.15s ease-in-out;
  --transition-normal: 0.2s ease-in-out;
  --transition-slow: 0.3s ease-in-out;
}
```

## 12. 実装例

### 12.1 天気カード実装例
```jsx
const WeatherCard = ({ weather }) => {
  return (
    <div className="weather-card card-base fade-in">
      <div className="flex items-center justify-between mb-4">
        <div className="weather-icon text-4xl">
          {weather.icon}
        </div>
        <div className="text-right">
          <div className="text-2xl font-bold">
            {weather.temperature}°
          </div>
          <div className="text-sm text-gray-600">
            {weather.condition}
          </div>
        </div>
      </div>
      
      <div className="grid grid-cols-2 gap-4 text-sm">
        <div>
          <div className="text-gray-600">最高気温</div>
          <div className="font-medium">{weather.maxTemp}°</div>
        </div>
        <div>
          <div className="text-gray-600">最低気温</div>
          <div className="font-medium">{weather.minTemp}°</div>
        </div>
        <div>
          <div className="text-gray-600">降水確率</div>
          <div className="font-medium">{weather.rainProbability}%</div>
        </div>
        <div>
          <div className="text-gray-600">湿度</div>
          <div className="font-medium">{weather.humidity}%</div>
        </div>
      </div>
    </div>
  );
};
```

### 12.2 服装カード実装例
```jsx
const ClothingCard = ({ outfit, style }) => {
  return (
    <div className="clothing-card card-base fade-in">
      <div className="flex items-center mb-4">
        <div className="outfit-icon text-3xl mr-4">
          {outfit.icon}
        </div>
        <div>
          <h3 className="text-lg font-bold">今日の服装</h3>
          <div className="text-sm text-gray-600">
            {style === 'business' ? 'ビジネス' : 'カジュアル'}
          </div>
        </div>
      </div>
      
      <div className="space-y-2">
        <div className="flex items-center">
          <span className="text-sm text-gray-600 w-16">上着:</span>
          <span className="font-medium">{outfit.top}</span>
        </div>
        <div className="flex items-center">
          <span className="text-sm text-gray-600 w-16">下着:</span>
          <span className="font-medium">{outfit.bottom}</span>
        </div>
        {outfit.outer && (
          <div className="flex items-center">
            <span className="text-sm text-gray-600 w-16">アウター:</span>
            <span className="font-medium">{outfit.outer}</span>
          </div>
        )}
      </div>
      
      {outfit.advice && (
        <div className="mt-4 p-3 bg-white bg-opacity-50 rounded-lg">
          <p className="text-sm text-gray-700">{outfit.advice}</p>
        </div>
      )}
    </div>
  );
};
```

このデザインガイドラインに従って、可愛くて直感的なUIを実装していきます！
