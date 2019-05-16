require 'bean_sprout/transaction'
require 'minitest/autorun'

class BeanSprout::Transaction::Test < MiniTest::Test
  class TestBean < Struct.new(:currency, :picked, :grown)
    def pick sprout
      picked.push sprout
    end

    def grow sprout
      grown.push sprout
    end
  end

  class TestSprout < Struct.new(:amount, :bean)
  end

  def setup
    @bean = TestBean.new(:AUD, [], [])
    @sprout0 = TestSprout.new(9, @bean)
    @sprout1 = TestSprout.new(-8, @bean)
    @sprout2 = TestSprout.new(-1, @bean)
    @sprouts = [@sprout0, @sprout1, @sprout2]

    @empty_bunch = BeanSprout::SproutBunch.new(1, [])
    @sprout_bunch = BeanSprout::SproutBunch.new(1, @sprouts)
    @unbalanced_bunch = BeanSprout::SproutBunch.new(2, [@sprout0, @sprout1])

    @unbalanced_trans = BeanSprout::Transaction.new(@unbalanced_bunch)
    @empty_trans = BeanSprout::Transaction.new(@empty_bunch)
    @transaction = BeanSprout::Transaction.new(@sprout_bunch)
  end

  def test_sprout_bunch_balanced
    assert @empty_bunch.balanced?
    assert @sprout_bunch.balanced?
    refute @unbalanced_bunch.balanced?

    # Should not throw.
    @empty_bunch.balanced!
    @sprout_bunch.balanced!

    # Should throw.
    e = assert_raises BeanSprout::SproutBunch::NotBalancedError do
      @unbalanced_bunch.balanced!
    end
    assert_match (/^\[.*\] not balanced\.$/), e.message
  end

  def test_sprout_bunch_multicurrency_balanced
    usd_bean = TestBean.new(:USD, [], [])
    usd_trans0 = TestSprout.new(198, usd_bean)
    usd_trans1 = TestSprout.new(-198, usd_bean)

    all_sprotus = @sprouts + [usd_trans0, usd_trans1]
    multicurrency_trans = BeanSprout::SproutBunch.new(3, all_sprotus)

    assert multicurrency_trans.balanced?
    multicurrency_trans.balanced!
  end

  def test_sprout_bunch_plant
    @sprout_bunch.plant
    assert_empty @bean.picked
    assert_equal @sprouts, @bean.grown
  end

  def test_sprout_bunch_plant_error
    assert_raises BeanSprout::SproutBunch::NotBalancedError do
      @unbalanced_bunch.plant
    end

    @empty_bunch.plant
    assert_raises BeanSprout::SproutBunch::IllegalStateError do
      @empty_bunch.plant
    end
  end

  def test_sprout_bunch_remove_error
    assert_raises BeanSprout::SproutBunch::NotBalancedError do
      @unbalanced_bunch.remove
    end

    assert_raises BeanSprout::SproutBunch::IllegalStateError do
      @empty_bunch.remove
    end
  end

  def test_sprout_bunch_remove
    @sprout_bunch.plant
    @sprout_bunch.remove
    assert_equal @sprouts, @bean.picked
    assert_equal @sprouts, @bean.grown
  end

  def test_sprout_bunch_to_transaction
    assert @transaction.instance_of? BeanSprout::Transaction
  end

  def test_transaction_api
    assert @transaction.respond_to? :balanced?
    assert @transaction.respond_to? :commit
    assert @transaction.respond_to? :revert
    assert @transaction.respond_to? :entries
    assert @transaction.respond_to? :local?
    assert @transaction.respond_to? :other_data

    refute @transaction.respond_to? :balanced!
    refute @transaction.respond_to? :plant
    refute @transaction.respond_to? :remove
    refute @transaction.respond_to? :sprout
  end

  def test_entries
    assert_empty @empty_trans.entries

    @empty_trans.entries.push "1"
    assert_empty @empty_trans.entries
  end

  def test_commit
    e = assert_raises RuntimeError do
      @unbalanced_trans.commit
    end
    assert_match (/^Cannot commit an imbalance transaction\.$/), e.message

    @empty_trans.commit
    e = assert_raises RuntimeError do
      @empty_trans.commit
    end
    assert_match (/^Cannot commit a transaction more than once\.$/), e.message

    @transaction.commit
  end

  def test_revert
    e = assert_raises RuntimeError do
      @unbalanced_trans.revert
    end
    assert_match (/^Cannot revert an imbalance transaction\.$/), e.message

    e = assert_raises RuntimeError do
      @empty_trans.revert
    end
    assert_match (/^Cannot revert a transaction more than once\.$/), e.message

    @sprout_bunch.instance_variable_set(:@in_place, true)
    @transaction.revert
  end

  def test_local
    assert @transaction.local?

    bean = TestBean.new(:USD, [], [])
    sprout = TestSprout.new(9, bean)
    sprout_bunch = BeanSprout::SproutBunch.new(1, [sprout, @sprout0])
    transaction = BeanSprout::Transaction.new(sprout_bunch)
    refute transaction.local?
  end
end
