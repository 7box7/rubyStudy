require 'rails_helper'
require 'bcrypt'

RSpec.describe Api::SessionController, type: :request do
    
    let!(:teacher_1) { 
        FactoryBot.create(
            :user, 
            fio: "Techer_1",                  
            email: "teacher_1@gmail.com",                 
            password: BCrypt::Password.create("tea1_1234"),      
            teacher: true,              
            jwt_validation: nil
        ) 
    }
    
    let(:teacher_1_token) { 
        JWT.encode({ 
            id: teacher_1.id,
            email: teacher_1.email,
            password: teacher_1.password,
            jwt_validation: teacher_1.jwt_validation,
            created_at: Time.now
        },
        "SK",
        "HS256")
    }

    let!(:teacher_2) { 
        FactoryBot.create(
            :user, 
            fio: "Techer_2",                  
            email: "teacher_2@gmail.com",                 
            password: BCrypt::Password.create("tea2_1234"),      
            teacher: true,              
            jwt_validation: nil
        ) 
    }

    let(:teacher_2_token) { 
        JWT.encode({ 
            id: teacher_2.id,
            email: teacher_2.email,
            password: teacher_2.password,
            jwt_validation: teacher_2.jwt_validation,
            created_at: Time.now
        },
        "SK",
        "HS256")
    }

    let!(:student_1) { 
        FactoryBot.create(
            :user, 
            fio: "Student_1",                  
            email: "student_1@gmail.com",                 
            password: BCrypt::Password.create("stu1_1234"),      
            teacher: false,              
            jwt_validation: nil
        ) 
    }

    let(:student_1_token) { 
        JWT.encode({ 
            id: student_1.id,
            email: student_1.email,
            password: student_1.password,
            jwt_validation: student_1.jwt_validation,
            created_at: Time.now
        },
        "SK",
        "HS256")
    }

    let!(:student_2) { 
        FactoryBot.create(
            :user, 
            fio: "Student_2",                  
            email: "student_2@gmail.com",                 
            password: BCrypt::Password.create("stu2_1234"),      
            teacher: false,              
            jwt_validation: nil
        ) 
    }

    let(:student_2_token) { 
        JWT.encode({ 
            id: student_2.id,
            email: student_2.email,
            password: student_2.password,
            jwt_validation: student_2.jwt_validation,
            created_at: Time.now
        },
        "SK",
        "HS256")
    }

    let!(:course_1) {
        FactoryBot.create(
            :course,
            title: "1 Курс",
            description: "Ну что-то про 1 курс тут интересное или не интересное",
            user_id: teacher_1.id
        )
    }


    it "POST api/courses" do
        true_answer = JSON.generate({
            "id": 2,
            "title": "1 Курс",
            "description": "Ну что-то про 1 курс тут интересное или не интересное",
            "fio": "Techer_1",
        })

        post "/api/courses",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer #{teacher_1_token}"
            },
            params: {
                course: {
                    title: "1 Курс",
                    description: "Ну что-то про 1 курс тут интересное или не интересное"
                }
            }.to_json
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq JSON.parse(true_answer)
    end


    it "GET api/courses" do
        true_answer = JSON.generate([{
            title:  course_1.title,
            description: course_1.description,
            fio: teacher_1.fio,
            id: 1
        }])

        get "/api/courses",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer #{teacher_1_token}"
            },
            params: {
                id_teach: 1
            }
       
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq JSON.parse(true_answer)
    end


    it "GET api/courses" do
        true_answer = []

        get "/api/courses",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer #{teacher_2_token}"
            },
            params: {
                "id_teach": 2
            }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq true_answer
    end


    it "POST api/courses" do
        post "/api/courses",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6NCwiZW1haWwiOiJzdHVAZ21haWwuY29tIiwicGFzc3dvcmQiOiIkMmEkMTIkN0ZjTndUVWZwc1ZIYjJXVnoxamRrLjN6aGNWNWVab3lxaXNiU0lxTUhPVUFGdS51M2xVSy4iLCJqd3RfdmFsaWRhdGlvbiI6IkhYdWdGdE9aaEd5ZFBMcGxQY0tKUEVuVkNzVktQbnJSIiwiY3JlYXRlZF9hdCI6IjIwMjQtMDQtMDYgMDI6MDE6MTMgKzAzMDAifQ.SWUXxmSwxJxO-O7-YeT1xscfV6hm3j3QgTcO3iyUQZ"
            },
            params: {
                course: {
                    title: "3 Курс",
                    description: "Ну что-то про 3 курс тут интересное или не интересное"
                }
            }.to_json
        
        expect(response).to have_http_status(:unauthorized)
    end


    it "POST api/courses" do
        post "/api/courses",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer #{student_1_token}"
            },
            params: {
                course: {
                    title: "1 Курс",
                    description: "Ну что-то про 1 курс тут интересное или не интересное"
                }
            }.to_json
        
        expect(response).to have_http_status(:forbidden)
    end


    it "GET api/courses" do
        true_answer = JSON.generate([{
            title:  course_1.title,
            description: course_1.description,
            fio: teacher_1.fio,
            id: 1
        }])

        get "/api/courses",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer #{teacher_1_token}"
            }
       
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq JSON.parse(true_answer)
    end


    it "GET api/courses" do
        true_answer = []

        get "/api/courses",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer #{student_1_token}"
            },
            params: {
                "id_stud": 3
            }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq true_answer
    end


    it "POST api/courses/1/subscribe, GET api/courses" do
        true_answer = JSON.generate([{
            title:  course_1.title,
            description: course_1.description,
            fio: teacher_1.fio,
            id: 1
        }])

        post "/api/courses/1/subscribe",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer #{student_1_token}"
            }
        
        expect(response).to have_http_status(:ok)
        get "/api/courses",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer #{student_1_token}"
            },
            params: {
                "id_stud": 3
            }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq JSON.parse(true_answer)
    end


    it "GET api/courses" do
        true_answer = []

        get "/api/courses",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer #{student_2_token}"
            },
            params: {
                "id_stud": 4
            }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq true_answer
    end


    it "POST api/courses/1/subscribe, GET api/courses" do
        true_answer = JSON.generate([{
            title:  course_1.title,
            description: course_1.description,
            fio: teacher_1.fio,
            id: 1
        }])

        post "/api/courses/1/subscribe",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer #{student_2_token}"
            }
        
        expect(response).to have_http_status(:ok)
        get "/api/courses",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer #{student_2_token}"
            },
            params: {
                "id_stud": 4
            }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq JSON.parse(true_answer)
    end
end
