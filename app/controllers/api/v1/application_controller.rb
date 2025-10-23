class Api::V1::ApplicationController < ActionController::API
  # API用のベースコントローラー
  
  # レスポンス圧縮とキャッシュヘッダー
  before_action :set_cache_headers
  after_action :set_response_headers
  
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
  
  private
  
  def set_cache_headers
    # APIレスポンスのキャッシュ設定
    response.headers['Cache-Control'] = 'public, max-age=300' # 5分間キャッシュ
    response.headers['ETag'] = Digest::MD5.hexdigest("#{request.path}#{params.to_s}")
  end
  
  def set_response_headers
    # レスポンス圧縮とセキュリティヘッダー
    response.headers['Content-Type'] = 'application/json; charset=utf-8'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
  end
  
  # エラーハンドリング
  rescue_from StandardError do |exception|
    Rails.logger.error "API Error: #{exception.message}"
    Rails.logger.error "Backtrace: #{exception.backtrace.first(10).join(', ')}"
    
    # エラーの種類に応じた適切なレスポンス
    case exception
    when ArgumentError, ActionController::ParameterMissing
      render_error('Invalid parameters provided', 'INVALID_PARAMETERS', 400)
    when ActiveRecord::RecordNotFound
      render_error('Resource not found', 'NOT_FOUND', 404)
    when Net::TimeoutError, SocketError
      render_error('Service temporarily unavailable', 'SERVICE_UNAVAILABLE', 503)
    else
      render_error('Internal server error', 'INTERNAL_ERROR', 500)
    end
  end

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    Rails.logger.warn "Invalid CSRF token: #{exception.message}"
    render_error('Invalid request', 'INVALID_REQUEST', 422)
  end

  rescue_from ActionController::ParameterMissing do |exception|
    Rails.logger.warn "Missing parameter: #{exception.message}"
    render_error("Missing required parameter: #{exception.param}", 'MISSING_PARAMETER', 400)
  end
end
