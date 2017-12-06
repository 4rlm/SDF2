class Webing < ApplicationRecord
  belongs_to :webable, polymorphic: true
  belongs_to :web

  accepts_nested_attributes_for :web

  validates :web_id, :uniqueness => { :scope => [:webable_type, :webable_id] } #=> ALSO IN MIGRATION!

end
