module BeanSprout
  class GlassJar
    attr_reader :accounts
    attr_reader :transactions

    def initialize
      @accounts = {}
      @account_id = 0

      @transactions = {}
      @transaction_id = 0

      @entries = {}
      @entries_of_account = {}
    end

    def create_account account
    end

    AccountEntitySizeBits = 20
    def commit_transaction trans
      raise "Creating transaction with no entries." if trans.entries.empty?
      if trans.entries.size >= (1 << AccountEntitySizeBits)
        raise "Creating transaction with too many entries."
      end

      trans.archive_in_glass_jar self, next_transaction_id
      trans.entries.each_with_index do |entry, index|
        entry_id = (trans.id << AccountEntitySizeBits) + index
        entry.archive_in_glass_jar self, entry_id

        valid_account! entry.account

        entries[entry_id] = entry
        entries_of_account[entry.account] = entry

        # TODO: adjust account balance.
      end
      transactions[trans.id] = trans
    end

    def create_transaction *entries, other_data: nil
      trans = Transaction.new(entries, other_data)
      commit_transaction(trans)
    end

    def entries_of account
      valid_account! account
      entries_of_account[account] || []
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
  end
end
