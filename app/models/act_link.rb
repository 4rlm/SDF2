class ActLink < ApplicationRecord
    belongs_to :act
    belongs_to :link

    accepts_nested_attributes_for :link
    validates_uniqueness_of :act, scope: :link_id
end
