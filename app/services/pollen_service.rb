class PollenService
  def initialize(lat:, lon:, date: Date.current)
    @lat = lat
    @lon = lon
    @date = date
  end
  
  def pollen_info
    # キャッシュから取得を試行
    cache_key = "pollen_#{@lat}_#{@lon}_#{@date.strftime('%Y%m%d')}"
    cached_data = Rails.cache.read(cache_key)
    
    if cached_data
      Rails.logger.info "Pollen data retrieved from cache"
      return cached_data
    end
    
    # 花粉情報を生成
    pollen_data = generate_pollen_data
    
    # 1日キャッシュ
    Rails.cache.write(cache_key, pollen_data, expires_in: 1.day)
    
    pollen_data
  end
  
  private
  
  def generate_pollen_data
    # 季節に基づく花粉情報
    season = determine_season(@date)
    pollen_levels = calculate_pollen_levels(season)
    
    {
      date: @date.strftime('%Y年%m月%d日'),
      season: season,
      overall_level: pollen_levels[:overall],
      pollen_types: pollen_levels[:types],
      advice: generate_pollen_advice(pollen_levels[:overall]),
      forecast: generate_forecast(season),
      location: determine_location_name(@lat, @lon)
    }
  end
  
  def determine_season(date)
    month = date.month
    case month
    when 3..5
      'spring'
    when 6..8
      'summer'
    when 9..11
      'autumn'
    else
      'winter'
    end
  end
  
  def calculate_pollen_levels(season)
    case season
    when 'spring'
      {
        overall: 'high',
        types: [
          { name: 'スギ花粉', level: 'very_high', icon: '🌲' },
          { name: 'ヒノキ花粉', level: 'high', icon: '🌲' },
          { name: 'ハンノキ花粉', level: 'medium', icon: '🌳' }
        ]
      }
    when 'summer'
      {
        overall: 'medium',
        types: [
          { name: 'イネ科花粉', level: 'medium', icon: '🌾' },
          { name: 'ブタクサ花粉', level: 'low', icon: '🌿' },
          { name: 'ヨモギ花粉', level: 'low', icon: '🌿' }
        ]
      }
    when 'autumn'
      {
        overall: 'low',
        types: [
          { name: 'ブタクサ花粉', level: 'medium', icon: '🌿' },
          { name: 'ヨモギ花粉', level: 'medium', icon: '🌿' },
          { name: 'カナムグラ花粉', level: 'low', icon: '🌿' }
        ]
      }
    else # winter
      {
        overall: 'very_low',
        types: [
          { name: 'スギ花粉', level: 'very_low', icon: '🌲' },
          { name: 'ハンノキ花粉', level: 'very_low', icon: '🌳' }
        ]
      }
    end
  end
  
  def generate_pollen_advice(overall_level)
    case overall_level
    when 'very_high'
      '花粉が非常に多い日です。外出時はマスクとメガネを必ず着用し、帰宅時は手洗い・うがいを忘れずに。'
    when 'high'
      '花粉が多い日です。マスクの着用をお勧めします。外出後は服を着替えると良いでしょう。'
    when 'medium'
      '花粉が中程度の日です。敏感な方はマスクの着用を検討してください。'
    when 'low'
      '花粉は少ないですが、敏感な方は注意が必要です。'
    else # very_low
      '花粉はほとんど飛散していません。安心してお出かけください。'
    end
  end
  
  def generate_forecast(season)
    case season
    when 'spring'
      [
        { day: '今日', level: 'high', icon: '🌲' },
        { day: '明日', level: 'high', icon: '🌲' },
        { day: '明後日', level: 'medium', icon: '🌳' }
      ]
    when 'summer'
      [
        { day: '今日', level: 'medium', icon: '🌾' },
        { day: '明日', level: 'low', icon: '🌿' },
        { day: '明後日', level: 'medium', icon: '🌾' }
      ]
    when 'autumn'
      [
        { day: '今日', level: 'low', icon: '🌿' },
        { day: '明日', level: 'low', icon: '🌿' },
        { day: '明後日', level: 'medium', icon: '🌿' }
      ]
    else # winter
      [
        { day: '今日', level: 'very_low', icon: '🌲' },
        { day: '明日', level: 'very_low', icon: '🌲' },
        { day: '明後日', level: 'very_low', icon: '🌲' }
      ]
    end
  end
  
  def determine_location_name(lat, lon)
    # 座標に基づいて地域名を決定（WeatherServiceと同じロジック）
    case
    when lat.between?(35.5, 35.8) && lon.between?(139.5, 139.9)
      '東京都, 渋谷区'
    when lat.between?(35.6, 35.7) && lon.between?(139.7, 139.8)
      '東京都, 新宿区'
    when lat.between?(35.6, 35.7) && lon.between?(139.7, 139.9)
      '東京都, 千代田区'
    when lat.between?(34.6, 34.8) && lon.between?(135.4, 135.6)
      '大阪府, 大阪市'
    when lat.between?(35.0, 35.2) && lon.between?(135.7, 135.8)
      '京都府, 京都市'
    when lat.between?(43.0, 43.1) && lon.between?(141.3, 141.4)
      '北海道, 札幌市'
    else
      "緯度: #{lat.round(4)}, 経度: #{lon.round(4)}"
    end
  end
end
