class Act < ApplicationRecord
  before_save :full_address, :track_act_change

  # has_many :conts, inverse_of: :act, optional: true
  validates_uniqueness_of :gp_id, allow_blank: true, allow_nil: true

  has_many :act_webs, dependent: :delete_all
  # has_many :webs, through: :act_webs
  has_many :webs, -> { distinct }, through: :act_webs
  # has_many :conts, through: :webs
  has_many :conts, -> { distinct }, through: :webs

  # has_many :links, through: :webs
  has_many :links, -> { distinct }, through: :webs

  # has_many :brands, through: :webs
  has_many :brands, -> { distinct }, through: :webs

  has_many :act_activities, dependent: :delete_all

  accepts_nested_attributes_for :act_webs, :webs, :conts, :links, :brands, :act_activities

  scope :web_is_cop_or_franchise, -> {joins(:webs).merge(Web.is_cop_or_franchise)}
  scope :is_valid_gp, ->{ where.not(gp_id: nil) }

  scope :has_id, -> { where.not(id: nil) }
  scope :with_webs, -> { joins(:webs).merge(Web.has_id) }
  scope :by_id, ->(id) { where(id: id) }
  # acts = Act.by_id(act_objs)
  scope :by_web, ->(web) { joins(:webs).merge(Web.by_id(web)) }
  # acts = Act.by_web(webs)


  def brands_to_string
    self[:brands_to_string]
    brands = self.brands&.map(&:brand_name)&.sort&.join(', ')
  end


  def attribute_vals(act_cols)
    self[:attribute_vals]
    values = self.attributes.slice(*act_cols).values
  end


  # LAMBDA TALLY SCOPES
  scope :created_between, lambda {|start_date, end_date| where("created_at >= ? AND created_at <= ?", start_date, end_date )}
  scope :adr_changed_between, lambda {|start_date, end_date| where("adr_changed >= ? AND adr_changed <= ?", start_date, end_date )}
  scope :act_changed_between, lambda {|start_date, end_date| where("act_changed >= ? AND act_changed <= ?", start_date, end_date )}
  scope :ax_date_between, lambda {|start_date, end_date| where("ax_date >= ? AND ax_date <= ?", start_date, end_date )}

  # created_at TALLY SCOPES
  # scope :created_between_days_45_35, -> {where("created_at >= ? AND created_at <= ?", 45.days.ago, 35.days.ago )}
  scope :created_between_wk_0_1, -> {where("created_at >= ? AND created_at <= ?", 1.week.ago, Time.now )}
  scope :created_between_wk_1_2, -> {where("created_at >= ? AND created_at <= ?", 2.weeks.ago, 1.week.ago )}
  scope :created_between_wk_2_3, -> {where("created_at >= ? AND created_at <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :created_between_wk_3_4, -> {where("created_at >= ? AND created_at <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :created_between_mo_1_2, -> {where("created_at >= ? AND created_at <= ?", 2.months.ago, 1.month.ago )}
  scope :created_between_mo_2_3, -> {where("created_at >= ? AND created_at <= ?", 3.months.ago, 2.month.ago )}

  # adr_changed TALLY SCOPES
  scope :adr_changed_between_wk_0_1, -> {where("adr_changed >= ? AND adr_changed <= ?", 1.week.ago, Time.now )}
  scope :adr_changed_between_wk_1_2, -> {where("adr_changed >= ? AND adr_changed <= ?", 2.weeks.ago, 1.week.ago )}
  scope :adr_changed_between_wk_2_3, -> {where("adr_changed >= ? AND adr_changed <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :adr_changed_between_wk_3_4, -> {where("adr_changed >= ? AND adr_changed <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :adr_changed_between_mo_1_2, -> {where("adr_changed >= ? AND adr_changed <= ?", 2.months.ago, 1.month.ago )}
  scope :adr_changed_between_mo_2_3, -> {where("adr_changed >= ? AND adr_changed <= ?", 3.months.ago, 2.month.ago )}

  # act_changed TALLY SCOPES
  scope :act_changed_between_wk_0_1, -> {where("act_changed >= ? AND act_changed <= ?", 1.week.ago, Time.now )}
  scope :act_changed_between_wk_1_2, -> {where("act_changed >= ? AND act_changed <= ?", 2.weeks.ago, 1.week.ago )}
  scope :act_changed_between_wk_2_3, -> {where("act_changed >= ? AND act_changed <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :act_changed_between_wk_3_4, -> {where("act_changed >= ? AND act_changed <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :act_changed_between_mo_1_2, -> {where("act_changed >= ? AND act_changed <= ?", 2.months.ago, 1.month.ago )}
  scope :act_changed_between_mo_2_3, -> {where("act_changed >= ? AND act_changed <= ?", 3.months.ago, 2.month.ago )}


  # ax_date TALLY SCOPES
  scope :ax_date_between_wk_0_1, -> {where("ax_date >= ? AND ax_date <= ?", 1.week.ago, Time.now )}
  scope :ax_date_between_wk_1_2, -> {where("ax_date >= ? AND ax_date <= ?", 2.weeks.ago, 1.week.ago )}
  scope :ax_date_between_wk_2_3, -> {where("ax_date >= ? AND ax_date <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :ax_date_between_wk_3_4, -> {where("ax_date >= ? AND ax_date <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :ax_date_between_mo_1_2, -> {where("ax_date >= ? AND ax_date <= ?", 2.months.ago, 1.month.ago )}
  scope :ax_date_between_mo_2_3, -> {where("ax_date >= ? AND ax_date <= ?", 3.months.ago, 2.month.ago )}


  def full_address
    self.full_address = [street, city, state, zip].compact.join(', ')
  end

  def track_act_change
    self.adr_changed = Time.now if full_address_changed?
    self.act_changed = Time.now if act_name_changed?
  end

  def self.generate_csv_acts(params, current_user)
    ActCsvTool.new.delay(priority: 0).start_act_webs_csv_and_log(params, current_user)
  end


end
