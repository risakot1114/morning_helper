class Api::V1::PollenController < Api::V1::ApplicationController
  def show
    # 必須パラメータの検証
    unless validate_required_params([:lat, :lon])
      return
    end
    
    lat = params[:lat].to_f
    lon = params[:lon].to_f
    date = params[:date] ? Date.parse(params[:date]) : Date.current
    
    # パラメータの範囲チェック
    if lat < -90 || lat > 90 || lon < -180 || lon > 180
      render_error('Invalid latitude or longitude values', 'INVALID_PARAMETERS', 400)
      return
    end
    
    begin
      # PollenServiceを使用して花粉情報を取得
      pollen_service = PollenService.new(lat: lat, lon: lon, date: date)
      pollen_data = pollen_service.pollen_info
      
      render_success(pollen_data, 'Pollen information retrieved successfully')
    rescue => e
      Rails.logger.error "Pollen controller error: #{e.message}"
      render_error('Failed to retrieve pollen information', 'INTERNAL_ERROR', 500)
    end
  end
end
