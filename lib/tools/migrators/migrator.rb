%w{uni_act_migrator uni_cont_migrator uni_web_migrator}.each { |x| require x }

class Migrator
  # extend ActiveSupport::Concern
  include UniActMigrator
  include UniContMigrator
  include UniWebMigrator
  # include WebMigrator

  ### To call any of the three UniMigrator Modules ###
  #Call: Migrator.new.migrate_uni_acts
  #Call: Migrator.new.migrate_uni_conts
  #Call: Migrator.new.migrate_uni_webs

  ### CAREFUL!!! BELOW METHODS BEING USED IN EACH UNI_MIGRATOR MODULE ###

  def initialize
    @formatter = Formatter.new
  end

  ## Used for Tables where only one Attr matters, like Phone.phone
  def save_simple_obj(model, attr_hsh)
    obj = model.classify.constantize.find_or_create_by(attr_hsh)
    #Ex: phone_obj = Phone.find_or_create_by(phone: phone)
    return obj
  end


  ## Used for Tables where we need to first find by one attribute, then save or update several other attributes like Act or Cont.
  def save_complex_obj(model, attr_hsh, obj_hsh)
    obj_hsh.delete_if { |key, value| value.blank? }
    obj = model.classify.constantize.find_by(attr_hsh)
    obj.present? ? update_obj_if_changed(obj_hsh, obj) : obj = model.classify.constantize.create(obj_hsh)
    #Ex: web_obj = Web.find_by(url: url)
    #Ex: web_obj.present? ? update_obj_if_changed(web_hsh, web_obj) : web_obj = Web.create(web_hsh)
    return obj
  end


  def create_obj_parent_assoc(model, obj, parent)
    if model.present? && obj.present? && parent.present?
      parent.send(model.pluralize.to_sym) << obj if !parent.send(model.pluralize.to_sym).include?(obj)
      #Ex: act.phones << phone_obj if !act.phones.include?(phone_obj)
    end
  end


  def update_obj_if_changed(hsh, obj)
    hsh.delete_if { |k, v| v.nil? }

    if hsh['updated_at']
      hsh.delete('updated_at')
      obj.record_timestamps = false
    end

    updated_attributes = (hsh.values) - (obj.attributes.values)
    obj.update_attributes(hsh) if !updated_attributes.empty?
  end


  def validate_hsh(cols, hsh)
    if cols.present? && hsh.present?
      keys = hsh.keys
      keys.each { |key| hsh.delete(key) if !cols.include?(key) }
      return hsh
    end
  end

  #Call: Migrator.new.reset_pk_sequence
  def reset_pk_sequence
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end


end
