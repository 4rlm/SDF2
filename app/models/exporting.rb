class Exporting < ApplicationRecord
  belongs_to :export
  belongs_to :exportable, polymorphic: true

  validates :export_id, :uniqueness => { :scope => [:exportable_type, :exportable_id] }
end
