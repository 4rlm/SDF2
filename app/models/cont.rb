class Cont < ApplicationRecord
  # validates :full_name, presence: true, case_sensitive: false, :uniqueness => { :scope => [:web_id] }
  # validates :full_name, :uniqueness => { :scope => [:web_id] }

  validates_presence_of :web
  belongs_to :web, inverse_of: :conts, optional: true
  has_many :links, through: :web
  has_many :brands, through: :web

  has_many :acts, through: :web
  has_many :web_activities, through: :web
  has_many :act_activities, through: :acts

  has_many :cont_activities, dependent: :delete_all
  accepts_nested_attributes_for :cont_activities, :web_activities, :act_activities


  def self.generate_csv_conts(params, current_user)
    ContCsvTool.new.delay(priority: 0).start_cont_web_csv_and_log(params, current_user)
  end

  # scope :is_email, ->{ where.not(email: nil) }
  scope :created_between, lambda {|start_date, end_date| where("created_at >= ? AND created_at <= ?", start_date, end_date )}
  scope :cx_date_between, lambda {|start_date, end_date| where("cx_date >= ? AND cx_date <= ?", start_date, end_date )}
  scope :job_changed_between, lambda {|start_date, end_date| where("job_changed >= ? AND job_changed <= ?", start_date, end_date )}
  scope :cont_changed_between, lambda {|start_date, end_date| where("cont_changed >= ? AND cont_changed <= ?", start_date, end_date )}
  scope :email_changed_between, lambda {|start_date, end_date| where("email_changed >= ? AND email_changed <= ?", start_date, end_date )}


  # created_at TALLY SCOPES
  # scope :created_between_days_45_35, -> {where("created_at >= ? AND created_at <= ?", 45.days.ago, 35.days.ago )}
  scope :created_between_wk_0_1, -> {where("created_at >= ? AND created_at <= ?", 1.week.ago, Time.now )}
  scope :created_between_wk_1_2, -> {where("created_at >= ? AND created_at <= ?", 2.weeks.ago, 1.week.ago )}
  scope :created_between_wk_2_3, -> {where("created_at >= ? AND created_at <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :created_between_wk_3_4, -> {where("created_at >= ? AND created_at <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :created_between_mo_1_2, -> {where("created_at >= ? AND created_at <= ?", 2.months.ago, 1.month.ago )}
  scope :created_between_mo_2_3, -> {where("created_at >= ? AND created_at <= ?", 3.months.ago, 2.month.ago )}

  # cx_date TALLY SCOPES
  scope :cx_between_wk_0_1, -> {where("cx_date >= ? AND cx_date <= ?", 1.week.ago, Time.now )}
  scope :cx_between_wk_1_2, -> {where("cx_date >= ? AND cx_date <= ?", 2.weeks.ago, 1.week.ago )}
  scope :cx_between_wk_2_3, -> {where("cx_date >= ? AND cx_date <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :cx_between_wk_3_4, -> {where("cx_date >= ? AND cx_date <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :cx_between_mo_1_2, -> {where("cx_date >= ? AND cx_date <= ?", 2.months.ago, 1.month.ago )}
  scope :cx_between_mo_2_3, -> {where("cx_date >= ? AND cx_date <= ?", 3.months.ago, 2.month.ago )}

  # job_changed TALLY SCOPES
  scope :job_changed_between_wk_0_1, -> {where("job_changed >= ? AND job_changed <= ?", 1.week.ago, Time.now )}
  scope :job_changed_between_wk_1_2, -> {where("job_changed >= ? AND job_changed <= ?", 2.weeks.ago, 1.week.ago )}
  scope :job_changed_between_wk_2_3, -> {where("job_changed >= ? AND job_changed <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :job_changed_between_wk_3_4, -> {where("job_changed >= ? AND job_changed <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :job_changed_between_mo_1_2, -> {where("job_changed >= ? AND job_changed <= ?", 2.months.ago, 1.month.ago )}
  scope :job_changed_between_mo_2_3, -> {where("job_changed >= ? AND job_changed <= ?", 3.months.ago, 2.month.ago )}

  # cont_changed TALLY SCOPES
  scope :cont_changed_between_wk_0_1, -> {where("cont_changed >= ? AND cont_changed <= ?", 1.week.ago, Time.now )}
  scope :cont_changed_between_wk_1_2, -> {where("cont_changed >= ? AND cont_changed <= ?", 2.weeks.ago, 1.week.ago )}
  scope :cont_changed_between_wk_2_3, -> {where("cont_changed >= ? AND cont_changed <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :cont_changed_between_wk_3_4, -> {where("cont_changed >= ? AND cont_changed <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :cont_changed_between_mo_1_2, -> {where("cont_changed >= ? AND cont_changed <= ?", 2.months.ago, 1.month.ago )}
  scope :cont_changed_between_mo_2_3, -> {where("cont_changed >= ? AND cont_changed <= ?", 3.months.ago, 2.month.ago )}

  # email_changed TALLY SCOPES
  scope :email_changed_between_wk_0_1, -> {where("email_changed >= ? AND email_changed <= ?", 1.week.ago, Time.now )}
  scope :email_changed_between_wk_1_2, -> {where("email_changed >= ? AND email_changed <= ?", 2.weeks.ago, 1.week.ago )}
  scope :email_changed_between_wk_2_3, -> {where("email_changed >= ? AND email_changed <= ?", 3.weeks.ago, 2.weeks.ago )}
  scope :email_changed_between_wk_3_4, -> {where("email_changed >= ? AND email_changed <= ?", 4.weeks.ago, 3.weeks.ago )}
  scope :email_changed_between_mo_1_2, -> {where("email_changed >= ? AND email_changed <= ?", 2.months.ago, 1.month.ago )}
  scope :email_changed_between_mo_2_3, -> {where("email_changed >= ? AND email_changed <= ?", 3.months.ago, 2.month.ago )}

end
