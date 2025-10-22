class ItemsService
  def initialize(temperature:, weather:, humidity: nil, wind_speed: nil)
    @temperature = temperature
    @weather = weather
    @humidity = humidity
    @wind_speed = wind_speed
  end
  
  def suggest_items
    # キャッシュから取得を試行
    cache_key = "items_#{@temperature}_#{@weather}_#{@humidity}_#{@wind_speed}"
    cached_data = Rails.cache.read(cache_key)
    
    if cached_data
      Rails.logger.info "Items suggestion retrieved from cache"
      return cached_data
    end
    
    # 持ち物提案ロジック
    items_data = generate_items_suggestion
    
    # 1時間キャッシュ
    Rails.cache.write(cache_key, items_data, expires_in: 1.hour)
    
    items_data
  end
  
  private
  
  def generate_items_suggestion
    essential_items = []
    optional_items = []
    advice = []
    
    # 天気に基づく持ち物
    case @weather
    when 'rainy'
      essential_items << {
        name: '折りたたみ傘',
        icon: '🌂',
        reason: '雨が予想されるので傘は必須です'
      }
      essential_items << {
        name: 'レインコート',
        icon: '🧥',
        reason: '急な雨に備えてレインコートがあると安心'
      }
      optional_items << {
        name: '濡れても良い靴',
        icon: '👟',
        reason: '雨で靴が濡れても大丈夫な靴を履きましょう'
      }
    when 'sunny'
      essential_items << {
        name: '日焼け止め',
        icon: '🧴',
        reason: '紫外線対策は忘れずに'
      }
      essential_items << {
        name: 'サングラス',
        icon: '🕶️',
        reason: '日差しが強いので目を保護しましょう'
      }
      optional_items << {
        name: '帽子',
        icon: '👒',
        reason: '直射日光を避けるために帽子があると良いです'
      }
    when 'cloudy'
      optional_items << {
        name: '折りたたみ傘',
        icon: '🌂',
        reason: '急な雨に備えて持参することをお勧めします'
      }
      optional_items << {
        name: '薄手のカーディガン',
        icon: '🧥',
        reason: '曇りで体感温度が低いので、羽織るものがあると安心'
      }
    when 'snowy'
      essential_items << {
        name: '手袋',
        icon: '🧤',
        reason: '雪が降るので手袋は必須です'
      }
      essential_items << {
        name: 'マフラー',
        icon: '🧣',
        reason: '首元の防寒対策を忘れずに'
      }
      essential_items << {
        name: '滑りにくい靴',
        icon: '👢',
        reason: '雪道では滑りにくい靴を履きましょう'
      }
    end
    
    # 気温に基づく持ち物
    if @temperature < 5
      essential_items << {
        name: 'カイロ',
        icon: '🔥',
        reason: '非常に寒いのでカイロがあると温かく過ごせます'
      }
      essential_items << {
        name: 'マフラー',
        icon: '🧣',
        reason: '首元の防寒対策を忘れずに'
      }
      essential_items << {
        name: '手袋',
        icon: '🧤',
        reason: '手の防寒対策も重要です'
      }
    elsif @temperature < 10
      essential_items << {
        name: 'カイロ',
        icon: '🔥',
        reason: '寒いのでカイロがあると温かく過ごせます'
      }
      essential_items << {
        name: 'マフラー',
        icon: '🧣',
        reason: '首元の防寒対策を忘れずに'
      }
    elsif @temperature < 15
      optional_items << {
        name: '薄手のカーディガン',
        icon: '🧥',
        reason: '肌寒いので、羽織るものがあると安心です'
      }
    elsif @temperature > 25
      essential_items << {
        name: '水筒',
        icon: '💧',
        reason: '暑いので水分補給は必須です'
      }
      essential_items << {
        name: '扇子',
        icon: '🌬️',
        reason: '涼しく過ごすために扇子があると便利'
      }
      optional_items << {
        name: '冷却スプレー',
        icon: '🧴',
        reason: '暑い日は冷却スプレーがあると涼しく過ごせます'
      }
    end
    
    # 湿度に基づく持ち物
    if @humidity && @humidity > 70
      optional_items << {
        name: 'タオル',
        icon: '🧻',
        reason: '湿度が高いので汗を拭くタオルがあると良いです'
      }
    end
    
    # 風速に基づく持ち物
    if @wind_speed && @wind_speed > 5
      optional_items << {
        name: '帽子',
        icon: '👒',
        reason: '風が強いので帽子があると髪が乱れません'
      }
    end
    
    # アドバイス生成
    advice = generate_advice
    
    {
      essential_items: essential_items,
      optional_items: optional_items,
      advice: advice,
      weather_summary: generate_weather_summary
    }
  end
  
  def generate_advice
    advice_parts = []
    
    if @weather == 'rainy'
      advice_parts << '雨が予想されるので、濡れても良い靴を履くことをお勧めします'
    end
    
    if @temperature < 5
      advice_parts << '非常に寒いので、防寒対策を万全にしてください'
    elsif @temperature > 30
      advice_parts << '非常に暑いので、熱中症対策を忘れずに'
    end
    
    if @humidity && @humidity > 80
      advice_parts << '湿度が高いので、汗をかきやすい服装を避けましょう'
    end
    
    if advice_parts.empty?
      '今日は快適な天気です。お出かけを楽しんでください！'
    else
      advice_parts.join('。')
    end
  end
  
  def generate_weather_summary
    {
      temperature: @temperature,
      weather: @weather,
      comfort_level: determine_comfort_level,
      risk_factors: identify_risk_factors
    }
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
  
  def identify_risk_factors
    risks = []
    
    if @temperature < 10
      risks << 'hypothermia'
    elsif @temperature > 30
      risks << 'heatstroke'
    end
    
    if @weather == 'rainy'
      risks << 'slippery_conditions'
    end
    
    if @wind_speed && @wind_speed > 10
      risks << 'strong_wind'
    end
    
    risks
  end
end
