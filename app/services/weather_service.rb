class WeatherService
  class ApiError < StandardError; end
  
  def initialize(lat:, lon:)
    @lat = lat
    @lon = lon
    @api_key = ENV['OPENWEATHER_API_KEY'] || 'ec7921a3624d9e05f40c59207977b5ab'
  end
  
  def current_weather
    # キャッシュから取得を試行
    cache_key = "weather_#{@lat}_#{@lon}"
    cached_data = Rails.cache.read(cache_key)
    
    if cached_data
      Rails.logger.info "Weather data retrieved from cache"
      return cached_data
    end
    
    # APIから取得
    weather_data = fetch_from_api
    
    # 30分間キャッシュ
    Rails.cache.write(cache_key, weather_data, expires_in: 30.minutes)
    
    weather_data
  end
  
  private
  
  def fetch_from_api
    # 一時的にデモデータを返す（APIキーが有効になるまで）
    return {
      current: {
        temperature: 22,
        feels_like: 24,
        condition: 'sunny',
        description: '晴れ',
        icon: '☀️',
        humidity: 65,
        wind_speed: 3.2,
        uv_index: 5
      },
      today: {
        max_temp: 26,
        min_temp: 18,
        rain_probability: 10,
        sunrise: '05:30',
        sunset: '18:45'
      }
    }
    
    # 実際のAPI呼び出し（コメントアウト）
    # raise ApiError, 'OpenWeather API key not configured' if @api_key.blank?
    # 
    # url = "https://api.openweathermap.org/data/2.5/weather"
    # params = {
    #   lat: @lat,
    #   lon: @lon,
    #   appid: @api_key,
    #   units: 'metric',
    #   lang: 'ja'
    # }
    # 
    # response = HTTParty.get(url, query: params, timeout: 10)
    # 
    # unless response.success?
    #   raise ApiError, "API request failed with status #{response.code}: #{response.message}"
    # end
    # 
    # parse_weather_response(response.parsed_response)
  rescue HTTParty::Error => e
    raise ApiError, "HTTP request failed: #{e.message}"
  rescue JSON::ParserError => e
    raise ApiError, "Failed to parse API response: #{e.message}"
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
end
