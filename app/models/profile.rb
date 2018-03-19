class Profile < ApplicationRecord
  belongs_to :user

  def fullname
    "#{self.first_name} #{self.last_name}"
  end
end
