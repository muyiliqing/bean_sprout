require 'forwardable'

module BeanSprout
  class SparseArray
    extend Forwardable

    def_delegators :@entities, :each, :has_key?, :each_value, :values

    def initialize index_offset = 0
      @entities = {}
      @index = index_offset
    end

    def store
      index = next_index
      @entities[index] = yield index
    end

    def fetch index
      @entities[index]
    end

    def fetch! index
      raise "Unkown index #{index}." unless @entities.has_key? index
      fetch index
    end

    private
    def next_index
      @index += 1
    end
  end
end
