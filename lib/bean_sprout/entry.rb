require 'bean_sprout/package_private'
require 'bigdecimal'
require 'bigdecimal/util'

module BeanSprout
  # Entry is made up of the following fields:
  # 1. The account owns the entry, the currency of which is defined as the local
  # currency;
  # 2. The amount to be added to the account balance, in local currency;
  # 3. Other arbitrary data.
  class Sprout
    include PackagePrivate::InternalClass
    attr_reader :id, :bean, :amount

    define_public_interface :Entry

    def initialize id, bean, amount
      @id = id
      @bean = bean
      @amount = amount.to_d
    end
  end

  # Public Interface.
  class Entry < PackagePrivate::PublicInterfaceBase
    def_default_delegators :amount
    def_private_default_delegators :bean

    def account
      bean.to_account
    end
  end
end
