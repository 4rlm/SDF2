require 'uni_account_migrator'
require 'uni_contact_migrator'
require 'uni_web_migrator'

class AboutMigrator
  # extend ActiveSupport::Concern
  include UniAccountMigrator
  include UniContactMigrator
  include UniWebMigrator

  ### To call any of the three UniMigrator Modules ###
  #Call: AboutMigrator.new.migrate_uni_accounts
  #Call: AboutMigrator.new.migrate_uni_contacts
  #Call: AboutMigrator.new.migrate_uni_webs

  ### BELOW METHODS BEING USED IN EACH UNI_MIGRATOR MODULE ###

  def save_simple_association(model, parent, attr_hash)
    obj = model.classify.constantize.find_or_create_by(attr_hash)
    parent.send(model.pluralize.to_sym) << obj if (obj && !parent.send(model.pluralize.to_sym).include?(obj))

    # if phone.present?
    #   phone_obj = Phone.find_or_create_by(phone: phone)
    #   account.phones << phone_obj if !account.phones.include?(phone_obj)
    # end
    return obj if obj
  end


  def save_complex_association(model, parent, attr_hash, obj_hash)
    obj = model.classify.constantize.find_by(attr_hash)
    obj.present? ? update_obj_if_changed(obj_hash, obj) : obj = model.classify.constantize.create(obj_hash)
    parent.send(model.pluralize.to_sym) << obj if (obj && !parent.send(model.pluralize.to_sym).include?(obj))

    # if url.present?
    #   web_obj = Web.find_by(url: url)
    #   web_obj.present? ? update_obj_if_changed(web_hash, web_obj) : web_obj = Web.create(web_hash)
    #   contact.webs << web_obj if !contact.webs.include?(web_obj)
    # end
    return obj if obj
  end


  def update_obj_if_changed(hash, obj)
    hash.delete_if { |k, v| v.nil? }

    if hash['updated_at']
      hash.delete('updated_at')
      obj.record_timestamps = false
    end

    updated_attributes = (hash.values) - (obj.attributes.values)
    obj.update_attributes(hash) if !updated_attributes.empty?
  end


  def validate_hash(cols, hash)
    # cols.map!(&:to_sym)
    keys = hash.keys
    keys.each { |key| hash.delete(key) if !cols.include?(key) }
    return hash
  end


end
