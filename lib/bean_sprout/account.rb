require 'bean_sprout/struct_from_hash_mixin'
require 'bean_sprout/struct_archive_mixin'

module BeanSprout
  class Account < Struct.new(:currency, :external_id, :other_data)
    include StructFromHashMixin
    include StructArchiveMixin

    class BalanceHolder < Struct.new(:value)
    end

    def initialize *fields
      super *fields
      @entries = []
      @balance = BalanceHolder.new(0)
    end

    def append_entry entry
      @entries.push entry
      @balance.value += entry.accurate_amount
    end

    def entries
      @entries.clone
    end

    def balance
      @balance.value
    end
  end
end
