require 'bean_sprout/forwardable_delegate'

module BeanSprout
  class Bean
    attr_reader :id, :balance, :currency, :rate, :sprouts, :other_data

    def initialize id, currency, rate = 1, other_data = nil
      @id = id
      @currency = currency
      @rate = rate
      @other_data = other_data && other_data.clone
      @sprouts = Set.new
      @balance = 0
    end

    def grow sprout
      @sprouts.add sprout
      @balance += sprout.amount
    end

    def pick sprout
      @sprouts.delete sprout
      @balance -= sprout.amount
    end

    def to_account
      Account.new(self)
    end
  end

  # Public interface.
  class Account < ForwardableDelegate
    def_default_delegators :balance, :currency, :rate, :other_data
    def_private_default_delegators :sprouts

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
