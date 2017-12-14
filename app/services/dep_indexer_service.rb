require 'open-uri'
require 'mechanize'
require 'uri'
require 'nokogiri'
require 'socket'
require 'httparty'
require 'delayed_job'
require 'indexer_helper/rts/dealerfire_rts'
require 'indexer_helper/rts/cobalt_rts'
require 'indexer_helper/rts/dealer_inspire_rts'
require 'indexer_helper/rts/dealeron_rts'
require 'indexer_helper/rts/dealer_com_rts'
require 'indexer_helper/rts/dealer_direct_rts'
require 'indexer_helper/rts/dealer_eprocess_rts'
require 'indexer_helper/rts/dealercar_search_rts'
# require 'indexer_helper/page_finder_original'  # ### CAN REMOVE THIS.  HAS BEEN REPLACED.
require 'indexer_helper/rts/rts_helper'
require 'indexer_helper/rts/rts_manager'
require 'indexer_helper/unknown_template' # Unknown template's info scraper
require 'indexer_helper/helper' # All helper methods for indexer_service
require 'servicers/url_verifier'
require 'servicers/formatter_caller'
require 'curb' #=> for url_redirector

class IndexerService

  ###############################################
  include PhoneFormatter
  # phone_formatter(phone)

  ###############################################
  # Call: IndexerService.new.model_phone_formatter_starter
  # Call: FormatterCaller.new.model_phone_formatter_caller
  def model_phone_formatter_starter
    puts ">> model_phone_formatter_starter..."
    # FormatterCaller.new.delay.model_phone_formatter_caller
    FormatterCaller.new.model_phone_formatter_caller
  end

  ###############################################
  # Call: IndexerService.new.start_url_redirect
  # Call: UrlVerifier.new.starter
  def start_url_redirect
    puts ">> start_url_redirect..."
    # UrlVerifier.new.delay.vu_starter
    UrlVerifier.new.vu_starter
  end

  ###############################################
  # Call: IndexerService.new.start_template_finder
  # Call: TemplateFinder.new.tf_starter
  def start_template_finder
    puts ">> start_template_finder..."
    # TemplateFinder.new.delay.tf_starter
    TemplateFinder.new.tf_starter
  end

  ###############################################
  # Call: IndexerService.new.start_account_scraper
  # Call: AccountScraper.new.as_starter
  def start_account_scraper
    puts ">> start_account_scraper..."
    # AccountScraper.new.delay.as_starter
    AccountScraper.new.as_starter
  end

  ###############################################
  # Call: IndexerService.new.start_account_scraper
  # Call: AccountScraper.new.as_starter
  def start_page_finder
    puts ">> start_page_finder..."
    PageFinder.new.delay.pf_starter
    PageFinder.new.pf_starter
  end
  ###############################################

  ############# FINALIZERS BEGIN #############
  ## 1) IdSorterFinalizer
  ## Call: IdSorterFinalizer.new.id_starter
  ## Description: Handles entire id sorting finalizer.  Replaces AcctNameIdSorter, PhoneIdSorter, AddrPinIdSorter, UrlIdSorter.
  ## Replaces:
  ##def url_arr_mover
  ##def pin_arr_mover
  ##def ph_arr_mover_express
  ##def acct_arr_mover
  ##def acct_squeezer_caller
  ##def acct_squeezer_processor
  ##def acct_squeezer
  ###############################################
  ## 2) ....score_calculator
  ## Call: ScoreCalculatorFinalizer.new.sc_starter
  ## Replaces ##def score_calculator
  ###############################################
  ## 3) ....scraper_migrator
  ## Call: UltimateMigratorFinalizer.new.um_starter
  ## Replaces ##def scraper_migrator
  ############################################

  ############## FINALIZERS END ##############





  ########################################################
  def remove_invalid_phones
    indexers = Indexer.where(archive: false)
    num = 0
    indexers.each do |indexer|
      phones = indexer.phones
      if phones.any?
        num += 1
        invalid = Regexp.new("[0-9]{5,}")
        valid_phones = phones.reject { |x| invalid.match(x) }

        reg = Regexp.new("[(]?[0-9]{3}[ ]?[)-.]?[ ]?[0-9]{3}[ ]?[-. ][ ]?[0-9]{4}")
        result = valid_phones.select { |x| reg.match(x) }

        indexer.update_attribute(:phones, result)
      end
    end
  end

  def count_staff
    indexers = Indexer.where(archive: false)
    num = 0
    indexers.each do |indexer|
      num += 1
      web_count = Staffer.where(domain: indexer.clean_url).where(cont_source: "Web").count
      crm_count = Staffer.where(domain: indexer.clean_url).where(cont_source: "CRM").count
      puts ">>>>> #{num}"
      indexer.update_attributes(web_staff_count: web_count, crm_staff_count: crm_count)
    end
  end

  #####################
  def staff_url_cleaner
    # indexers = Indexer.where(template: "Search Error").where("staff_url LIKE '%.comstaff%'")
    indexers = Indexer.where(template: "Search Error").where(staff_url: nil)
    counter=0
    indexers.each do |indexer|
      staff_url = indexer.staff_url

      counter+=1
      puts "#{counter}) #{staff_url}"
      # new_staff_url = staff_url.gsub(".comstaff", ".com/staff")
      # puts new_staff_url
      puts
      # indexer.update_attributes(template: nil, staff_url: new_staff_url)
      indexer.update_attribute(:template, nil)
    end
  end


  def dup_url_cleaner
    bigs = Indexer.where.not(raw_url: nil)
    big_counter=0
    small_counter=0
    if bigs
      bigs.each do |big|
        big_raw_url = big.raw_url
        big_id = big.id

        pre_count = Indexer.where(raw_url: big_raw_url).count
        big_counter+=1
        puts
        puts "#{big_counter}) #{big_raw_url}"
        puts "pre_count: #{pre_count}"

        smalls = Indexer.where(raw_url: big_raw_url).where.not(id: big_id)
        smalls.each do |small|
          small_raw_url = small.raw_url
          small_id = small.id

          small_counter+=1
          puts "------------------ #{small_counter} ------------------ "
          puts
          puts "big_raw_url: #{big_raw_url}"
          puts "small_raw_url: #{small_raw_url}"
          puts "big_id: #{big_id}"
          puts "small_id: #{small_id}"

          small.destroy
        end

        post_count = Indexer.where(raw_url: big_raw_url).count
        puts "post_count: #{post_count}"
        puts
      end
    end
  end

  def url_downcase
    a=0
    z=-1
    indexers = Indexer.where.not(raw_url: nil)[a..z]
    counter=0
    indexers.each do |indexer|
      raw_url = indexer.raw_url
      down_raw_url = raw_url.downcase if raw_url
      counter+=1
      unless raw_url == down_raw_url
        puts
        puts "[#{a}...#{z}] (#{counter}) #{raw_url} / #{down_raw_url}"
        puts
        indexer.update_attribute(:raw_url, down_raw_url)
      end
    end
  end


  def hyrell_cleaner
    indexers = Indexer.where("raw_url LIKE '%.hyrell.%'")
    indexers.each do |indexer|
      raw_url = indexer.raw_url
      if raw_url.include?(".hyrell")
        puts
        new_raw_url = raw_url.gsub(".hyrell.", ".")
        puts raw_url
        puts new_raw_url
        indexer.update_attributes(raw_url: new_raw_url, redirect_status: nil)
      end
    end
  end

  def count_contacts
    indexers = Indexer.where.not(clean_url: nil).where(contacts_count: nil)
    counter=0
    indexers.each do |indexer|
      clean_url = indexer.clean_url
      contacts_count = Staffer.where(domain: clean_url).count

      counter+=1
      puts "---------------------- #{counter} ----------------------"
      puts clean_url
      puts contacts_count
      puts
      indexer.update_attribute(:contacts_count, contacts_count)
    end
  end


  def scraped_contacts_sts_checker
    indexers = Indexer.where.not(staff_text: nil).where(contact_status: nil).where.not(clean_url: nil)

    counter=0
    indexers.each do |indexer|
      clean_url = indexer.clean_url
      indexer_template = indexer.template
      contact_status = indexer.contact_status

      contacts = Staffer.where(domain: clean_url)[0..0]
      contacts.each do |contact|

        unless contact_status
          staffer_status = contact.staffer_status
          cont_status = contact.cont_status
          staff_link = contact.staff_link
          domain = contact.domain
          staffer_template = contact.template

          if domain == clean_url && contact_status == nil
            counter+=1
            puts
            puts "------------------ #{counter} ------------------"
            puts staffer_status
            puts cont_status
            puts staff_link
            puts domain
            puts staffer_template
            puts

            indexer.update_attributes(contact_status: "CS Result", template: staffer_template)
          end
        end
      end
    end
  end


  def url_arr_extractor
    # locs = Location.where.not(url: nil).where.not(sts_duplicate: "URL Check")[0..-1]
    locs = Location.where.not(crm_url_redirect: nil)[0..-1]
    num=0
    print "#{num}, "

    loc_count=0
    indexer_count=0
    puts
    locs.each do |loc|
      loc_count+=1
      url_arr = loc.url_arr
      crm_url = loc.crm_url
      geo_url = loc.url
      crm_url_redirect = loc.crm_url_redirect
      geo_url_redirect = loc.geo_url_redirect

      exists = Indexer.exists?(raw_url: geo_url_redirect)

      if exists == false
        indexer_count+=1
        puts
        puts "(#{indexer_count}/#{loc_count}) Adding: #{geo_url_redirect}"
        loc.update_attribute(:sts_duplicate, "URL Check")
        Indexer.create(raw_url: geo_url_redirect)
      end
    end
    puts
  end


  def url_importer
    locs = Location.where.not(url: nil)
    counter=0
    locs.each do |loc|
      puts "#{counter}) #{loc.url}"
      Indexer.create(raw_url: loc.url)
    end
  end


  def template_counter
    indexer_terms = IndexerTerm.where(sub_category: "at_css").where.not(response_term: nil)
    indexer_terms.each do |term|
      template = term.response_term
      temp_count = Indexer.where(template: template).count
      puts "#{template}: #{temp_count}"
      term.update_attribute(:response_count, temp_count)
    end
  end


  def stafflink_express
    # Dealer.com > "#{clean_url}/dealership/staff.htm"
    # DealerOn" > "#{clean_url}/staff.aspx"
    # Dealer Direct" > "#{clean_url}/staff"
    # DEALER eProcess > "#{clean_url}/meet-our-staff"

    indexers = Indexer.where(template: "DEALER eProcess").where.not(indexer_status: "Archived").where.not(indexer_status: "Staff Link Updated")

    indexers.each do |indexer|
      clean_url = indexer.clean_url
      staff_url = indexer.staff_url
      staff_text = indexer.staff_text
      unless clean_url.blank?
        new_link = "#{clean_url}/meet-our-staff"
        puts "staff_text: #{staff_text}"
        puts "clean_url: #{clean_url}"
        puts "staff_url: #{staff_url}"
        puts "new_link: #{new_link}"
        puts "-------------------------------"
        indexer.update_attributes(staff_url: new_link, indexer_status: "Staff Link Updated", staff_text: "Staff Page", stf_status: "Staff Link Updated")

        Indexer.where.not(template: nil).count
      end
    end

  end

  def core_phone_norm
    #normalizes phone in core sfdc accounts.
    cores = Core.where.not(sfdc_ph: nil)
    cores.each do |core|
      alert = ""
      sfdc_ph = core.sfdc_ph
      puts "sfdc_ph: #{sfdc_ph}"
      norm_ph = phone_formatter(sfdc_ph) #=> via PhoneFormatter

      if norm_ph != sfdc_ph
        alert = "Alert!"
        core.update_attribute(:sfdc_ph, norm_ph)
      end
      puts "norm_ph: #{norm_ph} #{alert}\n\n"
    end
  end

  def core_url_redirect
    #Checks if sfdc_url exists in Indexer raw_url column, then saves Indexer clean_url to core_url_redirect column.
    # cores = Core.where.not(sfdc_url: nil).where(sfdc_url_redirect: nil)
    # cores.each do |core|
    #     sfdc_url = core.sfdc_url
    #     sfdc_url_redirect = core.sfdc_url_redirect
    #     indexer_raw = Indexer.where(raw_url: sfdc_url).map(&:raw_url).first
    #     indexer_clean = Indexer.where(raw_url: sfdc_url).map(&:clean_url).first
    #     puts "\n\n============="
    #     puts sfdc_url
    #     puts indexer_raw
    #     puts indexer_clean
    #     core.update_attribute(:sfdc_url_redirect, indexer_clean)
    #     puts "=============\n\n"
    # end

    ## Step 2: Sends core sfdc_url to indexer raw_url if doesn't exist in indexer raw_url column.
    # cores = Core.where.not(sfdc_url: nil).where(sfdc_url_redirect: nil)
    # counter = 0
    # cores.each do |core|
    #     sfdc_url = core.sfdc_url
    #     raw_url = Indexer.where(raw_url: sfdc_url).first
    #     if raw_url.blank?
    #         counter +=1
    #         puts "=============\n\n"
    #         puts "counter: #{counter}"
    #         puts "sfdc_url: #{sfdc_url}"
    #         puts "raw_url: #{raw_url}"
    #         Indexer.create(indexer_status: "SFDC URL", redirect_status: "SFDC URL", raw_url: sfdc_url)
    #         puts "=============\n\n"
    #     end
    # end


    # cops = Indexer.where(redirect_status: "COP URL")
    # cops.each do |cop|
    #     raw_cop = cop.raw_url
    #     url_count = Indexer.where(raw_url: raw_cop).map(&:raw_url).count
    #     raw_keep = Indexer.where.not(id: cop.id).where(raw_url: raw_cop).map(&:raw_url).first
    #
    #     if raw_keep
    #         puts "\n\n========================\n\n"
    #         puts "url_count: #{url_count}"
    #         puts "raw_cop: #{raw_cop}"
    #         puts "raw_keep: #{raw_keep}"
    #         cop.update_attribute(:redirect_status, "Delete")
    #         puts "\n\n========================\n\n"
    #     end
    # end
  end


  def indexer_duplicate_purger
    # Indexer.select([:clean_url]).group(:clean_url).having("count(*) > 1").map.count
    # Indexer.select([:clean_url]).group(:clean_url).having("count(*) < 2").map.count
    # Indexer.all.map(&:template).uniq
    # Indexer.all.map(&:clean_url).uniq.count
    # Indexer.where.not(indexer_status: "Archived").count
  end


  def db_data_trimmer
    # indexers = Indexer.where(clean_url: "http://www.alwestnissan.com")
    indexers = Indexer.where.not(indexer_status: "Archived").where.not(clean_url: nil)
    # indexers = Indexer.where("length(full_addr) > 100")[100...200]
    counter=0
    indexers.each do |indexer|
      clean_url = indexer.clean_url

      staff_text = indexer.staff_text
      location_text = indexer.location_text
      acct_name = indexer.acct_name
      street = indexer.street
      city = indexer.city
      state = indexer.state
      zip = indexer.zip
      phone = indexer.phone
      full_addr = indexer.full_addr

      trim_staff_text = trimmer(staff_text)
      trim_location_text = trimmer(location_text)
      trim_acct_name = trimmer(acct_name)
      trim_street = trimmer(street)
      trim_city = trimmer(city)
      trim_state = trimmer(state)
      trim_zip = trimmer(zip)
      trim_phone = trimmer(phone)
      trim_full_addr = long_trimmer(full_addr)

      counter+=1
      puts "#{counter}) #{clean_url}"
      if staff_text != trim_staff_text || location_text != trim_location_text || acct_name != trim_acct_name || street != trim_street || city != trim_city || state != trim_state || zip != trim_zip || phone != trim_phone || full_addr != trim_full_addr
        puts "\n\nLength Alert!\n\n"
        indexer.update_attributes(indexer_status: "Length Alert", staff_text: trim_staff_text, location_text: trim_location_text, acct_name: trim_acct_name, street: trim_street, city: trim_city, state: trim_state, zip: trim_zip, phone: trim_phone, full_addr: trim_full_addr)
      end
    end
  end


  def trimmer(str)
    if !str.blank? && str.length > 50
      puts "Old: #{str}"
      new_strs = str.split("\n")
      new_str = new_strs[0]
      new_str = new_str[0..50]
      new_str.gsub!("  ", "")
      new_str.strip!
      puts "New: #{new_str}\n#{"-"*40}\n\n"
    else
      new_str = str
    end
    new_str
  end

  def long_trimmer(str)
    if !str.blank? && str.length > 80
      puts "Old: #{str}"
      new_strs = str.split(",")
      new_strs.each do |sub_str|
        sub_str = sub_str[0..50]
        sub_str.gsub!("  ", "")
        sub_str.strip!
      end
      new_str = new_strs.join(",")
      puts "New: #{new_str}\n#{"-"*40}\n\n"
    else
      new_str = str
    end
    new_str
  end


  def acct_pin_gen_helper
    cores = Core.where.not(full_address: nil).where(sfdc_zip: nil)
    cores.each do |core|
      full_address = core.full_address

      puts "\n\n#{"-"*40}\n"

      if full_address.blank?
        puts "Blank"
        p full_address
        core.update_attribute(:full_address, nil)
      else
        address_parts = full_address.split(",")
        last_part = address_parts[-1].gsub(/[^0-9]/, "")

        if !last_part.blank?
          if last_part.length == 5
            new_zip = last_part
            puts "Address: #{full_address}"
            puts "new_zip: #{new_zip}"
            core.update_attribute(:sfdc_zip, new_zip)
          elsif last_part.length == 4
            new_zip = "0"+last_part
            new_full = address_parts[0...-1].join(",")
            new_full_addr = "#{new_full}, #{new_zip}"
            puts "new_full_addr: #{new_full_addr}"
            puts "new_zip: #{new_zip}"
            core.update_attributes(full_address: new_full_addr, sfdc_zip: new_zip)
          end

        end
      end
    end
  end


  def acct_pin_gen_starter
    inputs = Core.where.not(sfdc_street: nil).where.not(sfdc_zip: nil)
    # inputs = Location.where.not(street: nil).where.not(postal_code: nil)
    # inputs = Who.where.not(registrant_address: nil).where.not(registrant_zip: nil)

    inputs.each do |input|
      street = input.sfdc_street
      zip = input.sfdc_zip
      acct_pin = acct_pin_gen(street, zip)
      puts "\n\nstreet: #{street}"
      puts "zip: #{zip}"
      puts "Acct Pin: #{acct_pin}\n#{"-"*40}"
      input.update_attribute(:crm_acct_pin, acct_pin)
    end
  end


  def acct_pin_gen(street, zip)
    street_check = street.tr('^0-9', '')
    zip_check = zip.tr('^0-9', '')
    if (!street_check.blank? && !zip_check.blank?) && (zip_check != "0" && street_check != "0")
      if street.include?("DomainsByProxy")
        street_cuts = street.split(",")
        street = street_cuts[1]
      end

      if !street.blank?
        street_down = street.downcase
        if street_down.include?("box")
          street_num = street_down
        else
          street_parts = street.split(" ")
          street_num = street_parts[0]
        end

        street_num = street_num.tr('^0-9', '')
        new_zip = zip.strip
        new_zip = zip[0..4]
        if !new_zip.blank? && !street_num.blank?
          acct_pin = "z#{new_zip}-s#{street_num}"
        end
      end
    else
      acct_pin = nil
    end
    acct_pin
  end




  def pin_acct_counter
    # acct_pin_count = Indexer.select([:acct_pin]).group(:acct_pin).having("count(*) > 1").map.count
    # puts "\n#{"-"*30}\nacct_pin_count: #{acct_pin_count}\n#{"-"*30}\n"

    acct_pins = Indexer.select([:acct_pin]).group(:acct_pin).having("count(*) > 1")[0..100]
    acct_pins.each do |pin|
      indexers = Indexer.where(acct_pin: pin.acct_pin).where.not(acct_pin: nil)
      puts "--------------------------------"
      indexers.each do |indexer|
        target_pin = indexer.acct_pin
        target_addr = indexer.full_addr
        acct = indexer.acct_name
        puts "acct: #{acct}"
        puts "target_pin: #{target_pin}"
        puts "target_addr: #{target_addr}\n\n"
      end
    end


    # indexers = Indexer.where.not(indexer_status: "Archived").where()
    # dup_pins = Indexer.all.map(&:acct_pin).uniq
    #
    #
    # dup_pins.each do |pin|
    #     pin = pin.acct_pin
    #     addr = pin.addr
    #     acct = pin.acct_name
    #     target_pin = Indexer.where(acct_pin: pin)
    #     puts "\n#{"-"*30}\npin: #{target_pin}\acct: #{acct}\addr: #{addr}\n#{"-"*30}\n"
    # end

  end


  def redirect_url_migrator

    ## Step 1: Convert Indexer clean_url to downcase.
    # indexers = Indexer.where.not(clean_url: nil)
    # puts "\n#{"="*30}\n"
    # indexers.each do |indexer|
    #     clean_url = indexer.clean_url
    #     down_clean_url = clean_url.downcase
    #     if !clean_url.blank? && (clean_url != down_clean_url)
    #         puts "\n------------------------"
    #         puts "clean_url: #{clean_url}"
    #         puts "down_clean_url: #{down_clean_url}"
    #         puts "\n------------------------\n"
    #         indexer.update_attribute(:clean_url, down_clean_url)
    #     end
    # end


    ## Step 2: Migrate Indexer clean_url to Core sfdc_clean_url.
    # cores = Core.where.not(sfdc_url: nil)
    # cores.each do |core|
    #     sfdc_url = core.sfdc_url
    #     sfdc_clean_url = core.sfdc_clean_url
    #     bds_status = core.bds_status
    #     sfdc_acct = core.sfdc_acct
    #     clean_url = Indexer.where(raw_url: sfdc_url).map(&:clean_url).first
    #     puts "\n------------------------"
    #     puts "sfdc_url: #{sfdc_url}"
    #     puts "clean_url: #{clean_url}"
    #     puts "sfdc_acct: #{sfdc_acct}"
    #     puts "\n------------------------\n"
    #     core.update_attribute(:sfdc_clean_url, clean_url)
    # end

    # # Step 3: Migrate Indexer clean_url to Staffer sfdc_clean_url.
    # staffs = Staffer.where(cont_source: "CRM")[0..100]
    # staffs.each do |staff|
    #     domain = staff.domain
    #     acct_name = staff.acct_name
    #     clean_url = Indexer.where(raw_url: domain).map(&:clean_url).first
    #     puts "\n------------------------"
    #     puts "domain: #{domain}"
    #     puts "clean_url: #{clean_url}"
    #     puts "acct_name: #{acct_name}"
    #     puts "\n------------------------\n"
    #     # staff.update_attribute(:domain, clean_url)
    # end

    # Step 3: Migrate Indexer clean_url to Staffer sfdc_clean_url.
    staffs = Staffer.where(cont_source: "CRM")
    staffs.each do |staff|
      domain = staff.domain
      acct_name = staff.acct_name
      staff_acct_id = staff.sfdc_id
      sfdc_id = Core.where(sfdc_id: staff_acct_id).map(&:sfdc_id).first
      sfdc_clean_url = Core.where(sfdc_id: staff_acct_id).map(&:sfdc_clean_url).first

      if (sfdc_id && staff_acct_id && sfdc_clean_url) && (sfdc_id == staff_acct_id)
        puts "\n------------------------"
        puts "domain: #{domain}"
        puts "sfdc_clean_url: #{sfdc_clean_url}"
        puts "Staff_id: #{staff_acct_id}"
        puts "Core_id: #{sfdc_id}"
        puts "acct_name: #{acct_name}"
        puts "\n------------------------\n"
        staff.update_attribute(:domain, sfdc_clean_url)
      end
    end

  end

  def junk_cleaner
    junk = %w(advertising, feast, burger, weather, guide, motorcycle, atvs, accessories, manufacturer, coupon, agency, digital, media, credit, medical, communication, diner, dinner, food, cuisine, hotel, architect, journal, superstition, glass, sentinel, staffing, temporary, employment, robert half, harley-davidson, breaking, entertainment, traffic, boat, rvs, campers, atvs, sea-doo, ski-doo, trailer, equipment, racing, attorney, accident, personal injury, divorce, criminal, lawyer, watercraft, animal, powersport, scooter, estate, news, business, education, classified, directory, job, apt, house, apartment, video, streaming, trouble, restaurant, market, opinion, satire, drunk, eyewitness, haul, motorhomes, funeral, property, management, contractor, event, youth, tool, vacation, resort, medicine, health, casa, hear, grill, fitness, health, し, 大, ま, institute, economic, aviation, insurance)

    indexers = Indexer.where(indexer_status: "Meta Result").where.not(acct_name: nil)
    counter = 0
    indexers.each do |indexer|
      junk.each do |x|
        acct_name = indexer.acct_name
        down_name = acct_name.downcase
        if down_name.include?(x)
          counter +=1
          puts "\n\n#{counter}) X:> #{x}"
          puts "Title: #{down_name}\n\n"
          indexer.destroy
        end
      end
    end
  end


  def job_title_migrator
    job_titles = IndexerTerm.where(sub_category: "job_titles").map(&:criteria_term)
    counter=0
    job_titles.each do |title|
      staffs = Staffer.where("job_raw LIKE '%#{title}%'")
      staffs.each do |staff|
        job_raw = staff.job_raw
        counter+=1
        puts "\n\n================"
        puts counter
        puts "job_raw: #{job_raw}"
        puts "title: #{title}"
        puts "================\n\n"
        staff.update_attribute(:job, title)
      end
    end
  end


