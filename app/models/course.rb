class Course < ApplicationRecord
  belongs_to :user
  has_many :participants
  scope :sum_students, -> (id){where(id: id).joins(:participants).count}
end
