require 'bean_sprout/package_private'
require 'minitest/autorun'

class BeanSprout::PackagePrivate::Test < MiniTest::Test
  class TestInternalClass
    include BeanSprout::PackagePrivate::InternalClass
  end

  class TestInterface < BeanSprout::PackagePrivate::PublicInterfaceBase
  end

  def test_internal_class_methods
    assert (TestInternalClass.class_eval do
      respond_to? :define_public_interface
    end)

    a = TestInternalClass.new
    assert a.respond_to? :bind_public_interface
    assert a.respond_to? :public_interface
  end

  def test_internal_class_define_public_interface
    TestInternalClass.class_eval do
      define_public_interface :Xyz
    end

    a = TestInternalClass.new
    assert a.respond_to? :to_xyz
  end

  def test_internal_class_public_interface
    a = TestInternalClass.new
    assert_nil a.public_interface
    a.bind_public_interface "xyz"
    assert_equal "xyz", a.public_interface

    b = TestInternalClass.new
    assert_raises do
      b.bind_public_interface nil
    end

    assert_raises do
      a.bind_public_interface "123"
    end
  end

  def test_public_interface_bind
    a = TestInternalClass.new
    b = TestInterface.new a

    assert_equal b, a.public_interface
  end

  def test_public_interface_other_data
    a = TestInterface.new TestInternalClass.new, "456"
    assert_equal "456", a.other_data
  end
end
