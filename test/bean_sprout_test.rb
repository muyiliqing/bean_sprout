require 'bean_sprout'
require 'minitest/autorun'

class BeanSprout::Test < MiniTest::Test
  def test_import
    assert BeanSprout.const_defined? :Account
    assert BeanSprout.const_defined? :Entry
    assert BeanSprout.const_defined? :Transaction
    assert BeanSprout.const_defined? :GlassJar
    assert BeanSprout.const_defined? :VERSION
  end
end
