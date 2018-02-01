class Web < ApplicationRecord

  has_many :webings
  has_many :acts, through: :webings, source: :webable, source_type: :Act
  has_many :conts, through: :webings, source: :webable, source_type: :Cont
  has_many :whos, through: :webings, source: :webable, source_type: :Who

  has_many :textings, as: :textable
  has_many :texts, through: :textings
  accepts_nested_attributes_for :textings, :texts

  has_many :linkings, as: :linkable
  has_many :links, through: :linkings
  accepts_nested_attributes_for :linkings, :links

  validates_uniqueness_of :url, allow_blank: false, allow_nil: false
  # validates :url, uniqueness: true
  # accepts_nested_attributes_for :phone

  UNRANSACKABLE_ATTRIBUTES = %w(id urlx false fwd_web_id fwd_url url_ver_sts sts_code url_ver_date tmp_sts temp_name tmp_date slink_sts llink_sts stext_sts ltext_sts pge_date as_sts as_date cs_sts cs_date created_at updated_at)
  def self.ransackable_attributes auth_object = nil
    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end


end
