class Templating < ApplicationRecord

  belongs_to :templatable, polymorphic: true
  belongs_to :template

  accepts_nested_attributes_for :template

  validates :template_id, :uniqueness => { :scope => [:templatable_type, :templatable_id] } #=> ALSO IN MIGRATION!

end
