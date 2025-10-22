class Api::V1::ApplicationController < ActionController::API
  # API用のベースコントローラー
  
  # 共通のレスポンス形式
  def render_success(data = {}, message = 'Success')
    render json: {
      status: 'success',
      data: data,
      message: message,
      timestamp: Time.current.iso8601
    }
  end
  
  def render_error(message = 'Error', code = 'UNKNOWN_ERROR', status = 500)
    render json: {
      status: 'error',
      error: {
        code: code,
        message: message
      },
      timestamp: Time.current.iso8601
    }, status: status
  end
  
  # パラメータ検証
  def validate_required_params(required_params)
    missing_params = required_params.select { |param| params[param].blank? }
    
    if missing_params.any?
      render_error("Missing required parameters: #{missing_params.join(', ')}", 'INVALID_PARAMETERS', 400)
      return false
    end
    
    true
  end
  
  # エラーハンドリング
  rescue_from StandardError do |exception|
    Rails.logger.error "API Error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render_error('Internal server error', 'INTERNAL_ERROR', 500)
  end
end
