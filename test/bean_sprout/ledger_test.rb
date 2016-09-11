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
    entry = @ledger.create_entry(account, 10, 2.0)

    data_entry = @ledger.create_entry account, 1, other_data: "some_data"
    assert_equal "some_data", data_entry.other_data
  end

  def test_create_entry_errors
    account = @ledger.create_account("AUD")

    (account.instance_variable_get :@target).instance_variable_set :@id, 9

    e = assert_raises do
      @ledger.create_entry account, 10
    end

    assert_match /^Unkown account .* refered\.$/, e.message

    usd_account = @ledger.create_account("USD")
    e = assert_raises do
      @ledger.create_entry(usd_account, 10)
    end

    assert_match /Rate must be specified if account is not in base currency.*/,
      e.message
  end

  def test_create_transaction
    account = @ledger.create_account("AUD")
    entry = @ledger.create_entry(account, 10)

    trans = @ledger.create_transaction [@entry]

    data_trans = @ledger.create_transaction [@entry], other_data: "somedata"
    assert_equal "somedata", data_trans.other_data

    sprout_bunches = @ledger.transactions.map do |trans| get_target trans end

    assert_equal 2, @ledger.transactions.size
    assert sprout_bunches.include? get_target trans
    assert sprout_bunches.include? get_target data_trans
  end

  private
  def get_target obj
    obj.instance_variable_get :@target
  end
end
