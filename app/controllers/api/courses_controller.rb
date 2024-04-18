# frozen_string_literal: true

module Api
  class CoursesController < ApplicationController
    before_action :check_auth
    before_action :check_course_params, only: [:create]

    def index
      courses = find_courses
      return (render status: :unprocessable_entity) unless courses

      render json: courses, status: :ok
    end

    def show
      course = Course.find(params[:id])
      return (render status: :unprocessable_entity) unless course

      render json: {
        title: course.title,
        description: course.description,
        fio: User.find(course.user_id).fio,
        number_of_students: Course.sum_students(params[:id])
      }, status: :ok
    end

    def subscribe
      return (render status: :forbidden) if @user.teacher

      course = Course.find(params[:course_id])
      return (render status: :unprocessable_entity) unless course
      return (render status: :unprocessable_entity) if Participant.find_by(user: @user, course:)

      participant = Participant.new(user: @user, course:)
      participant.save
      render status: :ok
    end

    def create
      return (render status: :forbidden) unless @user.teacher

      @course = Course.new(title: course_params[:title], description: course_params[:description],
                           user: @user)
      @course.save
      render json: {
        id: @course.id,
        title: @course.title,
        description: @course.description,
        fio: @user.fio
      }, status: :ok
    end


    private

    def find_courses
      f_params
      if (@fs != 0) && (@ft != 0)
        Course.courses_teacher_student(@ft, @fs, pagin_offset, limit)
      elsif @fs != 0
        Course.courses_student(@fs, pagin_offset, limit)
      elsif @ft != 0
        Course.courses_teacher(@ft, pagin_offset, limit)
      else
        Course.courses(pagin_offset, limit)
      end
    end

    def f_params
      @ft = filter_params[:id_teach]
      @fs = filter_params[:id_stud]
    end

    def filter_params
      { id_stud: student_id_param, id_teach: teacher_id_param, pagination: pagination_param }
    end

    def student_id_param
      params[:id_stud].present? ? params[:id_stud] : 0
    end

    def teacher_id_param
      params[:id_teach].present? ? params[:id_teach] : 0
    end

    def pagin_offset
      (filter_params[:pagination][:page] - 1) * filter_params[:pagination][:limit]
    end

    def limit
      filter_params[:pagination][:limit]
    end

    def pagination_param
      if params[:pagination].present?
        { page: params[:pagination][:page],
          limit: params[:pagination][:limit] % 1000 }
      else
        { page: 1, limit: 50 }
      end
    end

    def check_auth
      return (render status: :unauthorized) unless check_token

      token = request.headers['Authorization'][7..]
      begin
        decoded_token = JWT.decode token, nil, false
      rescue JWT::DecodeError
        return (render status: :unauthorized)
      end
      @user = User.find_by(id: decoded_token[0]['id'], jwt_validation: decoded_token[0]['jwt_validation'])
      return if @user

      render status: :unauthorized
    end

    def check_course_params
      return if params['course'][:title].present? && params['course'][:description].present?

      (render status: :bad_request)
    end

    def course_params
      params.require(:course).permit(:title, :description)
    end

    def check_token
      request.headers['Authorization']
    end
  end
end
