# frozen_string_literal: true

module Api
  class RegController < ApplicationController
    def create
      unless check_params
        render json: { error: 'Bad request' }, status: :bad_request
        return
      end
    
      @user = User.new(fio: user_params[:fio], email: user_params[:email],
                       password: BCrypt::Password.create(user_params[:password]),
                       teacher: user_params[:teacher], jwt_validation: random_string(32))
    
      if @user.save
        render json: { message: 'User created successfully' }, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end


    private

    def random_string(num)
      o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
      (0...num).map { o[rand(o.length)] }.join
    end

    def user_params
      params.require(:user).permit(:fio, :email, :password, :teacher)
    end

    def check_params
      (params['user'][:fio].present? && params['user'][:email].present?) &&
        (params['user'][:password].present? && params['user'][:teacher].present?)
    end
  end
end
