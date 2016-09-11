require 'bean_sprout/sparse_array'
require 'minitest/autorun'

class BeanSprout::SparseArray::Test < MiniTest::Test
  def setup
    @sparse_array = BeanSprout::SparseArray.new
    @offset_sparse_array = BeanSprout::SparseArray.new 100
  end

  def test_store_fetch
    index_is = nil
    @sparse_array.store do |index|
      index_is = index
      "abc" + index.to_s
    end

    assert_equal "abc" + index_is.to_s, @sparse_array.fetch(index_is)
  end

  def test_delegators
    @sparse_array.instance_variable_set :@entities, {1 => "x1", 2 => 2}
    assert_equal ["x1", 2], @sparse_array.each_value.to_a
    assert_equal ["x1", 2], @sparse_array.values
    assert_equal [[1, "x1"], [2, 2]], @sparse_array.each.to_a
    assert @sparse_array.has_key? 1
    assert @sparse_array.has_key? 2
    refute @sparse_array.has_key? 3
  end
end
