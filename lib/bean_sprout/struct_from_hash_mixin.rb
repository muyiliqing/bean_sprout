module BeanSprout
  module StructFromHashMixin
    def self.included klass
      klass.extend ClassMethods
    end

    module ClassMethods
      def self.from_hash hash
        new(*hash.values_at(*members))
      end
    end
  end
end

