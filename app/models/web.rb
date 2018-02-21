class Web < ApplicationRecord
  validates_uniqueness_of :url, allow_blank: false, allow_nil: false

  has_many :conts
  accepts_nested_attributes_for :conts

  has_many :web_links, dependent: :destroy
  has_many :links, through: :web_links
  accepts_nested_attributes_for :web_links, :links

  has_many :act_webs, dependent: :destroy
  has_many :acts, through: :act_webs

  accepts_nested_attributes_for :act_webs, :acts
end
