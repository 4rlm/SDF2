module WebAssociator
  ## Ensures web url objects with redirect url columns have had their associations tied to new url web obj (for links, texts, accounts, templates).  First need to verify all possible associations web could have.

  #CALL: WebAssociator.start_web_associator
  def self.start_web_associator
    raw_query = Web.where.not(redirect_url: nil).order("updated_at DESC").pluck(:id)

    raw_query.each do |id|
      web_obj = Web.find(id)
      transfer_web_associations(web_obj)
    end
  end


  #Gets the associations of the current web obj and saves them to redirected web obj.
  #CALL: WebAssociator.transfer_web_associations(web_obj)
  def self.transfer_web_associations(web_obj)
    redirect_obj = Web.find_by(redirect_url: web_obj.redirect_url)
    web_obj.update_attributes(archived: TRUE, web_status: 'Updated', url_redirect_id: redirect_obj.id)

    models = %w(account template link text who)
    models.each do |model|
      associations = web_obj.send(model.pluralize)
      associations.each { |obj| Migrator.new.create_obj_parent_assoc(model, obj, redirect_obj) } if associations.present?
    end
  end


end