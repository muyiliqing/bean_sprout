require 'bean_sprout/entry'
require 'minitest/autorun'
require 'bigdecimal'

class BeanSprout::Entry::Test < MiniTest::Test
  class FakeBean
    attr_accessor :rate
    def to_account
      self
    end
  end

  def setup
    @bean = FakeBean.new
    @bean.rate = 2.0
    @sprout = BeanSprout::Sprout.new(13, @bean, 17)
    @entry = @sprout.to_entry
  end

  def test_sprout_bean
    assert_equal @bean, @sprout.bean
  end

  def test_sprout_amount
    assert_equal 17, @sprout.amount

    sprout = BeanSprout::Sprout.new(1, @bean, 1.9)
    assert_equal BigDecimal.new("1.9"), sprout.amount

    sprout = BeanSprout::Sprout.new(1, @bean, 1000000000000.9)
    assert_equal BigDecimal.new("1000000000000.9"), sprout.amount
  end

  def test_sprout_unified_amount
    assert_equal 34, @sprout.unified_amount
  end

  def test_sprout_other_data
    sprout = BeanSprout::Sprout.new(17, @bean, 1, "other data")
    assert_equal "other data", sprout.other_data
  end

  def test_sprout_to_entry
    assert @entry.instance_of? BeanSprout::Entry
  end

  def test_entry_api
    assert @entry.respond_to? :amount
    assert @entry.respond_to? :unified_amount
    assert @entry.respond_to? :other_data
    assert @entry.respond_to? :account

    refute @entry.respond_to? :bean
    refute @entry.respond_to? :to_entry
  end

  def test_entry_account
    assert_equal @bean, @entry.account
  end
end
