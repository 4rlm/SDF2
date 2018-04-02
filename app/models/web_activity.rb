class WebActivity < ApplicationRecord
  belongs_to :user
  belongs_to :web
  # belongs_to :export
end
