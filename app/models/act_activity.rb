class ActActivity < ApplicationRecord
  belongs_to :user
  belongs_to :act
  # belongs_to :export
end
