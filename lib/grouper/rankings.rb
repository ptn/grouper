require 'delegate'

module Grouper
  class Rankings < DelegateClass(Hash)
    def initialize(hsh=nil)
      super(hsh)
    end

    def commons(other)
      commons_hash = {}

      common_keys = self.keys & other.keys
      common_keys.each do |k|
        commons_hash[k] = [self[k], other[k]]
      end

      commons_hash
    end
  end
end
