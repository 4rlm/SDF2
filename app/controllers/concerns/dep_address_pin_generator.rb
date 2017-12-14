module AddressPinGenerator
  extend ActiveSupport::Concern

  def generate_pin(street, zip)
    acct_pin = nil
    if street && zip
      street_parts = street.split(" ")
      street_num = street_parts[0]
      street_num = street_num.tr('^0-9', '')
      new_zip = zip.strip
      new_zip = zip[0..4]
      acct_pin = "z#{new_zip}-s#{street_num}"
    end
    acct_pin
  end


end
