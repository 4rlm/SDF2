class Cont < ApplicationRecord

  # attribute :full_name, :string
  # before_validation :full_name
  #
  # def full_name
  #   [last_name, first_name].compact.join(',')
  # end

  # belongs_to :act
  # belongs_to :act, inverse_of: :conts
  # validates_presence_of :act
  belongs_to :act, inverse_of: :conts, optional: true
  # accepts_nested_attributes_for :act

  has_many :phonings, as: :phonable
  has_many :phones, through: :phonings
  accepts_nested_attributes_for :phonings, :phones

  has_many :webings, as: :webable
  has_many :webs, through: :webings
  accepts_nested_attributes_for :webings, :webs

end
