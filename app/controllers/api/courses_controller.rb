# frozen_string_literal: true

module Api
  class CoursesController < ApplicationController
    before_action :ensure_authorized
    before_action :check_course_params, only: [:create]

    def index
      courses = find_courses
      return (render json: { error: 'Unprocessable entity' }, status: :unprocessable_entity) unless courses

      render json: courses, status: :ok
    end

    def show
      course = Course.find(params[:id])
      return (render json: { error: 'Unprocessable entity' }, status: :unprocessable_entity) unless course

      render json: {
        title: course.title,
        description: course.description,
        fio: User.find(course.user_id).fio,
        number_of_students: Course.sum_students(params[:id])
      }, status: :ok
    end

    def subscribe
      return (render json: { error: 'Forbidden' }, status: :forbidden) if @user.teacher

      course = Course.find(params[:course_id])
      return (render json: { error: 'Unprocessable entity' }, status: :unprocessable_entity) unless course
      return (render json: { error: 'Unprocessable entity' }, status: :unprocessable_entity) if Participant.find_by(user: @user, course:)

      participant = Participant.new(user: @user, course:)
      participant.save
      render json: {message: "OK"}, status: :ok
    end

    def create
      return (render json: { error: 'Forbidden' }, status: :forbidden) unless @user.teacher

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
      filtered_params
      if (@filtered_params_student != 0) && (@filtered_params_teacher != 0)
        Course.courses_teacher_student(@filtered_params_teacher, @filtered_params_student, paginagion_offset, limit)
      elsif @filtered_params_student != 0
        Course.courses_student(@filtered_params_student, paginagion_offset, limit)
      elsif @filtered_params_teacher != 0
        Course.courses_teacher(@filtered_params_teacher, paginagion_offset, limit)
      else
        Course.courses(paginagion_offset, limit)
      end
    end

    def filtered_params
      @filtered_params_teacher = filter_params[:id_teach]
      @filtered_params_student = filter_params[:id_stud]
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

    def paginagion_offset
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

    def check_course_params
      return if params['course'][:title].present? && params['course'][:description].present?

      (render json: { error: 'Bad request' }, status: :bad_request)
    end

    def course_params
      params.require(:course).permit(:title, :description)
    end
  end
end
