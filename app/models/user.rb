class User < ApplicationRecord

  validates_presence_of :first_name, :last_name, :phone, presence: true, on: :create # which won't validate presence of name on update action

  # Additional Devise Modules: :omniauthable, :validatable, :confirmable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :timeoutable, :lockable

  has_many :exports, dependent: :delete_all
  has_many :queries, dependent: :delete_all

  # has_many :activities, dependent: :delete_all

  has_many :act_activities, dependent: :delete_all
  has_many :acts, through: :act_activities

  has_many :cont_activities, dependent: :delete_all
  has_many :conts, through: :cont_activities

  has_many :web_activities, dependent: :delete_all
  has_many :webs, through: :web_activities


  # User.where(id: 1).followed_web_ids
  scope :followed_web_ids, ->{ joins(:web_activities).merge(WebActivity.followed).pluck(:web_id) }
  scope :unfollowed_web_ids, ->{ joins(:web_activities).merge(WebActivity.unfollowed).pluck(:web_id) }
  scope :hidden_web_ids, ->{ joins(:web_activities).merge(WebActivity.hidden).pluck(:web_id) }
  scope :unhidden_web_ids, ->{ joins(:web_activities).merge(WebActivity.unhidden).pluck(:web_id) }


  enum role: [:pending, :basic, :intermediate, :advanced, :admin]

  def init
    self.role ||= :pending if self.has_attribute? :role
  end

  # scope :is_franchise, ->{ joins(:brands).merge(Brand.is_franchise) }

end
