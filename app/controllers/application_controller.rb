class ApplicationController < ActionController::Base
    
    AUTH_TOKEN_OFFSET = 7

    def ensure_authorized
        return (render json: { error: 'Unauthorized' }, status: :unauthorized) unless check_token
        token = request.headers['Authorization'][AUTH_TOKEN_OFFSET..]
        begin
          decoded_token = JWT.decode token, nil, false
        rescue JWT::DecodeError
          return (render json: { error: 'Unauthorized' }, status: :unauthorized)
        end
        @user = User.find_by(id: decoded_token[0]['id'], jwt_validation: decoded_token[0]['jwt_validation'])
        return if @user

        render json: { error: 'Unauthorized' }, status: :unauthorized
    end

    def check_token
        request.headers['Authorization']
    end
end
