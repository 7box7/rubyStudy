class Api::CoursesController < ApplicationController
    before_action :check_auth

    def index
        filters = get_filters()
        courses = get_courses(filters)
        
        return (render status: :unprocessable_entity) if !courses
        
        render json: courses, status: :ok
    end


    def show
        course = Course.find(params[:id])
        return (render status: :unprocessable_entity) if !course

        render json: {
            title:  course.title,
            description: course.description,
            fio: User.find(course.user_id).fio,
            number_of_students: Course.sum_students(params[:id])
        }, status: :ok
        
    end


    def subscribe
        return (render status: :forbidden) if @user.teacher
        
        course = Course.find(params[:course_id])
        return (render status: :unprocessable_entity) if !course
        return (render status: :unprocessable_entity) if Participant.find_by(:user => @user, :course => course)
        
        participant = Participant.new(:user => @user, :course => course)
        participant.save
        render status: :ok
    end


    def create
        return (render status: :bad_request) if !check_course_params
        return (render status: :forbidden) if !@user.teacher

        @course = Course.new(:title => course_params[:title], :description => course_params[:description], :user => @user)
        @course.save
        render json: {
            "id": @course.id,
            "title": @course.title,
            "description": @course.description,
            "fio": @user.fio
        }, status: :ok
    end

    
    private def get_courses(filters)
        pagin_offset = (filters[:pagination][:page] - 1) * filters[:pagination][:limit]

        if (filters[:id_stud] != 0) and (filters[:id_teach] != 0)
            courses = Course.select("users.fio, courses.title, courses.description, courses.id").where(user_id: filters[:id_teach]).joins(:participants).where("participants.user_id" => filters[:id_stud]).joins(:user).offset(pagin_offset).take(filters[:pagination][:limit])
        elsif (filters[:id_stud] != 0)
            courses = Course.select("users.fio, courses.title, courses.description, courses.id").joins(:participants).where("participants.user_id" => filters[:id_stud]).joins(:user).offset(pagin_offset).take(filters[:pagination][:limit])
        elsif (filters[:id_teach] != 0)
            courses = Course.select("users.fio, courses.title, courses.description, courses.id").where(user_id: filters[:id_teach]).joins(:user).offset(pagin_offset).take(filters[:pagination][:limit])
        else
            courses = Course.select("users.fio, courses.title, courses.description, courses.id").joins(:user).offset(pagin_offset).take(filters[:pagination][:limit])
        end

        return courses
    end


    private def get_filters
        return {:id_stud => get_id_stud(), :id_teach => get_id_teach(), :pagination => get_pagination()}
    end


    private def get_id_stud
        return (params.include? :id_stud) ? params[:id_stud] : 0
    end


    private def get_id_teach
        return (params.include? :id_teach) ? params[:id_teach] : 0
    end


    private def get_pagination
        return (params.include? :pagination) ? {:page => params[:pagination][:page], :limit => params[:pagination][:limit] % 1000} : {:page => 1, :limit => 50}
    end


    private def check_auth
        return (render status: :unauthorized) if !check_token

        token = request.headers['Authorization'][7..-1]
        begin
            decoded_token = JWT.decode token, nil, false
        rescue JWT::DecodeError
            return (render status: :unauthorized)
        end

        @user = User.find_by(id: decoded_token[0]["id"], jwt_validation: decoded_token[0]["jwt_validation"])
        if !@user
            render status: :unauthorized
        end
    end


    private def check_course_params
        return ((params["course"].include? :title) and (params["course"].include? :description))
    end


    private def course_params
        params.require(:course).permit(:title, :description)
    end


    private def check_token
        return request.headers['Authorization']
    end

end
