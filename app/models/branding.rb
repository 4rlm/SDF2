class Branding < ApplicationRecord

  belongs_to :brandable, polymorphic: true
  belongs_to :brand

  accepts_nested_attributes_for :brand

  validates :brand_id, :uniqueness => { :scope => [:brandable_type, :brandable_id] } #=> ALSO IN MIGRATION!

end
