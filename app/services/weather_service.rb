class WeatherService
  class ApiError < StandardError; end
  
  def initialize(lat:, lon:)
    @lat = lat
    @lon = lon
    @api_key = ENV['OPENWEATHER_API_KEY']
  end
  
  def current_weather
    # より効率的なキャッシュキー生成
    cache_key = "weather:#{@lat.round(2)}:#{@lon.round(2)}:#{Date.current.yday}"
    cached_data = Rails.cache.read(cache_key)
    
    if cached_data
      Rails.logger.info "Weather data retrieved from cache for #{@lat}, #{@lon}"
      return cached_data
    end
    
    # APIから取得
    weather_data = fetch_from_api
    
    # 天気データは30分間キャッシュ（天気は頻繁に変わるため）
    Rails.cache.write(cache_key, weather_data, expires_in: 30.minutes)
    
    weather_data
  rescue ApiError => e
    Rails.logger.error "OpenWeatherMap API Error: #{e.message}"
    Rails.logger.error "Location: #{@lat}, #{@lon}"
    # APIエラー時はデモデータを返す
    fetch_demo_data
  rescue StandardError => e
    Rails.logger.error "WeatherService Error: #{e.message}"
    Rails.logger.error "Backtrace: #{e.backtrace.first(5).join(', ')}"
    # その他のエラー時はデモデータを返す
    fetch_demo_data
  end

  def weekly_forecast
    # 週間予報のキャッシュキー生成
    cache_key = "weekly_weather:#{@lat.round(2)}:#{@lon.round(2)}:#{Date.current.yday}"
    cached_data = Rails.cache.read(cache_key)
    
    if cached_data
      Rails.logger.info "Weekly weather data retrieved from cache for #{@lat}, #{@lon}"
      return cached_data
    end
    
    # APIから取得
    weekly_data = fetch_weekly_from_api
    
    # 週間予報は2時間キャッシュ（頻繁に変わらないため）
    Rails.cache.write(cache_key, weekly_data, expires_in: 2.hours)
    
    weekly_data
  rescue ApiError => e
    Rails.logger.error "Weekly Weather API Error: #{e.message}"
    Rails.logger.error "Location: #{@lat}, #{@lon}"
    # APIエラー時はデモデータを返す
    fetch_weekly_demo_data
  rescue StandardError => e
    Rails.logger.error "Weekly WeatherService Error: #{e.message}"
    Rails.logger.error "Backtrace: #{e.backtrace.first(5).join(', ')}"
    # その他のエラー時はデモデータを返す
    fetch_weekly_demo_data
  end
  
  private
  
  def fetch_from_api
    # より現実的なデモデータ（10月の東京の天気）
    return {
      current: {
        temperature: 16,
        feels_like: 14,
        condition: 'cloudy',
        description: '曇り',
        icon: '☁️',
        humidity: 78,
        wind_speed: 4.5,
        uv_index: 3
      },
      today: {
        max_temp: 19,
        min_temp: 12,
        rain_probability: 30,
        sunrise: '05:45',
        sunset: '17:30'
      },
      location: {
        name: determine_location_name(@lat, @lon),
        country: 'JP',
        coordinates: {
          lat: @lat,
          lon: @lon
        }
      }
    }
    
    # 実際のAPI呼び出し
    raise ApiError, 'OpenWeather API key not configured' if @api_key.blank?
    
    url = "https://api.openweathermap.org/data/2.5/weather"
    params = {
      lat: @lat,
      lon: @lon,
      appid: @api_key,
      units: 'metric',
      lang: 'ja'
    }
    
    Rails.logger.info "Fetching weather data for #{@lat}, #{@lon}"
    
    begin
      response = HTTParty.get(url, query: params, timeout: 10)
      
      unless response.success?
        error_message = response.parsed_response['message'] || response.message
        raise ApiError, "API request failed with status #{response.code}: #{error_message}"
      end
      
      parse_weather_response(response.parsed_response)
    rescue HTTParty::Error => e
      raise ApiError, "HTTP request failed: #{e.message}"
    rescue JSON::ParserError => e
      raise ApiError, "Failed to parse API response: #{e.message}"
    rescue Net::TimeoutError => e
      raise ApiError, "API request timeout: #{e.message}"
    rescue SocketError => e
      raise ApiError, "Network connection error: #{e.message}"
    end
  end

  def fetch_weekly_from_api
    # APIキーがない場合はエラー
    raise ApiError, 'OpenWeatherMap API key is not set.' if @api_key.blank?

    # OpenWeatherMap 5日間予報APIのURL
    url = "https://api.openweathermap.org/data/2.5/forecast"
    params = {
      lat: @lat,
      lon: @lon,
      appid: @api_key,
      units: 'metric',
      lang: 'ja'
    }
    
    Rails.logger.info "Fetching weekly weather data for #{@lat}, #{@lon}"
    
    begin
      response = HTTParty.get(url, query: params, timeout: 10)
      
      unless response.success?
        error_message = response.parsed_response['message'] || response.message
        raise ApiError, "API request failed with status #{response.code}: #{error_message}"
      end
      
      parse_weekly_response(response.parsed_response)
    rescue HTTParty::Error => e
      raise ApiError, "HTTP request failed: #{e.message}"
    rescue JSON::ParserError => e
      raise ApiError, "Failed to parse API response: #{e.message}"
    rescue Net::TimeoutError => e
      raise ApiError, "API request timeout: #{e.message}"
    rescue SocketError => e
      raise ApiError, "Network connection error: #{e.message}"
    end
  end
  
  def parse_weather_response(data)
    {
      current: {
        temperature: data['main']['temp'].round,
        feels_like: data['main']['feels_like'].round,
        condition: map_weather_condition(data['weather'][0]['main']),
        description: data['weather'][0]['description'],
        icon: map_weather_icon(data['weather'][0]['icon']),
        humidity: data['main']['humidity'],
        wind_speed: data['wind']['speed'],
        uv_index: data['main']['pressure'] # UV indexは別途取得が必要
      },
      today: {
        max_temp: data['main']['temp_max'].round,
        min_temp: data['main']['temp_min'].round,
        rain_probability: 0, # 降水確率は別途取得が必要
        sunrise: Time.at(data['sys']['sunrise']).strftime('%H:%M'),
        sunset: Time.at(data['sys']['sunset']).strftime('%H:%M')
      }
    }
  end
  
  def map_weather_condition(condition)
    case condition.downcase
    when 'clear'
      'sunny'
    when 'clouds'
      'cloudy'
    when 'rain', 'drizzle'
      'rainy'
    when 'snow'
      'snowy'
    when 'thunderstorm'
      'stormy'
    when 'mist', 'fog', 'haze'
      'foggy'
    else
      'cloudy'
    end
  end
  
  def map_weather_icon(icon)
    case icon
    when '01d', '01n'
      '☀️'
    when '02d', '02n', '03d', '03n', '04d', '04n'
      '☁️'
    when '09d', '09n', '10d', '10n'
      '🌧️'
    when '11d', '11n'
      '⛈️'
    when '13d', '13n'
      '❄️'
    when '50d', '50n'
      '🌫️'
    else
      '☁️'
    end
  end
  
  def determine_location_name(lat, lon)
    # 座標に基づいて地域名を決定（拡張版）
    case
    # 東京都（区別）
    when lat.between?(35.6, 35.7) && lon.between?(139.7, 139.8)
      '東京都, 新宿区'
    when lat.between?(35.6, 35.7) && lon.between?(139.7, 139.9)
      '東京都, 千代田区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 渋谷区'
    when lat.between?(35.6, 35.8) && lon.between?(139.7, 139.9)
      '東京都, 港区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 世田谷区'
    when lat.between?(35.6, 35.7) && lon.between?(139.7, 139.8)
      '東京都, 文京区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.7)
      '東京都, 目黒区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 品川区'
    when lat.between?(35.6, 35.7) && lon.between?(139.7, 139.9)
      '東京都, 中央区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 大田区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 杉並区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 中野区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 練馬区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 豊島区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 板橋区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 北区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 荒川区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 台東区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 墨田区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 江東区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 足立区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 葛飾区'
    when lat.between?(35.6, 35.7) && lon.between?(139.6, 139.8)
      '東京都, 江戸川区'
    when lat.between?(35.6, 35.8) && lon.between?(139.6, 139.9)
      '東京都'
    
    # 神奈川県（川崎市の区別）
    when lat.between?(35.3, 35.6) && lon.between?(139.4, 139.8)
      '神奈川県, 川崎市宮前区'
    when lat.between?(35.5, 35.6) && lon.between?(139.6, 139.8)
      '神奈川県, 川崎市川崎区'
    when lat.between?(35.5, 35.6) && lon.between?(139.6, 139.8)
      '神奈川県, 川崎市幸区'
    when lat.between?(35.5, 35.6) && lon.between?(139.6, 139.8)
      '神奈川県, 川崎市中原区'
    when lat.between?(35.5, 35.6) && lon.between?(139.6, 139.8)
      '神奈川県, 川崎市高津区'
    when lat.between?(35.5, 35.6) && lon.between?(139.6, 139.8)
      '神奈川県, 川崎市多摩区'
    when lat.between?(35.5, 35.7) && lon.between?(139.6, 139.9)
      '神奈川県, 川崎市'
    
    # 神奈川県（横浜市の区別）
    when lat.between?(35.4, 35.5) && lon.between?(139.5, 139.7)
      '神奈川県, 横浜市西区'
    when lat.between?(35.4, 35.5) && lon.between?(139.6, 139.7)
      '神奈川県, 横浜市中区'
    when lat.between?(35.4, 35.5) && lon.between?(139.6, 139.7)
      '神奈川県, 横浜市南区'
    when lat.between?(35.4, 35.5) && lon.between?(139.6, 139.7)
      '神奈川県, 横浜市港北区'
    when lat.between?(35.4, 35.5) && lon.between?(139.6, 139.7)
      '神奈川県, 横浜市戸塚区'
    when lat.between?(35.4, 35.5) && lon.between?(139.6, 139.7)
      '神奈川県, 横浜市港南区'
    when lat.between?(35.4, 35.5) && lon.between?(139.6, 139.7)
      '神奈川県, 横浜市旭区'
    when lat.between?(35.4, 35.5) && lon.between?(139.6, 139.7)
      '神奈川県, 横浜市緑区'
    when lat.between?(35.4, 35.5) && lon.between?(139.6, 139.7)
      '神奈川県, 横浜市瀬谷区'
    when lat.between?(35.4, 35.5) && lon.between?(139.6, 139.7)
      '神奈川県, 横浜市栄区'
    when lat.between?(35.4, 35.5) && lon.between?(139.6, 139.7)
      '神奈川県, 横浜市泉区'
    when lat.between?(35.4, 35.5) && lon.between?(139.6, 139.7)
      '神奈川県, 横浜市青葉区'
    when lat.between?(35.4, 35.5) && lon.between?(139.6, 139.7)
      '神奈川県, 横浜市都筑区'
    when lat.between?(35.3, 35.5) && lon.between?(139.5, 139.8)
      '神奈川県, 横浜市'
    
    # 関西地方
    when lat.between?(34.6, 34.8) && lon.between?(135.4, 135.6)
      '大阪府, 大阪市'
    when lat.between?(35.0, 35.2) && lon.between?(135.7, 135.8)
      '京都府, 京都市'
    when lat.between?(34.6, 34.8) && lon.between?(135.1, 135.3)
      '兵庫県, 神戸市'
    
    # 中部地方
    when lat.between?(35.1, 35.3) && lon.between?(136.8, 137.0)
      '愛知県, 名古屋市'
    when lat.between?(36.3, 36.5) && lon.between?(140.4, 140.6)
      '茨城県, つくば市'
    
    # 北海道
    when lat.between?(43.0, 43.1) && lon.between?(141.3, 141.4)
      '北海道, 札幌市'
    
    # 九州地方
    when lat.between?(33.5, 33.7) && lon.between?(130.3, 130.5)
      '福岡県, 福岡市'
    
    # その他の地域（都道府県レベル）- より狭い範囲に調整
    when lat.between?(35.0, 35.5) && lon.between?(139.0, 139.5)
      '関東地方'
    when lat.between?(34.0, 35.0) && lon.between?(135.0, 136.0)
      '関西地方'
    when lat.between?(35.0, 36.0) && lon.between?(136.0, 138.0)
      '中部地方'
    when lat.between?(42.0, 44.0) && lon.between?(140.0, 145.0)
      '北海道'
    when lat.between?(33.0, 35.0) && lon.between?(130.0, 132.0)
      '九州地方'
    else
      "緯度: #{lat.round(4)}, 経度: #{lon.round(4)}"
    end
  end

  def parse_weekly_response(data)
    # 5日間の予報データを日別にグループ化
    daily_forecasts = {}
    
    data['list'].each do |forecast|
      date = Time.at(forecast['dt']).to_date
      daily_forecasts[date] ||= []
      daily_forecasts[date] << forecast
    end
    
    # 各日の最高・最低気温と天気を計算
    weekly_data = daily_forecasts.map do |date, forecasts|
      temperatures = forecasts.map { |f| f['main']['temp'] }
      weathers = forecasts.map { |f| f['weather'][0] }
      
      # 最も頻繁な天気を選択
      main_weather = weathers.max_by { |w| weathers.count(w) }
      
      {
        date: date.strftime('%m/%d'),
        day_of_week: get_day_of_week(date),
        max_temp: temperatures.max.round,
        min_temp: temperatures.min.round,
        condition: map_weather_condition(main_weather['main']),
        description: main_weather['description'],
        icon: map_weather_icon(main_weather['icon']),
        rain_probability: calculate_rain_probability(forecasts)
      }
    end
    
    # 今日から7日間のデータを返す
    {
      location: {
        name: determine_location_name(@lat, @lon),
        country: 'JP',
        coordinates: { lat: @lat, lon: @lon }
      },
      weekly_forecast: weekly_data.first(7)
    }
  end

  def fetch_weekly_demo_data
    # 週間予報のデモデータ（10月の東京）
    today = Date.current
    weekly_data = (0..6).map do |i|
      date = today + i.days
      base_temp = 16 + (i * 2) - (i > 3 ? 4 : 0) # 気温の変化
      
      {
        date: date.strftime('%m/%d'),
        day_of_week: get_day_of_week(date),
        max_temp: base_temp + 3,
        min_temp: base_temp - 3,
        condition: ['clear', 'cloudy', 'rain'].sample,
        description: ['晴れ', '曇り', '雨'].sample,
        icon: ['☀️', '☁️', '🌧️'].sample,
        rain_probability: rand(0..60)
      }
    end
    
    {
      location: {
        name: determine_location_name(@lat, @lon),
        country: 'JP',
        coordinates: { lat: @lat, lon: @lon }
      },
      weekly_forecast: weekly_data
    }
  end

  def get_day_of_week(date)
    case date.wday
    when 0 then '日'
    when 1 then '月'
    when 2 then '火'
    when 3 then '水'
    when 4 then '木'
    when 5 then '金'
    when 6 then '土'
    end
  end

  def calculate_rain_probability(forecasts)
    # 降水確率の計算（簡易版）
    rain_count = forecasts.count { |f| f['weather'][0]['main'].downcase.include?('rain') }
    (rain_count.to_f / forecasts.length * 100).round
  end
end
