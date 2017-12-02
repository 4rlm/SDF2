class ContactDescription < ApplicationRecord
  belongs_to :contact
  belongs_to :description

  validates_uniqueness_of :contact, scope: :description_id

end
