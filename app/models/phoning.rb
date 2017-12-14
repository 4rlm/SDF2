class Phoning < ApplicationRecord
  belongs_to :phonable, polymorphic: true
  belongs_to :phone

  # accepts_nested_attributes_for :phone
  accepts_nested_attributes_for :phone, allow_destroy: true

  validates :phone_id, :uniqueness => { :scope => [:phonable_type, :phonable_id] } #=> ALSO IN MIGRATION!

end
