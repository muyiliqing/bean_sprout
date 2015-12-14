require 'bean_sprout/struct_archive_mixin'

module BeanSprout
  class Transaction < Struct.new(:entries, :other_data)
    include StructArchiveMixin

    def balanced?
      balance = 0
      entries.each do |entry|
        balance += entry.amount / entry.rate_or_one
      end
      balance == 0
    end

    def balanced!
      raise "#{@entries} is not balanced." unless balanced?
    end

    def entries
      super.clone
    end
  end
end

