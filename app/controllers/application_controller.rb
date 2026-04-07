# class ApplicationController < ActionController::API

# 	# respond_to :json
#   	# before_action :authenticate_request
#   	# before_action :set_default_format

# 	# private

#     # def set_default_format
#     #     request.format = :json
#     # end

#     # def authenticate_request
#     #     token = request.headers['Authorization']&.split(' ')&.last
#     #     return render json: { error: 'Missing token' }, status: :unauthorized unless token

#     #     begin
#     #     decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256').first
#     #     @current_user = User.find(decoded['sub'])
#     #     rescue JWT::DecodeError
#     #     render json: { error: 'Invalid token' }, status: :unauthorized
#     #     end
#     # end


#     before_action :authenticate_request
#     before_action :set_default_format

#     before_action do
#         Rails.logger.info "AUTH HEADER: #{request.headers['Authorization']}"
#     end

#     private

#     def set_default_format
#         request.format = :json
#     end
# end

class ApplicationController < ActionController::API
  before_action :authenticate_request

  attr_reader :current_user

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header&.split(' ')&.last

    return render json: { error: 'Missing token' }, status: :unauthorized unless token

    begin
      payload = Warden::JWTAuth::TokenDecoder.new.call(token)
      @current_user = User.find(payload['sub'])

    rescue JWT::ExpiredSignature
      render json: { error: 'Token expired' }, status: :unauthorized

    rescue Warden::JWTAuth::Errors::RevokedToken
      render json: { error: 'Token revoked' }, status: :unauthorized

    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error: #{e.message}"
      render json: { error: 'Invalid token' }, status: :unauthorized

    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized

    rescue => e
      Rails.logger.error "JWT AUTH ERROR: #{e.class} - #{e.message}"
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end







