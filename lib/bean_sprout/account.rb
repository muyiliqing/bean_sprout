require 'bean_sprout/struct_from_hash_mixin'
require 'bean_sprout/struct_archive_mixin'

module BeanSprout
  class Account < Struct.new(:currency, :other_data)
    include StructFromHashMixin
    include StructArchiveMixin

    def initialize *fields
      super *fields
      @entries = []
      @balances = [0]
    end

    def append_entry entry
      @entries.push entry
      @balances.push balance + entry.accurate_amount
    end

    def entries
      @entries.clone
    end

    def balance
      @balances.last
    end
  end
end
