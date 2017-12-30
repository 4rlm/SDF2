class Brand < ApplicationRecord

  has_many :brandings
  has_many :acts, through: :brandings, source: :brandable, source_type: :Act

end
