class Cont < ApplicationRecord
  # validates :full_name, presence: true, case_sensitive: false, :uniqueness => { :scope => [:web_id] }
  # validates :full_name, :uniqueness => { :scope => [:web_id] }

  validates_presence_of :web
  belongs_to :web, inverse_of: :conts, optional: true
  has_many :acts, through: :web
  has_many :links, through: :web
  has_many :brands, through: :web

  has_many :cont_activities, dependent: :destroy
  accepts_nested_attributes_for :cont_activities

end
