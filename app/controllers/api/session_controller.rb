# frozen_string_literal: true

require 'jwt'
require 'time'

module Api
  class SessionController < ApplicationController
    before_action :ensure_authorized, only: [:destroy]
    before_action :check_params, only: [:create]
    before_action :check_email, only: [:create]

    def create
      return (render json: { error: 'Unauthorized' }, status: :unauthorized) if BCrypt::Password.new(@user.password) != user_params[:password]

      payload_new = { id: @user.id, email: @user.email, password: @user.password, jwt_validation: @user.jwt_validation,
                      created_at: Time.now }
      token = (JWT.encode payload_new, 'SK', 'HS256')
      return (render json: { error: 'Unprocessable entity' }, status: :unprocessable_entity) unless token

      render json: { jwt: token }, status: :ok
    end

    def destroy
      begin
        decoded_token = JWT.decode request.headers['Authorization'][AUTH_TOKEN_OFFSET..], nil, false
      rescue JWT::DecodeError
        return (render json: { error: 'Unauthorized' }, status: :unauthorized)
      end

      user = User.find_by(id: decoded_token[0]['id'], jwt_validation: decoded_token[0]['jwt_validation'])
      return (render json: { error: 'Unprocessable entity' }, status: :unprocessable_entity) unless user

      user.jwt_validation = ToolsService.random_string(32)
      user.save

      render json: {message: "OK"}, status: :ok
    end


    private

    def check_email
      @user = User.find_by(email: user_params[:email])
      (render json: { error: 'Unauthorized' }, status: :unauthorized) unless @user
    end

    def user_params
      params.require(:user).permit(:email, :password)
    end

    def check_params
      (render json: { error: 'Bad request' }, status: :bad_request) unless params['user'][:email].present? && params['user'][:password].present?
    end
  end
end
