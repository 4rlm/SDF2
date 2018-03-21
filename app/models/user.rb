class User < ApplicationRecord
  acts_as_favoritor ## Allows Users to add Acts, Conts, Webs to Favorites.

  validates_presence_of :first_name, :last_name, :phone, presence: true, on: :create # which won't validate presence of name on update action

  # Additional Devise Modules: :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable, :timeoutable, :lockable

  has_many :exports, dependent: :destroy
end
