require 'bean_sprout/forwardable_delegate'
require 'bean_sprout/struct_archive_mixin'

module BeanSprout
  class SproutBunch
    attr_reader :sprouts, :other_data

    class NotBalancedError < StandardError
    end

    class IllegalStateError < StandardError
    end

    def initialize id, sprouts, other_data = nil
      @id = id
      @sprouts = sprouts
      @other_data = other_data
    end

    def balanced?
      balance = 0
      @sprouts.each do |sprout|
        balance += sprout.unified_amount
      end
      balance == 0
    end

    def balanced!
      raise NotBalancedError.new("#{@sprouts} not balanced.") unless balanced?
    end

    def plant
      balanced!
      raise IllegalStateError, "Can't plant twice." if @in_place
      sprouts.each do |sprout|
        sprout.bean.grow sprout
      end
      @in_place = true
    end

    def remove
      balanced!
      raise IllegalStateError, "Must plant before remove." unless @in_place
      sprouts.each do |sprout|
        sprout.bean.pick sprout
      end
      @in_place = false
    end

    def to_transaction
      Transaction.new(self)
    end
  end

  class Transaction < ForwardableDelegate
    def_default_delegators :balanced?, :other_data
    def_private_default_delegators :sprouts, :plant, :remove

    def commit
      begin
        plant
      rescue SproutBunch::NotBalancedError
        raise "Cannot commit an imbalance transaction."
      rescue SproutBunch::IllegalStateError
        raise "Cannot commit a transaction more than once."
      end
    end

    def revert
      begin
        remove
      rescue SproutBunch::NotBalancedError
        raise "Cannot revert an imbalance transaction."
      rescue SproutBunch::IllegalStateError
        raise "Cannot revert a transaction more than once."
      end
    end

    def entries
      sprouts.map do |sprout|
        if block_given?
          yield sprout.to_entry
        else
          sprout.to_entry
        end
      end
    end
  end
end
