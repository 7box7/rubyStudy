FactoryBot.define do
    factory :course do
      title { "1 Курс" }
      description { "Ну что-то про 1 курс тут интересное или не интересное" }
      user_id { 1 }
    end
  end
