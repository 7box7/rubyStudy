require 'rails_helper'
require 'bcrypt'

RSpec.describe Api::SessionController, type: :request do
    
    let(:teacher_1) { create(:user, teacher: true) }

    let(:student_1) { create(:user) }

    describe 'POST api/session, DELETE api/session' do
        subject(:log_in) do
            post "/api/session",
            headers: headers_login,
            params: params
        end

        subject(:log_out) do
            delete "/api/session",
            headers: headers_logout
        end

        context 'when 1 teacher login and logout' do
            let(:headers_login) do
                {
                    "Content-Type": "application/json",
                }
            end

            let(:params) do
                {
                    user: {
                        email: teacher_1.email,                 
                        password: "user1_1234",    
                    }
                }.to_json
            end

            let(:headers_logout) do
                {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer " + JSON.parse(response.body)["jwt"]
                }
            end

            it 'returns expected response' do
                teacher_1
                log_in
                expect(response).to have_http_status(:ok)
                log_out
                expect(response).to have_http_status(:ok)
            end
        end

        context 'when 1 student login and logout' do
            let(:headers_login) do
                {
                    "Content-Type": "application/json",
                }
            end

            let(:params) do
                JSON.generate({
                    user: {
                        email: student_1.email,                 
                        password: "user2_1234",    
                    }
                })
            end

            let(:headers_logout) do
                {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer " + JSON.parse(response.body)["jwt"]
                }
            end

            it 'returns expected response' do
                student_1
                log_in
                expect(response).to have_http_status(:ok)
                log_out
                expect(response).to have_http_status(:ok)
            end
        end

    end
end
