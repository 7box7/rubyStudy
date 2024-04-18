class Course < ApplicationRecord
  belongs_to :user
  has_many :participants
  scope :sum_students, -> (id){where(id: id).joins(:participants).count}
  scope :courses_teacher_student, -> (id_teach, id_stud, pagin_offset, limit){select('users.fio, courses.title, courses.description, courses.id').where(['user_id = ?', "#{id_teach}"]).joins(:participants).where(['participants.user_id = ?', "#{id_stud}"]).joins(:user).offset(pagin_offset).take(limit)}
  scope :courses_student, -> (id_stud, pagin_offset, limit){select('users.fio, courses.title, courses.description, courses.id').joins(:participants).where(['participants.user_id = ?', "#{id_stud}"]).joins(:user).offset(pagin_offset).take(limit)}
  scope :courses_teacher, -> (id_teach, pagin_offset, limit){select('users.fio, courses.title, courses.description, courses.id').where(['user_id = ?', "#{id_teach}"]).joins(:user).offset(pagin_offset).take(limit)}
  scope :courses, -> (pagin_offset, limit){select('users.fio, courses.title, courses.description, courses.id').joins(:user).offset(pagin_offset).take(limit)}
end
