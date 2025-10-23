class FortuneService
  def initialize(lat:, lon:, zodiac: nil)
    @lat = lat
    @lon = lon
    @zodiac = zodiac
  end

  def current_fortune
    if @zodiac
      zodiac_fortune_with_cache
    else
      daily_fortune_with_cache
    end
  end

  private

  def zodiac_fortune_with_cache
    # 星座占いは1日キャッシュ（日付が変わると運勢が変わるため）
    cache_key = "fortune:zodiac:#{@zodiac}:#{Date.current.yday}:#{Time.current.hour}"
    cached_data = Rails.cache.read(cache_key)
    
    if cached_data
      Rails.logger.info "Zodiac fortune retrieved from cache for #{@zodiac}"
      return cached_data
    end
    
    fortune_data = zodiac_fortune
    
    # 星座占いは1時間キャッシュ（時間帯で運勢が変わるため）
    Rails.cache.write(cache_key, fortune_data, expires_in: 1.hour)
    
    fortune_data
  end

  def daily_fortune_with_cache
    # デフォルト占いは1日キャッシュ
    cache_key = "fortune:daily:#{Date.current.yday}:#{Time.current.hour}"
    cached_data = Rails.cache.read(cache_key)
    
    if cached_data
      Rails.logger.info "Daily fortune retrieved from cache"
      return cached_data
    end
    
    fortune_data = daily_fortune
    
    # デフォルト占いは1時間キャッシュ
    Rails.cache.write(cache_key, fortune_data, expires_in: 1.hour)
    
    fortune_data
  end

  def zodiac_fortune
    # 星座に基づく運勢データ
    zodiac_data = get_zodiac_data(@zodiac)
    
    # 日付と時間による調整（より大きな変動を加える）
    current_time = Time.current
    day_modifier = Math.sin(current_time.yday * 0.1) * 0.3 + 1.0
    hour_modifier = case current_time.hour
    when 6..11 then 1.15  # 朝
    when 12..17 then 1.0  # 昼
    when 18..22 then 1.15 # 夜
    else 0.85              # 深夜
    end
    
    # 星座ごとに異なるランダム要素を追加
    zodiac_seed = @zodiac.hash + current_time.yday
    random_factor = Random.new(zodiac_seed).rand(0.8..1.2)
    
    # 最終的な運勢を計算
    fortune_scores = {
      luck: [(zodiac_data[:luck] * day_modifier * hour_modifier * random_factor).round, 100].min,
      love: [(zodiac_data[:love] * day_modifier * hour_modifier * random_factor).round, 100].min,
      work: [(zodiac_data[:work] * day_modifier * hour_modifier * random_factor).round, 100].min,
      health: [(zodiac_data[:health] * day_modifier * hour_modifier * random_factor).round, 100].min
    }
    
    generate_fortune_data(fortune_scores)
  end

  def get_zodiac_data(zodiac)
    case zodiac
    when 'aries'
      { luck: 75, love: 70, work: 80, health: 75, element: '火', symbol: '♈' }
    when 'taurus'
      { luck: 70, love: 85, work: 75, health: 80, element: '土', symbol: '♉' }
    when 'gemini'
      { luck: 80, love: 75, work: 85, health: 70, element: '風', symbol: '♊' }
    when 'cancer'
      { luck: 70, love: 80, work: 70, health: 75, element: '水', symbol: '♋' }
    when 'leo'
      { luck: 85, love: 80, work: 80, health: 80, element: '火', symbol: '♌' }
    when 'virgo'
      { luck: 75, love: 70, work: 90, health: 85, element: '土', symbol: '♍' }
    when 'libra'
      { luck: 80, love: 90, work: 75, health: 75, element: '風', symbol: '♎' }
    when 'scorpio'
      { luck: 75, love: 85, work: 80, health: 80, element: '水', symbol: '♏' }
    when 'sagittarius'
      { luck: 90, love: 75, work: 75, health: 80, element: '火', symbol: '♐' }
    when 'capricorn'
      { luck: 70, love: 70, work: 95, health: 85, element: '土', symbol: '♑' }
    when 'aquarius'
      { luck: 80, love: 75, work: 85, health: 75, element: '風', symbol: '♒' }
    when 'pisces'
      { luck: 75, love: 85, work: 70, health: 75, element: '水', symbol: '♓' }
    else
      { luck: 75, love: 75, work: 75, health: 75, element: '?', symbol: '⭐' }
    end
  end

  def daily_fortune
    # 星座が指定されていない場合のデフォルト占い
    current_time = Time.current
    day_of_year = current_time.yday
    hour = current_time.hour
    
    # 座標に基づいて地域の運勢を調整
    region_modifier = calculate_region_modifier
    
    # 基本的な運勢を計算
    base_fortune = calculate_base_fortune(day_of_year, hour, region_modifier)
    
    # 運勢データを生成
    generate_fortune_data(base_fortune)
  end

  def calculate_region_modifier
    # 座標に基づいて地域の運勢調整値を計算
    case
    when @lat.between?(35.6, 35.8) && @lon.between?(139.6, 139.9)
      # 東京都 - 都会の運気
      { luck: 1.2, love: 1.1, work: 1.3, health: 0.9 }
    when @lat.between?(35.3, 35.6) && @lon.between?(139.4, 139.8)
      # 神奈川県 - 海の運気
      { luck: 1.1, love: 1.2, work: 1.0, health: 1.1 }
    when @lat.between?(34.6, 34.8) && @lon.between?(135.4, 135.6)
      # 大阪府 - 商売の運気
      { luck: 1.3, love: 1.0, work: 1.2, health: 1.0 }
    else
      # その他の地域
      { luck: 1.0, love: 1.0, work: 1.0, health: 1.0 }
    end
  end

  def calculate_base_fortune(day_of_year, hour, region_modifier)
    # 日付と時間に基づいて基本運勢を計算
    luck_base = Math.sin(day_of_year * 0.1) * 50 + 50
    love_base = Math.cos(day_of_year * 0.15) * 40 + 60
    work_base = Math.sin(day_of_year * 0.08) * 45 + 55
    health_base = Math.cos(day_of_year * 0.12) * 35 + 65
    
    # 時間による調整
    time_modifier = case hour
    when 6..11
      { luck: 1.1, love: 1.0, work: 1.2, health: 1.1 } # 朝
    when 12..17
      { luck: 1.0, love: 1.1, work: 1.0, health: 1.0 } # 昼
    when 18..22
      { luck: 1.1, love: 1.2, work: 0.9, health: 1.0 } # 夜
    else
      { luck: 0.9, love: 1.1, work: 0.8, health: 0.9 } # 深夜
    end
    
    # 最終的な運勢を計算
    {
      luck: [(luck_base * region_modifier[:luck] * time_modifier[:luck]).round, 100].min,
      love: [(love_base * region_modifier[:love] * time_modifier[:love]).round, 100].min,
      work: [(work_base * region_modifier[:work] * time_modifier[:work]).round, 100].min,
      health: [(health_base * region_modifier[:health] * time_modifier[:health]).round, 100].min
    }
  end

  def generate_fortune_data(fortune_scores)
    # 運勢レベルを決定
    overall_level = calculate_overall_level(fortune_scores)
    
    # 運勢メッセージを生成
    messages = generate_fortune_messages(fortune_scores)
    
    # ラッキーカラーとアイテム
    lucky_items = generate_lucky_items(fortune_scores)
    
    {
      overall_level: overall_level,
      scores: fortune_scores,
      messages: messages,
      lucky_color: lucky_items[:color],
      lucky_item: lucky_items[:item],
      advice: generate_daily_advice(fortune_scores, overall_level),
      forecast: generate_weekly_forecast(fortune_scores)
    }
  end

  def calculate_overall_level(scores)
    average = scores.values.sum / scores.size
    case average
    when 80..100
      'excellent'
    when 60..79
      'good'
    when 40..59
      'average'
    when 20..39
      'poor'
    else
      'very_poor'
    end
  end

  def generate_fortune_messages(scores)
    {
      luck: get_luck_message(scores[:luck]),
      love: get_love_message(scores[:love]),
      work: get_work_message(scores[:work]),
      health: get_health_message(scores[:health])
    }
  end

  def get_luck_message(score)
    if @zodiac
      get_zodiac_luck_message(score)
    else
      get_general_luck_message(score)
    end
  end

  def get_zodiac_luck_message(score)
    zodiac_name = get_zodiac_data(@zodiac)[:name]
    case score
    when 80..100
      "#{zodiac_name}の総合運が最高潮！今日は全てが順調に進みそうです🌟"
    when 60..79
      "#{zodiac_name}の総合運が上昇中！積極的に行動すると良い結果が！"
    when 40..59
      "#{zodiac_name}の総合運は普通です。穏やかに過ごしましょう。"
    when 20..39
      "#{zodiac_name}の総合運が少し下がっています。慎重に行動を。"
    else
      "#{zodiac_name}の総合運が低い日です。無理をせず、休息を取って。"
    end
  end

  def get_general_luck_message(score)
    case score
    when 80..100
      '今日は最高の運気！新しい出会いやチャンスが訪れそうです✨'
    when 60..79
      '良い運気に恵まれています。積極的に行動してみてください！'
    when 40..59
      '普通の運気です。無理をせず、自然体で過ごしましょう。'
    when 20..39
      '少し運気が下がっています。慎重に行動することが大切です。'
    else
      '運気が低い日です。静かに過ごし、明日に備えましょう。'
    end
  end

  def get_love_message(score)
    case score
    when 80..100
      '恋愛運が最高潮！素敵な出会いが待っているかもしれません💕'
    when 60..79
      '恋愛運が上昇中！心を開いて新しい関係を築いてみて。'
    when 40..59
      '恋愛運は普通です。今の関係を大切にしましょう。'
    when 20..39
      '恋愛運が少し下がっています。焦らずに待つのが吉。'
    else
      '恋愛運が低い日です。自分磨きに集中しましょう。'
    end
  end

  def get_work_message(score)
    case score
    when 80..100
      '仕事運が絶好調！新しいプロジェクトや昇進のチャンスが！'
    when 60..79
      '仕事運が良好です。積極的に新しいことに挑戦してみて。'
    when 40..59
      '仕事運は普通です。コツコツと努力を続けましょう。'
    when 20..39
      '仕事運が下がっています。ミスに注意して慎重に。'
    else
      '仕事運が低い日です。無理をせず、基本的な作業に集中。'
    end
  end

  def get_health_message(score)
    case score
    when 80..100
      '健康運が最高！体調も良く、エネルギッシュな一日になりそうです！'
    when 60..79
      '健康運が良好です。適度な運動で体を動かしてみて。'
    when 40..59
      '健康運は普通です。規則正しい生活を心がけましょう。'
    when 20..39
      '健康運が下がっています。休息を取って体を労って。'
    else
      '健康運が低い日です。無理をせず、ゆっくり休みましょう。'
    end
  end

  def generate_lucky_items(scores)
    # 最高のスコアに基づいてラッキーアイテムを決定
    best_category = scores.max_by { |_, score| score }[0]
    
    colors = {
      luck: ['ピンク', 'ゴールド', 'レッド', 'オレンジ'],
      love: ['ピンク', 'ローズ', 'ラベンダー', 'コーラル'],
      work: ['ブルー', 'ネイビー', 'シルバー', 'グレー'],
      health: ['グリーン', 'エメラルド', 'ターコイズ', 'ミント']
    }
    
    items = {
      luck: ['四つ葉のクローバー', '招き猫', 'お守り', 'クリスタル'],
      love: ['ハートのアクセサリー', 'バラの花', 'ピンクの石', 'ロマンチックな香り'],
      work: ['ペン', 'ノート', '名刺入れ', '時計'],
      health: ['ハーブティー', 'エッセンシャルオイル', 'ヨガマット', 'ウォーターボトル']
    }
    
    {
      color: colors[best_category].sample,
      item: items[best_category].sample
    }
  end

  def generate_daily_advice(scores, overall_level)
    case overall_level
    when 'excellent'
      '今日は全てが順調！新しいことに挑戦する絶好のチャンスです。'
    when 'good'
      '良い運気に恵まれています。積極的に行動して、チャンスを掴みましょう。'
    when 'average'
      '安定した運気です。無理をせず、自然体で過ごすことが大切です。'
    when 'poor'
      '運気が下がっています。慎重に行動し、明日に備えましょう。'
    else
      '運気が低い日です。静かに過ごし、自分磨きに集中しましょう。'
    end
  end

  def generate_weekly_forecast(scores)
    # 今後の7日間の運勢予報を生成
    (0..6).map do |day_offset|
      future_time = Time.current + day_offset.days
      future_scores = calculate_base_fortune(
        future_time.yday,
        future_time.hour,
        calculate_region_modifier
      )
      
      {
        day: future_time.strftime('%m/%d'),
        weekday: future_time.strftime('%a'),
        level: calculate_overall_level(future_scores),
        icon: get_forecast_icon(calculate_overall_level(future_scores))
      }
    end
  end

  def get_forecast_icon(level)
    case level
    when 'excellent'
      '🌟'
    when 'good'
      '✨'
    when 'average'
      '😊'
    when 'poor'
      '😐'
    else
      '😔'
    end
  end
end
