require 'bean_sprout/entry'
require 'minitest/autorun'
require 'bigdecimal'

class BeanSprout::Entry::Test < MiniTest::Test
  class FakeBean
    def to_account
      self
    end
  end

  def setup
    @bean = FakeBean.new
    @sprout = BeanSprout::Sprout.new(13, @bean, 17)
    @entry = BeanSprout::Entry.new(@sprout)
  end

  def test_sprout_bean
    assert_equal @bean, @sprout.bean
  end

  def test_sprout_amount
    assert_equal 17, @sprout.amount

    sprout = BeanSprout::Sprout.new(1, @bean, 1.9)
    assert_equal BigDecimal("1.9"), sprout.amount

    sprout = BeanSprout::Sprout.new(1, @bean, 1000000000000.9)
    assert_equal BigDecimal("1000000000000.9"), sprout.amount
  end

  def test_sprout_to_entry
    assert @entry.instance_of? BeanSprout::Entry
  end

  def test_entry_api
    assert @entry.respond_to? :amount
    assert @entry.respond_to? :other_data
    assert @entry.respond_to? :account

    refute @entry.respond_to? :bean
    refute @entry.respond_to? :to_entry
  end

  def test_entry_account
    assert_equal @bean, @entry.account
  end
end
