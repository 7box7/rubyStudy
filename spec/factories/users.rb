require 'bcrypt'

FactoryBot.define do
  factory :user do
    sequence(:fio) { |n| "User_#{n}" }
    sequence(:email) { |n| "user_#{n}@gmail.com" }
    sequence(:password) { |n| BCrypt::Password.create("user#{n}_1234") }
    teacher { false }
    jwt_validation { nil }
  end
end
