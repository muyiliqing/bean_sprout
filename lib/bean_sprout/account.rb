require 'bean_sprout/struct_from_hash_mixin'
require 'bean_sprout/struct_archive_mixin'

module BeanSprout
  # TODO: support setting base currency.
  class Account < Struct.new(:currency, :balance, :other_data)
    include StructFromHashMixin
    include StructArchiveMixin
  end
end
