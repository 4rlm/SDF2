class User < ApplicationRecord

  validates_presence_of :first_name, :last_name, :phone, presence: true, on: :create # which won't validate presence of name on update action

  # Additional Devise Modules: :omniauthable, :validatable, :confirmable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :timeoutable, :lockable

  has_many :exports, dependent: :destroy
  has_many :queries, dependent: :destroy

  # has_many :activities, dependent: :destroy

  has_many :act_activities, dependent: :destroy
  has_many :acts, through: :act_activities

  has_many :cont_activities, dependent: :destroy
  has_many :conts, through: :cont_activities

  has_many :web_activities, dependent: :destroy
  has_many :webs, through: :web_activities

end
