require 'rails_helper'
require 'bcrypt'

RSpec.describe Api::SessionController, type: :request do
    
    let(:teacher_1) { create(:user, teacher: true) }

    let(:student_1) { create(:user) }

    it "POST api/session, DELETE api/session" do
        post "/api/session",
            headers: {
                "Content-Type": "application/json",
            },
            params: {
                user: {
                    email: teacher_1.email,                 
                    password: "user1_1234",    
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
                    email: student_1.email,                 
                    password: "user2_1234",    
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
