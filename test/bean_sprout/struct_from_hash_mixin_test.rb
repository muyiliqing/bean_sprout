require 'bean_sprout/struct_from_hash_mixin'
require 'minitest/autorun'

class BeanSprout::StructFromHashMixin::Test < MiniTest::Test
  class TestClass < Struct.new(:a, :b, :c)
    include BeanSprout::StructFromHashMixin
  end

  def test_initializer_omit
    instance = TestClass.from_hash(a: 19)
    assert_equal ({a: 19, b: nil, c: nil}), instance.to_h
    instance = TestClass.from_hash(b: 9)
    assert_equal ({a: nil, b: 9, c: nil}), instance.to_h
    instance = TestClass.from_hash(c: 3)
    assert_equal ({a: nil, b: nil, c: 3}), instance.to_h
  end

  def test_initializer
    instance = TestClass.from_hash(a: 1, b: 2, c: "3")
    assert_equal ({a: 1, b: 2, c: "3"}), instance.to_h
  end

  def test_initializer_extra
    instance = TestClass.from_hash(a: 1, b: 2, c: "3", d: "D")
    assert_equal ({a: 1, b: 2, c: "3"}), instance.to_h
  end
end
