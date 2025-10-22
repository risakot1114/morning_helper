class ClothingService
  def initialize(temperature:, weather:, style: 'business', gender: 'unisex')
    @temperature = temperature
    @weather = weather
    @style = style
    @gender = gender
  end
  
  def suggest_outfit
    # キャッシュから取得を試行
    cache_key = "clothing_#{@temperature}_#{@weather}_#{@style}_#{@gender}"
    cached_data = Rails.cache.read(cache_key)
    
    if cached_data
      Rails.logger.info "Clothing suggestion retrieved from cache"
      return cached_data
    end
    
    # 服装提案ロジック
    outfit_data = generate_outfit_suggestion
    
    # 1時間キャッシュ
    Rails.cache.write(cache_key, outfit_data, expires_in: 1.hour)
    
    outfit_data
  end
  
  private
  
  def generate_outfit_suggestion
    outfit = select_outfit_items
    advice = generate_advice
    
    {
      outfit: outfit,
      advice: advice,
      comfort_level: determine_comfort_level,
      temperature_range: {
        min: @temperature - 3,
        max: @temperature + 3
      }
    }
  end
  
  def select_outfit_items
    case @style
    when 'business'
      select_business_outfit
    when 'casual'
      select_casual_outfit
    when 'child'
      select_child_outfit
    else
      select_casual_outfit
    end
  end
  
  def select_business_outfit
    case @temperature
    when -10..5
      {
        top: '厚手ワイシャツ',
        bottom: 'スラックス',
        outer: 'コート',
        shoes: '革靴',
        accessories: ['ネクタイ', 'マフラー'],
        icon: '🧥',
        style: 'business'
      }
    when 6..15
      {
        top: 'ワイシャツ',
        bottom: 'スラックス',
        outer: 'ジャケット',
        shoes: '革靴',
        accessories: ['ネクタイ'],
        icon: '👔',
        style: 'business'
      }
    when 16..25
      {
        top: '薄手ワイシャツ',
        bottom: 'スラックス',
        outer: nil,
        shoes: '革靴',
        accessories: ['ネクタイ'],
        icon: '👔',
        style: 'business'
      }
    else # 26以上
      {
        top: 'ポロシャツ',
        bottom: 'チノパン',
        outer: nil,
        shoes: 'ローファー',
        accessories: [],
        icon: '👕',
        style: 'business'
      }
    end
  end
  
  def select_casual_outfit
    case @temperature
    when -10..5
      {
        top: 'セーター',
        bottom: 'ジーンズ',
        outer: 'ダウンジャケット',
        shoes: 'ブーツ',
        accessories: ['マフラー', '手袋'],
        icon: '🧥',
        style: 'casual'
      }
    when 6..15
      {
        top: '長袖Tシャツ',
        bottom: 'ジーンズ',
        outer: 'パーカー',
        shoes: 'スニーカー',
        accessories: [],
        icon: '👕',
        style: 'casual'
      }
    when 16..25
      {
        top: 'Tシャツ',
        bottom: 'ジーンズ',
        outer: nil,
        shoes: 'スニーカー',
        accessories: [],
        icon: '👕',
        style: 'casual'
      }
    else # 26以上
      {
        top: 'タンクトップ',
        bottom: 'ショートパンツ',
        outer: nil,
        shoes: 'サンダル',
        accessories: [],
        icon: '🩳',
        style: 'casual'
      }
    end
  end
  
  def select_child_outfit
    case @temperature
    when -10..5
      {
        top: '長袖シャツ',
        bottom: 'ズボン',
        outer: 'コート',
        shoes: 'ブーツ',
        accessories: ['マフラー', '手袋'],
        icon: '🧥',
        style: 'child'
      }
    when 6..15
      {
        top: '長袖シャツ',
        bottom: 'ズボン',
        outer: 'ジャケット',
        shoes: '運動靴',
        accessories: [],
        icon: '👕',
        style: 'child'
      }
    when 16..25
      {
        top: '半袖シャツ',
        bottom: 'ズボン',
        outer: nil,
        shoes: '運動靴',
        accessories: [],
        icon: '👕',
        style: 'child'
      }
    else # 26以上
      {
        top: '半袖シャツ',
        bottom: '半ズボン',
        outer: nil,
        shoes: 'サンダル',
        accessories: [],
        icon: '🩳',
        style: 'child'
      }
    end
  end
  
  def generate_advice
    advice_parts = []
    
    if @weather == 'rainy'
      advice_parts << '雨が予想されるので傘をお忘れなく'
    end
    
    if @temperature < 10
      advice_parts << '寒いので防寒対策をしっかりと'
    elsif @temperature > 25
      advice_parts << '暑いので熱中症対策を忘れずに'
    end
    
    if advice_parts.empty?
      '今日は快適な気温です'
    else
      advice_parts.join('。')
    end
  end
  
  def determine_comfort_level
    case @temperature
    when 18..24
      'comfortable'
    when 10..17, 25..30
      'moderate'
    else
      'uncomfortable'
    end
  end
end
