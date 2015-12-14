require 'bean_sprout/struct_archive_mixin'

module BeanSprout
  class Transaction < Struct.new(:entries, :other_data)
    include StructArchiveMixin

    alias entries_data entries
    private :entries_data

    public
    def balanced?
      balance = 0
      entries_data.each do |entry|
        balance += entry.accurate_amount / entry.rate_or_one
      end
      balance == 0
    end

    def balanced!
      raise "#{entries_data} is not balanced." unless balanced?
    end

    def entries
      entries_data.clone
    end
  end
end

