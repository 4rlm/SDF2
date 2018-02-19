class Link < ApplicationRecord

  has_many :act_links, dependent: :destroy
  has_many :acts, through: :act_links
  accepts_nested_attributes_for :act_links, :acts

end
