require 'bean_sprout/struct_from_hash_mixin'
require 'bean_sprout/struct_archive_mixin'
require 'bigdecimal'
require 'bigdecimal/util'

module BeanSprout
  # Entry is made up of the following fields:
  # 1. The account owns the entry, the currency of which is defined as the local
  # currency;
  # 2. The amount to be added to the account balance, in local currency;
  # 3. Convention rate from local currency to the base currency;
  # 4. Other arbitrary data.
  class Entry < Struct.new(:account, :amount, :rate, :other_data)
    include StructFromHashMixin
    include StructArchiveMixin

    def rate_or_one
      rate or 1
    end

    def accurate_amount
      @accurate_amount ||= amount.to_d
    end
  end
end
