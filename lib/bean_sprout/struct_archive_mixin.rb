module BeanSprout
  module StructArchiveMixin
    def self.included klass
      klass.class_eval do
        attr_reader :id
        attr_reader :glass_jar
      end
    end

    def archive_in_glass_jar glass_jar, id
      @glass_jar = glass_jar
      @id = id
      values.each do |val| val.freeze end
      freeze
    end
  end
end
