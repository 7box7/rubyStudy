3.times do |i|
    User.create(fio: "User #{i}", email: "user#{i}@gmail.com", password: BCrypt::Password.create("user#{i}_1234"), teacher: false)
end

3.times do |i|
    User.create(fio: "User #{i + 3}", email: "user#{i + 3}@gmail.com", password: BCrypt::Password.create("user#{i + 3}_1234"), teacher: true)
end

3.times do |i|
    Course.create(title: "test_course #{i}", description: "pass", user_id: i + 4)
end

3.times do |i|
    Participant.create(user_id: i + 1, course_id: i + 1)
end