#####################################################

  # ADDS CORE ID TO INDEXER PH ARRAY
  # def ph_arr_mover
  #     ## TAKES TOO LONG!  USE EXPRESS VERSION ABOVE INSTEAD.
  #     puts "\n\n#{"="*40}STARTING ID SORTER METHOD 4: PHONE ARRAY MOVER (*EXTENDED VERSION)\nChecks for SFDC Core IDs with same Scraped Phone as Indexer and saves ID in array in Indexer/Scrapers.\n\n"
  #
  #     cores = Core.where.not(sfdc_ph: nil)
  #     counter=0
  #     cores.each do |core|
  #         sfdc_ph = core.sfdc_ph
  #         sfdc_id = core.sfdc_id
  #
  #         indexers = Indexer.where(archive: false).where.not(phones: [])
  #         indexers.each do |indexer|
  #             phones = indexer.phones
  #             if phones.include?(sfdc_ph)
  #                 crm_ph_ids = indexer.crm_ph_ids
  #
  #                 counter+=1
  #                 puts "\n\n#{"="*50}\n#{counter}"
  #                 puts "IDs: #{crm_ph_ids}"
  #                 puts "CRM ID: #{sfdc_id}"
  #                 puts "CRM Ph: #{sfdc_ph}"
  #                 puts "Web Ph: #{phones}"
  #
  #                 crm_ph_ids << sfdc_id
  #                 final_array = crm_ph_ids.uniq.sort
  #                 puts "IDs: #{crm_ph_ids}"
  #                 puts "Final: #{final_array}"
  #
  #
  #                 indexer.update_attribute(:crm_ph_ids, final_array)
  #             end
  #         end
  #     end
  # end


end # IndexerService class Ends ---
