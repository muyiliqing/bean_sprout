require 'bean_sprout/forwardable_delegate'
require 'minitest/autorun'

class BeanSprout::ForwardableDelegate::Test < MiniTest::Test
  class TestSubject < BeanSprout::ForwardableDelegate
  end

  def test_def_default_delegators
    TestSubject.class_eval do
      def_default_delegators :size, :index
    end

    a = TestSubject.new([])
    assert a.respond_to? :index
    assert a.respond_to? :size
    assert_equal a.size, 0

    b = TestSubject.new([1, 2, 3])
    assert_equal 3, b.size
    assert_equal 0, b.index(1)
  end

  def test_def_private_default_delegators
    TestSubject.class_eval do
      def_private_default_delegators :push
      def mypush *arg
        push(*arg)
      end
    end

    arr = []
    a = TestSubject.new(arr)

    refute a.respond_to? :push
    a.mypush "x"
    assert_equal arr[0], "x"
  end
end
