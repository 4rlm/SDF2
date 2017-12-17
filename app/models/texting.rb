class Texting < ApplicationRecord
  belongs_to :textable, polymorphic: true
  belongs_to :text

  # accepts_nested_attributes_for :text
  accepts_nested_attributes_for :text, allow_destroy: true

  validates :text_id, :uniqueness => { :scope => [:textable_type, :textable_id] } #=> ALSO IN MIGRATION!

end
