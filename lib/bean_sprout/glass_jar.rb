module BeanSprout
  class GlassJar
    # TODO: maybe each transaction can have its own
    # currency.
    attr_reader :base_currency

    def initialize base_currency
      @base_currency = base_currency

      @accounts = {}
      @account_id = 0
      @account_external_ids = {}

      @transactions = {}
      @transaction_id = 0

      @entries = {}
    end

    def create_account account
      account.archive_in_glass_jar self, next_account_id
      @accounts[account.id] = account
      @account_external_ids[account.external_id] = account
    end

    def accounts
      @accounts.values
    end

    def account id
      @accounts[id]
    end

    def account_for external_id
      @account_external_ids[external_id]
    end

    def transactions
      @transactions.values
    end

    def transaction id
      @transactions[id]
    end

    def entries
      @entries.values
    end

    def entry id
      @entries[id]
    end

    AccountEntitySizeBits = 30
    def commit_transaction trans
      raise "Creating transaction with no entries." if trans.entries.empty?
      if trans.entries.size >= (1 << AccountEntitySizeBits)
        raise "Creating transaction with too many entries."
      end

      # Validate trans status.
      trans.entries.each do |entry|
        valid_account! entry.account
        valid_rate! entry
      end
      trans.balanced!

      trans.archive_in_glass_jar self, next_transaction_id
      trans.entries.each_with_index do |entry, index|
        entry_id = (trans.id << AccountEntitySizeBits) + index
        entry.archive_in_glass_jar self, entry_id

        @entries[entry_id] = entry
        account(entry.account).append_entry(entry)
      end
      @transactions[trans.id] = trans
    end

    def create_transaction *entries, other_data: nil
      trans = Transaction.new(entries, other_data)
      commit_transaction(trans)
    end

    private
    def next_account_id
      @account_id += 1
    end

    def next_transaction_id
      @transaction_id += 1
    end

    def valid_account! account
      if not @accounts.has_key? account
        raise "Unkown account #{account} refered."
      end
    end

    def valid_rate! entry
      if not (entry.rate or account(entry.account).currency == base_currency)
        raise "Rate must be specified if entry is not in base currency " +
          "#{base_currency}.\n Entry is #{entry}"
      end
    end
  end
end
