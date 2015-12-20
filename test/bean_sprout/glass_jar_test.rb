require 'bean_sprout/glass_jar'
require 'bean_sprout/account'
require 'minitest/autorun'

class BeanSprout::GlassJar::Test < MiniTest::Test

  def setup
    @glass_jar = BeanSprout::GlassJar.new("AUD")
    @account = BeanSprout::Account.new "AUD"
    @usd_account = BeanSprout::Account.new "USD"
    @entry = BeanSprout::Entry.new 1, 16
    @usd_entry = BeanSprout::Entry.new 2, -8, 0.5

    @glass_jar.open_account @account
    @glass_jar.open_account @usd_account
  end

  def test_account_id
    assert_equal @account.id, 1
    assert_equal @usd_account.id, 2
    for i in 3..100 do
      account = @account.dup
      account = @glass_jar.open_account(account)
      assert_equal i, account.id
    end
  end

  def test_transaction_id
    for i in 1..100 do
      trans = @glass_jar.create_transaction @entry.dup, @usd_entry.dup
      assert_equal i, trans.id, "#{trans}"
    end
  end

  def test_account_external_id
    account_external = @glass_jar.open_account BeanSprout::Account.new "A", 3
    assert_equal @glass_jar.account_for(3), account_external
  end

  # TODO: make this better using stubbing.
  def test_accessors
    assert_equal @account, @glass_jar.account(1)
    assert_equal @usd_account, @glass_jar.account(2)

    trans = @glass_jar.create_transaction @entry, @usd_entry
    assert_equal trans, @glass_jar.transaction(1)

    assert_equal @entry, @glass_jar.entry((1<<30) + 0)
    assert_equal @usd_entry, @glass_jar.entry((1<<30) + 1)
  end

  def test_create_account
    assert @account.id
    assert @usd_account.id

    assert @glass_jar.accounts.include? @account
    assert @glass_jar.accounts.include? @usd_account
    assert_equal 2, @glass_jar.accounts.size
  end

  def test_create_transaction
    trans = @glass_jar.create_transaction @entry, @usd_entry

    assert @entry.id
    assert @usd_entry.id
    assert trans.id

    assert_equal 1, @glass_jar.transactions.size
    assert @glass_jar.transactions.include? trans
    assert @glass_jar.entries.include? @entry

    assert_equal 1, @glass_jar.transactions.size
    assert @glass_jar.entries.include? @usd_entry

    assert @glass_jar.account(1).entries.include? @entry
    assert @glass_jar.account(2).entries.include? @usd_entry

    assert_equal 16, @glass_jar.account(1).balance
    assert_equal -8, @glass_jar.account(2).balance
  end

  def test_create_transaction_errors
    e = assert_raises do
      @glass_jar.create_transaction
    end
    assert_match /^Creating transaction with no entries\.$/, e.message

    invalid_account_entry = BeanSprout::Entry.new 3, 0
    e = assert_raises do
      @glass_jar.create_transaction invalid_account_entry
    end
    assert_match /^Unkown account 3 refered\.$/, e.message

    invalid_rate_entry = BeanSprout::Entry.new 2, 16
    e = assert_raises do
      @glass_jar.create_transaction invalid_rate_entry
    end
    assert_match /Rate must be specified if entry is not in base currency.*/,
      e.message

    @usd_entry.amount = -7
    e = assert_raises do
      @glass_jar.create_transaction @entry, @usd_entry
    end
    assert_match /^.* is not balanced\.$/, e.message
  end

  def test_valid_account
    @glass_jar.send :"valid_account!", 1

    e = assert_raises do
      @glass_jar.send :"valid_account!", 3
    end
    assert_match /^Unkown account 3 refered\.$/, e.message
  end

  def test_valid_entry
    @glass_jar.send :"valid_rate!", @entry
    @glass_jar.send :"valid_rate!", @usd_entry

    valid_entry = BeanSprout::Entry.new 1, 18, 1
    @glass_jar.send :"valid_rate!", valid_entry

    invalid_entry = BeanSprout::Entry.new 2, 16
    e = assert_raises do
      @glass_jar.send :"valid_rate!", invalid_entry
    end
    assert_match /Rate must be specified if entry is not in base currency.*/,
      e.message
  end
end
