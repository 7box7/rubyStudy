FactoryBot.define do
    factory :user do
      fio { "Teacher" }
      email { "tea@gmail.com" }
      password { 'tea1234' }
      teacher { true }
    end
  end
