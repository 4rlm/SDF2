class ContActivity < ApplicationRecord
  belongs_to :user
  belongs_to :cont
  # belongs_to :export
end
