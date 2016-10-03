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
      @dummy_accounts = {}
    end

    def create_account currency, other_data: nil
      bean = @beans.store do |next_id|
        Bean.new(next_id, currency)
      end

      Account.new(bean, other_data)
    end

    def create_entry account, amount, other_data: nil
      bean = get_target account
      if not @beans.has_key? bean.id
        raise "Unkown account #{bean.to_account} refered."
      end

      sprout = @sprouts.store do |next_id|
        Sprout.new(next_id, bean, amount)
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
      commit_entries [entry0, entry1]
    end

    def forex_transfer from_acc, to_acc, from_amount, to_amount
      entry0 = create_entry from_acc, -from_amount
      entry1 = create_entry (dummy_account from_acc.currency), from_amount
      entry2 = create_entry to_acc, to_amount
      entry3 = create_entry (dummy_account to_acc.currency), -to_amount
      commit_entries [entry0, entry1, entry2, entry3]
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

    def dummy_account currency = nil
      currency ||= @base_currency
      acc = create_account currency, other_data: "This is a dummy account for #{currency}."
      @dummy_accounts[currency] ||= acc
    end

    private
    def get_target obj
      obj.instance_variable_get :@target
    end

    def commit_entries entries
      trans = create_transaction entries
      trans.commit
      trans
    end
  end
end
