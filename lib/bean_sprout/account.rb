require 'bean_sprout/forwardable_delegate'

module BeanSprout
  # TODO: abstract :id? abstract :other_data?
  # TODO: abstract to_account/entry/transaction?
  class Bean
    attr_reader :id, :balance, :currency, :sprouts, :other_data

    def initialize id, currency, other_data = nil
      @id = id
      @currency = currency
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
    def_default_delegators :balance, :currency, :other_data
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
