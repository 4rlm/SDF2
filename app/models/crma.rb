class Crma < ApplicationRecord

  has_many :crmcs
  accepts_nested_attributes_for :crmcs

  ## Will have to change this so crma is not unique.  Uniqueness of crma AND act_id, so it can act like a join table.
  validates_uniqueness_of :crma, allow_blank: false, allow_nil: false

end
