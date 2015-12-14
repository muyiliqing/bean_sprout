require 'bean_sprout/transaction'
require 'minitest/autorun'

class BeanSprout::Transaction::Test < MiniTest::Test
  class TestEntry < Struct.new(:accurate_amount, :rate_or_one)
  end

  def test_entries
    trans = BeanSprout::Transaction.new([])

    trans.entries.push "1"
    assert_equal [], trans.entries
  end

  def test_entries_data
    trans = BeanSprout::Transaction.new([])
    assert_raises NoMethodError do
      trans.entries_data
    end
  end

  def test_balanced_empty
    trans = BeanSprout::Transaction.new([])

    assert trans.balanced?
    trans.balanced!
  end

  def test_balanced
    trans = BeanSprout::Transaction.new(
      [ TestEntry.new(13, 1), TestEntry.new(-13, 1), ]
    )

    assert trans.balanced?
    trans.balanced!

    trans = BeanSprout::Transaction.new(
      [
        TestEntry.new(13, 1),
        TestEntry.new(-20, 1),
        TestEntry.new(14, 2),
      ]
    )

    assert trans.balanced?
    trans.balanced!
  end

  def test_balanced_raise
    trans = BeanSprout::Transaction.new(
      [
        TestEntry.new(13, 1),
        TestEntry.new(-20, 1),
      ]
    )
    refute trans.balanced?
    e = assert_raises RuntimeError do
      trans.balanced!
    end
    assert_match (/^\[.*\] is not balanced\.$/), e.message

    trans = BeanSprout::Transaction.new(
      [
        TestEntry.new(13, 1),
        TestEntry.new(-20, 2),
      ]
    )
    refute trans.balanced?
    e = assert_raises RuntimeError do
      trans.balanced!
    end
    assert_match (/^\[.*\] is not balanced\.$/), e.message
  end
end

