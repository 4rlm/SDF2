# BLOG: http://mitrev.net/ruby/2015/11/13/the-operator-in-ruby/

# === Safe Navigation Operator === #

##########
## Scenario:
##########
  if account && account.owner && account.owner.address
  ...
  end
  ####
  if account.try(:owner).try(:address)
  ...
  end
##########
## Using &.
##########
  account&.owner&.address
##########
# More examples:
##########
  account = Account.new(owner: nil) # account without an owner
  account.owner.address # => NoMethodError: undefined method `address' for nil:NilClass
  account && account.owner && account.owner.address # => nil
  account.try(:owner).try(:address) # => nil
  account&.owner&.address # => nil
##########
# More examples:
##########
  account = Account.new(owner: false)
  account.owner.address # => NoMethodError: undefined method `address' for false:FalseClass `
  account && account.owner && account.owner.address # => false
  account.try(:owner).try(:address) # => nil
  account&.owner&.address # => undefined method `address' for false:FalseClass`
##########
# More examples:
# Here comes the first surprise - the &. syntax only skips nil but recognizes false! It is not exactly equivalent to the s1 && s1.s2 && s1.s2.s3 syntax. What if the owner is present but doesn’t respond to address?
##########
  account = Account.new(owner: Object.new)
  account.owner.address # => NoMethodError: undefined method `address' for #<Object:0x00559996b5bde8>
  account && account.owner && account.owner.address # => NoMethodError: undefined method `address' for #<Object:0x00559996b5bde8>`
  account.try(:owner).try(:address) # => nil
  account&.owner&.address # => NoMethodError: undefined method `address' for #<Object:0x00559996b5bde8>`
##########
# OOPS!:
# Oops, the try method doesn’t check if the receiver responds to the given symbol. This is why it’s always better to use the stricter version of try - try!:
##########
  nil.nil? # => true
  nil?.nil? # => false
  nil&.nil? # => nil

  account.try!(:owner).try!(:address) # => NoMethodError: undefined method `address' for #<Object:0x00559996b5bde8>`
##########
