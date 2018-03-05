class Act < ApplicationRecord

  before_save :full_address, :track_act_change

  # has_many :conts, inverse_of: :act, optional: true
  validates_uniqueness_of :gp_id, allow_blank: true, allow_nil: true

  # has_one :act_web, dependent: :destroy
  # has_one :web, through: :act_web
  has_many :act_webs, dependent: :destroy
  has_many :webs, through: :act_webs

  has_many :conts, through: :webs
  has_many :links, through: :webs
  has_many :brands, through: :webs

  accepts_nested_attributes_for :act_webs, :webs, :conts, :links, :brands

  def full_address
    self.full_address = [street, city, state, zip].compact.join(', ')
  end

  def track_act_change
    self.adr_changed = Time.now if full_address_changed?
    self.act_changed = Time.now if act_name_changed?
  end

  scope :web_is_cop_or_franchise, -> {joins(:webs).merge(Web.is_cop_or_franchise)}

end
