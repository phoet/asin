require 'hashie'

module ASIN

  # =Item
  #
  # The +Item+ class is a wrapper for the Amazon XML-REST-Response.
  #
  # A Hashie::Mash is used for the internal data representation and can be accessed over the +raw+ attribute.
  #
  class Cart

    attr_reader :raw

    def initialize(hash)
      @raw = Hashie::Mash.new(hash)
    end

    def cart_id
      @raw.CartId
    end

    def hmac
      @raw.HMAC
    end

    def url
      @raw.PurchaseURL
    end

    def price
      @raw.SubTotal.FormattedPrice
    end

    def items
      return [] unless @raw.CartItems
      @raw.CartItems.CartItem.is_a?(Array) ? @raw.CartItems.CartItem : [@raw.CartItems.CartItem]
    end

    def saved_items
      return [] unless @raw.SavedForLaterItems
      @raw.SavedForLaterItems.SavedForLaterItem.is_a?(Array) ? @raw.SavedForLaterItems.SavedForLaterItem : [@raw.SavedForLaterItems.SavedForLaterItem]
    end

    def valid?
      @raw.Request.IsValid == 'True'
    end

    def empty?
      @raw.CartItems.nil?
    end

  end
end