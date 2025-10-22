class Api::V1::ItemsController < Api::V1::ApplicationController
  def show
    # 必須パラメータの検証
    unless validate_required_params([:temperature, :weather])
      return
    end
    
    temperature = params[:temperature].to_i
    weather = params[:weather]
    humidity = params[:humidity]&.to_i
    wind_speed = params[:wind_speed]&.to_f
    
    begin
      # ItemsServiceを使用して持ち物提案を取得
      items_service = ItemsService.new(
        temperature: temperature,
        weather: weather,
        humidity: humidity,
        wind_speed: wind_speed
      )
      
      items_data = items_service.suggest_items
      
      render_success(items_data, 'Items suggestion retrieved successfully')
    rescue => e
      Rails.logger.error "Items controller error: #{e.message}"
      render_error('Failed to retrieve items suggestion', 'INTERNAL_ERROR', 500)
    end
  end
end
