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
  end
end
