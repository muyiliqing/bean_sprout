require 'forwardable'

module BeanSprout
  class ForwardableDelegate
    extend Forwardable

    def initialize obj
      @target = obj
    end

    class << self
      def def_default_delegators *args
        def_delegators :@target, *args
      end

      def def_private_default_delegators *args
        def_default_delegators *args
        private *args
      end

      private :def_default_delegators, :def_private_default_delegators
    end
  end
end
