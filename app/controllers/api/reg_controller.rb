class Api::RegController < ApplicationController
    def create
        return (render status: 400) if !check_params

        @user = User.new(fio: user_params[:fio], email: user_params[:email], password: BCrypt::Password.create(user_params[:password]), teacher: user_params[:teacher], jwt_validation: get_random_string(32))
        return (render status: :unprocessable_entity) if !@user.save
        
        render status: :ok
    end


    private def get_random_string(num)
        o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
        return (0...num).map { o[rand(o.length)] }.join
    end


    private def user_params
        params.require(:user).permit(:fio, :email, :password, :teacher)
    end


    private def check_params
        return ((params["user"].include? :fio) and (params["user"].include? :email) and (params["user"].include? :password) and (params["user"].include? :teacher))
    end
end
