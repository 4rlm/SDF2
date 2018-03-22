class Web < ApplicationRecord
  acts_as_favoritable ## Allows Model to be Favorited by users.

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

  has_many :exportings, as: :exportable
  has_many :exports, through: :exportings
  # has_many :exports, as: :exportable, dependent: :destroy

  def track_web_change
    self.web_changed = Time.now if url_changed? || fwd_url_changed? || wx_date_changed?
  end

  def prevent_valid_wx
    self.wx_date = nil if url_sts == 'Valid'
  end

  scope :is_franchise, ->{ joins(:brands).merge(Brand.is_franchise) }
  scope :act_is_valid_gp, ->{ joins(:acts).merge(Act.is_valid_gp) }
  scope :is_cop, ->{ where(cop: true) }
  scope :is_cop_or_franchise, -> {is_franchise.merge(is_cop)}
  scope :is_not_wx, ->{ where(wx_date: nil) }
  scope :web_act_state, ->{ joins(:acts).merge(Act.where.not(state: nil)) }

  scope :web_act_gp_sts, ->{ joins(:acts).merge(Act.where.not(gp_sts: nil)) }
  scope :web_act_gp_indus, ->{ joins(:acts).merge(Act.where.not(gp_indus: nil)) }






  # merged = Web.is_cop.merge(Web.is_franchise)

  # scope :act_names, ->(ids_ary) { joins(:acts).where("locations.id" => ids_ary) }


  # scope :unsent, -> { joins(:user).merge(User.unsent) }
  # scope :sent, -> { joins(:user).merge(User.sent) }
  # scope :accepted, -> { joins(:user).merge(User.accepted) }
  #
  # scope :containing_blog_keyword_with_id_greater_than, ->(id) { contains_blog_keyword.or(id_greater_than(id)) }


end
