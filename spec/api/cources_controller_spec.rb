require 'rails_helper'
require 'bcrypt'

RSpec.describe Api::SessionController, type: :request do

    let(:teacher_1) do
        create(:user, teacher: true)
    end

    let(:teacher_1_token) do
        JWT.encode({ 
            id: teacher_1.id,
            email: teacher_1.email,
            password: teacher_1.password,
            jwt_validation: teacher_1.jwt_validation,
            created_at: Time.now
        },
        "SK",
        "HS256")
    end

    let(:teacher_2) do 
        create(:user, teacher: true) 
    end

    let(:teacher_2_token) do 
        JWT.encode({ 
            id: teacher_2.id,
            email: teacher_2.email,
            password: teacher_2.password,
            jwt_validation: teacher_2.jwt_validation,
            created_at: Time.now
        },
        "SK",
        "HS256")
    end

    let(:student_1) do
        create(:user)
    end

    let(:student_1_token) do
        JWT.encode({ 
            id: student_1.id,
            email: student_1.email,
            password: student_1.password,
            jwt_validation: student_1.jwt_validation,
            created_at: Time.now
        },
        "SK",
        "HS256")
    end

    let(:student_2) do
        create(:user)
    end

    let(:student_2_token) do 
        JWT.encode({ 
            id: student_2.id,
            email: student_2.email,
            password: student_2.password,
            jwt_validation: student_2.jwt_validation,
            created_at: Time.now
        },
        "SK",
        "HS256")
    end

    let(:course_1) do 
        create(:course, user_id: teacher_1.id) 
    end


    describe 'POST api/courses' do
        subject do
            post "/api/courses",
            headers: headers,
            params: params
        end

        context 'when 1 teacher creating course' do
            let(:expected_response) do
                JSON.generate({
                    title:  course_1.title,
                    description: course_1.description,
                    fio: teacher_1.fio,
                    id: course_1.id - 1
                })
            end

            let(:headers) do
                {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer #{teacher_1_token}"
                }
            end

            let(:params) do
                JSON.generate({
                    course: {
                        title: "1 Курс",
                        description: "Ну что-то про 1 курс тут интересное или не интересное"
                    }
                })
            end

            it 'returns expected response' do
                subject
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)).to eq JSON.parse(expected_response)
            end
        end

        context 'when 1 student trying to create course' do
            let(:headers) do
                {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer #{student_1_token}"
                }
            end

            let(:params) do
                JSON.generate({
                    course: {
                        title: "1 Курс",
                        description: "Ну что-то про 1 курс тут интересное или не интересное"
                    }
                })
            end

            it 'forbids creating the course' do
                subject
                expect(response).to have_http_status(:forbidden)
            end
        end

        context 'when user with uncorrect token trying to create course' do
            let(:headers) do
                {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6NCwiZW1haWwiOiJzdHVAZ21haWwuY29tIiwicGFzc3dvcmQiOiIkMmEkMTIkN0ZjTndUVWZwc1ZIYjJXVnoxamRrLjN6aGNWNWVab3lxaXNiU0lxTUhPVUFGdS51M2xVSy4iLCJqd3RfdmFsaWRhdGlvbiI6IkhYdWdGdE9aaEd5ZFBMcGxQY0tKUEVuVkNzVktQbnJSIiwiY3JlYXRlZF9hdCI6IjIwMjQtMDQtMDYgMDI6MDE6MTMgKzAzMDAifQ.SWUXxmSwxJxO-O7-YeT1xscfV6hm3j3QgTcO3iyUQZ"
                }
            end

            let(:params) do
                JSON.generate({
                    course: {
                        title: "3 Курс",
                        description: "Ну что-то про 3 курс тут интересное или не интересное"
                    }
                })
            end

            it 'forbids creating the course' do
                subject
                expect(response).to have_http_status(:unauthorized)
            end
        end
    end


    describe 'GET api/courses' do
        subject do
            get "/api/courses",
            headers: headers,
            params: params
        end

        context 'when 1 teacher getting his course' do
            let(:expected_response) do
                JSON.generate([{
                    title:  course_1.title,
                    description: course_1.description,
                    fio: teacher_1.fio,
                    id: course_1.id
                }])
            end

            let(:headers) do
                {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer #{teacher_1_token}"
                }
            end

            let(:params) do
                JSON.generate({
                    id_teach: teacher_1.id
                })
            end

            it 'returns 1 teacher course' do
                course_1
                subject
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)).to eq JSON.parse(expected_response)
            end
        end

        context 'when 2 teacher getting his course' do
            let(:headers) do
                {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer #{teacher_2_token}"
                }
            end

            let(:params) do
                JSON.generate({
                    id_teach: teacher_2.id
                })
            end

            it 'returns nothing' do
                subject
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)).to eq []
            end
        end

        context 'when 1 teacher getting all courses' do
            let(:expected_response) do
                JSON.generate([{
                    title:  course_1.title,
                    description: course_1.description,
                    fio: teacher_1.fio,
                    id: course_1.id
                }])
            end

            let(:headers) do
                {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer #{teacher_1_token}"
                }
            end

            let(:params) do
                {}
            end

            it 'returns 1 course' do
                course_1
                subject
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)).to eq JSON.parse(expected_response)
            end
        end

        context 'when 1 student getting all his courses' do
            let(:headers) do
                {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer #{student_1_token}"
                }
            end

            let(:params) do
                {
                    id_stud: student_1.id
                }
            end

            it 'returns nothing' do
                subject
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)).to eq []
            end
        end

        context 'when 2 student getting all his courses' do
            let(:headers) do
                {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer #{student_2_token}"
                }
            end

            let(:params) do
                {
                    id_stud: student_2.id
                }
            end

            it 'returns nothing' do
                subject
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)).to eq []
            end
        end
    end


    describe 'POST api/courses/1/subscribe, GET api/courses' do
        subject(:subscribe) do
            post "/api/courses/1/subscribe",
            headers: headers
        end

        subject(:get_courses) do
            get "/api/courses",
            headers: headers,
            params: params
        end

        context 'when 1 student subscribe on course' do
            let(:expected_response) do
                JSON.generate([{
                    title:  course_1.title,
                    description: course_1.description,
                    fio: teacher_1.fio,
                    id: course_1.id
                }])
            end

            let(:headers) do
                {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer #{student_1_token}"
                }
            end

            let(:params) do
                {
                    id_stud: student_1.id
                }
            end

            it 'returns OK' do
                course_1
                subscribe
                expect(response).to have_http_status(:ok)
            end

            it 'returns 1 course of 1 student' do
                course_1
                subscribe
                get_courses
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)).to eq JSON.parse(expected_response)
            end
        end

        context 'when 1 student subscribe on course' do
            let(:expected_response) do
                JSON.generate([{
                    title:  course_1.title,
                    description: course_1.description,
                    fio: teacher_1.fio,
                    id: course_1.id
                }])
            end

            let(:headers) do
                {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer #{student_2_token}"
                }
            end

            let(:params) do
                {
                    id_stud: student_2.id
                }
            end

            it 'returns OK' do
                course_1
                subscribe
                expect(response).to have_http_status(:ok)
            end

            it 'returns 1 course of 1 student' do
                course_1
                subscribe
                get_courses
                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)).to eq JSON.parse(expected_response)
            end
        end
    end
end
