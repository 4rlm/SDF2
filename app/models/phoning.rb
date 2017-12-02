class Phoning < ApplicationRecord
  belongs_to :phonable, polymorphic: true
  belongs_to :phone

  accepts_nested_attributes_for :phone

  validates :phone_id, :uniqueness => { :scope => [:phonable_type, :phonable_id] } #=> ALSO IN MIGRATION!

end
