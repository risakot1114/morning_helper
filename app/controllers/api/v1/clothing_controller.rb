class Api::V1::ClothingController < Api::V1::ApplicationController
  def show
    # 必須パラメータの検証
    unless validate_required_params([:temperature, :weather])
      return
    end
    
    temperature = params[:temperature].to_i
    weather = params[:weather]
    style = params[:style] || 'business'
    gender = params[:gender] || 'unisex'
    
    begin
      # ClothingServiceを使用して服装提案を取得
      clothing_service = ClothingService.new(
        temperature: temperature,
        weather: weather,
        style: style,
        gender: gender
      )
      
      clothing_data = clothing_service.suggest_outfit
      
      render_success(clothing_data, 'Clothing suggestion retrieved successfully')
    rescue => e
      Rails.logger.error "Clothing controller error: #{e.message}"
      render_error('Failed to retrieve clothing suggestion', 'INTERNAL_ERROR', 500)
    end
  end
end
