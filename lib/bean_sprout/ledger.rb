require 'bean_sprout/sparse_array'
require 'bean_sprout/account'
require 'bean_sprout/entry'
require 'bean_sprout/transaction'

module BeanSprout
  class Ledger
    attr_reader :base_currency

    def initialize base_currency
      @base_currency = base_currency

      @beans = SparseArray.new
      @sprout_bunches = SparseArray.new
      @sprouts = SparseArray.new
    end

    def create_account currency, other_data = nil
      bean = @beans.store do |next_id|
        Bean.new(next_id, currency, other_data)
      end
      bean.to_account
    end

    def create_entry account, amount, rate = nil, other_data = nil
      bean = get_target account
      if not @beans.has_key? bean.id
        raise "Unkown account #{bean.to_account} refered."
      end

      if not (rate or bean.currency == base_currency)
        raise "Rate must be specified if account is not in base currency " +
          "#{base_currency}."
      end
      rate ||= 1


      sprout = @sprouts.store do |next_id|
        Sprout.new(next_id, bean, amount, rate, other_data)
      end

      sprout.to_entry
    end

    def create_transaction entries, other_data = nil
      sprouts = entries.map do |entry| get_target entry end
      sprout_bunch = @sprout_bunches.store do |next_id|
        SproutBunch.new(next_id, sprouts, other_data)
      end
      sprout_bunch.to_transaction
    end

    # TODO: clients can't access ID.
    def account id
      @beans.fetch(id).to_account
    end

    # TODO: clients can't access ID.
    def transaction id
      @sprout_bunches.fetch(id).to_transaction
    end

    # TODO: test
    def accounts
      @beans.values.map do |bean|
        if block_given?
          yield bean.to_account
        else
          bean.to_account
        end
      end
    end

    # TODO: test
    def transactions
      @sprout_bunches.values.map do |sprout_bunch|
        if block_given?
          yield sprout_bunch.to_transaction
        else
          sprout_bunch.to_transaction
        end
      end
    end

    # TODO: implement transfer.
    # TODO: implement dummpy account.

    private
    def get_target obj
      obj.instance_variable_get :@target
    end
  end
end
