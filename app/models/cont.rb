class Cont < ApplicationRecord

  belongs_to :web, inverse_of: :conts, optional: true
  validates_presence_of :web
  validates :full_name, :uniqueness => { :scope => [:web_id] } #=> ALSO IN MIGRATION!
  
end
