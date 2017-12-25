%w{uni_account_migrator uni_contact_migrator uni_web_migrator}.each { |x| require x }

class Migrator
  # extend ActiveSupport::Concern
  include UniAccountMigrator
  include UniContactMigrator
  include UniWebMigrator
  # include WebMigrator

  ### To call any of the three UniMigrator Modules ###
  #Call: Migrator.new.migrate_uni_accounts
  #Call: Migrator.new.migrate_uni_contacts
  #Call: Migrator.new.migrate_uni_webs

  ### CAREFUL!!! BELOW METHODS BEING USED IN EACH UNI_MIGRATOR MODULE ###

  ## Used for Tables where only one Attr matters, like Phone.phone
  def save_simple_obj(model, attr_hash)
    obj = model.classify.constantize.find_or_create_by(attr_hash)
    #Ex: phone_obj = Phone.find_or_create_by(phone: phone)
    return obj
  end


  ## Used for Tables where we need to first find by one attribute, then save or update several other attributes like Account or Contact.
  def save_complex_obj(model, attr_hash, obj_hash)
    obj_hash.delete_if { |key, value| value.blank? }
    obj = model.classify.constantize.find_by(attr_hash)
    obj.present? ? update_obj_if_changed(obj_hash, obj) : obj = model.classify.constantize.create(obj_hash)
    #Ex: web_obj = Web.find_by(url: url)
    #Ex: web_obj.present? ? update_obj_if_changed(web_hash, web_obj) : web_obj = Web.create(web_hash)
    return obj
  end


  def create_obj_parent_assoc(model, obj, parent)
    parent.send(model.pluralize.to_sym) << obj if (obj && !parent.send(model.pluralize.to_sym).include?(obj))
    #Ex: account.phones << phone_obj if !account.phones.include?(phone_obj)
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


  def validate_hsh(cols, hash)
    if cols.present? && hash.present?
      keys = hash.keys
      keys.each { |key| hash.delete(key) if !cols.include?(key) }
      return hash
    end
  end


end
