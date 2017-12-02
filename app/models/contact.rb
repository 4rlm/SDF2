class Contact < ApplicationRecord
  # belongs_to :account

  belongs_to :account, inverse_of: :contacts
  # belongs_to :account, optional: true

  # validates_presence_of :account




  has_many :phonings, as: :phonable
  has_many :phones, through: :phonings

  has_many :contact_descriptions, dependent: :destroy
  has_many :descriptions, through: :contact_descriptions

  has_many :contact_titles, dependent: :destroy
  has_many :titles, through: :contact_titles

  validates_uniqueness_of :crm_cont_num, allow_blank: true, allow_nil: true

end
