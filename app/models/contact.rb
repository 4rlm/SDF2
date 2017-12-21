class Contact < ApplicationRecord

  attribute :full_name, :string
  before_validation :full_name

  def full_name
    [last_name, first_name].compact.join(',')
  end

  # belongs_to :account
  # belongs_to :account, inverse_of: :contacts
  # validates_presence_of :account
  belongs_to :account, inverse_of: :contacts, optional: true
  # accepts_nested_attributes_for :account

  has_many :contact_descriptions, dependent: :destroy
  has_many :descriptions, through: :contact_descriptions
  accepts_nested_attributes_for :contact_descriptions, :descriptions

  has_many :contact_titles, dependent: :destroy
  has_many :titles, through: :contact_titles
  accepts_nested_attributes_for :contact_titles, :titles

  has_many :phonings, as: :phonable
  has_many :phones, through: :phonings
  accepts_nested_attributes_for :phonings, :phones

  has_many :webings, as: :webable
  has_many :webs, through: :webings
  accepts_nested_attributes_for :webings, :webs

  validates_uniqueness_of :crm_cont_num, allow_blank: true, allow_nil: true

end
