class Cont < ApplicationRecord
  validates :full_name, :uniqueness => { :scope => [:act_id] } #=> ALSO IN MIGRATION!

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

end
