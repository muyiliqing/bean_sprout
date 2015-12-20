require 'bean_sprout/entry'
require 'minitest/autorun'
require 'bigdecimal'

class BeanSprout::Entry::Test < MiniTest::Test

  def test_rate_or_one
    entry = BeanSprout::Entry.new(nil, nil)
    assert_equal 1, entry.rate_or_one

    entry.rate = "0.1"
    assert_equal "0.1", entry.rate

    entry.rate = nil
    assert_equal 1, entry.rate_or_one
  end

  def test_accurate_amount
    entry = BeanSprout::Entry.new(nil, 1.9)
    assert_equal BigDecimal.new("1.9"), entry.accurate_amount

    entry = BeanSprout::Entry.new(nil, 1000000000000.9)
    assert_equal BigDecimal.new("1000000000000.9"), entry.accurate_amount
  end
end
