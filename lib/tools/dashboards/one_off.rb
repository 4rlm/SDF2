module OneOff

  ## Migrates data from Act to Web.  Will later remove from Act.
  #CALL: OneOff.act_to_web
  def self.act_to_web
    act_ids = Act.select(:id).where.not(url: nil).pluck(:id)
    act_ids.each do |act_id|
      act = Act.find(act_id)
      web = Web.find_or_create_by(url: act.url)

      web.update(url: act.url, url_sts_code: act.url_sts_code, temp_name: act.temp_name, tmp_date: act.tmp_date, gp_date: act.gp_date, page_date: act.page_date, url_date: act.url_date, cs_date: act.cs_date, url_sts: act.url_sts, temp_sts: act.temp_sts, page_sts: act.page_sts, cs_sts: act.cs_sts)


      act_conts = act.conts
      act_conts.each do |act_cont|
        web.conts << act_cont if !web.conts.present?
      end


      act_links = act.links
      act_links.each do |act_link|
        web.links << act_link if !web.links.present?
      end

    end
  end




end
