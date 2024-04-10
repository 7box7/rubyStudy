require 'rails_helper'
require 'bcrypt'

RSpec.describe Api::SessionController, type: :request do
    
    let! (:teacher_1) { 
        FactoryBot.create(
            :user, 
            fio: "Techer_1",                  
            email: "teacher_1@gmail.com",                 
            password: BCrypt::Password.create("tea1_1234"),      
            teacher: true,              
            jwt_validation: nil
        ) 
    }

    let! (:student_1) { 
        FactoryBot.create(
            :user, 
            fio: "Student_1",                  
            email: "student_1@gmail.com",                 
            password: BCrypt::Password.create("stu1_1234"),      
            teacher: false,              
            jwt_validation: nil
        ) 
    }


    it "POST api/session, DELETE api/session" do
        post "/api/session",
            headers: {
                "Content-Type": "application/json",
            },
            params: {
                user: {
                    email: "teacher_1@gmail.com",                 
                    password: "tea1_1234",    
                }
            }.to_json
        
        expect(response).to have_http_status(:ok)

        delete "/api/session",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + JSON.parse(response.body)["jwt"]
            }
        
        expect(response).to have_http_status(:ok)
    end


    it "POST api/session, DELETE api/session" do
        post "/api/session",
            headers: {
                "Content-Type": "application/json",
            },
            params: {
                user: {
                    email: "student_1@gmail.com",                 
                    password: "stu1_1234",    
                }
            }.to_json
        
        expect(response).to have_http_status(:ok)

        delete "/api/session",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + JSON.parse(response.body)["jwt"]
            }
        
        expect(response).to have_http_status(:ok)
    end
end
