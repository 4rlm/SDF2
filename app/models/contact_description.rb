class ContactDescription < ApplicationRecord
  belongs_to :contact
  belongs_to :description

  accepts_nested_attributes_for :description

  validates_uniqueness_of :contact, scope: :description_id

end
