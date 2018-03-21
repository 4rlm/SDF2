class Cont < ApplicationRecord
  acts_as_favoritable ## Allows Model to be Favorited by users.

  # validates :full_name, presence: true, case_sensitive: false, :uniqueness => { :scope => [:web_id] }
  # validates :full_name, :uniqueness => { :scope => [:web_id] }

  validates_presence_of :web
  belongs_to :web, inverse_of: :conts, optional: true
  has_many :acts, through: :web
  has_many :links, through: :web
  has_many :brands, through: :web

  has_many :exportings, as: :exportable
  has_many :exports, through: :exportings

end
