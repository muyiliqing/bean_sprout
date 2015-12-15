require 'bean_sprout/account'
require 'minitest/autorun'

class BeanSprout::Account::Test < MiniTest::Test
  def setup
    entry_class = Struct.new(:accurate_amount)
    @account = BeanSprout::Account.new
    @entry = entry_class.new(13)
  end

  def test_append_entry
    @account.append_entry @entry
    assert_equal [@entry], @account.entries

    @account.append_entry @entry
    assert_equal [@entry, @entry], @account.entries
  end

  def test_entries
    assert_empty @account.entries

    @account.append_entry @entry
    assert_equal [@entry], @account.entries

    @account.entries.push @entry
    assert_equal [@entry], @account.entries
  end

  def test_balance
    assert_equal 0, @account.balance

    @account.append_entry @entry
    assert_equal 13, @account.balance

    entry2 = @entry.clone
    entry2.accurate_amount = -9
    @account.append_entry entry2
    assert_equal 4, @account.balance
  end
end

