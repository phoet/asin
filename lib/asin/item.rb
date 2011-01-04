require 'hashie'

module ASIN

  # =Item
  # 
  # The +Item+ class is a wrapper for the Amazon XML-REST-Response.
  # 
  # A Hashie::Mash is used for the internal data representation and can be accessed over the +raw+ attribute.
  # 
  class Item

    attr_reader :raw

    def initialize(hash)
      @raw = Hashie::Mash.new(hash)
    end

    def title
      @raw.ItemAttributes.Title
    end
  end
  
end