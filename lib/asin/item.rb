require 'hashie'

module ASIN

  # =SimpleItem
  #
  # The +SimpleItem+ class is a wrapper for the Amazon XML-REST-Response.
  #
  # A Hashie::Mash is used for the internal data representation and can be accessed over the +raw+ attribute.
  #
  class SimpleItem

    attr_reader :raw

    def initialize(hash)
      @raw = Hashie::Mash.new(hash)
    end

    def asin
      @raw.ASIN
    end

    def title
      @raw.ItemAttributes!.Title
    end

    def amount
      @raw.ItemAttributes!.ListPrice!.Amount.to_i
    end

    def details_url
      @raw.DetailPageURL
    end

    def review
       @raw.EditorialReviews!.EditorialReview!.Content
    end

    def image_url
      @raw.LargeImage!.URL
    end
  end

end
