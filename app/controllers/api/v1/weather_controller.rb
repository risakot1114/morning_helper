class Api::V1::WeatherController < Api::V1::ApplicationController
  def show
    # 必須パラメータの検証
    unless validate_required_params([:lat, :lon])
      return
    end
    
    lat = params[:lat].to_f
    lon = params[:lon].to_f
    
    # パラメータの範囲チェック
    if lat < -90 || lat > 90 || lon < -180 || lon > 180
      render_error('Invalid latitude or longitude values', 'INVALID_PARAMETERS', 400)
      return
    end
    
    begin
      # WeatherServiceを使用して天気情報を取得
      weather_service = WeatherService.new(lat: lat, lon: lon)
      weather_data = weather_service.current_weather
      
      render_success(weather_data, 'Weather data retrieved successfully')
    rescue WeatherService::ApiError => e
      Rails.logger.error "Weather API Error: #{e.message}"
      Rails.logger.error "Location: #{lat}, #{lon}"
      render_error("Weather service temporarily unavailable", 'SERVICE_UNAVAILABLE', 503)
    rescue => e
      Rails.logger.error "Weather controller error: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.first(5).join(', ')}"
      render_error('Failed to retrieve weather data', 'INTERNAL_ERROR', 500)
    end
  end

  def weekly
    # 必須パラメータの検証
    unless validate_required_params([:lat, :lon])
      return
    end

    lat = params[:lat].to_f
    lon = params[:lon].to_f

    # パラメータの範囲チェック
    if lat < -90 || lat > 90 || lon < -180 || lon > 180
      render_error('Invalid latitude or longitude values', 'INVALID_PARAMETERS', 400)
      return
    end

    begin
      # WeatherServiceを使用して週間天気情報を取得
      weather_service = WeatherService.new(lat: lat, lon: lon)
      weekly_data = weather_service.weekly_forecast

      render_success(weekly_data, 'Weekly weather forecast retrieved successfully')
    rescue WeatherService::ApiError => e
      Rails.logger.error "Weekly Weather API Error: #{e.message}"
      Rails.logger.error "Location: #{lat}, #{lon}"
      render_error("Weather service temporarily unavailable", 'SERVICE_UNAVAILABLE', 503)
    rescue => e
      Rails.logger.error "Weekly Weather controller error: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.first(5).join(', ')}"
      render_error('Failed to retrieve weekly weather data', 'INTERNAL_ERROR', 500)
    end
  end
end
