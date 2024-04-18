# frozen_string_literal: true

module Api
  class RegController < ApplicationController
    def create
      return (render status: 400) unless check_params

      @user = User.new(fio: user_params[:fio], email: user_params[:email],
                       password: BCrypt::Password.create(user_params[:password]),
                       teacher: user_params[:teacher], jwt_validation: random_string(32))
      return (render status: :unprocessable_entity) unless @user.save

      render status: :ok
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
