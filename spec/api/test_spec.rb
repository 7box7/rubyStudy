require 'rails_helper'
require 'bcrypt'

RSpec.describe Api::SessionController, type: :request do
  let!(:user1) { FactoryBot.create(:user, fio: "Учитель1",
                                  email: "email_teacher1@mail.ru",
                                  password: BCrypt::Password.create("password1"),
                                  teacher: true,
                                  jwt_validation: nil) }
  let!(:user2) { FactoryBot.create(:user, fio: "Ученик1",
                                   email: "email_student1@mail.ru",
                                   password: BCrypt::Password.create("password2"),
                                   teacher: false,
                                   jwt_validation: nil) }
  let!(:user3) { FactoryBot.create(:user, fio: "Ученик2",
                                   email: "email_student2@mail.ru",
                                   password: BCrypt::Password.create("password3"),
                                   teacher: false,
                                   jwt_validation: nil) }
  let(:token1) { JWT.encode({ id: user1.id,
                             email: "email_teacher1@mail.ru",
                             password: BCrypt::Password.create("password1"),
                             teacher: true,
                             created_at: Time.now() },
                           "SK",
                           "HS256") }
  let(:token2) { JWT.encode({ id: user2.id,
                              email: "email_student1@mail.ru",
                              password: BCrypt::Password.create("password2"),
                              teacher: false,
                              created_at: Time.now() },
                            "SK",
                            "HS256") }
  let(:token3) { JWT.encode({ id: user3.id,
                              email: "email_student2@mail.ru",
                              password: BCrypt::Password.create("password3"),
                              teacher: false,
                              created_at: Time.now() },
                            "SK",
                            "HS256") }

it "POST api/courses" do
    ans_for_compare = { "description": "Nice subject", "fio": "Учитель1" }
    post "/api/courses",
            params: { course: { title: "Math", description: "Nice subject" } }.to_json,
            headers: { Authorization: "Bearer #{token1}", "Content-Type": "application/json" }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["description_of_course"]).to eq ans_for_compare[:description]
    expect(JSON.parse(response.body)["fio_of_teacher"]).to eq ans_for_compare[:fio]
    expect(Course.find_by(user_id: user1.id).title).to eq "Math"
    expect(Course.find_by(user_id: user1.id).description).to eq "Nice subject"

    end



    let!(:course) {FactoryBot.create(:course,
                                    title: "Math",
                                    description: "Nice subject",
                                    user_id: user1.id)}


    it "GET api/courses?id_teach=1" do
        ans_for_compare = [{"id"=>"1", "description"=>"Nice subject", "title"=>"Math"}]
        get "/api/courses?id_teach=1", headers: { Authorization: "Bearer #{token1}", "Content-Type": "application/json" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq ans_for_compare
    end


    it "POST api/courses unauthorised" do
    delete "/api/session", params: {},
            headers: {'Authorization': "Bearer #{token1}" }
    post "/api/courses",
            params: { course: { title: "Math", description: "Nice subject" } }.to_json,
            headers: { Authorization: "Bearer #{token1}", "Content-Type": "application/json" }
    expect(response).to have_http_status(401)
    end

    it "POST api/courses student forbidden and GET api/courses" do
    post "/api/courses",
            params: { course: { title: "Math", description: "Nice subject" } }.to_json,
            headers: { Authorization: "Bearer #{token2}", "Content-Type": "application/json" }
    expect(response).to have_http_status(403)
    expect(Course.count).to eq 1
    ans_for_compare = [{"creator"=>"Учитель1", "description"=>"Nice subject", "title"=>"Math"}]

    get "/api/courses"
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq ans_for_compare
    end

    it "GET api/courses?student_id={id студента}" do
    get "/api/courses?student_id=2"
    ans_for_compare = []
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq ans_for_compare
    end

    it "POST api/cources/4/subscribe" do
    post "/api/cources/4/subscribe",
            headers: { Authorization: "Bearer #{token2}", "Content-Type": "application/json" }
    get "/api/courses?student_id=2"
    ans_for_compare = []
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq ans_for_compare
    end

    it "POST api/courses student forbidden and GET api/courses" do
    post "/api/courses",
            params: { course: { title: "Math", description: "Nice subject" } }.to_json,
            headers: { Authorization: "Bearer #{token3}", "Content-Type": "application/json" }
    expect(response).to have_http_status(403)
    expect(Course.count).to eq 1
    ans_for_compare = [{"creator"=>"Учитель1", "description"=>"Nice subject", "title"=>"Math"}]

    get "/api/courses"
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq ans_for_compare
    end

    it "GET api/courses?student_id={id студента}" do
    get "/api/courses?student_id=3"
    ans_for_compare = []
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq ans_for_compare
    end

    it "POST api/cources/4/subscribe" do
    post "/api/cources/4/subscribe",
            headers: { Authorization: "Bearer #{token3}", "Content-Type": "application/json" }
    get "/api/courses?student_id=3"
    ans_for_compare = []
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq ans_for_compare
    end
end