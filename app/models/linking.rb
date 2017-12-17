class Linking < ApplicationRecord
  belongs_to :linkable, polymorphic: true
  belongs_to :link

  # accepts_nested_attributes_for :link
  accepts_nested_attributes_for :link, allow_destroy: true

  validates :link_id, :uniqueness => { :scope => [:linkable_type, :linkable_id] } #=> ALSO IN MIGRATION!

end
