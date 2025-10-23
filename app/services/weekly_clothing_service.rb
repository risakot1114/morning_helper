class WeeklyClothingService
  def initialize(weekly_weather:, style: 'business', gender: 'unisex')
    @weekly_weather = weekly_weather
    @style = style
    @gender = gender
  end

  def suggest_weekly_outfits
    # 週間服装提案のキャッシュキー生成
    cache_key = "weekly_clothing:#{@style}:#{@gender}:#{Date.current.yday}"
    cached_data = Rails.cache.read(cache_key)
    
    if cached_data
      Rails.logger.info "Weekly clothing suggestion retrieved from cache for #{@style} style"
      return cached_data
    end
    
    # 週間服装提案ロジック
    weekly_outfits = generate_weekly_outfits
    
    # 週間服装提案は4時間キャッシュ（天気が変わらないため）
    Rails.cache.write(cache_key, weekly_outfits, expires_in: 4.hours)
    
    weekly_outfits
  end

  private

  def generate_weekly_outfits
    outfits = @weekly_weather[:weekly_forecast].map do |day_weather|
      {
        date: day_weather[:date],
        day_of_week: day_weather[:day_of_week],
        weather: day_weather,
        outfit: suggest_daily_outfit(day_weather),
        advice: generate_daily_advice(day_weather),
        laundry_suggestion: suggest_laundry_timing(day_weather)
      }
    end
    
    {
      weekly_outfits: outfits,
      weekly_summary: generate_weekly_summary(outfits),
      style: @style,
      location: @weekly_weather[:location]
    }
  end

  def suggest_daily_outfit(day_weather)
    avg_temp = (day_weather[:max_temp] + day_weather[:min_temp]) / 2.0
    weather_condition = day_weather[:condition]
    
    case @style
    when 'business'
      suggest_business_outfit(avg_temp, weather_condition)
    when 'casual'
      suggest_casual_outfit(avg_temp, weather_condition)
    when 'child'
      suggest_child_outfit(avg_temp, weather_condition)
    else
      suggest_casual_outfit(avg_temp, weather_condition)
    end
  end

  def suggest_business_outfit(avg_temp, weather_condition)
    case avg_temp
    when -10..8
      {
        top: '厚手ワイシャツ',
        bottom: 'ウールスラックス',
        outer: 'ウールコート',
        shoes: '革靴',
        accessories: ['ネクタイ', 'マフラー', '手袋'],
        icon: '🧥',
        style: 'business'
      }
    when 9..12
      {
        top: 'ワイシャツ',
        bottom: 'スラックス',
        outer: 'トレンチコート',
        shoes: '革靴',
        accessories: ['ネクタイ'],
        icon: '🧥',
        style: 'business'
      }
    when 13..18
      {
        top: 'ワイシャツ',
        bottom: 'スラックス',
        outer: 'ブレザー',
        shoes: '革靴',
        accessories: ['ネクタイ'],
        icon: '👔',
        style: 'business'
      }
    when 19..22
      {
        top: 'ワイシャツ',
        bottom: 'スラックス',
        outer: 'カーディガン',
        shoes: '革靴',
        accessories: ['ネクタイ'],
        icon: '👔',
        style: 'business'
      }
    else # 23以上
      {
        top: '薄手ワイシャツ',
        bottom: 'スラックス',
        outer: nil,
        shoes: '革靴',
        accessories: ['ネクタイ'],
        icon: '👔',
        style: 'business'
      }
    end
  end

  def suggest_casual_outfit(avg_temp, weather_condition)
    case avg_temp
    when -10..8
      {
        top: 'セーター',
        bottom: 'ジーンズ',
        outer: 'ダウンジャケット',
        shoes: 'ブーツ',
        accessories: ['マフラー', '手袋', 'ニット帽'],
        icon: '🧥',
        style: 'casual'
      }
    when 9..12
      {
        top: '長袖Tシャツ',
        bottom: 'ジーンズ',
        outer: 'ウールコート',
        shoes: 'スニーカー',
        accessories: [],
        icon: '🧥',
        style: 'casual'
      }
    when 13..18
      {
        top: '長袖Tシャツ',
        bottom: 'ジーンズ',
        outer: 'ジャケット',
        shoes: 'スニーカー',
        accessories: [],
        icon: '👕',
        style: 'casual'
      }
    when 19..22
      {
        top: '長袖Tシャツ',
        bottom: 'ジーンズ',
        outer: 'カーディガン',
        shoes: 'スニーカー',
        accessories: [],
        icon: '👕',
        style: 'casual'
      }
    else # 23以上
      {
        top: 'Tシャツ',
        bottom: 'ジーンズ',
        outer: nil,
        shoes: 'スニーカー',
        accessories: [],
        icon: '👕',
        style: 'casual'
      }
    end
  end

  def suggest_child_outfit(avg_temp, weather_condition)
    case avg_temp
    when -10..8
      {
        top: '長袖シャツ',
        bottom: 'ズボン',
        outer: 'コート',
        shoes: 'ブーツ',
        accessories: ['マフラー', '手袋', 'ニット帽'],
        icon: '🧥',
        style: 'child'
      }
    when 9..12
      {
        top: '長袖シャツ',
        bottom: 'ズボン',
        outer: 'ウインドブレーカー',
        shoes: '運動靴',
        accessories: [],
        icon: '🧥',
        style: 'child'
      }
    when 13..18
      {
        top: '長袖シャツ',
        bottom: 'ズボン',
        outer: 'ジャケット',
        shoes: '運動靴',
        accessories: [],
        icon: '👕',
        style: 'child'
      }
    when 19..22
      {
        top: '長袖シャツ',
        bottom: 'ズボン',
        outer: 'カーディガン',
        shoes: '運動靴',
        accessories: [],
        icon: '👕',
        style: 'child'
      }
    else # 23以上
      {
        top: '半袖シャツ',
        bottom: 'ズボン',
        outer: nil,
        shoes: '運動靴',
        accessories: [],
        icon: '👕',
        style: 'child'
      }
    end
  end

  def generate_daily_advice(day_weather)
    advice_parts = []
    
    # 天気に基づくアドバイス
    case day_weather[:condition]
    when 'rain', 'drizzle', 'thunderstorm'
      advice_parts << '雨が降る予報なので、防水対策を忘れずに。'
    when 'snow'
      advice_parts << '雪が降る予報なので、防寒対策をしっかりしましょう。'
    when 'clear'
      advice_parts << '晴れて気持ちの良い一日になりそうです。'
    when 'cloudy'
      advice_parts << '曇り空ですが、過ごしやすい一日でしょう。'
    end
    
    # 気温に基づくアドバイス
    avg_temp = (day_weather[:max_temp] + day_weather[:min_temp]) / 2.0
    case avg_temp
    when -10..5
      advice_parts << '極寒です！最大限の防寒対策をしてください。'
    when 6..10
      advice_parts << '肌寒いです。暖かいアウターを羽織りましょう。'
    when 11..15
      advice_parts << '少し肌寒さを感じるでしょう。薄手の羽織ものがあると安心です。'
    when 16..20
      advice_parts << '過ごしやすい気温です。日中は快適に過ごせるでしょう。'
    when 21..25
      advice_parts << '暖かい一日です。薄着で快適に過ごせます。'
    else # 26以上
      advice_parts << '暑い一日になりそうです。熱中症対策を忘れずに。'
    end
    
    advice_parts.join(' ')
  end

  def suggest_laundry_timing(day_weather)
    # 洗濯タイミングの提案
    case day_weather[:condition]
    when 'clear'
      '晴れの日なので洗濯日和です！'
    when 'cloudy'
      '曇りですが洗濯は可能です。'
    when 'rain', 'drizzle', 'thunderstorm'
      '雨の予報なので洗濯は控えましょう。'
    else
      '天気を確認してから洗濯を決めましょう。'
    end
  end

  def generate_weekly_summary(outfits)
    # 週間の服装傾向を分析
    outer_counts = outfits.count { |outfit| outfit[:outfit][:outer].present? }
    rain_days = outfits.count { |outfit| outfit[:weather][:condition].include?('rain') }
    
    summary_parts = []
    
    if outer_counts > 4
      summary_parts << '今週は寒い日が多いので、厚手のアウターを多めに準備しましょう。'
    elsif outer_counts < 2
      summary_parts << '今週は暖かい日が多いので、薄手の服装で過ごせそうです。'
    else
      summary_parts << '今週は気温の変化が大きいので、調整しやすい服装がおすすめです。'
    end
    
    if rain_days > 2
      summary_parts << '雨の日が多いので、防水アイテムを忘れずに。'
    elsif rain_days == 0
      summary_parts << '今週は雨の心配がなさそうです。'
    else
      summary_parts << '雨の日もあるので、折りたたみ傘があると安心です。'
    end
    
    summary_parts.join(' ')
  end
end
