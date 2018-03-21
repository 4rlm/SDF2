class Exporting < ApplicationRecord
  belongs_to :exportable, polymorphic: true
  belongs_to :export

  validates :export_id, :uniqueness => { :scope => [:exportable_type, :exportable_id] }
end
