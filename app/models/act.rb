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
  has_many :act_activities, dependent: :destroy

  accepts_nested_attributes_for :act_webs, :webs, :conts, :links, :brands, :act_activities

  def full_address
    self.full_address = [street, city, state, zip].compact.join(', ')
  end

  def track_act_change
    self.adr_changed = Time.now if full_address_changed?
    self.act_changed = Time.now if act_name_changed?
  end

  scope :web_is_cop_or_franchise, -> {joins(:webs).merge(Web.is_cop_or_franchise)}
  scope :is_valid_gp, ->{ where.not(gp_id: nil) }

  scope :created_between, lambda {|start_date, end_date| where("created_at >= ? AND created_at <= ?", start_date, end_date )}
  scope :adr_changed_between, lambda {|start_date, end_date| where("adr_changed >= ? AND adr_changed <= ?", start_date, end_date )}
  scope :act_changed_between, lambda {|start_date, end_date| where("act_changed >= ? AND act_changed <= ?", start_date, end_date )}
  scope :ax_date_between, lambda {|start_date, end_date| where("ax_date >= ? AND ax_date <= ?", start_date, end_date )}


  # created_at TALLY SCOPES
  # scope :created_between_days_45_35, -> {where("created_at >= ? AND created_at <= ?", 45.days.ago, 35.days.ago )}
  scope :created_between_week_1_0, -> {where("created_at >= ? AND created_at <= ?", 1.week.ago, Time.now )}
  scope :created_between_week_2_1, -> {where("created_at >= ? AND created_at <= ?", 2.weeks.ago, 1.week.ago )}
  scope :created_between_week_3_2, -> {where("created_at >= ? AND created_at <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :created_between_week_4_3, -> {where("created_at >= ? AND created_at <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :created_between_mo_2_1, -> {where("created_at >= ? AND created_at <= ?", 2.months.ago, 1.month.ago )}
  scope :created_between_mo_3_2, -> {where("created_at >= ? AND created_at <= ?", 3.months.ago, 2.month.ago )}

end
