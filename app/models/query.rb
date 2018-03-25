class Query < ApplicationRecord
  # serialize :ransack_query, Hash
  belongs_to :user

end

# JSON.parse( h.to_json, {:symbolize_names => true} )
