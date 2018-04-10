class Web < ApplicationRecord
  # include WebCsvTool
  before_save :track_web_change, :prevent_valid_wx

  validates_uniqueness_of :url, allow_blank: false, allow_nil: false
  has_many :conts

  has_many :web_links, dependent: :destroy
  has_many :links, through: :web_links

  has_many :web_brands, dependent: :destroy
  has_many :brands, through: :web_brands

  has_many :act_webs, dependent: :destroy
  has_many :acts, through: :act_webs
  has_many :act_activities, through: :acts

  has_many :web_activities, dependent: :destroy
  has_many :users, through: :web_activities

  accepts_nested_attributes_for :act_webs, :acts, :conts, :web_links, :links, :web_brands, :brands, :web_activities

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
  

  scope :created_between, lambda {|start_date, end_date| where("created_at >= ? AND created_at <= ?", start_date, end_date )}
  scope :web_changed_between, lambda {|start_date, end_date| where("web_changed >= ? AND web_changed <= ?", start_date, end_date )}
  scope :wx_date_between, lambda {|start_date, end_date| where("wx_date >= ? AND wx_date <= ?", start_date, end_date )}

  # created_at TALLY SCOPES
  # scope :created_between_days_45_35, -> {where("created_at >= ? AND created_at <= ?", 45.days.ago, 35.days.ago )}
  scope :created_between_wk_0_1, -> {where("created_at >= ? AND created_at <= ?", 1.week.ago, Time.now )}
  scope :created_between_wk_1_2, -> {where("created_at >= ? AND created_at <= ?", 2.weeks.ago, 1.week.ago )}
  scope :created_between_wk_2_3, -> {where("created_at >= ? AND created_at <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :created_between_wk_3_4, -> {where("created_at >= ? AND created_at <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :created_between_mo_1_2, -> {where("created_at >= ? AND created_at <= ?", 2.months.ago, 1.month.ago )}
  scope :created_between_mo_2_3, -> {where("created_at >= ? AND created_at <= ?", 3.months.ago, 2.month.ago )}

  # web_changed TALLY SCOPES
  scope :web_changed_between_wk_0_1, -> {where("web_changed >= ? AND web_changed <= ?", 1.week.ago, Time.now )}
  scope :web_changed_between_wk_1_2, -> {where("web_changed >= ? AND web_changed <= ?", 2.weeks.ago, 1.week.ago )}
  scope :web_changed_between_wk_2_3, -> {where("web_changed >= ? AND web_changed <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :web_changed_between_wk_3_4, -> {where("web_changed >= ? AND web_changed <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :web_changed_between_mo_1_2, -> {where("web_changed >= ? AND web_changed <= ?", 2.months.ago, 1.month.ago )}
  scope :web_changed_between_mo_2_3, -> {where("web_changed >= ? AND web_changed <= ?", 3.months.ago, 2.month.ago )}

  # wx_date TALLY SCOPES
  scope :wx_date_between_wk_0_1, -> {where("wx_date >= ? AND wx_date <= ?", 1.week.ago, Time.now )}
  scope :wx_date_between_wk_1_2, -> {where("wx_date >= ? AND wx_date <= ?", 2.weeks.ago, 1.week.ago )}
  scope :wx_date_between_wk_2_3, -> {where("wx_date >= ? AND wx_date <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :wx_date_between_wk_3_4, -> {where("wx_date >= ? AND wx_date <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :wx_date_between_mo_1_2, -> {where("wx_date >= ? AND wx_date <= ?", 2.months.ago, 1.month.ago )}
  scope :wx_date_between_mo_2_3, -> {where("wx_date >= ? AND wx_date <= ?", 3.months.ago, 2.month.ago )}

end
