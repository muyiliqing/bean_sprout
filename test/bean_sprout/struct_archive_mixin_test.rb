require 'bean_sprout/struct_archive_mixin'
require 'minitest/autorun'

class BeanSprout::StructArchiveMixin::Test < MiniTest::Test
  class TestClass
    include BeanSprout::StructArchiveMixin
  end

  def test_id_and_glass_jar
    instance = TestClass.new
    assert_equal nil, instance.id
    assert_equal nil, instance.glass_jar

    assert_raises NoMethodError do
      instance.id = 9
    end

    assert_raises NoMethodError do
      instance.glass_jar = 9
    end

    instance.archive_in_glass_jar "a", "b"
    assert_equal "a", instance.glass_jar
    assert_equal "b", instance.id
    assert instance.frozen?
  end
end

