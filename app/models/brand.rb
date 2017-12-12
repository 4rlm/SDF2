class Brand < ApplicationRecord

  has_many :brandings
  has_many :accounts, through: :brandings, source: :brandable, source_type: :Account
  
end
