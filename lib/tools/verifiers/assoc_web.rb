module AssocWeb
  ## Ensures web url objects with redirect url columns have had their associations tied to new url web obj (for links, texts, acts, templates).  First need to verify all possible associations web could have.

  ## start_assoc_web is for one-off db query and update.  Not needed!
  #CALL: AssocWeb.start_assoc_web
  # def self.start_assoc_web
  #   query = Web.where.not(fwd_url: nil).order("updated_at DESC").pluck(:id)
  #   query.each do |id|
  #     web_obj = Web.find(id)
  #     fwd_web_obj = Web.find_by(url: web_obj.fwd_url)
  #     transfer_web_associations(web_obj, fwd_web_obj)
  #   end
  # end


  #Gets the associations of the current web obj and saves them to FWD web obj.
  #CALL: AssocWeb.transfer_web_associations(web_obj, fwd_web_obj)
  def self.transfer_web_associations(web_obj, fwd_web_obj)
    models = %w(act cont link)
    models.each do |model|
      associations = web_obj.send(model.pluralize)
      associations.each { |obj| Mig.new.create_obj_parent_assoc(model, obj, fwd_web_obj) } if associations.present?
    end

    fwd_web_obj.update(url_sts: 'Valid', url_date: Time.now, timeout: 0)
    web_obj.update(fwd_web_id: fwd_web_obj.id, url_sts: 'FWD', url_date: Time.now, timeout: 0)

    Act.where(url: fwd_web_obj.url).each do |act|
      act.webs << fwd_web_obj if !act.webs.include?(fwd_web_obj)
    end

  end
end

#Call: VerUrl.new.start_ver_url
