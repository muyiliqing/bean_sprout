require 'bean_sprout/account'
require 'minitest/autorun'

class BeanSprout::Account::Test < MiniTest::Test
  def setup
    sprout_class = Struct.new(:amount) do
      def to_entry
        self
      end

      def __getobj__
        self
      end
    end

    @bean = BeanSprout::Bean.new(0, "CNY")
    @sprout = sprout_class.new(13)
    @sprout2 = sprout_class.new(-9)

    @account = BeanSprout::Account.new(@bean)
  end

  def test_bean_grow
    @bean.grow @sprout
    assert_equal [@sprout], @bean.sprouts.to_a

    @bean.grow @sprout2
    assert_equal [@sprout, @sprout2], @bean.sprouts.to_a
  end

  def test_bean_pick
    @bean.grow @sprout
    assert_equal [@sprout], @bean.sprouts.to_a

    @bean.pick @sprout
    assert_empty @bean.sprouts
  end

  def test_bean_sprouts
    assert_empty @bean.sprouts.to_a

    @bean.grow @sprout
    assert_equal [@sprout], @bean.sprouts.to_a

    @bean.sprouts.add @sprout2
    assert_equal [@sprout, @sprout2], @bean.sprouts.to_a
  end

  def test_bean_balance
    assert_equal 0, @bean.balance

    @bean.grow @sprout
    assert_equal 13, @bean.balance

    @bean.grow @sprout2
    assert_equal 4, @bean.balance
  end

  def test_bean_currency
    assert_equal "CNY", @bean.currency
  end

  def test_to_account
    assert @account.instance_of? BeanSprout::Account
  end

  def test_account_api
    # assert @account.respond_to? :id
    assert @account.respond_to? :entries
    assert @account.respond_to? :balance
    assert @account.respond_to? :currency
    assert @account.respond_to? :other_data

    refute @account.respond_to? :to_account
    refute @account.respond_to? :pick
    refute @account.respond_to? :grow
    refute @account.respond_to? :sprouts
  end

  def test_entries
    assert_empty @account.entries

    @bean.grow @sprout
    assert_equal [@sprout], (@account.entries.map do |x| x.__getobj__ end)

    @account.entries.push @sprout
    assert_equal [@sprout], (@account.entries.map do |x| x.__getobj__ end)
  end
end
