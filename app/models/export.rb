class Export < ApplicationRecord
  belongs_to :user
  has_many :web_activities

end
