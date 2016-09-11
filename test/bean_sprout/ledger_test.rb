require 'bean_sprout/ledger'
require 'minitest/autorun'

class BeanSprout::Ledger::Test < MiniTest::Test

  def setup
    @ledger = BeanSprout::Ledger.new("AUD")
  end

  # TODO: split tests.
  def test_create_account
    account = @ledger.create_account("AUD")

    e = assert_raises do
      usd_account = @ledger.create_account("USD")
    end

    assert_match /Rate must be specified if account is not in base currency.*/,
      e.message

    usd_account = @ledger.create_account("USD", 1.2)

    data_account = @ledger.create_account("AUD", 1, "some data")
    assert_equal "some data", data_account.other_data

    beans = @ledger.accounts.map do |acc| get_target acc end

    assert beans.include? get_target account
    assert beans.include? get_target usd_account
    assert beans.include? get_target data_account
    assert_equal 3, @ledger.accounts.size
  end

  def test_create_entry
    account = @ledger.create_account("AUD")
    entry = @ledger.create_entry(account, 10)

    data_entry = @ledger.create_entry account, 1, "some_data"
    assert_equal "some_data", data_entry.other_data

    (account.instance_variable_get :@target).instance_variable_set :@id, 9

    e = assert_raises do
      @ledger.create_entry account, 10
    end

    assert_match /^Unkown account .* refered\.$/, e.message
  end

  def test_create_transaction
    account = @ledger.create_account("AUD")
    entry = @ledger.create_entry(account, 10)

    trans = @ledger.create_transaction [@entry]

    data_trans = @ledger.create_transaction [@entry], "somedata"
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
