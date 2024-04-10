require 'jwt'
require "time"

class Api::SessionController < ApplicationController
    def create
        return (render status: 400) if !check_params

        user = User.find_by(email: user_params[:email])
        return (render status: :unauthorized) if !user
        return (render status: :unauthorized) if BCrypt::Password.new(user.password) != user_params[:password]

        payload_new = {id: user.id, email: user.email, password: user.password, jwt_validation: user.jwt_validation, created_at: Time.now}
        token = (JWT.encode payload_new, "SK", "HS256")
        return (render status: :unprocessable_entity) if !token

        render json: {jwt: token}, status: :ok
    end


    def destroy
        return (render status: :unauthorized) if !check_token

        token = request.headers['Authorization'][7..-1]
        begin
            decoded_token = JWT.decode token, nil, false
        rescue JWT::DecodeError
            return (render status: :unauthorized)
        end

        user = User.find_by(id: decoded_token[0]["id"], jwt_validation: decoded_token[0]["jwt_validation"])
        return (render status: :unprocessable_entity) if !user

        user.jwt_validation = get_random_string(32)
        user.save
        
        render status: :ok
    end

    private def get_random_string(num)
        o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
        return (0...num).map { o[rand(o.length)] }.join
    end


    private def user_params
        params.require(:user).permit(:email, :password)
    end


    private def check_params
        return ((params["user"].include? :email) and (params["user"].include? :password))
    end


    private def check_token
        return request.headers['Authorization']
    end
end
