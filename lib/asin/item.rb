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

    def asin
      @raw.ASIN
    end

    def title
      @raw.ItemAttributes.Title
    end

    def cents
      price_container = @raw.ItemAttributes.ListPrice || 
                        @raw.OfferSummary.LowestUsedPrice
      if amount = price_container.Amount
        amount.to_i
      end
    end

    def url
      @raw.DetailPageURL
    end

    def description
      (@raw.EditorialReviews.EditorialReview.Content rescue nil) ||
      (@raw.ItemAttributes.Feature.join('.') rescue nil)
    end
  end

end
