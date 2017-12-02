class ContactTitle < ApplicationRecord
  belongs_to :contact
  belongs_to :title

  validates_uniqueness_of :contact, scope: :title_id

end
