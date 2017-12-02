class ContactTitle < ApplicationRecord
  belongs_to :contact
  belongs_to :title

  accepts_nested_attributes_for :title

  validates_uniqueness_of :contact, scope: :title_id

end
