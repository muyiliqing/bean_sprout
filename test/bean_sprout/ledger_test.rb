require 'bean_sprout/ledger'
require 'minitest/autorun'

class BeanSprout::Ledger::Test < MiniTest::Test

  def setup
    @ledger = BeanSprout::Ledger.new("AUD")
  end

  # TODO: split tests.
  def test_create_account
    account = @ledger.create_account("AUD")

    usd_account = @ledger.create_account("USD")

    data_account = @ledger.create_account("AUD", other_data: "some data")
    assert_equal "some data", data_account.other_data

    beans = @ledger.accounts.map do |acc| get_target acc end

    assert beans.include? get_target account
    assert beans.include? get_target usd_account
    assert beans.include? get_target data_account
    assert_equal 3, @ledger.accounts.size
  end

  def test_create_entry
    account = @ledger.create_account("AUD")
    _ = @ledger.create_entry(account, 10)

    data_entry = @ledger.create_entry account, 1, other_data: "some_data"
    assert_equal "some_data", data_entry.other_data
  end

  def test_create_entry_errors
    account = @ledger.create_account("AUD")

    (account.instance_variable_get :@target).instance_variable_set :@id, 9

    e = assert_raises do
      @ledger.create_entry account, 10
    end

    assert_match(/^Unkown account .* refered\.$/, e.message)
  end

  def test_create_transaction
    account = @ledger.create_account("AUD")
    entry0 = @ledger.create_entry(account, 10)
    entry1 = @ledger.create_entry(account, -10)
    entries = [entry0, entry1]

    trans = @ledger.create_transaction entries

    data_trans = @ledger.create_transaction entries, other_data: "somedata"
    assert_equal "somedata", data_trans.other_data

    sprout_bunches = @ledger.transactions.map do |trans_| get_target trans_ end

    assert_equal 2, @ledger.transactions.size
    assert sprout_bunches.include? get_target trans
    assert sprout_bunches.include? get_target data_trans
  end

  def test_transfer
    acc0 = @ledger.create_account "AUD"
    acc1 = @ledger.create_account "AUD"
    @ledger.transfer acc0, acc1, 100
    assert_equal (-100), acc0.balance
    assert_equal 100, acc1.balance
  end

  def test_transfer_same_currency
    acc0 = @ledger.create_account "USD"
    acc1 = @ledger.create_account "USD"
    @ledger.transfer acc0, acc1, 100
    assert_equal (-100), acc0.balance
    assert_equal 100, acc1.balance
  end

  def test_transfer_error
    acc0 = @ledger.create_account "USD"
    acc1 = @ledger.create_account "AUD"
    e = assert_raises do
      @ledger.transfer acc0, acc1, 100
    end

    assert_match(/^Cannot transfer between two forex accounts\.$/, e.message)
  end

  def test_base_currency_forex_transfer
    acc0 = @ledger.create_account "USD"
    acc1 = @ledger.create_account "AUD"
    @ledger.forex_transfer acc0, acc1, 50, 100
    assert_equal (-50), acc0.balance
    assert_equal 100, acc1.balance
  end

  def test_non_base_currency_forex_transfer
    acc0 = @ledger.create_account "USD"
    acc1 = @ledger.create_account "CNY"

    @ledger.forex_transfer acc0, acc1, 100, 99
    assert_equal (-100), acc0.balance
    assert_equal 99, acc1.balance
  end

  def test_forex_account
    acc0 = @ledger.create_account "AUD"
    @ledger.transfer acc0, (@ledger.forex_account), 10

    assert_equal (-10), acc0.balance
  end

  def test_income_account
    acc0 = @ledger.create_account "AUD"
    @ledger.transfer acc0, (@ledger.income_account), 10

    assert_equal (-10), acc0.balance
  end

  def test_expense_account
    acc0 = @ledger.create_account "AUD"
    @ledger.transfer acc0, (@ledger.expense_account), 10

    assert_equal (-10), acc0.balance
  end

  private
  def get_target obj
    obj.instance_variable_get :@target
  end
end
