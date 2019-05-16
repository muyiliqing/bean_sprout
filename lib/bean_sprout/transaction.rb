require 'bean_sprout/package_private'

module BeanSprout
  class SproutBunch
    include PackagePrivate::InternalClass

    attr_reader :sprouts

    define_public_interface :Transaction

    class NotBalancedError < StandardError
    end

    class IllegalStateError < StandardError
    end

    def initialize id, sprouts
      @id = id
      @sprouts = sprouts
    end

    def balanced?
      balances = Hash.new(0)
      @sprouts.each do |sprout|
        currency = sprout.bean.currency
        balances[currency] += sprout.amount
      end
      balances.values.inject(true) do |acc, currency_balance|
        acc && currency_balance == 0
      end
    end

    def balanced!
      raise NotBalancedError.new("#{@sprouts} not balanced.") unless balanced?
    end

    def plant
      balanced!
      raise IllegalStateError, "Can't plant twice." if defined? @in_place
      sprouts.each do |sprout|
        sprout.bean.grow sprout
      end
      @in_place = true
    end

    def remove
      balanced!
      unless defined? @in_place
        raise IllegalStateError, "Must plant before remove."
      end
      sprouts.each do |sprout|
        sprout.bean.pick sprout
      end
      @in_place = false
    end
  end

  class Transaction < PackagePrivate::PublicInterfaceBase
    def_default_delegators :balanced?
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

    # If this transaction only involves one local currency.
    def local?
      currency = sprouts[0].bean.currency
      sprouts.inject(true) do |acc, sprout|
        acc && sprout.bean.currency == currency
      end
    end
  end
end
