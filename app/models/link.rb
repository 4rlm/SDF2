class Link < ApplicationRecord

  has_many :web_links, dependent: :delete_all
  has_many :webs, through: :web_links
  accepts_nested_attributes_for :web_links, :webs

end
