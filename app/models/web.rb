class Web < ApplicationRecord

  before_save :track_web_change, :prevent_valid_wx

  validates_uniqueness_of :url, allow_blank: false, allow_nil: false
  has_many :conts

  has_many :web_links, dependent: :destroy
  has_many :links, through: :web_links

  has_many :web_brands, dependent: :destroy
  has_many :brands, through: :web_brands

  has_many :act_webs, dependent: :destroy
  has_many :acts, through: :act_webs

  accepts_nested_attributes_for :act_webs, :acts, :conts, :web_links, :links, :web_brands, :brands

  def track_web_change
    self.web_changed = Time.now if url_changed? || fwd_url_changed? || wx_date_changed?
  end

  def prevent_valid_wx
    self.wx_date = nil if url_sts == 'Valid'
  end

  scope :is_franchise, ->{ joins(:brands).merge(Brand.is_franchise) }
  scope :is_cop, ->{ where(cop: true) }
  scope :is_cop_or_franchise, -> {is_franchise.merge(is_cop)}
  # merged = Web.is_cop.merge(Web.is_franchise)


  # scope :unsent, -> { joins(:user).merge(User.unsent) }
  # scope :sent, -> { joins(:user).merge(User.sent) }
  # scope :accepted, -> { joins(:user).merge(User.accepted) }
  #
  # scope :containing_blog_keyword_with_id_greater_than, ->(id) { contains_blog_keyword.or(id_greater_than(id)) }


end
