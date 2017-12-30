# BLOG: http://mitrev.net/ruby/2015/11/13/the-operator-in-ruby/

# === Safe Navigation Operator === #

##########
## Scenario:
##########
  if act && act.owner && act.owner.address
  ...
  end
  ####
  if act.try(:owner).try(:address)
  ...
  end
##########
## Using &.
##########
  act&.owner&.address
##########
# More examples:
##########
  act = Act.new(owner: nil) # act without an owner
  act.owner.address # => NoMethodError: undefined method `address' for nil:NilClass
  act && act.owner && act.owner.address # => nil
  act.try(:owner).try(:address) # => nil
  act&.owner&.address # => nil
##########
# More examples:
##########
  act = Act.new(owner: false)
  act.owner.address # => NoMethodError: undefined method `address' for false:FalseClass `
  act && act.owner && act.owner.address # => false
  act.try(:owner).try(:address) # => nil
  act&.owner&.address # => undefined method `address' for false:FalseClass`
##########
# More examples:
# Here comes the first surprise - the &. syntax only skips nil but recognizes false! It is not exactly equivalent to the s1 && s1.s2 && s1.s2.s3 syntax. What if the owner is present but doesn’t respond to address?
##########
  act = Act.new(owner: Object.new)
  act.owner.address # => NoMethodError: undefined method `address' for #<Object:0x00559996b5bde8>
  act && act.owner && act.owner.address # => NoMethodError: undefined method `address' for #<Object:0x00559996b5bde8>`
  act.try(:owner).try(:address) # => nil
  act&.owner&.address # => NoMethodError: undefined method `address' for #<Object:0x00559996b5bde8>`
##########
# OOPS!:
# Oops, the try method doesn’t check if the receiver responds to the given symbol. This is why it’s always better to use the stricter version of try - try!:
##########
  nil.nil? # => true
  nil?.nil? # => false
  nil&.nil? # => nil

  act.try!(:owner).try!(:address) # => NoMethodError: undefined method `address' for #<Object:0x00559996b5bde8>`
##########
