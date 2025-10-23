class Api::V1::WeeklyClothingController < Api::V1::ApplicationController
  def show
    # 必須パラメータの検証
    unless validate_required_params([:lat, :lon])
      return
    end

    lat = params[:lat].to_f
    lon = params[:lon].to_f
    style = params[:style] || 'business'
    gender = params[:gender] || 'unisex'

    # パラメータの範囲チェック
    if lat < -90 || lat > 90 || lon < -180 || lon > 180
      render_error('Invalid latitude or longitude values', 'INVALID_PARAMETERS', 400)
      return
    end

    begin
      # 週間天気情報を取得
      weather_service = WeatherService.new(lat: lat, lon: lon)
      weekly_weather = weather_service.weekly_forecast

      # 週間服装提案を生成
      weekly_clothing_service = WeeklyClothingService.new(
        weekly_weather: weekly_weather,
        style: style,
        gender: gender
      )
      weekly_outfits = weekly_clothing_service.suggest_weekly_outfits

      render_success(weekly_outfits, 'Weekly clothing suggestions retrieved successfully')
    rescue WeatherService::ApiError => e
      Rails.logger.error "Weekly Weather API Error: #{e.message}"
      Rails.logger.error "Location: #{lat}, #{lon}"
      render_error("Weather service temporarily unavailable", 'SERVICE_UNAVAILABLE', 503)
    rescue => e
      Rails.logger.error "Weekly Clothing controller error: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.first(5).join(', ')}"
      render_error('Failed to retrieve weekly clothing suggestions', 'INTERNAL_ERROR', 500)
    end
  end
end
