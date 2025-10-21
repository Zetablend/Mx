class ApplicationController < ActionController::API

	respond_to :json
  	before_action :authorize_request
  	before_action :set_default_format

	private

    def set_default_format
        request.format = :json
    end

    def authorize_request
        token = request.headers['Authorization']&.split(' ')&.last
        return render json: { error: 'Missing token' }, status: :unauthorized unless token

        begin
        decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256').first
        @current_user = User.find(decoded['sub'])
        rescue JWT::DecodeError
        render json: { error: 'Invalid token' }, status: :unauthorized
        end
    end
end
