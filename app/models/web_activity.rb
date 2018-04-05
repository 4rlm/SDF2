class WebActivity < ApplicationRecord
  belongs_to :user
  belongs_to :web
  # belongs_to :export

  validates_uniqueness_of :web_id, scope: [:user_id]
end
