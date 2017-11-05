require 'bean_sprout/ledger'
require 'minitest/autorun'

class BeanSprout::IntegrationTest < MiniTest::Test
  def setup
    @ledger = BeanSprout::Ledger.new("AUD")
    @aud_account = @ledger.create_account("AUD")
    @usd_account = @ledger.create_account("USD")
    @dummy_account = @ledger.create_account("AUD")

    @entry0 = @ledger.create_entry(@aud_account, 15, other_data: "initial deposit")
    @entry1 = @ledger.create_entry(@dummy_account, -15, other_data: "initial deposit")

    @entry2 = @ledger.create_entry(@usd_account, 150, other_data: "left over") # USD
    @entry20 = @ledger.create_entry((@ledger.forex_account "USD"), -150, other_data: "left over") # USD
    @entry3 = @ledger.create_entry(@dummy_account, -202.5, other_data: "left over" ) # AUD
    @entry30 = @ledger.create_entry(@aud_account, 202.5, other_data: "left over" ) # AUD

  end

  def test_commit_transaction
    @transaction0 = @ledger.create_transaction([@entry0, @entry1])
    assert_equal 15, @aud_account.balance
    assert_equal -15, @dummy_account.balance
    assert_equal 15, @aud_account.entries.first.amount
    assert_equal -15, @dummy_account.entries.first.amount

    @transaction1 = @ledger.create_transaction([@entry2, @entry3, @entry20, @entry30])
    assert_equal 150, @usd_account.balance
    assert_equal -217.5, @dummy_account.balance
    assert_equal 150, @usd_account.entries.first.amount
    assert_equal -15, @dummy_account.entries.first.amount
  end

  # TODO: test revert.
end
