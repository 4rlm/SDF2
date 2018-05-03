class Tally < ApplicationRecord

  # serialize :ransack_query, Hash
  # serialize :acts, HashSerializer
  # serialize :links, HashSerializer
  # serialize :act_links, HashSerializer
  # store_accessor :acts, :links, :act_links

  def self.generate_csv_tallies(current_user, tally_hsh)
    TalliesTool.new.delay(priority: 0).generate_csv_tallies(current_user, tally_hsh)
  end


  def self.follow_hide_tallies(action, current_user, tally_hsh)
    if action == 'follow'
      TalliesTool.new.delay(priority: 0).follow_all_tallies(current_user, tally_hsh)
    elsif action == 'unfollow'
      TalliesTool.new.delay(priority: 0).unfollow_all_tallies(current_user, tally_hsh)
    elsif action == 'hide'
      TalliesTool.new.delay(priority: 0).hide_all_tallies(current_user, tally_hsh)
    elsif action == 'unhide'
      TalliesTool.new.delay(priority: 0).unhide_all_tallies(current_user, tally_hsh)
    end
  end

end
