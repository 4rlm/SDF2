class Query < ApplicationRecord
  # serialize :ransack_query, Hash
  belongs_to :user

  # Query below:
  # user.queries.web_queries
  scope :act_queries, ->{ where(mod_name: 'Act').order("updated_at DESC") }
  scope :cont_queries, ->{ where(mod_name: 'Cont').order("updated_at DESC") }
  scope :web_queries, ->{ where(mod_name: 'Web').order("updated_at DESC") }

end

# JSON.parse( h.to_json, {:symbolize_names => true} )
