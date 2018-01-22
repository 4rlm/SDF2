class Crmc < ApplicationRecord

  # belongs_to :crma
  # belongs_to :crma, inverse_of: :crmcs
  # validates_presence_of :crma
  belongs_to :crma, inverse_of: :crmcs, optional: true

  validates_uniqueness_of :crmc, allow_blank: false, allow_nil: false
  # validates_uniqueness_of :crmc

end
