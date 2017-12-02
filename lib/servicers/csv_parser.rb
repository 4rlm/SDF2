## Call: AccountSaver.new.start_account_saver
## Description: ........

class AccountSaver
  include AccountParser

  def initialize
    puts "\n\n== Welcome to the AccountSaver Class! ==\n\n"
  end

  def start_account_saver
    welcome #=> via AccountParser
    sampler
  end


  def sampler
    puts "In the sampler!"

    act_num_id = 'ac_100'
    act_num_id = 'ac_200'
    act_num_id = 'ac_300'
    act_num_id = 'ac_400'
    act_num_id = 'ac_500'

    act_name = 'Account 100'
    act_name = 'Account 200'
    act_name = 'Account 300'
    act_name = 'Account 400'
    act_name = 'Account 500'

    phone = '888-888-8888'
    phone = '777-777-7777'
    phone = '555-555-5555'
    phone = '444-444-4444'
    phone = '333-333-3333'

    # act_num = ActNum.find_or_create_by(act_num: act_num_id)
    # act_num.act_name = ActName.find_or_create_by(act_name: act_name)
    # # act_num.act_names << ActName.find_or_create_by(act_name: act_name)
    # act_num.phones << Phone.find_or_create_by(phone: phone)

  end


end
