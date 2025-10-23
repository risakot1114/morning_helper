class Api::V1::FortuneController < Api::V1::ApplicationController
  def show
    # 必須パラメータの検証
    unless validate_required_params([:lat, :lon])
      return
    end

    lat = params[:lat].to_f
    lon = params[:lon].to_f
    zodiac = params[:zodiac]

    # パラメータの範囲チェック
    if lat < -90 || lat > 90 || lon < -180 || lon > 180
      render_error('Invalid latitude or longitude values', 'INVALID_PARAMETERS', 400)
      return
    end

    begin
      # FortuneServiceを使用して占い情報を取得
      fortune_service = FortuneService.new(lat: lat, lon: lon, zodiac: zodiac)
      fortune_data = fortune_service.current_fortune

      render_success(fortune_data, 'Fortune data retrieved successfully')
    rescue => e
      Rails.logger.error "Fortune controller error: #{e.message}"
      render_error('Failed to retrieve fortune data', 'INTERNAL_ERROR', 500)
    end
  end
end
