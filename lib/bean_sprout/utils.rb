module BeanSprout
  module Utils
    def self.to_bigdecimal num
      # TODO: make 16 configurable.
      # 16 is the magical maximum.
      BigDecimal.new(num, 16).round(2)
    end
  end
end
