require 'bean_sprout/package_private'

module BeanSprout
  # TODO: abstract :id?
  class Bean
    include PackagePrivate::InternalClass

    attr_reader :id, :balance, :currency, :sprouts

    define_public_interface :Account

    def initialize id, currency
      @id = id
      @currency = currency

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
  end

  # Public interface.
  class Account < PackagePrivate::PublicInterfaceBase
    def_default_delegators :balance, :currency
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
