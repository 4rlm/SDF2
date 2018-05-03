class Query < ApplicationRecord
  # serialize :ransack_query, Hash
  belongs_to :user

  # Query below:
  # user.queries.web_queries
  scope :act_queries, ->{ where(mod_name: 'Act').order("updated_at DESC") }
  scope :cont_queries, ->{ where(mod_name: 'Cont').order("updated_at DESC") }
  scope :web_queries, ->{ where(mod_name: 'Web').order("updated_at DESC") }


  def self.follow_hide_queries(action, query_id, current_user)
    if action == 'follow'
      QueriesTool.new.delay(priority: 0).follow_all_queries(current_user, query_id)
    elsif action == 'unfollow'
      QueriesTool.new.delay(priority: 0).unfollow_all_queries(current_user, query_id)
    elsif action == 'hide'
      QueriesTool.new.delay(priority: 0).hide_all_queries(current_user, query_id)
    elsif action == 'unhide'
      QueriesTool.new.delay(priority: 0).unhide_all_queries(current_user, query_id)
    end
  end

end

# JSON.parse( h.to_json, {:symbolize_names => true} )
