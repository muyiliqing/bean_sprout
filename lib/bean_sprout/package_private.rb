require 'bean_sprout/forwardable_delegate'

module BeanSprout
  # Implements the concept of package private methods.
  module PackagePrivate
    # A module to be included by the delegatee.
    module InternalClass
      # The public interface, set by PublicInterfaceBase.
      attr_reader :public_interface

      def self.included klass
        klass.extend ClassMethods
      end

      def bind_public_interface public_interface
        raise "Cannot bind public interface to null." if public_interface.nil?
        raise "Cannot bind public interface twice." if defined? @public_interface
        @public_interface = public_interface
      end

      module ClassMethods
        def define_public_interface klass_name
          define_method "to_#{(klass_name.to_s.split "::").last.downcase}" do
            @public_interface
          end
        end
      end
    end

    # A base class for delegator classes.
    class PublicInterfaceBase < ForwardableDelegate
      def initialize obj, other_data = nil
        super(obj)
        obj.bind_public_interface self
        @other_data = other_data
      end

      attr_accessor :other_data
    end
  end
end
