require 'hashie'
require 'active_support/core_ext/hash/keys'
require 'active_support/inflector'

module ASIN
  class Response < Hashie::Mash
    disable_warnings

    def self.create(data)
      data.deep_transform_keys! { |key| key.underscore }
      new(data)
    end
  end
end
