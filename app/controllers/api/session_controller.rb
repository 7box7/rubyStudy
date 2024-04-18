# frozen_string_literal: true

require 'jwt'
require 'time'

module Api
  class SessionController < ApplicationController
    before_action :check_token, only: [:destroy]
    before_action :check_params, only: [:create]
    before_action :check_email, only: [:create]

    def create
      return (render status: :unauthorized) if BCrypt::Password.new(@user.password) != user_params[:password]

      payload_new = { id: @user.id, email: @user.email, password: @user.password, jwt_validation: @user.jwt_validation,
                      created_at: Time.now }
      token = (JWT.encode payload_new, 'SK', 'HS256')
      return (render status: :unprocessable_entity) unless token

      render json: { jwt: token }, status: :ok
    end

    def destroy
      begin
        decoded_token = JWT.decode request.headers['Authorization'][7..], nil, false
      rescue JWT::DecodeError
        return (render status: :unauthorized)
      end

      user = User.find_by(id: decoded_token[0]['id'], jwt_validation: decoded_token[0]['jwt_validation'])
      return (render status: :unprocessable_entity) unless user

      user.jwt_validation = random_string(32)
      user.save

      render status: :ok
    end


    private

    def check_email
      @user = User.find_by(email: user_params[:email])
      (render status: :unauthorized) unless @user
    end

    def random_string(num)
      o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
      (0...num).map { o[rand(o.length)] }.join
    end

    def user_params
      params.require(:user).permit(:email, :password)
    end

    def check_params
      (render status: 400) unless params['user'][:email].present? && params['user'][:password].present?
    end

    def check_token
      (render status: :unauthorized) unless request.headers['Authorization']
    end
  end
end
