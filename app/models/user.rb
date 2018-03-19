class User < ApplicationRecord
  has_secure_password
  validates :username, :email, :password, presence: true
  validates :email, uniqueness: true

  has_many :tracks, dependent: :destroy
  has_one :profile, dependent: :destroy
end
