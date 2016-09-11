require 'bean_sprout/forwardable_delegate'
require 'bigdecimal'
require 'bigdecimal/util'

module BeanSprout
  # Entry is made up of the following fields:
  # 1. The account owns the entry, the currency of which is defined as the local
  # currency;
  # 2. The amount to be added to the account balance, in local currency;
  # 3. Other arbitrary data.
  class Sprout
    attr_reader :id, :bean, :amount, :rate, :other_data

    # Can't specify other_data unless specify rate. Not good syntax.
    def initialize id, bean, amount, rate = 1, other_data = nil
      @id = id
      @bean = bean
      @amount = amount.to_d
      @rate = rate
      @other_data = other_data
    end

    def unified_amount
      amount * rate
    end

    def to_entry
      Entry.new(self)
    end
  end

  # Public Interface.
  class Entry < ForwardableDelegate
    def_default_delegators :amount, :unified_amount, :rate, :other_data
    def_private_default_delegators :bean

    def account
      bean.to_account
    end
  end
end
