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

    def create_account currency, other_data: nil
      bean = @beans.store do |next_id|
        Bean.new(next_id, currency)
      end

      Account.new(bean, other_data)
    end

    def create_entry account, amount, rate = nil, other_data: nil
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
        Sprout.new(next_id, bean, amount, rate)
      end

      Entry.new(sprout, other_data)
    end

    def create_transaction entries, other_data: nil
      sprouts = entries.map do |entry| get_target entry end
      sprout_bunch = @sprout_bunches.store do |next_id|
        SproutBunch.new(next_id, sprouts)
      end

      Transaction.new(sprout_bunch, other_data)
    end

    def transfer from_acc, to_acc, amount
      if from_acc.currency != @base_currency || to_acc.currency != @base_currency
        raise "Cannot transfer between two forex accounts."
      end

      entry0 = create_entry from_acc, -amount
      entry1 = create_entry to_acc, amount
      trans = create_transaction [entry0, entry1]
      trans.commit
      trans
    end

    def base_currency_forex_transfer from_acc, to_acc, from_amount, to_amount
      raise "Amount can't be 0." unless from_amount != 0 && to_amount != 0

      rate0 = rate1 = 1
      if from_acc.currency == @base_currency
        rate0 = to_amount / from_amount
      elsif to_acc.currency == @base_currency
        rate1 = from_amount / to_amount
      else
        raise "Forex transfer must be to or from an account of base currency."
      end

      entry0 = create_entry from_acc, -from_amount, rate0
      entry1 = create_entry to_acc, to_amount, rate1
      trans = create_transaction [entry0, entry1]
      trans.commit
      trans
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

    def dummy_account
      @dummy_account ||= create_account @base_currency, other_data: "This is a dummy account."
    end

    private
    def get_target obj
      obj.instance_variable_get :@target
    end
  end
end
