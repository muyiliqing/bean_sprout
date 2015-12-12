module BeanSprout
  module Utils
    def to_bigdecimal num
      # TODO: make 24 configurable.
      BigDecimal.new(num, 24).round(2)
    end
  end
end
